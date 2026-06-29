<?php
/**
 * Admin route handlers (user management, analytics).
 */

function adminListUsers($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $page = max(1, intval($_GET['page'] ?? 1));
    $limit = max(1, min(100, intval($_GET['limit'] ?? 10)));
    $offset = ($page - 1) * $limit;
    $search = SecurityUtils::sanitizeString($_GET['search'] ?? '');
    $hasAccess = $_GET['hasAccess'] ?? null;
    $language = SecurityUtils::sanitizeString($_GET['language'] ?? '');
    $role = SecurityUtils::sanitizeString($_GET['role'] ?? '');
    $sortDir = (strtoupper($_GET['sortDir'] ?? 'DESC') === 'ASC') ? 'ASC' : 'DESC';
    $dateFrom = SecurityUtils::sanitizeString($_GET['dateFrom'] ?? '');
    $dateTo = SecurityUtils::sanitizeString($_GET['dateTo'] ?? '');
    $todayOnly = ($_GET['today'] ?? '') === '1';

    $conditions = [];
    $bindTypes = '';
    $bindValues = [];

    if (!empty($search)) {
        $conditions[] = '(u.fullName LIKE ? OR u.phoneNumber LIKE ?)';
        $like = '%' . $search . '%';
        $bindTypes .= 'ss';
        $bindValues[] = $like;
        $bindValues[] = $like;
    }

    if ($hasAccess === 'true' || $hasAccess === '1') {
        $conditions[] = 'ac.expiresAt > NOW()';
    } elseif ($hasAccess === 'false' || $hasAccess === '0') {
        $conditions[] = '(ac.expiresAt IS NULL OR ac.expiresAt <= NOW())';
    }

    if (!empty($language)) {
        $conditions[] = 'u.preferredLanguage = ?';
        $bindTypes .= 's';
        $bindValues[] = $language;
    }

    if (!empty($role)) {
        $conditions[] = 'u.role = ?';
        $bindTypes .= 's';
        $bindValues[] = strtoupper($role);
    }

    if ($todayOnly) {
        $conditions[] = 'DATE(u.createdAt) = CURDATE()';
    } elseif (!empty($dateFrom) && !empty($dateTo)) {
        $conditions[] = 'u.createdAt BETWEEN ? AND ?';
        $bindTypes .= 'ss';
        $bindValues[] = $dateFrom . ' 00:00:00';
        $bindValues[] = $dateTo . ' 23:59:59';
    } elseif (!empty($dateFrom)) {
        $conditions[] = 'u.createdAt >= ?';
        $bindTypes .= 's';
        $bindValues[] = $dateFrom . ' 00:00:00';
    }

    $where = empty($conditions) ? '' : 'WHERE ' . implode(' AND ', $conditions);

    $joinSql = 'LEFT JOIN (
        SELECT ac.* FROM access_codes ac
        WHERE ac.id = (
            SELECT id FROM access_codes ac2
            WHERE ac2.userId = ac.userId
            ORDER BY ac2.createdAt DESC, ac2.id DESC
            LIMIT 1
        )
    ) ac ON u.id = ac.userId';

    $countSql = "SELECT COUNT(*) as total FROM users u $joinSql $where";
    if (!empty($bindValues)) {
        $countRefs = [];
        foreach ($bindValues as $k => &$v) {
            $countRefs[] = &$v;
        }
        unset($v);
        $countRow = Database::fetchOne($conn, $countSql, $bindTypes, $countRefs);
    } else {
        $countRow = Database::fetchOne($conn, $countSql);
    }
    $total = $countRow ? intval($countRow['total']) : 0;

    $pageSql = "SELECT u.id, u.fullName, u.phoneNumber, u.role, u.isActive,
                       u.preferredLanguage, u.lastCalledAt, u.lastCalledBy, u.callNotes, u.createdAt,
                       ac.code as accessCode, ac.expiresAt as accessExpiresAt,
                       ac.paymentTier, ac.paymentAmount,
                       CASE WHEN ac.expiresAt > NOW() THEN 1 ELSE 0 END as hasActiveAccess
                FROM users u
                $joinSql
                $where
                ORDER BY u.createdAt $sortDir
                LIMIT ? OFFSET ?";

    $pageTypes = $bindTypes . 'ii';
    $pageValues = $bindValues;
    $pageValues[] = $limit;
    $pageValues[] = $offset;

    $pageRefs = [];
    foreach ($pageValues as $k => &$v) {
        $pageRefs[] = &$v;
    }
    unset($v);

    $rows = Database::fetchAll($conn, $pageSql, $pageTypes, $pageRefs);

    respond([
        'users' => $rows ?: [],
        'total' => $total,
        'page'  => $page,
        'limit' => $limit,
    ], 200);
}

