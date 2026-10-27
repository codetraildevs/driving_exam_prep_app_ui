<?php
require_once __DIR__ . '/../IremboValidation.php';

/** Exceptions carry only safe error identifiers, never applicant data. */
function irFail(string $code, int $status = 400): void { throw new RuntimeException($code, $status); }
function irQuery($db, string $sql, array $values = []) {
    $stmt = $db->prepare($sql);
    if (!$stmt || !$stmt->execute($values)) throw new RuntimeException('storage', 500);
    return $stmt;
}
function irStaff(array $actor): bool { return in_array($actor['role'], ['ADMIN','MANAGER'], true); }
function irMask(?string $value): ?string {
    return $value === null ? null : str_repeat('*', max(0, strlen($value) - 4)) . substr($value, -4);
}
function irPresent(array $row, bool $full = false): array {
    unset($row['payloadHash'], $row['requestKey']);
    $row['version'] = intval($row['version']);
    if (!$full) {
        $row['nationalId'] = irMask($row['nationalId']);
        $row['provisoireCode'] = irMask($row['provisoireCode']);
    }
    return $row;
}
function irAudit($db, string $id, string $actor, array $changes): void {
    irQuery($db, 'INSERT INTO irembo_audit (id, requestId, actorId, changesJson, createdAt) VALUES (?, ?, ?, ?, UTC_TIMESTAMP())',
        [generateUUID(), $id, $actor, json_encode($changes, JSON_UNESCAPED_UNICODE)]);
}
// Owner-confirmed scope: both ADMIN and MANAGER can process all requests.
function irInStaffScope(array $actor, array $row): bool { return irStaff($actor); }
function irScopeFilter(array $actor, array &$where, array &$values): void {
    if (!irStaff($actor)) irFail('forbidden',403);
}
function irCheckAssignmentPermission(array $actor, array $row, $staffId): void {
    if (!irStaff($actor)) irFail('forbidden',403);
}
function irCanRead(array $actor, array $row): bool {
    if ($actor['role'] === 'USER') return $row['userId'] === $actor['id'];
    return irInStaffScope($actor, $row);
}
function irGet($db, string $id, bool $lock = false): array {
    $r = irQuery($db, 'SELECT * FROM irembo_requests WHERE id = ?' . ($lock ? ' FOR UPDATE' : ''), [$id])->fetch(PDO::FETCH_ASSOC);
    if (!$r) irFail('notFound', 404);
    return $r;
}
function irList($db, array $actor): array {
    $where = []; $values = [];
    if ($actor['role'] === 'USER') { $where[] = 'r.userId = ?'; $values[] = $actor['id']; }
    else irScopeFilter($actor, $where, $values);
    $allowed = [
        'service'=>['Provisoire','Permis'], 'permisOption'=>['Manual','Automatic'],
        'category'=>['A','B','F'], 'status'=>IremboValidation::STATUSES,
        'examLanguage'=>['rw','en','fr'], 'district'=>IremboValidation::DISTRICTS,
    ];
    foreach ($allowed as $field=>$options) {
        $v = $_GET[$field] ?? '';
        if ($v === '') continue;
        if (!is_string($v) || !in_array($v, $options, true)) irFail('invalidFilters');
        $where[] = "r.$field = ?"; $values[] = $v;
    }
    if (irStaff($actor)) {
        $assigned = $_GET['assignedStaffId'] ?? '';
        if (!is_string($assigned)) irFail('invalidFilters');
        if ($assigned === 'unassigned') $where[] = 'r.assignedStaffId IS NULL';
        elseif ($assigned !== '') { $where[] = 'r.assignedStaffId = ?'; $values[] = $assigned; }
        $search = $_GET['search'] ?? '';
        if (!is_string($search) || strlen($search) > 150) irFail('invalidFilters');
        if (trim($search) !== '') {
            // Treat LIKE wildcard characters as literal search text.
            $needle = '%' . str_replace(['!','%','_'], ['!!','!%','!_'], trim($search)) . '%';
            $where[] = "(r.reference LIKE ? ESCAPE '!' OR r.fullName LIKE ? ESCAPE '!' OR r.phoneNumber LIKE ? ESCAPE '!')";
            array_push($values, $needle, $needle, $needle);
        }
    }
    foreach (['from','to'] as $f) if (!empty($_GET[$f])) {
        $date = IremboValidation::date($_GET[$f], $f);
        $where[] = 'r.createdAt ' . ($f === 'from' ? '>= ?' : '< DATE_ADD(?, INTERVAL 1 DAY)');
        $values[] = $date;
    }
    if (!empty($_GET['from']) && !empty($_GET['to']) && $_GET['from'] > $_GET['to']) irFail('invalidFilters');
    $orders = ['newest'=>'r.createdAt DESC, r.id DESC','oldest'=>'r.createdAt, r.id','name'=>'r.fullName, r.id','updated'=>'r.updatedAt DESC, r.id DESC'];
    $sort = $_GET['sort'] ?? 'newest';
    if (!is_string($sort) || !isset($orders[$sort])) irFail('invalidFilters');
    $page = filter_var($_GET['page'] ?? 1, FILTER_VALIDATE_INT);
    if (!$page || $page < 1 || $page > 100000) irFail('invalidFilters');
    $condition = $where ? ' WHERE ' . implode(' AND ', $where) : '';
    $count = irQuery($db, 'SELECT COUNT(*) AS total FROM irembo_requests r' . $condition, $values)->fetch(PDO::FETCH_ASSOC);
    $applicant = $actor['role'] === 'USER';
    if ($applicant) $page = 1;
    $offset = ($page - 1) * 20;
    $limit = $applicant ? '' : " LIMIT 20 OFFSET $offset";
    $rows = irQuery($db, 'SELECT r.*, u.fullName AS assignedStaffName FROM irembo_requests r LEFT JOIN users u ON u.id = r.assignedStaffId' . $condition . ' ORDER BY ' . $orders[$sort] . $limit, $values)->fetchAll(PDO::FETCH_ASSOC);
    return ['items'=>array_map(function($r) { return irPresent($r); }, $rows), 'total'=>intval($count['total']), 'page'=>$page, 'pageSize'=>$applicant ? intval($count['total']) : 20];
}
function irCreate($db, array $actor, array $input): array {
    if ($actor['role'] !== 'USER') irFail('forbidden', 403);
    $key = $input['requestKey'] ?? null;
    if (!is_string($key) || !preg_match('/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/iD', $key)) irFail('invalidRequest');
    $data = IremboValidation::registration($input);
    $hash = hash('sha256', json_encode($data, JSON_UNESCAPED_UNICODE));
    $existing = irQuery($db, 'SELECT * FROM irembo_requests WHERE userId = ? AND requestKey = ?', [$actor['id'],$key])->fetch(PDO::FETCH_ASSOC);
    if ($existing) {
        if (!hash_equals($existing['payloadHash'], $hash)) irFail('conflict', 409);
        return irPresent($existing);
    }
    $id = generateUUID();
    $data = array_merge(['id'=>$id,'reference'=>'IR-' . strtoupper(str_replace('-', '', $id)), 'userId'=>$actor['id'], 'requestKey'=>$key, 'payloadHash'=>$hash], $data);
    // Transactions use SQL commands supported by both PDO and this project's mysqli shim.
    $db->exec('START TRANSACTION');
    try {
        // Serialize submissions for this account, including different devices/keys.
        $owner = irQuery($db, 'SELECT id, isActive FROM users WHERE id = ? FOR UPDATE', [$actor['id']])->fetch(PDO::FETCH_ASSOC);
        if (!$owner || intval($owner['isActive']) !== 1) irFail('forbidden', 403);
        $prior = irQuery($db, 'SELECT * FROM irembo_requests WHERE userId = ? ORDER BY createdAt, id LIMIT 1 FOR UPDATE', [$actor['id']])->fetch(PDO::FETCH_ASSOC);
        if ($prior) {
            if ($prior['requestKey'] === $key && hash_equals($prior['payloadHash'], $hash)) {
                $db->exec('COMMIT');
                return irPresent($prior);
            }
            irFail('alreadySubmitted', 409);
        }
        $cols = array_keys($data);
        irQuery($db, 'INSERT INTO irembo_requests (' . implode(',', $cols) . ', createdAt, updatedAt) VALUES (' . implode(',', array_fill(0,count($cols),'?')) . ', UTC_TIMESTAMP(), UTC_TIMESTAMP())', array_values($data));
        irAudit($db, $id, $actor['id'], ['created'=>true, 'status'=>['to'=>'Pending']]);
        $row = irGet($db, $id);
        $db->exec('COMMIT');
        return irPresent($row);
    } catch (Throwable $e) {
        $db->exec('ROLLBACK');
        // A concurrent retry can win the unique (userId, requestKey) insert.
        $existing = irQuery($db, 'SELECT * FROM irembo_requests WHERE userId = ? AND requestKey = ?', [$actor['id'],$key])->fetch(PDO::FETCH_ASSOC);
        if ($existing && hash_equals($existing['payloadHash'], $hash)) return irPresent($existing);
        throw $e;
    }
}
function irUpdate($db, array $actor, string $id, array $input): array {
    if (!irStaff($actor)) irFail('forbidden', 403);
    $db->exec('START TRANSACTION');
    try {
        $old = irGet($db, $id, true);
        if (!irInStaffScope($actor, $old)) irFail('notFound', 404);
        if (!isset($input['version']) || !is_int($input['version']) || $input['version'] !== intval($old['version'])) irFail('conflict',409);
        $fields = ['fullName','phoneNumber','nationalId','dob','service','permisOption','category','provisoireCode','examLanguage','district','preferredExamDate'];
        $new = IremboValidation::registration(array_merge($old, array_intersect_key($input,array_flip($fields))));
        $new['status'] = $input['status'] ?? $old['status'];
        if (!in_array($new['status'], IremboValidation::STATUSES, true)) irFail('invalidStatus');
        $new['assignedStaffId'] = $old['assignedStaffId'];
        if (array_key_exists('assignedStaffId', $input)) {
            irCheckAssignmentPermission($actor, $old, $input['assignedStaffId']);
            $staffId = $input['assignedStaffId'];
            if ($staffId !== null) {
                if (!is_string($staffId)) irFail('invalidAssignment');
                $staff = irQuery($db, "SELECT id FROM users WHERE id = ? AND role IN ('ADMIN','MANAGER') AND isActive = 1", [$staffId])->fetch(PDO::FETCH_ASSOC);
                if (!$staff) irFail('invalidAssignment');
            }
            $new['assignedStaffId'] = $staffId;
        }
        $reason = IremboValidation::text($input,'reason',2000,false);
        if ($new['status'] !== $old['status'] && in_array($new['status'], ['Needs Information','Rejected'],true) && !$reason) irFail('reasonRequired');
        $note = IremboValidation::text($input,'internalNote',2000,false);
        $message = IremboValidation::text($input,'applicantMessage',2000,false);
        $changes = [];
        foreach ($new as $field=>$value) if ($old[$field] !== $value) $changes[$field] = ['from'=>$old[$field], 'to'=>$value];
        if ($reason) $changes['reason'] = $reason;
        foreach ([[$note,0],[$message,1],[$reason,1]] as [$body,$visible]) if ($body) {
            irQuery($db, 'INSERT INTO irembo_messages (id,requestId,staffId,applicantVisible,body,createdAt) VALUES (?,?,?,?,?,UTC_TIMESTAMP())', [generateUUID(),$id,$actor['id'],$visible,$body]);
        }
        if ($note) $changes['internalNoteAdded'] = true;
        if ($message) $changes['applicantMessageAdded'] = true;
        $set = implode(',', array_map(function($key) { return "$key = ?"; }, array_keys($new)));
        irQuery($db, 'UPDATE irembo_requests SET ' . $set . ', version = version + 1, updatedAt = UTC_TIMESTAMP() WHERE id = ?', array_merge(array_values($new),[$id]));
        irAudit($db,$id,$actor['id'],$changes);
        $row = irGet($db,$id);
        $db->exec('COMMIT');
        return irPresent($row, true);
    } catch (Throwable $e) { $db->exec('ROLLBACK'); throw $e; }
}
function iremboRequests($db, $params): void {
    global $tokenData;
    header('Cache-Control: no-store');
    try {
        // Match authLogin and adminBlockUser: isActive is authoritative.
        // The legacy isBlocked field defaults to 1 even for active accounts.
        $actor = irQuery($db, 'SELECT id, role, isActive FROM users WHERE id = ?', [$tokenData['userId'] ?? ''])->fetch(PDO::FETCH_ASSOC);
        if (!$actor || intval($actor['isActive']) !== 1 || !in_array($actor['role'],['USER','MANAGER','ADMIN'],true)) irFail('forbidden',403);
        $method = $_SERVER['REQUEST_METHOD'];
        if (($params['id'] ?? '') === 'staff') {
            if (!irStaff($actor) || $method !== 'GET') irFail('forbidden',403);
            $rows = irQuery($db, "SELECT id, fullName AS name, role FROM users WHERE role IN ('ADMIN','MANAGER') AND isActive = 1 ORDER BY fullName, id")->fetchAll(PDO::FETCH_ASSOC);
            respond($rows,200); return;
        }
        $id = $params['id'] ?? null;
        if ($method === 'GET' && !$id) { respond(irList($db,$actor)); return; }
        if ($method === 'POST' && !$id) { respond(irCreate($db,$actor,getInput()),201); return; }
        if ($method === 'PUT' && $id) { respond(irUpdate($db,$actor,$id,getInput())); return; }
        if ($method === 'GET' && $id) {
            $row = irGet($db,$id);
            if (!irCanRead($actor,$row)) irFail('notFound',404);
            $staff = irStaff($actor);
            $result = irPresent($row,$staff);
            $result['messages'] = irQuery($db,'SELECT m.id,m.body,m.applicantVisible,m.createdAt,u.fullName AS staffName FROM irembo_messages m LEFT JOIN users u ON u.id=m.staffId WHERE m.requestId=?' . ($staff?'':' AND m.applicantVisible=1') . ' ORDER BY m.createdAt,m.id',[$id])->fetchAll(PDO::FETCH_ASSOC);
            if ($staff) $result['audit'] = irQuery($db,'SELECT a.actorId,a.createdAt,a.changesJson,u.fullName AS actorName FROM irembo_audit a LEFT JOIN users u ON u.id=a.actorId WHERE a.requestId=? ORDER BY a.createdAt,a.id',[$id])->fetchAll(PDO::FETCH_ASSOC);
            respond($result); return;
        }
        irFail('notFound',404);
    } catch (InvalidArgumentException $e) {
        ErrorHandler::error('invalid:' . $e->getMessage(),400);
    } catch (Throwable $e) {
        $status = intval($e->getCode());
        if ($e instanceof RuntimeException && in_array($status,[400,403,404,409],true)) ErrorHandler::error($e->getMessage(),$status);
        // A missing additive migration is different from a network outage.
        if (($e instanceof PDOException || $e instanceof mysqli_sql_exception) && ((string)$e->getCode() === '42S02' || (int)$e->getCode() === 1146)) {
            ErrorHandler::error('iremboSetupRequired',503);
        }
        // Never include SQL errors, form data or exception traces in logs/responses.
        ErrorHandler::error('iremboUnavailable',503);
    }
}
