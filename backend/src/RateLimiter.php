<?php
/**
 * Simple IP-based rate limiter.
 *
 * Uses file-based storage to track request counts per IP per route.
 * Limits are defined per route prefix.
 *
 * Rate limit window: 60 seconds
 * Default limits:
 *   - Auth routes:   10 requests per minute
 *   - Payment routes: 5 requests per minute
 */
class RateLimiter
{
    private static string $storageDir = '';
    private static array $limits = [
        'POST:/api/auth/'     => 10,
        'POST:/api/payments/' => 5,
    ];

    /**
     * Check if the current request is within the rate limit.
     * Calls ErrorHandler::error(429) and exits if exceeded.
     */
    public static function check(string $routeKey): void
    {
        $limit = self::getLimit($routeKey);
        if ($limit <= 0) {
            return; // no limit configured for this route
        }

        $ip = self::getClientIp();
        $now = time();
        $window = 60; // 1 minute sliding window

        $storage = self::getStorage($routeKey, $ip);
        self::cleanExpired($storage, $now - $window);

        // Count requests in current window
        $count = count($storage);
        if ($count >= $limit) {
            $oldest = $storage[0] ?? $now;
            $retryAfter = $window - ($now - $oldest);
            Logger::security('Rate limit exceeded', [
                'routeKey' => $routeKey,
                'ip'       => $ip,
                'limit'    => $limit,
                'count'    => $count,
            ]);

            http_response_code(429);
            header('Retry-After: ' . max(1, $retryAfter));
            echo json_encode([
                'success'     => false,
                'message'     => 'Too many requests. Please try again later.',
                'retryAfter'  => max(1, $retryAfter),
                'code'        => 'RATE_LIMITED',
            ]);
            exit();
        }

        // Record this request
        $storage[] = $now;
        self::saveStorage($routeKey, $ip, $storage);
    }

    private static function getLimit(string $routeKey): int
    {
        foreach (self::$limits as $prefix => $limit) {
            if (strpos($routeKey, $prefix) === 0) {
                return $limit;
            }
        }
        return 0;
    }

    private static function getClientIp(): string
    {
        foreach (['HTTP_X_FORWARDED_FOR', 'HTTP_X_REAL_IP', 'REMOTE_ADDR'] as $key) {
            if (!empty($_SERVER[$key])) {
                $ip = $_SERVER[$key];
                // X-Forwarded-For may contain a comma-separated list
                if (strpos($ip, ',') !== false) {
                    $ip = trim(explode(',', $ip)[0]);
                }
                return $ip;
            }
        }
        return '127.0.0.1';
    }

    private static function getStorageDir(): string
    {
        if (empty(self::$storageDir)) {
            self::$storageDir = __DIR__ . '/../storage/rate_limiter';
            if (!is_dir(self::$storageDir)) {
                @mkdir(self::$storageDir, 0755, true);
            }
        }
        return self::$storageDir;
    }

    private static function getStorageKey(string $routeKey, string $ip): string
    {
        return md5($routeKey . '|' . $ip);
    }

    private static function getStorage(string $routeKey, string $ip): array
    {
        $file = self::getStorageDir() . '/' . self::getStorageKey($routeKey, $ip) . '.json';
        if (!file_exists($file)) {
            return [];
        }
        $data = @file_get_contents($file);
        if ($data === false) {
            return [];
        }
        $decoded = json_decode($data, true);
        return is_array($decoded) ? $decoded : [];
    }

    private static function saveStorage(string $routeKey, string $ip, array $timestamps): void
    {
        $file = self::getStorageDir() . '/' . self::getStorageKey($routeKey, $ip) . '.json';
        @file_put_contents($file, json_encode($timestamps), LOCK_EX);
    }

    private static function cleanExpired(array &$storage, int $cutoff): void
    {
        $storage = array_values(array_filter($storage, fn($ts) => $ts >= $cutoff));
    }

    /**
     * Reset rate limit storage — useful for testing.
     */
    public static function reset(): void
    {
        $dir = self::getStorageDir();
        if (is_dir($dir)) {
            array_map('unlink', glob($dir . '/*.json'));
        }
    }
}
