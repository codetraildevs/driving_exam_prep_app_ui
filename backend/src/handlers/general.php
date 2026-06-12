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