function adminBlockUser($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $userId = SecurityUtils::sanitizeString($params['userId'] ?? '');
    if (!$userId) {
        ErrorHandler::badRequest('Invalid user ID');
    }

    $user = Database::fetchOne($conn, 'SELECT id, isActive FROM users WHERE id = ? LIMIT 1', 's', [&$userId]);
    if (!$user) {
        ErrorHandler::notFound('User not found');
    }

    $input = getInput();
    $isActive = isset($input['isActive']) ? (intval($input['isActive']) ? 1 : 0) : 0;
    $now = date('Y-m-d H:i:s');

    Database::query($conn, 'UPDATE users SET isActive = ?, updatedAt = ? WHERE id = ?', 'iss', [&$isActive, &$now, &$userId]);

    $status = $isActive ? 'unblocked' : 'blocked';
    Logger::info("User $status", ['userId' => $userId, 'adminId' => $tokenData['userId']]);
    respond(['id' => $userId, 'isActive' => $isActive], 200, "User $status successfully");
}

function adminDeleteUser($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $userId = SecurityUtils::sanitizeString($params['userId'] ?? '');
    if (!$userId) {
        ErrorHandler::badRequest('Invalid user ID');
    }

    $user = Database::fetchOne($conn, 'SELECT id, isActive FROM users WHERE id = ? LIMIT 1', 's', [&$userId]);
    if (!$user) {
        ErrorHandler::notFound('User not found');
    }

    if (intval($user['isActive']) !== 0) {
        http_response_code(422);
        respond(['error' => 'User must be blocked before deletion. Block the user first.', 'code' => 'BLOCK_FIRST'], 422);
        exit;
    }

    Database::query($conn, 'DELETE FROM access_codes WHERE userId = ?', 's', [&$userId]);
    Database::query($conn, 'DELETE FROM exam_results WHERE userId = ?', 's', [&$userId]);
    $affected = Database::query($conn, 'DELETE FROM users WHERE id = ?', 's', [&$userId]);

    if ($affected === false) {
        ErrorHandler::serverError('Failed to delete user');
    }
    if ($affected === 0) {
        ErrorHandler::notFound('User not found');
    }

    Logger::info('User deleted by admin', ['userId' => $userId, 'adminId' => $tokenData['userId']]);
    respond([], 200, 'User deleted successfully');
}

