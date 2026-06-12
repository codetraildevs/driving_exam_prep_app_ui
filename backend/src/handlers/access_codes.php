<?php
/**
 * Access code route handlers.
 */

function verifyAccessCode($conn, $params): void
{
    $input = getInput();

    $validation = SecurityUtils::validateRequired($input, ['code', 'userId']);
    if ($validation) {
        ErrorHandler::badRequest($validation);
    }

    $code = SecurityUtils::sanitizeString($input['code']);
    $userId = SecurityUtils::sanitizeString($input['userId']);

    $accessCode = Database::fetchOne($conn,
        'SELECT id, code, isUsed, expiresAt FROM access_codes WHERE code = ? AND isUsed = 0 LIMIT 1',
        's',
        [&$code]
    );

    if (!$accessCode) {
        Logger::warning('Invalid access code attempt', ['userId' => $userId]);
        ErrorHandler::notFound('Invalid or expired access code');
    }

    if (strtotime($accessCode['expiresAt']) < time()) {
        Logger::warning('Expired access code attempt', ['userId' => $userId]);
        ErrorHandler::badRequest('Access code has expired');
    }

    $now = date('Y-m-d H:i:s');
    Database::query($conn,
        'UPDATE access_codes SET isUsed = 1, usedAt = ? WHERE code = ?',
        'ss',
        [&$now, &$code]
    );

    Logger::info('Access code verified', ['userId' => $userId, 'code' => substr($code, -4)]);
    respond(['message' => 'Access code verified', 'code' => $code], 200);
}

function listAccessCodes($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $page = max(1, intval($_GET['page'] ?? 1));
    $limit = max(1, min(100, intval($_GET['limit'] ?? 10)));
    $offset = ($page - 1) * $limit;
    $sortDir = (strtoupper($_GET['sortDir'] ?? 'DESC') === 'ASC') ? 'ASC' : 'DESC';
    $dateFrom = SecurityUtils::sanitizeString($_GET['dateFrom'] ?? '');
    $dateTo = SecurityUtils::sanitizeString($_GET['dateTo'] ?? '');
    $todayOnly = ($_GET['today'] ?? '') === '1';
    $isBlocked = $_GET['isBlocked'] ?? null;

    $conditions = [];
    $bindTypes = '';
    $bindValues = [];

    if ($todayOnly) {
        $conditions[] = 'DATE(ac.createdAt) = CURDATE()';
    } elseif (!empty($dateFrom) && !empty($dateTo)) {
        $conditions[] = 'ac.createdAt BETWEEN ? AND ?';
        $bindTypes .= 'ss';
        $bindValues[] = $dateFrom . ' 00:00:00';
        $bindValues[] = $dateTo . ' 23:59:59';
    } elseif (!empty($dateFrom)) {
        $conditions[] = 'ac.createdAt >= ?';
        $bindTypes .= 's';
        $bindValues[] = $dateFrom . ' 00:00:00';
    }

    if ($isBlocked === 'true' || $isBlocked === '1') {
        $conditions[] = '(ac.isUsed = 1 OR ac.expiresAt <= NOW())';
    } elseif ($isBlocked === 'false' || $isBlocked === '0') {
        $conditions[] = '(ac.isUsed = 0 AND ac.expiresAt > NOW())';
    }

    $where = empty($conditions) ? '' : 'WHERE ' . implode(' AND ', $conditions);

    $countSql = "SELECT COUNT(*) as total FROM access_codes ac $where";
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

    $pageSql = "SELECT ac.id, ac.code, ac.userId, ac.isUsed, ac.expiresAt, ac.createdAt,
                       ac.paymentTier, ac.paymentAmount, ac.durationDays,
                       ac.generatedByManagerId,
                       u.fullName as userName, u.phoneNumber as userPhone,
                       CASE WHEN ac.isUsed = 1 OR ac.expiresAt <= NOW() THEN 1 ELSE 0 END as isBlocked
                FROM access_codes ac
                LEFT JOIN users u ON u.id = ac.userId
                $where
                ORDER BY ac.createdAt $sortDir
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

    $codes = Database::fetchAll($conn, $pageSql, $pageTypes, $pageRefs);

    respond([
        'codes' => $codes ?: [],
        'total' => $total,
        'page'  => $page,
        'limit' => $limit,
    ], 200);
}

