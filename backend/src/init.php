<?php
/**
 * Application bootstrap.
 * Loads environment, sets up error handlers, security headers, CORS,
 * performs authentication, and dispatches routes.
 */

// ---------------------------------------------------------------------------
// 1. Load environment
// ---------------------------------------------------------------------------
require_once __DIR__ . '/Env.php';
Env::load(__DIR__ . '/../.env');

// Composer autoloader (required for Sentry SDK and future packages)
$autoloadPath = __DIR__ . '/../vendor/autoload.php';
if (file_exists($autoloadPath)) {
    require_once $autoloadPath;
}

if (!Env::get('APP_ENV')) {
    $_ENV['APP_ENV'] = 'development';
    $_SERVER['APP_ENV'] = 'development';
}

// ---------------------------------------------------------------------------
// 2. Set error & exception handlers FIRST so loading errors are caught
// ---------------------------------------------------------------------------
require_once __DIR__ . '/Logger.php';
require_once __DIR__ . '/ErrorHandler.php';

set_error_handler(function ($errno, $errstr, $errfile, $errline) {
    static $inError = false;
    if ($inError) return false;
    $inError = true;

    Logger::error("PHP Error: $errstr", ['file' => $errfile, 'line' => $errline]);

    if (class_exists('\\Sentry\\SentrySdk') && \Sentry\SentrySdk::getCurrentHub()->getClient() !== null) {
        \Sentry\captureException(new \ErrorException($errstr, 0, $errno, $errfile, $errline));
    }

    $inError = false;
    ErrorHandler::serverError($errstr);
});

set_exception_handler(function ($exception) {
    static $inException = false;
    if ($inException) {
        http_response_code(500);
        echo '{"success":false,"message":"Fatal error during exception handling"}';
        exit();
    }
    $inException = true;

    $exceptionMsg = $exception->getMessage();
    $exceptionType = get_class($exception);

    Logger::error('Uncaught Exception: ' . $exceptionMsg, [
        'type'  => $exceptionType,
        'file'  => $exception->getFile(),
        'line'  => $exception->getLine(),
        'trace' => $exception->getTraceAsString(),
    ]);

    if (class_exists('\\Sentry\\SentrySdk') && \Sentry\SentrySdk::getCurrentHub()->getClient() !== null) {
        \Sentry\captureException($exception);
    }

    ErrorHandler::serverError($exceptionType . ': ' . $exceptionMsg);
});

// ---------------------------------------------------------------------------
// 3. Load remaining core classes & helpers
// ---------------------------------------------------------------------------
require_once __DIR__ . '/SecurityUtils.php';
require_once __DIR__ . '/Database.php';
require_once __DIR__ . '/RateLimiter.php';
require_once __DIR__ . '/helpers.php';

// ---------------------------------------------------------------------------
// 4. Sentry error monitoring (P0b)
// ---------------------------------------------------------------------------
$sentryDsn = Env::get('SENTRY_DSN', '');
if (!empty($sentryDsn) && class_exists('\\Sentry\\SentrySdk')) {
    \Sentry\init([
        'dsn'         => $sentryDsn,
        'environment' => Env::get('APP_ENV', 'production'),
        'sample_rate' => 1.0,
    ]);
    Logger::info('Sentry error monitoring initialized');
}

// ---------------------------------------------------------------------------
// 5. JWT Secret validation (P0c)
// ---------------------------------------------------------------------------
$jwtSecret = Env::get('JWT_SECRET');
if (empty($jwtSecret) || $jwtSecret === 'your-secret-key-change-in-production') {
    Logger::security('JWT_SECRET is not set or still uses the default value');
    if (Env::get('APP_ENV') === 'production') {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Server configuration error. Contact support.',
        ]);
        exit();
    }
}
set_error_handler(function ($errno, $errstr, $errfile, $errline) {
    static $inError = false;
    if ($inError) return false;
    $inError = true;

    Logger::error("PHP Error: $errstr", ['file' => $errfile, 'line' => $errline]);

    // Report to Sentry if available
    if (class_exists('\\Sentry\\SentrySdk') && \Sentry\SentrySdk::getCurrentHub()->getClient() !== null) {
        \Sentry\captureException(new \ErrorException($errstr, 0, $errno, $errfile, $errline));
    }

    $inError = false;
    // Show the actual PHP error message (not hidden in production)
    ErrorHandler::serverError($errstr);
});

set_exception_handler(function ($exception) {
    static $inException = false;
    if ($inException) {
        http_response_code(500);
        echo '{"success":false,"message":"Fatal error during exception handling"}';
        exit();
    }
    $inException = true;

    $exceptionMsg = $exception->getMessage();
    $exceptionType = get_class($exception);

    Logger::error('Uncaught Exception: ' . $exceptionMsg, [
        'type'  => $exceptionType,
        'file'  => $exception->getFile(),
        'line'  => $exception->getLine(),
        'trace' => $exception->getTraceAsString(),
    ]);

    // Report to Sentry
    if (class_exists('\\Sentry\\SentrySdk') && \Sentry\SentrySdk::getCurrentHub()->getClient() !== null) {
        \Sentry\captureException($exception);
    }

    // Show the actual exception message (not hidden in production)
    ErrorHandler::serverError($exceptionType . ': ' . $exceptionMsg);
});

