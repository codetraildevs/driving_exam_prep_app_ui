<?php
/** Authenticated group directory; administrators and managers may mutate it. */
function whatsappGroups($conn, $params): void
{
    global $tokenData;
    $method = $_SERVER['REQUEST_METHOD'];
    if ($method !== 'GET') {
        requireRole($tokenData, ['ADMIN', 'MANAGER']);
    }
    // Existing installations need only CRUD privileges. Create the table only
    // when MySQL specifically reports that it does not exist.
    try {
        $probe = $conn->prepare('SELECT id FROM whatsapp_groups LIMIT 0');
        if (!$probe || !$probe->execute()) {
            throw new RuntimeException('Unable to check WhatsApp groups table');
        }
        $probe->closeCursor();
    } catch (Throwable $e) {
        $missingTable = $e instanceof PDOException &&
            ((string)$e->getCode() === '42S02' || (int)$e->getCode() === 1146);
        if (!$missingTable) {
            ErrorHandler::serverError('Unable to load WhatsApp groups.');
            return;
        }
        try {
            $created = $conn->exec('CREATE TABLE IF NOT EXISTS whatsapp_groups (
                id VARCHAR(36) PRIMARY KEY,
                name VARCHAR(120) NOT NULL,
                inviteUrl VARCHAR(500) NOT NULL,
                createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4');
            if ($created === false) {
                throw new RuntimeException('Unable to create WhatsApp groups table');
            }
        } catch (Throwable $creationError) {
            ErrorHandler::serverError('WhatsApp groups storage is not configured. Contact support.');
            return;
        }
    }
    if ($method === 'GET') {
        $stmt = whatsappGroupsQuery($conn, 'SELECT id, name, inviteUrl FROM whatsapp_groups ORDER BY createdAt, id');
        $groups = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $stmt->closeCursor();
        respond($groups, 200);
        return;
    }
    $id = $params['id'] ?? null;
    if ($id && !whatsappGroupsQuery($conn, 'SELECT id FROM whatsapp_groups WHERE id = ?', [$id])->fetch(PDO::FETCH_ASSOC)) {
        ErrorHandler::notFound('Group not found');
    }
    if ($method === 'DELETE') {
        whatsappGroupsQuery($conn, 'DELETE FROM whatsapp_groups WHERE id = ?', [$id]);
        respond(['deleted' => true], 200);
        return;
    }
    $input = getInput();
    $name = trim((string)($input['name'] ?? ''));
    $url = trim((string)($input['inviteUrl'] ?? ''));
    if ($name === '' || strlen($name) > 120 || strlen($url) > 500 ||
        !preg_match('~^https://chat\.whatsapp\.com/[A-Za-z0-9]+(?:\?[^\s#]*)?$~D', $url)) {
        ErrorHandler::badRequest('Enter a group name and a valid HTTPS WhatsApp invite link.');
    }
    if ($method === 'POST') {
        $id = generateUUID();
        whatsappGroupsQuery($conn, 'INSERT INTO whatsapp_groups (id, name, inviteUrl) VALUES (?, ?, ?)', [$id, $name, $url]);
    } else {
        whatsappGroupsQuery($conn, 'UPDATE whatsapp_groups SET name = ?, inviteUrl = ? WHERE id = ?', [$name, $url, $id]);
    }
    respond(['id' => $id, 'name' => $name, 'inviteUrl' => $url], $method === 'POST' ? 201 : 200);
}

/** Fail closed: never report success after a failed database operation. */
function whatsappGroupsQuery($conn, string $sql, array $params = [])
{
    try {
        $stmt = $conn->prepare($sql);
        if ($stmt && $stmt->execute($params)) {
            return $stmt;
        }
    } catch (Throwable $e) {
        // Keep database internals out of the API response.
    }
    ErrorHandler::serverError('Unable to complete the WhatsApp group request. Please try again.');
    exit();
}
