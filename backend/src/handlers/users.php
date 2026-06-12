<?php
/**
 * User route handlers.
 */

function getUser($conn, $params): void
{
    $id = SecurityUtils::sanitizeString($params['id']);
    if (!$id) {
        ErrorHandler::badRequest('Invalid user ID');
    }

    $user = Database::fetchOne($conn,
        'SELECT id, phoneNumber, fullName, role, isActive, createdAt FROM users WHERE id = ? LIMIT 1',
        's',
        [&$id]
    );

    if (!$user) {
        ErrorHandler::notFound('User not found');
    }

    respond($user, 200);
}

function listUsers($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $users = Database::fetchAll($conn,
        'SELECT id, phoneNumber, fullName, role, isActive, createdAt FROM users ORDER BY createdAt DESC LIMIT 100',
        '',
        []
    );

    if ($users === null) {
        ErrorHandler::serverError('Failed to fetch users');
    }

    respond($users, 200);
}

function updateUser($conn, $params): void
{
    global $tokenData;

    $id = SecurityUtils::sanitizeString($params['id']);
    if (!$id) {
        ErrorHandler::badRequest('Invalid user ID');
    }

    if (!$tokenData || !isset($tokenData['userId']) || !isset($tokenData['role'])) {
        ErrorHandler::unauthorized('Invalid or missing token data');
    }

    $isAdminOrManager = in_array($tokenData['role'], ['ADMIN', 'MANAGER']);
    $isSelf = $tokenData['userId'] === $id;

    if (!$isAdminOrManager && !$isSelf) {
        Logger::security('Unauthorized attempt to update another user', [
            'requestedUserId' => $id,
            'actualUserId'    => $tokenData['userId'],
        ]);
        ErrorHandler::forbidden('You can only update your own profile');
    }

    $user = Database::fetchOne($conn, 'SELECT id, role, phoneNumber FROM users WHERE id = ? LIMIT 1', 's', [&$id]);
    if (!$user) {
        ErrorHandler::notFound('User not found');
    }

    $input = getInput();
    if (empty($input)) {
        ErrorHandler::badRequest('No fields to update');
    }

    // Protect Admin and Demo account from being blocked
    if (isset($input['isActive']) && (int)$input['isActive'] === 0) {
        if ($user['role'] === 'ADMIN') {
            ErrorHandler::forbidden('Cannot block an ADMIN account.');
        }
        if ($user['phoneNumber'] === '0787012615') {
            ErrorHandler::forbidden('Cannot block the Demo account.');
        }
    }

    $selfAllowedFields = ['fullName', 'preferredLanguage'];
    $adminOnlyFields = ['role', 'isActive', 'lastCalledAt', 'lastCalledBy', 'callNotes'];

    $allowedFields = $isAdminOrManager
        ? array_merge($selfAllowedFields, $adminOnlyFields)
        : $selfAllowedFields;

    $updates = [];
    $types = '';
    $values = [];

    foreach ($allowedFields as $field) {
        if (isset($input[$field])) {
            $val = SecurityUtils::sanitizeString((string)$input[$field]);

            if ($field === 'role' && !SecurityUtils::isValidRole($val)) {
                ErrorHandler::badRequest('Invalid role value');
            }

            $updates[] = "$field = ?";
            $values[] = $val;
            $types .= 's';
        }
    }

    if (empty($updates)) {
        ErrorHandler::badRequest('No valid fields to update');
    }

    $now = date('Y-m-d H:i:s');
    $updates[] = 'updatedAt = ?';
    $values[] = $now;
    $types .= 's';
    $values[] = $id;
    $types .= 's';

    $sql = 'UPDATE users SET ' . implode(', ', $updates) . ' WHERE id = ?';
    $stmt = Database::execute($conn, $sql, $types, $values);

    if (!$stmt) {
        Logger::error('Failed to update user', ['userId' => $id]);
        ErrorHandler::serverError('Failed to update user');
    }

    Logger::info('User updated', ['userId' => $id, 'updatedBy' => $tokenData['userId']]);
    respond(['id' => $id], 200, 'User updated');
}

function deleteUser($conn, $params): void
{
    global $tokenData;

    $id = SecurityUtils::sanitizeString($params['id']);
    if (!$id) {
        ErrorHandler::badRequest('Invalid user ID');
    }

    // Protect Admin and Demo account
    $targetUser = Database::fetchOne($conn, 'SELECT role, phoneNumber FROM users WHERE id = ? LIMIT 1', 's', [&$id]);
    if ($targetUser) {
        if ($targetUser['role'] === 'ADMIN') {
            ErrorHandler::forbidden('Cannot delete an ADMIN account.');
        }
        if ($targetUser['phoneNumber'] === '0787012615') {
            ErrorHandler::forbidden('Cannot delete the Demo account.');
        }
    }

    $isSelf = isset($tokenData['userId']) && $tokenData['userId'] === $id;
    if (!$isSelf) {
        requireRole($tokenData, ['ADMIN', 'MANAGER']);
    }

    $affected = Database::query($conn, 'DELETE FROM users WHERE id = ?', 's', [&$id]);

    if ($affected === false) {
        ErrorHandler::serverError('Failed to delete user');
    }
    if ($affected === 0) {
        ErrorHandler::notFound('User not found');
    }

    Logger::info('User deleted', ['userId' => $id, 'adminId' => $tokenData['userId']]);
    respond([], 200, 'User deleted');
}