function blockAccessCode($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $id = SecurityUtils::sanitizeString($params['id'] ?? '');
    if (!$id) {
        ErrorHandler::badRequest('Invalid access code ID');
    }

    $code = Database::fetchOne($conn, 'SELECT id FROM access_codes WHERE id = ? LIMIT 1', 's', [&$id]);
    if (!$code) {
        ErrorHandler::notFound('Access code not found');
    }

    $now = date('Y-m-d H:i:s');
    $affected = Database::query($conn,
        'UPDATE access_codes SET isUsed = 1, expiresAt = ?, updatedAt = ? WHERE id = ?',
        'sss',
        [&$now, &$now, &$id]
    );

    if ($affected === false) {
        ErrorHandler::serverError('Failed to block access code');
    }

    Logger::info('Access code blocked', ['codeId' => $id, 'adminId' => $tokenData['userId']]);
    respond(['id' => $id, 'blocked' => true], 200, 'Access code blocked');
}

function deleteAccessCode($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $id = SecurityUtils::sanitizeString($params['id'] ?? '');
    if (!$id) {
        ErrorHandler::badRequest('Invalid access code ID');
    }

    $affected = Database::query($conn, 'DELETE FROM access_codes WHERE id = ?', 's', [&$id]);

    if ($affected === false) {
        ErrorHandler::serverError('Failed to delete access code');
    }
    if ($affected === 0) {
        ErrorHandler::notFound('Access code not found');
    }

    Logger::info('Access code deleted', ['codeId' => $id, 'adminId' => $tokenData['userId']]);
    respond([], 200, 'Access code deleted');
}

function generateAccessCode($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $input = getInput();

    $validation = SecurityUtils::validateRequired($input, ['userId']);
    if ($validation) {
        ErrorHandler::badRequest($validation);
    }

    $userId = SecurityUtils::sanitizeString($input['userId']);
    $days = intval($input['durationDays'] ?? 30);

    if ($days < 1 || $days > 365) {
        ErrorHandler::badRequest('Duration must be between 1 and 365 days');
    }

    $id = 'code_' . generateUUID();
    $code = strtoupper(substr(md5(uniqid(random_bytes(16), true)), 0, 12));
    $expiresAt = date('Y-m-d H:i:s', strtotime("+$days days"));
    $now = date('Y-m-d H:i:s');

    $result = Database::insert($conn,
        'INSERT INTO access_codes (id, code, userId, expiresAt, isUsed, createdAt, updatedAt) VALUES (?, ?, ?, ?, 0, ?, ?)',
        'ssssss',
        [&$id, &$code, &$userId, &$expiresAt, &$now, &$now]
    );

    if ($result) {
        Logger::info('Access code generated', ['codeId' => $id, 'userId' => $userId, 'createdBy' => $tokenData['userId']]);
        respond(['id' => $id, 'code' => $code, 'expiresAt' => $expiresAt], 201, 'Access code generated');
    } else {
        Logger::error('Failed to generate access code', ['userId' => $userId]);
        ErrorHandler::serverError('Failed to generate access code');
    }
}

function getAccessCodeStatus($conn, $params): void
{
    global $tokenData;

    $userId = SecurityUtils::sanitizeString($_GET['userId'] ?? '');
    if (!$userId) {
        $userId = $tokenData['userId'];
    }

    $row = Database::fetchOne(
        $conn,
        'SELECT code, expiresAt, paymentTier, paymentAmount FROM access_codes WHERE userId = ? AND expiresAt > NOW() ORDER BY createdAt DESC LIMIT 1',
        's',
        [&$userId]
    );

    if ($row) {
        respond([
            'hasActiveAccess' => true,
            'expiresAt'       => $row['expiresAt'],
            'paymentTier'     => $row['paymentTier'],
            'code'            => $row['code'],
        ], 200);
    } else {
        respond(['hasActiveAccess' => false], 200);
    }
}
