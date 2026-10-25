<?php
/** Authenticated group directory; only administrators may mutate it. */
function whatsappGroups($conn, $params): void
{
    global $tokenData;
    $method = $_SERVER['REQUEST_METHOD'];
    if ($method !== 'GET') {
        requireRole($tokenData, ['ADMIN', 'MANAGER']);
    }
    $conn->exec('CREATE TABLE IF NOT EXISTS whatsapp_groups (
        id VARCHAR(36) PRIMARY KEY,
        name VARCHAR(120) NOT NULL,
        inviteUrl VARCHAR(500) NOT NULL,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4');
    if ($method === 'GET') {
        respond(Database::fetchAll($conn, 'SELECT id, name, inviteUrl FROM whatsapp_groups ORDER BY createdAt, id') ?: [], 200);
        return;
    }
    $id = $params['id'] ?? null;
    if ($id && !Database::fetchOne($conn, 'SELECT id FROM whatsapp_groups WHERE id = ?', 's', [&$id])) {
        ErrorHandler::notFound('Group not found');
    }
    if ($method === 'DELETE') {
        Database::query($conn, 'DELETE FROM whatsapp_groups WHERE id = ?', 's', [&$id]);
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
        Database::insert($conn, 'INSERT INTO whatsapp_groups (id, name, inviteUrl) VALUES (?, ?, ?)', 'sss', [&$id, &$name, &$url]);
    } else {
        Database::query($conn, 'UPDATE whatsapp_groups SET name = ?, inviteUrl = ? WHERE id = ?', 'sss', [&$name, &$url, &$id]);
    }
    respond(['id' => $id, 'name' => $name, 'inviteUrl' => $url], $method === 'POST' ? 201 : 200);
}
