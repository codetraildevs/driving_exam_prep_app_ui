<?php
// CLI-only regression harness; never deploy tests to production.
if (PHP_SAPI !== 'cli') exit();
$scenario = $argv[1] ?? 'demo';
class Env {
    public static function get($key, $default = null) {
        return $key === 'JWT_SECRET' ? 'test-only-signing-key' : $default;
    }
}
class Logger {
    public static function info($message, $context = []) {}
    public static function warning($message, $context = []) {}
    public static function security($message, $context = []) {}
}
class ErrorHandler {
    public static function badRequest($message) { respond(['message' => $message], 400); }
    public static function unauthorized($message) { respond(['message' => $message], 401); }
}
class TestConnection { public function exec($sql) { return 0; } }
class Database {
    public static function fetchOne($conn, $sql, $types = '', $params = []) {
        global $scenario;
        if (strpos($sql, 'FROM refresh_tokens') !== false) {
            return ['userId' => 'demo-user', 'expiresAt' => '2099-01-01', 'revoked' => 0];
        }
        return ['id' => 'demo-user', 'phoneNumber' => strpos($scenario, 'regular') === 0 ? '0788123456' : '0787012615',
            'fullName' => 'Demo Driver', 'role' => 'USER', 'deviceId' => 'original-device',
            'isActive' => $scenario === 'inactive' ? 0 : 1];
    }
    public static function insert($conn, $sql, $types = '', $params = []) { return 1; }
    public static function query($conn, $sql, $types = '', $params = []) { return 1; }
}
function getInput() {
    global $scenario;
    return ['phoneNumber' => strpos($scenario, 'regular') === 0 ? '0788123456' :
        ($scenario === 'international' ? '+250 787 012 615' : '0787012615'),
        'deviceId' => $scenario === 'regular-same' ? 'original-device' : 'new-device'];
}
function respond($data = [], $status = 200, $message = null) {
    echo json_encode(['status' => $status, 'data' => $data]); exit();
}
require __DIR__ . '/../src/SecurityUtils.php';
require __DIR__ . '/../src/handlers/auth.php';
$conn = new TestConnection();
if (strpos($scenario, 'refresh') === 0) {
    $_SERVER['HTTP_AUTHORIZATION'] = 'Bearer ' . ($scenario === 'refresh-old' ? 'owner.' : '') . str_repeat('a', 64);
    authRefresh($conn, []);
} else {
    authLogin($conn, []);
}
