<?php
/**
 * Shared helper functions used by all route handlers.
 */

/**
 * Match a URL pattern (with :param placeholders) against a URI.
 */
function matchRoute($pattern, $uri, &$params): bool
{
    $pattern = preg_replace('/:(\w+)/', '(?P<$1>[^/]+)', $pattern);
    if (preg_match('#^' . $pattern . '$#', $uri, $matches)) {
        $params = array_filter($matches, 'is_string', ARRAY_FILTER_USE_KEY);
        return true;
    }
    return false;
}

/**
 * Send a success JSON response and exit.
 */
function respond($data = [], int $status = 200, ?string $message = null): void
{
    ErrorHandler::respond($data, $status, $message);
}

/**
 * Send an error JSON response and exit.
 */
function error(string $message = 'An error occurred', int $status = 400, $details = null): void
{
    ErrorHandler::error($message, $status, $details);
}

/**
 * Parse JSON request body.
 */
function getInput(): array
{
    $raw = file_get_contents('php://input');
    $data = json_decode($raw, true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        Logger::error('JSON decode error', ['error' => json_last_error_msg()]);
        ErrorHandler::badRequest('Invalid JSON in request body');
    }
    return $data ?: [];
}

/**
 * Convert a relative path to a full URL using the current request scheme + host.
 */
function fullUrl(?string $path): ?string
{
    if (!$path) return null;
    if (preg_match('#^https?://#i', $path)) return $path;
    $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    $host = isset($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : 'localhost';
    if (strpos($path, '/') === 0) {
        return $scheme . '://' . $host . $path;
    }
    return $scheme . '://' . $host . '/' . $path;
}

/**
 * Require the authenticated user to have one of the allowed roles.
 * Calls ErrorHandler::forbidden() and exits if the check fails.
 */
function requireRole(?array $tokenData, array $allowedRoles = ['ADMIN']): void
{
    if (!isset($tokenData['role']) || !in_array($tokenData['role'], $allowedRoles)) {
        Logger::security('Insufficient role for operation', [
            'required' => $allowedRoles,
            'actual'   => $tokenData['role'] ?? 'unknown',
        ]);
        ErrorHandler::forbidden('Insufficient permissions for this operation');
    }
}

/**
 * Generate a UUID v4 string.
 */
function generateUUID(): string
{
    $data = null;
    if (function_exists('random_bytes')) {
        $data = random_bytes(16);
    } elseif (function_exists('openssl_random_pseudo_bytes')) {
        $data = openssl_random_pseudo_bytes(16);
    } else {
        $data = '';
        for ($i = 0; $i < 16; $i++) {
            $data .= chr(mt_rand(0, 255));
        }
    }

    $data[6] = chr(ord($data[6]) & 0x0f | 0x40);
    $data[8] = chr(ord($data[8]) & 0x3f | 0x80);
    return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
}
