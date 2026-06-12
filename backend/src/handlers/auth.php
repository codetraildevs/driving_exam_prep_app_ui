<?php
/**
 * Authentication route handlers.
 *
 * Implements refresh token flow:
 *  - Login/Register return { token (15min JWT), refresh_token (30-day opaque), user }
 *  - POST /api/auth/refresh accepts refresh_token in Authorization: Bearer header
 *  - Logout invalidates the refresh token in the database
 */

/**
 * Ensure the refresh_tokens table exists.
 */
function _ensureRefreshTokensTable($conn): void
{
    $conn->exec('
        CREATE TABLE IF NOT EXISTS refresh_tokens (
            id          INT AUTO_INCREMENT PRIMARY KEY,
            userId      VARCHAR(36) NOT NULL,
            token       VARCHAR(128) NOT NULL UNIQUE,
            expiresAt   DATETIME NOT NULL,
            createdAt   DATETIME DEFAULT CURRENT_TIMESTAMP,
            revoked     TINYINT(1) DEFAULT 0,
            INDEX idx_userId (userId),
            INDEX idx_token (token)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ');
}

/**
 * Generate and store a refresh token for the given user.
 * Returns the raw token string.
 */
function _createRefreshToken($conn, string $userId): string
{
    _ensureRefreshTokensTable($conn);
    $token = SecurityUtils::generateRandomToken(64);
    $expiresAt = date('Y-m-d H:i:s', time() + 30 * 24 * 60 * 60); // 30 days
    Database::insert($conn,
        'INSERT INTO refresh_tokens (userId, token, expiresAt) VALUES (?, ?, ?)',
        'sss',
        [&$userId, &$token, &$expiresAt]
    );
    return $token;
}

/**
 * Revoke all refresh tokens for a given user.
 */
function _revokeUserRefreshTokens($conn, string $userId): void
{
    _ensureRefreshTokensTable($conn);
    Database::query($conn,
        'UPDATE refresh_tokens SET revoked = 1 WHERE userId = ? AND revoked = 0',
        's',
        [&$userId]
    );
}

/**
 * Revoke a specific refresh token.
 */
function _revokeRefreshToken($conn, string $token): void
{
    _ensureRefreshTokensTable($conn);
    Database::query($conn,
        'UPDATE refresh_tokens SET revoked = 1 WHERE token = ? AND revoked = 0',
        's',
        [&$token]
    );
}

function authRegister($conn, $params): void
{
    $input = getInput();

    // Validate required fields
    $validation = SecurityUtils::validateRequired($input, ['phoneNumber', 'fullName', 'deviceId']);
    if ($validation) {
        ErrorHandler::badRequest($validation);
    }

    $phone = SecurityUtils::sanitizeString($input['phoneNumber']);
    if (!SecurityUtils::isValidPhone($phone)) {
        ErrorHandler::badRequest('Invalid phone number format');
    }

    $name = SecurityUtils::sanitizeString($input['fullName']);
    if (!SecurityUtils::validateLength($name, 2, 255)) {
        ErrorHandler::badRequest('Full name must be between 2 and 255 characters');
    }

    $device = SecurityUtils::sanitizeString($input['deviceId']);
    if (!SecurityUtils::validateLength($device, 5, 255)) {
        ErrorHandler::badRequest('Device ID must be between 5 and 255 characters');
    }

    $role = $input['role'] ?? 'USER';
    if (!SecurityUtils::isValidRole($role)) {
        $role = 'USER';
    }

    $preferredLanguage = 'en';
    if (!empty($input['preferredLanguage']) && in_array($input['preferredLanguage'], ['en', 'fr', 'rw'])) {
        $preferredLanguage = $input['preferredLanguage'];
    }

    // Check existing phone
    $existing = Database::fetchOne($conn, 'SELECT id, deviceId, role FROM users WHERE phoneNumber = ? LIMIT 1', 's', [&$phone]);
    if ($existing) {
        if ($existing['deviceId'] === $device || $existing['role'] === 'ADMIN' || $existing['role'] === 'MANAGER') {
            Logger::info('Registration attempt with existing phone', ['phone' => substr($phone, -4)]);
            ErrorHandler::conflict('You already have an account with this phone number. Please go back and tap "Log In".');
        } else {
            Logger::warning('Phone registered on different device', ['phone' => substr($phone, -4)]);
            ErrorHandler::conflict('This phone number is already registered on a different phone. Please log in on your original phone or contact support.');
        }
    }

    // Check existing device (Anti-Fraud: 1 device = 1 account)
    $existingDevice = Database::fetchOne($conn, 'SELECT id, phoneNumber, role FROM users WHERE deviceId = ? LIMIT 1', 's', [&$device]);
    if ($existingDevice) {
        if ($existingDevice['role'] !== 'ADMIN' && $existingDevice['role'] !== 'MANAGER') {
            Logger::warning('Device already registered', ['device' => substr($device, -4)]);
            ErrorHandler::conflict('This phone is already registered to another user. For security, only one account is allowed per device.');
        }
    }

    $id = generateUUID();
    $now = date('Y-m-d H:i:s');

    $result = Database::insert($conn,
        'INSERT INTO users (id, fullName, phoneNumber, deviceId, role, isActive, preferredLanguage, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, 1, ?, ?, ?)',
        'ssssssss',
        [&$id, &$name, &$phone, &$device, &$role, &$preferredLanguage, &$now, &$now]
    );

    if ($result !== null) {
        $token = SecurityUtils::generateToken([
            'userId'      => $id,
            'phoneNumber' => $phone,
            'role'        => $role,
        ]);
        $refreshToken = _createRefreshToken($conn, $id);

        Logger::info('User registered successfully', ['userId' => $id]);
        respond([
            'id'            => $id,
            'phoneNumber'   => $phone,
            'fullName'      => $name,
            'role'          => $role,
            'token'         => $token,
            'refresh_token' => $refreshToken,
        ], 201, 'User registered');
    } else {
        Logger::error('User registration failed', ['phone' => substr($phone, -4)]);
        ErrorHandler::serverError('Registration failed');
    }
}

function authLogin($conn, $params): void
{
    $input = getInput();

    $validation = SecurityUtils::validateRequired($input, ['phoneNumber']);
    if ($validation) {
        ErrorHandler::badRequest($validation);
    }

    $phone = SecurityUtils::sanitizeString($input['phoneNumber']);
    if (!SecurityUtils::isValidPhone($phone)) {
        Logger::warning('Login attempt with invalid phone format', ['phone' => substr($phone, -4)]);
        ErrorHandler::badRequest('Invalid phone number format');
    }

    $device = isset($input['deviceId']) ? SecurityUtils::sanitizeString($input['deviceId']) : null;

    $user = Database::fetchOne($conn,
        'SELECT id, phoneNumber, fullName, role, deviceId, isActive FROM users WHERE phoneNumber = ? LIMIT 1',
        's',
        [&$phone]
    );

    if (!$user) {
        Logger::warning('Login attempt with non-existent user', ['phone' => substr($phone, -4)]);
        ErrorHandler::unauthorized('Phone number not registered. Please register first.');
    }

    if (!$user['isActive']) {
        Logger::security('Login attempt on inactive account', ['userId' => $user['id']]);
        ErrorHandler::forbidden('Account is inactive. Please contact support.');
    }

    // Device binding logic
    if ($user['role'] === 'USER' && $phone !== '0787012615') {
        if (!$device) {
            Logger::warning('USER login without deviceId', ['userId' => $user['id']]);
            ErrorHandler::badRequest('Device ID is required for user login');
        }
        if ($user['deviceId'] !== $device) {
            Logger::security('Login device mismatch', [
                'userId'   => $user['id'],
                'expected' => substr($user['deviceId'], -4),
                'provided' => substr($device, -4),
            ]);
            ErrorHandler::unauthorized('Device not registered for this account');
        }
    } else {
        if ($device) {
            Logger::info('Admin login from device', ['userId' => $user['id']]);
        }
    }

    $token = SecurityUtils::generateToken([
        'userId'      => $user['id'],
        'phoneNumber' => $user['phoneNumber'],
        'role'        => $user['role'],
    ]);
    $refreshToken = _createRefreshToken($conn, $user['id']);

    Logger::info('User login successful', ['userId' => $user['id'], 'role' => $user['role']]);

    respond([
        'id'            => $user['id'],
        'phoneNumber'   => $user['phoneNumber'],
        'fullName'      => $user['fullName'],
        'role'          => $user['role'],
        'token'         => $token,
        'refresh_token' => $refreshToken,
    ], 200, 'Login successful');
}

function authLogout($conn, $params): void
{
    // Safely parse body — handle empty/missing body gracefully
    $raw = file_get_contents('php://input');
    $input = $raw ? (json_decode($raw, true) ?: []) : [];

    // Try to revoke the specific refresh token (if provided)
    if (!empty($input['refresh_token'])) {
        _revokeRefreshToken($conn, $input['refresh_token']);
    }

    // Also revoke all tokens for the current user (if we have the userId from JWT)
    global $tokenData;
    if (!empty($tokenData['userId'])) {
        _revokeUserRefreshTokens($conn, $tokenData['userId']);
    }

    Logger::info('User logged out — refresh tokens revoked');
    respond(['message' => 'Logged out successfully'], 200);
}

function authRefresh($conn, $params): void
{
    // Accept refresh token from Authorization: Bearer header
    $authToken = SecurityUtils::getTokenFromHeaders();
    if (!$authToken) {
        ErrorHandler::unauthorized('Missing refresh token');
    }

    _ensureRefreshTokensTable($conn);

    // Find the refresh token in the database
    $row = Database::fetchOne($conn,
        'SELECT userId, expiresAt, revoked FROM refresh_tokens WHERE token = ? LIMIT 1',
        's',
        [&$authToken]
    );

    if (!$row) {
        Logger::security('Refresh token not found');
        ErrorHandler::unauthorized('Invalid refresh token');
    }

    if ($row['revoked']) {
        Logger::security('Attempted use of revoked refresh token', ['userId' => $row['userId']]);
        // Revoke ALL tokens for this user — likely token theft
        _revokeUserRefreshTokens($conn, $row['userId']);
        ErrorHandler::unauthorized('Refresh token has been revoked. Please log in again.');
    }

    if (strtotime($row['expiresAt']) < time()) {
        Logger::info('Expired refresh token used', ['userId' => $row['userId']]);
        _revokeRefreshToken($conn, $authToken);
        ErrorHandler::unauthorized('Refresh token has expired. Please log in again.');
    }

    $userId = $row['userId'];

    // Look up the user
    $user = Database::fetchOne($conn,
        'SELECT id, phoneNumber, role FROM users WHERE id = ? LIMIT 1',
        's',
        [&$userId]
    );

    if (!$user) {
        Logger::security('User not found for refresh token', ['userId' => $userId]);
        ErrorHandler::unauthorized('User not found');
    }

    // Revoke old refresh token (rotation)
    _revokeRefreshToken($conn, $authToken);

    // Issue new tokens
    $newToken = SecurityUtils::generateToken([
        'userId'      => $user['id'],
        'phoneNumber' => $user['phoneNumber'],
        'role'        => $user['role'],
    ]);
    $newRefreshToken = _createRefreshToken($conn, $userId);

    Logger::info('Tokens refreshed', ['userId' => $userId]);

    respond([
        'token'         => $newToken,
        'refresh_token' => $newRefreshToken,
    ], 200, 'Tokens refreshed');
}
