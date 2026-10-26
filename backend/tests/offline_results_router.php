<?php
// Test harness only. Never deploy backend/tests/ to the server.
if (PHP_SAPI !== 'cli-server' || getenv('WHATSAPP_TEST_MODE') !== '1') {
    http_response_code(404);
    exit();
}
class Logger {
    public static function info($message, $context = []) {}
    public static function warning($message, $context = []) {}
    public static function error($message, $context = []) {}
    public static function security($message, $context = []) {}
}
class Env {
    public static function get($key) { return 'production'; }
}
require __DIR__ . '/../src/ErrorHandler.php';
require __DIR__ . '/../src/helpers.php';
require __DIR__ . '/../src/SecurityUtils.php';
require __DIR__ . '/../src/Database.php';
require __DIR__ . '/../src/handlers/exam_results.php';
$role = $_SERVER['HTTP_X_TEST_ROLE'] ?? null;
if (!$role) ErrorHandler::unauthorized();
$tokenData = ['role' => $role, 'userId' => $_SERVER['HTTP_X_TEST_USER'] ?? 'u1'];
$user = $_SERVER['HTTP_X_TEST_DB_USER'] ?? 'root';
if (!in_array($user, ['root', 'wa_crud', 'wa_read'])) exit();
$conn = new PDO('mysql:host=127.0.0.1;dbname=wa_test;charset=utf8mb4',
    $user, 'test-password', [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_EMULATE_PREPARES => false]);
$routes = require __DIR__ . '/../src/routes.php';
foreach ($routes as [$method, $path, $handler]) {
    $params = [];
    if ($handler === 'submitPracticeResult' && $method === $_SERVER['REQUEST_METHOD'] &&
        matchRoute($path, parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH), $params)) {
        submitPracticeResult($conn, $params);
        exit();
    }
}
ErrorHandler::notFound();