function adminGrantAccess($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $userId = SecurityUtils::sanitizeString($params['userId'] ?? '');
    if (!$userId) {
        ErrorHandler::badRequest('Invalid user ID');
    }

    $user = Database::fetchOne($conn, 'SELECT id FROM users WHERE id = ? LIMIT 1', 's', [&$userId]);
    if (!$user) {
        ErrorHandler::notFound('User not found');
    }

    $input = getInput();

    $paymentTier = SecurityUtils::sanitizeString($input['paymentTier'] ?? '');
    $paymentAmount = isset($input['paymentAmount']) ? intval($input['paymentAmount']) : 0;
    $customDays = isset($input['durationDays']) ? intval($input['durationDays']) : 0;

    $tierMap = ['1_MONTH' => 30, '3_MONTHS' => 90, '6_MONTHS' => 180];

    if ($customDays > 0) {
        $durationDays = $customDays;
        if (empty($paymentTier)) {
            $paymentTier = $customDays <= 30 ? '1_MONTH' : ($customDays <= 90 ? '3_MONTHS' : '6_MONTHS');
        }
    } elseif (isset($tierMap[$paymentTier])) {
        $durationDays = $tierMap[$paymentTier];
    } else {
        ErrorHandler::badRequest('Provide paymentTier (1_MONTH|3_MONTHS|6_MONTHS) or durationDays');
    }

    if ($paymentAmount <= 0) {
        ErrorHandler::badRequest('paymentAmount must be greater than 0');
    }

    $id = generateUUID();
    $code = strtoupper(bin2hex(random_bytes(6)));
    $managerId = $tokenData['userId'];
    $expiresAt = date('Y-m-d H:i:s', strtotime("+{$durationDays} days"));
    $now = date('Y-m-d H:i:s');

    $result = Database::insert(
        $conn,
        'INSERT INTO access_codes (id, userId, code, generatedByManagerId, paymentAmount, durationDays, paymentTier, expiresAt, isUsed, createdAt, updatedAt) VALUES (?,?,?,?,?,?,?,?,0,?,?)',
        'ssssiissss',
        [&$id, &$userId, &$code, &$managerId, &$paymentAmount, &$durationDays, &$paymentTier, &$expiresAt, &$now, &$now]
    );

    if (!$result) {
        Logger::error('Failed to grant access', ['userId' => $userId]);
        ErrorHandler::serverError('Failed to grant access');
    }

    Logger::info('Access granted', ['userId' => $userId, 'adminId' => $managerId, 'tier' => $paymentTier]);
    respond([
        'id'            => $id,
        'code'          => $code,
        'userId'        => $userId,
        'paymentTier'   => $paymentTier,
        'paymentAmount' => $paymentAmount,
        'durationDays'  => $durationDays,
        'expiresAt'     => $expiresAt,
        'message'       => 'Access granted successfully',
    ], 201);
}

function adminMarkCalled($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $userId = SecurityUtils::sanitizeString($params['userId'] ?? '');
    if (!$userId) {
        ErrorHandler::badRequest('Invalid user ID');
    }

    $user = Database::fetchOne($conn, 'SELECT id FROM users WHERE id = ? LIMIT 1', 's', [&$userId]);
    if (!$user) {
        ErrorHandler::notFound('User not found');
    }

    $input = getInput();
    $notes = SecurityUtils::sanitizeString($input['notes'] ?? '');
    $adminId = $tokenData['userId'];
    $calledAt = date('Y-m-d H:i:s');

    $stmt = Database::execute(
        $conn,
        'UPDATE users SET lastCalledAt = ?, lastCalledBy = ?, callNotes = ?, updatedAt = ? WHERE id = ?',
        'sssss',
        [&$calledAt, &$adminId, &$notes, &$calledAt, &$userId]
    );

    if (!$stmt) {
        Logger::error('Failed to mark called', ['userId' => $userId]);
        ErrorHandler::serverError('Failed to log call');
    }

    Logger::info('Call logged', ['userId' => $userId, 'adminId' => $adminId]);
    respond([
        'userId'       => $userId,
        'lastCalledAt' => $calledAt,
        'lastCalledBy' => $adminId,
        'callNotes'    => $notes,
        'message'      => 'Call logged successfully',
    ], 200);
}

