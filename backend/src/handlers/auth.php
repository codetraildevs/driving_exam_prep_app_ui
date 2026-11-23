<?php
require_once __DIR__ . '/../ReferralService.php';
require_once __DIR__ . '/../UserRegistrationTime.php';
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
    // Refresh tokens are long-lived but bounded to reduce exposure if stolen.
    // Rotation on refresh keeps active users signed in.
    $expiresAt = date('Y-m-d H:i:s', time() + 365 * 24 * 60 * 60); // ~1 year
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

function _authError(string $message, int $status, string $errorCode): void
{
    http_response_code($status);
    echo json_encode([
        'success' => false,
        'message' => $message,
        'code' => $status,
        'error_code' => $errorCode,
    ]);
    exit();
}

function _registeredResponse($conn, array $user, string $referralStatus): void
{
    $id = $user['id'];
    $token = SecurityUtils::generateToken(['userId' => $id, 'phoneNumber' => $user['phoneNumber'], 'role' => $user['role']]);
    $refreshToken = _createRefreshToken($conn, $id);
    respond([
        'id' => $id, 'phoneNumber' => $user['phoneNumber'], 'fullName' => $user['fullName'], 'role' => $user['role'],
        'token' => $token, 'refresh_token' => $refreshToken, 'referralStatus' => $referralStatus,
    ], 201, 'User registered');
}

function _registrationRetryResponse($conn, ?string $keyHash, string $payloadHash): void
{
    try {
        $receipt = ReferralService::receipt($conn, $keyHash, $payloadHash);
        if ($receipt) {
            _registeredResponse($conn, ['id' => $receipt['userId'], 'phoneNumber' => $receipt['phoneNumber'], 'fullName' => $receipt['fullName'], 'role' => $receipt['role']], $receipt['referralStatus']);
        }
    } catch (DomainException $e) {
        _authError('Please log in or start a new registration.', 409, 'REGISTRATION_RETRY_REJECTED');
    } catch (Throwable $e) {
        error('Registration temporarily unavailable', 503);
    }
}

