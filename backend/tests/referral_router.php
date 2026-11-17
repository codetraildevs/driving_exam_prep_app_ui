<?php
if (PHP_SAPI !== 'cli-server' || getenv('REFERRAL_TEST_MODE') !== '1') { http_response_code(404); exit(); }
class Env {
    public static function get($key, $default = null) {
        if ($key === 'JWT_SECRET') return 'referral-test-only-signing-key';
        if ($key === 'REFERRAL_TEST_DB_PORT') return '3306';
        if ($key === 'REFERRAL_TEST_DB_PASSWORD') return '';
        if ($key === 'ANDROID_APP_SIGNING_SHA256') return implode(':', array_fill(0, 32, 'AA'));
        return $default;
    }
}
class Logger {
    public static function error($m, $c = []) {}
    public static function info($m, $c = []) {}
    public static function warning($m, $c = []) {}
    public static function security($m, $c = []) {}
}
require __DIR__ . '/../src/ErrorHandler.php';
require __DIR__ . '/../src/helpers.php';
require __DIR__ . '/../src/SecurityUtils.php';
require __DIR__ . '/../src/Database.php';
require __DIR__ . '/../src/handlers/auth.php';
require __DIR__ . '/../src/handlers/referrals.php';
$port = getenv('REFERRAL_TEST_DB_PORT') ?: '3306';
$password = getenv('REFERRAL_TEST_DB_PASSWORD');
if ($password === false) $password = 'test-password';
$conn = new PDO("mysql:host=127.0.0.1;port=$port;dbname=referral_test;charset=utf8mb4", 'root', $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_EMULATE_PREPARES => false]);
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$tokenData = null;
if ($path === '/api/referrals/me' || strpos($path, '/api/admin/referrals') === 0) {
    $tokenData = SecurityUtils::verifyToken(SecurityUtils::getTokenFromHeaders() ?? '');
    if (!$tokenData) ErrorHandler::unauthorized();
}
foreach (require __DIR__ . '/../src/routes.php' as [$method, $route, $handler]) {
    $params = [];
    if (in_array($handler, ['authRegister','authLogin','referralDashboard','referralLanding','referralAssetLinks','adminReferrals'], true) && $_SERVER['REQUEST_METHOD'] === $method && matchRoute($route, $path, $params)) {
        $handler($conn, $params);
        exit();
    }
}
ErrorHandler::notFound();