// ---------------------------------------------------------------------------
// 6. Response headers
// ---------------------------------------------------------------------------
header('Content-Type: application/json');

// Security headers
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('X-XSS-Protection: 1; mode=block');
header('Strict-Transport-Security: max-age=31536000; includeSubDomains');

// CORS
$allowedOrigins = explode(',', Env::get('ALLOWED_ORIGINS') ?: '*');
$origin = $_SERVER['HTTP_ORIGIN'] ?? null;

// Always allow localhost / 127.0.0.1 origins for local development
// (e.g. flutter run -d chrome on port 8000). This check runs before
// the production ALLOWED_ORIGINS whitelist so dev workflows are never
// blocked even if the env var is strictly set for production domains.
$isLocalhost = $origin !== null && preg_match(
    '/^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/i',
    $origin
);

if ($isLocalhost || in_array('*', $allowedOrigins) || in_array($origin, $allowedOrigins)) {
    header('Access-Control-Allow-Origin: ' . ($origin ?: '*'));
    header('Access-Control-Allow-Credentials: true');
}
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS, PATCH');
header('Access-Control-Allow-Headers: Content-Type, Authorization, device-id, X-Requested-With');
header('Access-Control-Max-Age: 86400');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// ---------------------------------------------------------------------------
// 7. Database connection
// ---------------------------------------------------------------------------
$conn = Database::getConnection();

// ---------------------------------------------------------------------------
// 8. Parse request
// ---------------------------------------------------------------------------
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Clean up path for different server setups
$path = str_replace('/backend/public', '', $path);
$path = str_replace('/public', '', $path);
if ($path === '' || $path === '/index.php') {
    $path = '/';
}

// ---------------------------------------------------------------------------
// 9. Public routes (no auth required)
// ---------------------------------------------------------------------------
$publicRoutes = [
    'GET:/',
    'GET:/health',
    'GET:/api/health',
    'POST:/api/auth/register',
    'POST:/api/auth/login',
    'POST:/api/auth/rebind-device',
    'POST:/api/auth/refresh',
    'POST:/api/auth/logout',
    'GET:/api/pricing',
];

$routeKey = "$method:$path";
$isPublicRoute = in_array($routeKey, $publicRoutes, true);

// ---------------------------------------------------------------------------
// 10. Authentication
// ---------------------------------------------------------------------------
$tokenData = null;
if (!$isPublicRoute) {
    $authToken = SecurityUtils::getTokenFromHeaders();
    if (!$authToken) {
        $debugHeaders = [];
        if (function_exists('getallheaders')) {
            $debugHeaders['getallheaders'] = array_keys(array_change_key_case(getallheaders(), CASE_LOWER));
        }
        foreach (['HTTP_AUTHORIZATION', 'REDIRECT_HTTP_AUTHORIZATION', 'REDIRECT_REDIRECT_HTTP_AUTHORIZATION'] as $k) {
            if (isset($_SERVER[$k])) $debugHeaders[$k] = 'present';
        }
        Logger::security('Unauthorized access attempt to protected route', [
            'path'          => $path,
            'method'        => $method,
            'headers_debug' => $debugHeaders,
        ]);
        ErrorHandler::unauthorized('Missing or invalid authorization token');
    }

    $tokenData = SecurityUtils::verifyToken($authToken);
    if (!$tokenData) {
        Logger::security('Invalid token attempt', ['path' => $path, 'method' => $method]);
        ErrorHandler::unauthorized('Invalid or expired token');
    }
}

// ---------------------------------------------------------------------------
// 11. Rate limiting (P0d) — apply to auth + payment endpoints
// ---------------------------------------------------------------------------
$rateLimitedPrefixes = ['POST:/api/auth/', 'POST:/api/payments/'];
foreach ($rateLimitedPrefixes as $prefix) {
    if (strpos($routeKey, $prefix) === 0) {
        RateLimiter::check($routeKey);
        break;
    }
}

// ---------------------------------------------------------------------------
// 12. Load all handler files
// ---------------------------------------------------------------------------
require_once __DIR__ . '/handlers/general.php';
require_once __DIR__ . '/handlers/auth.php';
require_once __DIR__ . '/handlers/exam.php';
require_once __DIR__ . '/handlers/questions.php';
require_once __DIR__ . '/handlers/exam_results.php';
require_once __DIR__ . '/handlers/users.php';
require_once __DIR__ . '/handlers/access_codes.php';
require_once __DIR__ . '/handlers/payments.php';
require_once __DIR__ . '/handlers/admin.php';
require_once __DIR__ . '/handlers/analytics.php';
require_once __DIR__ . '/handlers/pricing.php';
require_once __DIR__ . '/handlers/notifications.php';

// ---------------------------------------------------------------------------
// 13. Route matching & dispatch
// ---------------------------------------------------------------------------
$routes = require __DIR__ . '/routes.php';

$matched = false;
$params  = [];

foreach ($routes as $route) {
    [$route_method, $route_path, $handler] = $route;
    if ($route_method !== $method) continue;

    if (matchRoute($route_path, $path, $params)) {
        $matched = true;
        call_user_func($handler, $conn, $params);
        break;
    }
}

if (!$matched) {
    Logger::warning('Route not found', ['method' => $method, 'path' => $path]);
    ErrorHandler::notFound("Route not found: $method $path");
}