function authRegister($conn, $params): void
{
    $input = getInput();

    // Validate required fields
    $validation = SecurityUtils::validateRequired($input, ['phoneNumber', 'fullName', 'deviceId']);
    if ($validation) {
        ErrorHandler::badRequest($validation);
    }

    $phone = SecurityUtils::normalizePhone(SecurityUtils::sanitizeString($input['phoneNumber']));
    if (!SecurityUtils::isValidPhone($phone)) {
        _authError('Invalid phone number format', 400, 'INVALID_PHONE_FORMAT');
    }

    $name = SecurityUtils::sanitizeString($input['fullName']);
    if (!SecurityUtils::validateLength($name, 2, 255)) {
        ErrorHandler::badRequest('Full name must be between 2 and 255 characters');
    }

    $device = SecurityUtils::sanitizeString($input['deviceId']);
    if (!SecurityUtils::validateLength($device, 5, 255)) {
        ErrorHandler::badRequest('Device ID must be between 5 and 255 characters');
    }

    $role = 'USER'; // Public registration must never grant administrative access.
    if (!SecurityUtils::isValidRole($role)) {
        $role = 'USER';
    }

    $preferredLanguage = 'rw';
    if (!empty($input['preferredLanguage']) && in_array($input['preferredLanguage'], ['en', 'fr', 'rw'])) {
        $preferredLanguage = $input['preferredLanguage'];
    }

    if ($phone === '0787012615') {
        _authError('This phone number is reserved. Please log in.', 403, 'RESERVED_ACCOUNT');
    }

    $referralCode = $input['referralCode'] ?? null;
    $registrationKey = ReferralService::key($input['registrationKey'] ?? null);
    if (isset($input['registrationKey']) && $registrationKey === null) {
        _authError('Invalid registration request', 400, 'INVALID_REGISTRATION_KEY');
    }
    $payloadHash = ReferralService::payloadHash([$phone, $name, $device, $preferredLanguage], $referralCode);
    try {
        $receipt = ReferralService::receipt($conn, $registrationKey, $payloadHash);
        if ($receipt) {
            _registeredResponse($conn, ['id' => $receipt['userId'], 'phoneNumber' => $receipt['phoneNumber'], 'fullName' => $receipt['fullName'], 'role' => $receipt['role']], $receipt['referralStatus']);
        }
    } catch (DomainException $e) {
        _authError('Please log in or start a new registration.', 409, 'REGISTRATION_RETRY_REJECTED');
    } catch (Throwable $e) {
        error('Registration temporarily unavailable', 503);
    }

    // Check existing phone
    $existing = Database::fetchOne($conn, 'SELECT id, deviceId, role FROM users WHERE phoneNumber = ? LIMIT 1', 's', [&$phone]);
    if (!$existing) {
        $existing = Database::fetchOne($conn, "SELECT id, deviceId, role FROM users WHERE (CASE WHEN REPLACE(REPLACE(REPLACE(REPLACE(phoneNumber, ' ', ''), '-', ''), '(', ''), ')', '') REGEXP '^([+]?250|0)?7[2389][0-9]{7}$' THEN CONCAT('0', RIGHT(REPLACE(REPLACE(REPLACE(REPLACE(phoneNumber, ' ', ''), '-', ''), '(', ''), ')', ''), 9)) ELSE REPLACE(REPLACE(REPLACE(REPLACE(phoneNumber, ' ', ''), '-', ''), '(', ''), ')', '') END) = ? LIMIT 1", 's', [&$phone]);
    }
    if ($existing) {
        // Another request may have committed since our first receipt lookup.
        _registrationRetryResponse($conn, $registrationKey, $payloadHash);
        if ($existing['deviceId'] === $device || $existing['role'] === 'ADMIN' || $existing['role'] === 'MANAGER') {
            Logger::info('Registration attempt with existing phone', ['phone' => substr($phone, -4)]);
            _authError('You already have an account with this phone number. Please go back and tap "Log In".', 409, 'ACCOUNT_ALREADY_EXISTS');
        } else {
            Logger::warning('Phone registered on different device', ['phone' => substr($phone, -4)]);
            _authError('This phone number is already registered on a different phone. Please verify and move your account to this phone.', 409, 'PHONE_BOUND_TO_OTHER_DEVICE');
        }
    }

    // Check existing device (Anti-Fraud: 1 device = 1 account)
    $existingDevice = Database::fetchOne($conn, 'SELECT id, phoneNumber, role FROM users WHERE deviceId = ? LIMIT 1', 's', [&$device]);
    if ($existingDevice) {
        _registrationRetryResponse($conn, $registrationKey, $payloadHash);
        if ($existingDevice['role'] !== 'ADMIN' && $existingDevice['role'] !== 'MANAGER') {
            Logger::warning('Device already registered', ['device' => substr($device, -4)]);
            _authError('This phone is already registered to another user. For security, only one account is allowed per device.', 409, 'DEVICE_ALREADY_IN_USE');
        }
    }

    $id = generateUUID();
    $now = UserRegistrationTime::now();

    try {
        $conn->exec('START TRANSACTION');
        ReferralService::query($conn,
            'INSERT INTO users (id, fullName, phoneNumber, deviceId, role, isActive, preferredLanguage, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, 1, ?, ?, ?)',
            [$id, $name, $phone, $device, $role, $preferredLanguage, $now, $now]);
        ReferralService::ensureCode($conn, $id);
        $referralStatus = ReferralService::attributeNewAccount($conn, $id, $device, $referralCode);
        if ($registrationKey !== null) {
            ReferralService::query($conn, 'INSERT INTO referral_registration_receipts (keyHash, payloadHash, userId, referralStatus) VALUES (?, ?, ?, ?)',
                [$registrationKey, $payloadHash, $id, $referralStatus]);
        }
        $conn->exec('COMMIT');
    } catch (Throwable $e) {
        $conn->exec('ROLLBACK');
        // A concurrent identical request may have won the unique constraints.
        _registrationRetryResponse($conn, $registrationKey, $payloadHash);
        Logger::error('Registration transaction failed');
        error('Registration could not be completed. Please retry or log in if the account already exists.', 503);
    }
    Logger::info('User registered successfully', ['userId' => $id]);
    _registeredResponse($conn, ['id' => $id, 'phoneNumber' => $phone, 'fullName' => $name, 'role' => $role], $referralStatus);
}

