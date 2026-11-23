<?php
/**
 * Database-backed rate limiter.
 *
 * Tracks request timestamps per route and client IP in MySQL.
 * Only REMOTE_ADDR is trusted unless the immediate peer is localhost.
 */
class RateLimiter
{
    private static array $limits = [
        'POST:/api/auth/'     => 10,
        'POST:/api/payments/' => 5,
    ];

    public static function check(string $routeKey): void
    {
        $limit = self::getLimit($routeKey);
        if ($limit <= 0) {
            return; // no limit configured for this route
        }

        $ip = self::getClientIp();
        $conn = Database::connect();
        self::ensureTable($conn);

        $window = 60;
        $cutoff = date('Y-m-d H:i:s', time() - $window);

        // Remove expired entries for this route/IP.
        Database::query(
            $conn,
            'DELETE FROM rate_limits WHERE routeKey = ? AND clientIp = ? AND requestedAt < ?',
            '',
            [$routeKey, $ip, $cutoff]
        );

        $row = Database::fetchOne(
            $conn,
            'SELECT COUNT(*) AS requestCount, MIN(requestedAt) AS oldestRequest FROM rate_limits WHERE routeKey = ? AND clientIp = ? AND requestedAt >= ?',
            '',
            [$routeKey, $ip, $cutoff]
        );

        $count = (int) ($row['requestCount'] ?? 0);
        if ($count >= $limit) {
            $oldest = $row['oldestRequest'] ?? null;
            $retryAfter = $window;
            if ($oldest) {
                $retryAfter = $window - (time() - strtotime($oldest));
            }

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

        Database::insert(
            $conn,
            'INSERT INTO rate_limits (routeKey, clientIp, requestedAt) VALUES (?, ?, NOW())',
            '',
            [$routeKey, $ip]
        );
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
        $remoteAddr = $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1';

        // Only trust forwarded headers when the immediate peer is local.
        if (in_array($remoteAddr, ['127.0.0.1', '::1'], true)) {
            foreach (['HTTP_X_FORWARDED_FOR', 'HTTP_X_REAL_IP'] as $key) {
                if (!empty($_SERVER[$key])) {
                    $ip = trim(explode(',', $_SERVER[$key])[0]);
                    if (filter_var($ip, FILTER_VALIDATE_IP)) {
                        return $ip;
                    }
                }
            }
        }

        return $remoteAddr;
    }

    private static function ensureTable(PDO $conn): void
    {
        $conn->exec('
            CREATE TABLE IF NOT EXISTS rate_limits (
                id INT AUTO_INCREMENT PRIMARY KEY,
                routeKey VARCHAR(128) NOT NULL,
                clientIp VARCHAR(45) NOT NULL,
                requestedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                KEY idx_rate_limits_lookup (routeKey, clientIp, requestedAt)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
        ');
    }

    public static function reset(): void
    {
        $conn = Database::connect();
        self::ensureTable($conn);
        Database::query($conn, 'DELETE FROM rate_limits', '', []);
    }
}