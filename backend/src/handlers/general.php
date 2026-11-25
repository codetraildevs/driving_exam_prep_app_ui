<?php
/**
 * General route handlers (root, health check).
 */

function rootHandler($conn, $params): void
{
    respond([
        'message'       => 'Welcome to Traffic Rules Practice App API',
        'version'       => '1.0.0',
        'documentation' => '/api/health',
    ], 200);
}

function healthCheck($conn, $params): void
{
    $result = Database::fetchOne($conn, 'SELECT 1');
    if ($result !== null) {
        respond(['status' => 'ok', 'database' => 'connected'], 200);
    } else {
        ErrorHandler::serverError('Database connection error');
    }
}

function resourceFile($conn, $params): void
{
    $allowed = ['Ibyapa.pdf', 'Igazeti.pdf'];
    $name = basename((string) ($params['name'] ?? ''));
    if (!in_array($name, $allowed, true)) {
        http_response_code(404);
        exit;
    }
    $path = API_ROOT . '/../storage/resources/' . $name;
    if (!is_file($path)) {
        http_response_code(404);
        exit;
    }
    header('Content-Type: application/pdf');
    header('Content-Length: ' . filesize($path));
    header('Cache-Control: public, max-age=604800');
    readfile($path);
    exit;
}