function adminAnalytics($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $dateFrom = SecurityUtils::sanitizeString($_GET['dateFrom'] ?? '');
    $dateTo = SecurityUtils::sanitizeString($_GET['dateTo'] ?? '');

    // 1. Overall Quick Stats
    $totalUsersRow = Database::fetchOne($conn, 'SELECT COUNT(*) as total FROM users');
    $totalUsers = $totalUsersRow ? intval($totalUsersRow['total']) : 0;

    $totalPracticesRow = Database::fetchOne($conn, 'SELECT COUNT(*) as total FROM exam_results');
    $totalPractices = $totalPracticesRow ? intval($totalPracticesRow['total']) : 0;

    $activeSubsRow = Database::fetchOne($conn, 'SELECT COUNT(DISTINCT userId) as total FROM access_codes WHERE expiresAt > NOW()');
    $activeSubscriptions = $activeSubsRow ? intval($activeSubsRow['total']) : 0;

    $usersByLangRaw = Database::fetchAll($conn, 'SELECT preferredLanguage, COUNT(*) as count FROM users GROUP BY preferredLanguage', '', []);
    $usersByLanguage = ['rw' => 0, 'en' => 0, 'fr' => 0];
    if ($usersByLangRaw) {
        foreach ($usersByLangRaw as $row) {
            $lang = strtolower($row['preferredLanguage'] ?? 'en');
            if (isset($usersByLanguage[$lang])) {
                $usersByLanguage[$lang] += intval($row['count']);
            } else {
                $usersByLanguage['en'] += intval($row['count']);
            }
        }
    }

    // 2. Filtered Analytics
    $conditions = [];
    $bindTypes = '';
    $bindValues = [];

    if (!empty($dateFrom) && !empty($dateTo)) {
        $conditions[] = 'completedAt BETWEEN ? AND ?';
        $bindTypes .= 'ss';
        $bindValues[] = $dateFrom . ' 00:00:00';
        $bindValues[] = $dateTo . ' 23:59:59';
    } elseif (!empty($dateFrom)) {
        $conditions[] = 'completedAt >= ?';
        $bindTypes .= 's';
        $bindValues[] = $dateFrom . ' 00:00:00';
    } elseif (!empty($dateTo)) {
        $conditions[] = 'completedAt <= ?';
        $bindTypes .= 's';
        $bindValues[] = $dateTo . ' 23:59:59';
    }

    $where = empty($conditions) ? '' : 'WHERE ' . implode(' AND ', $conditions);

    $bindRefs = [];
    foreach ($bindValues as $k => &$v) {
        $bindRefs[] = &$v;
    }
    unset($v);

    $filteredTotalExamsRow = empty($bindValues)
        ? Database::fetchOne($conn, "SELECT COUNT(*) as total FROM exam_results $where")
        : Database::fetchOne($conn, "SELECT COUNT(*) as total FROM exam_results $where", $bindTypes, $bindRefs);
    $filteredTotalExams = $filteredTotalExamsRow ? intval($filteredTotalExamsRow['total']) : 0;

    $filteredUniqueUsersRow = empty($bindValues)
        ? Database::fetchOne($conn, "SELECT COUNT(DISTINCT userId) as total FROM exam_results $where")
        : Database::fetchOne($conn, "SELECT COUNT(DISTINCT userId) as total FROM exam_results $where", $bindTypes, $bindRefs);
    $filteredUniqueUsers = $filteredUniqueUsersRow ? intval($filteredUniqueUsersRow['total']) : 0;

    $dailyStatsSql = "SELECT DATE(completedAt) as date, COUNT(*) as count FROM exam_results $where GROUP BY DATE(completedAt) ORDER BY date ASC";
    $dailyStatsRaw = empty($bindValues)
        ? Database::fetchAll($conn, $dailyStatsSql, '', [])
        : Database::fetchAll($conn, $dailyStatsSql, $bindTypes, $bindRefs);

    $dailyStats = [];
    if ($dailyStatsRaw) {
        foreach ($dailyStatsRaw as $row) {
            $dailyStats[] = [
                'date'  => $row['date'],
                'count' => intval($row['count']),
            ];
        }
    }

    respond([
        'quickStats' => [
            'totalUsers'          => $totalUsers,
            'totalPractices'      => $totalPractices,
            'activeSubscriptions' => $activeSubscriptions,
            'usersByLanguage'     => $usersByLanguage,
        ],
        'analytics' => [
            'totalExams'  => $filteredTotalExams,
            'uniqueUsers' => $filteredUniqueUsers,
            'dailyStats'  => $dailyStats,
        ],
    ], 200);
}
