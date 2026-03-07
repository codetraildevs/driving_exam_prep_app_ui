<?php

class SecurityUtils
{
    private static $jwtSecret = null;

    public static function init($secret = null)
    {
        self::$jwtSecret = $secret ?: getenv('JWT_SECRET') ?: 'your-secret-key-change-in-production';
    }

    /**
     * Generate JWT Token
     */
    public static function generateToken($data, $expiresIn = 86400)
    {
        if (!self::$jwtSecret) {
            self::init();
        }

        $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
        $payload = json_encode(array_merge($data, [
            'iat' => time(),
            'exp' => time() + $expiresIn
        ]));

        $base64Header = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
        $base64Payload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));
        $signature = hash_hmac('sha256', "$base64Header.$base64Payload", self::$jwtSecret, true);
        $base64Signature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));

        return "$base64Header.$base64Payload.$base64Signature";
    }

    /**
     * Verify and Decode JWT Token
     */
    public static function verifyToken($token)
    {
        if (!self::$jwtSecret) {
            self::init();
        }

        if (!$token || strpos($token, '.') === false) {
            return null;
        }

        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            return null;
        }

        list($base64Header, $base64Payload, $base64Signature) = $parts;

        // Verify signature
        $signature = hash_hmac('sha256', "$base64Header.$base64Payload", self::$jwtSecret, true);
        $base64SignatureVerify = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));

        if ($base64SignatureVerify !== $base64Signature) {
            return null;
        }

        // Decode payload
        $payload = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $base64Payload)), true);

        if (!$payload) {
            return null;
        }

        // Check expiration
        if (isset($payload['exp']) && $payload['exp'] < time()) {
            return null;
        }

        return $payload;
    }

    /**
     * Get JWT from Authorization header.
     *
     * Works across all PHP SAPI configurations:
     *  - Apache with mod_php / getallheaders() (case-insensitive lookup)
     *  - Apache mod_rewrite + PHP-CGI (REDIRECT_HTTP_AUTHORIZATION)
     *  - Nginx / PHP-FPM (HTTP_AUTHORIZATION in $_SERVER)
     */
    public static function getTokenFromHeaders()
    {
        // 1. getallheaders() – normalise to lowercase for case-insensitive match
        if (function_exists('getallheaders')) {
            $headers = array_change_key_case(getallheaders(), CASE_LOWER);
            if (!empty($headers['authorization'])) {
                if (preg_match('/Bearer\s+(\S+)/i', $headers['authorization'], $m)) {
                    return $m[1];
                }
            }
        }

        // 2. $_SERVER fallbacks (CGI / FastCGI / mod_rewrite pass-through)
        foreach (['HTTP_AUTHORIZATION', 'REDIRECT_HTTP_AUTHORIZATION'] as $key) {
            if (!empty($_SERVER[$key])) {
                if (preg_match('/Bearer\s+(\S+)/i', $_SERVER[$key], $m)) {
                    return $m[1];
                }
            }
        }

        return null;
    }

    /**
     * Validate input - check required fields
     */
    public static function validateRequired($data, $required = [])
    {
        foreach ($required as $field) {
            if (!isset($data[$field]) || $data[$field] === '') {
                return "Missing required field: $field";
            }
        }
        return null;
    }

    /**
     * Sanitize string input
     */
    public static function sanitizeString($input)
    {
        return trim(htmlspecialchars($input, ENT_QUOTES, 'UTF-8'));
    }

    /**
     * Sanitize email
     */
    public static function sanitizeEmail($input)
    {
        return strtolower(trim($input));
    }

    /**
     * Validate email format
     */
    public static function isValidEmail($email)
    {
        return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
    }

    /**
     * Validate phone number format (basic)
     */
    public static function isValidPhone($phone)
    {
        // Remove common separators and validate length
        $cleaned = preg_replace('/[^\d+]/', '', $phone);
        return strlen($cleaned) >= 7 && strlen($cleaned) <= 15 && preg_match('/^\+?[\d]{7,15}$/', $cleaned);
    }

    /**
     * Validate input length
     */
    public static function validateLength($input, $min = 1, $max = 255)
    {
        $len = strlen($input);
        return $len >= $min && $len <= $max;
    }

    /**
     * Sanitize UUID
     */
    public static function sanitizeUUID($uuid)
    {
        // UUID v4 format validation: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
        if (preg_match('/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i', $uuid)) {
            return $uuid;
        }
        // Also accept UUID without dashes or other custom ID formats
        if (preg_match('/^[a-zA-Z0-9\-_]{20,}$/', $uuid)) {
            return $uuid;
        }
        return null;
    }

    /**
     * Validate role
     */
    public static function isValidRole($role, $allowed = ['USER', 'MANAGER', 'ADMIN'])
    {
        return in_array($role, $allowed);
    }
}

SecurityUtils::init();