function authLogin($conn, $params): void
{
    $input = getInput();

    $validation = SecurityUtils::validateRequired($input, ['phoneNumber']);
    if ($validation) {
        ErrorHandler::badRequest($validation);
    }

    $phone = SecurityUtils::normalizePhone(SecurityUtils::sanitizeString($input['phoneNumber']));
    if (!SecurityUtils::isValidPhone($phone)) {
        Logger::warning('Login attempt with invalid phone format', ['phone' => substr($phone, -4)]);
        _authError('Invalid phone number format', 400, 'INVALID_PHONE_FORMAT');
    }

    $device = isset($input['deviceId']) ? SecurityUtils::sanitizeString($input['deviceId']) : null;

    $user = Database::fetchOne($conn,
        'SELECT id, phoneNumber, fullName, role, deviceId, isActive FROM users WHERE phoneNumber = ? LIMIT 1',
        's',
        [&$phone]
    );
    if (!$user) {
        $user = Database::fetchOne($conn,
            "SELECT id, phoneNumber, fullName, role, deviceId, isActive FROM users WHERE (CASE WHEN REPLACE(REPLACE(REPLACE(REPLACE(phoneNumber, ' ', ''), '-', ''), '(', ''), ')', '') REGEXP '^([+]?250|0)?7[2389][0-9]{7}$' THEN CONCAT('0', RIGHT(REPLACE(REPLACE(REPLACE(REPLACE(phoneNumber, ' ', ''), '-', ''), '(', ''), ')', ''), 9)) ELSE REPLACE(REPLACE(REPLACE(REPLACE(phoneNumber, ' ', ''), '-', ''), '(', ''), ')', '') END) = ? LIMIT 1",
            's',
            [&$phone]
        );
    }

    if (!$user) {
        Logger::warning('Login attempt with non-existent user', ['phone' => substr($phone, -4)]);
        _authError('Phone number not registered. Please register first.', 401, 'PHONE_NOT_REGISTERED');
    }

    if (!$user['isActive']) {
        Logger::security('Login attempt on inactive account', ['userId' => $user['id']]);
        _authError('Account is inactive. Please contact support.', 403, 'ACCOUNT_INACTIVE');
    }

    // Only the existing Play Store demo account may sign in across devices.
    if ($user['role'] === 'USER' && $phone !== '0787012615') {
        if (!$device) {
            Logger::warning('USER login without deviceId', ['userId' => $user['id']]);
            _authError('Device ID is required for user login', 400, 'DEVICE_ID_REQUIRED');
        }
        if ($user['deviceId'] !== $device) {
            Logger::security('Login device mismatch', [
                'userId'   => $user['id'],
                'expected' => substr($user['deviceId'], -4),
                'provided' => substr($device, -4),
            ]);
            _authError('This account is linked to another device. Use account recovery to move it to this device.', 401, 'DEVICE_MISMATCH');
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

function authRebindDevice($conn, $params): void
{
    $input = getInput();
    $validation = SecurityUtils::validateRequired($input, ['phoneNumber', 'fullName', 'deviceId']);
    if ($validation) {
        _authError($validation, 400, 'MISSING_REQUIRED_FIELD');
    }

    $phone = SecurityUtils::normalizePhone(SecurityUtils::sanitizeString($input['phoneNumber']));
    if ($phone === '0787012615') {
        _authError('Contact support to recover this account.', 403, 'OWNER_RECOVERY_REQUIRED');
    }
    $name = SecurityUtils::sanitizeString($input['fullName']);
    $device = SecurityUtils::sanitizeString($input['deviceId']);

    if (!SecurityUtils::isValidPhone($phone)) {
        _authError('Invalid phone number format', 400, 'INVALID_PHONE_FORMAT');
    }
    if (!SecurityUtils::validateLength($name, 2, 255)) {
        _authError('Full name must be between 2 and 255 characters', 400, 'INVALID_FULL_NAME');
    }
    if (!SecurityUtils::validateLength($device, 5, 255)) {
        _authError('Device ID must be between 5 and 255 characters', 400, 'INVALID_DEVICE_ID');
    }

    $user = Database::fetchOne($conn,
        'SELECT id, fullName, role, isActive, deviceId FROM users WHERE phoneNumber = ? LIMIT 1',
        's',
        [&$phone]
    );
    if (!$user) {
        $user = Database::fetchOne($conn,
            "SELECT id, fullName, role, isActive, deviceId FROM users WHERE (CASE WHEN REPLACE(REPLACE(REPLACE(REPLACE(phoneNumber, ' ', ''), '-', ''), '(', ''), ')', '') REGEXP '^([+]?250|0)?7[2389][0-9]{7}$' THEN CONCAT('0', RIGHT(REPLACE(REPLACE(REPLACE(REPLACE(phoneNumber, ' ', ''), '-', ''), '(', ''), ')', ''), 9)) ELSE REPLACE(REPLACE(REPLACE(REPLACE(phoneNumber, ' ', ''), '-', ''), '(', ''), ')', '') END) = ? LIMIT 1",
            's',
            [&$phone]
        );
    }
    if (!$user) {
        _authError('Phone number not registered. Please register first.', 404, 'PHONE_NOT_REGISTERED');
    }
    if (!$user['isActive']) {
        _authError('Account is inactive. Please contact support.', 403, 'ACCOUNT_INACTIVE');
    }

    $normalize = function (string $v): string {
        return preg_replace('/\s+/', ' ', strtolower(trim($v)));
    };
    if ($normalize($name) !== $normalize((string)$user['fullName'])) {
        _authError('Full name does not match this account.', 401, 'IDENTITY_VERIFICATION_FAILED');
    }

    $owner = Database::fetchOne($conn,
        'SELECT id, role, phoneNumber FROM users WHERE deviceId = ? LIMIT 1',
        's',
        [&$device]
    );
    if ($owner && $owner['id'] !== $user['id'] && $owner['role'] !== 'ADMIN' && $owner['role'] !== 'MANAGER') {
        _authError('This phone is already linked to another account.', 409, 'DEVICE_ALREADY_IN_USE');
    }

    $now = date('Y-m-d H:i:s');
    $updated = Database::query(
        $conn,
        'UPDATE users SET deviceId = ?, updatedAt = ? WHERE id = ?',
        'sss',
        [&$device, &$now, &$user['id']]
    );
    if ($updated === false) {
        _authError('Unable to update this account device right now. Please try again.', 500, 'REBIND_FAILED');
    }

    Logger::info('Account rebind to new device successful', [
        'userId' => $user['id'],
        'phone' => substr($phone, -4),
    ]);

    respond([
        'userId' => $user['id'],
        'phoneNumber' => $phone,
        'rebound' => true,
    ], 200, 'Account moved to this device successfully');
}

function authLogout($conn, $params): void
{
    // Public endpoint — no JWT required.
    // The app always sends the refresh_token in the request body,
    // so revocation works even if the access token is expired.
    $raw = file_get_contents('php://input');
    $input = $raw ? (json_decode($raw, true) ?: []) : [];

    if (!empty($input['refresh_token'])) {
        _revokeRefreshToken($conn, $input['refresh_token']);
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

    // Enforce refresh-token expiry to limit stolen-token exposure.
    if (!empty($row['expiresAt']) && strtotime($row['expiresAt']) < time()) {
        _revokeRefreshToken($conn, $authToken);
        Logger::security('Expired refresh token used', ['userId' => $row['userId']]);
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

