<?php

// Load environment vars from .env file
$envFile = __DIR__ . '/../.env';
if (file_exists($envFile)) {
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos($line, '=') !== false && strpos($line, '#') !== 0) {
            list($key, $value) = explode('=', $line, 2);
            putenv(trim($key) . '=' . trim($value));
        }
    }
}

// Set application environment
if (!getenv('APP_ENV')) {
    putenv('APP_ENV=development');
}

// Load utility classes
require_once __DIR__ . '/../src/Logger.php';
require_once __DIR__ . '/../src/ErrorHandler.php';
require_once __DIR__ . '/../src/SecurityUtils.php';
require_once __DIR__ . '/../src/Database.php';

// Set error handler
set_error_handler(function ($errno, $errstr, $errfile, $errline) {
    Logger::error("PHP Error: $errstr", ['file' => $errfile, 'line' => $errline]);
    if (getenv('APP_ENV') !== 'production') {
        ErrorHandler::serverError($errstr);
    } else {
        ErrorHandler::serverError('An error occurred');
    }
});

// Headers - Content Type
header('Content-Type: application/json');

// Security Headers
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('X-XSS-Protection: 1; mode=block');
header('Strict-Transport-Security: max-age=31536000; includeSubDomains');

// CORS - Allow specific origins in production
$allowedOrigins = explode(',', getenv('ALLOWED_ORIGINS') ?: '*');
$origin = $_SERVER['HTTP_ORIGIN'] ?? null;

if (in_array('*', $allowedOrigins) || in_array($origin, $allowedOrigins)) {
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

// Get connection
$conn = Database::getConnection();

// Public routes that don't require authentication
$publicRoutes = [
    'GET:/',
    'GET:/health',
    'GET:/api/health',
    'POST:/api/auth/register',
    'POST:/api/auth/login',
    'GET:/api/pricing',
];

// Parse request
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Clean up path - handle different server setups
$path = str_replace('/backend/public', '', $path);
$path = str_replace('/public', '', $path);
if ($path === '' || $path === '/index.php') {
    $path = '/';
}

// Check if this is a protected route and validate token
$routeKey = "$method:$path";
$isPublicRoute = false;
foreach ($publicRoutes as $pubRoute) {
    if ($pubRoute === $routeKey || (strpos($pubRoute, ':') && strpos($path, substr($pubRoute, strpos($pubRoute, ':') + 1)) === 0)) {
        $isPublicRoute = true;
        break;
    }
}

$tokenData = null;
if (!$isPublicRoute) {
    $authToken = SecurityUtils::getTokenFromHeaders();
    if (!$authToken) {
        Logger::security('Unauthorized access attempt to protected route', ['path' => $path, 'method' => $method]);
        ErrorHandler::unauthorized('Missing or invalid authorization token');
    }
    
    $tokenData = SecurityUtils::verifyToken($authToken);
    if (!$tokenData) {
        Logger::security('Invalid token attempt', ['path' => $path, 'method' => $method]);
        ErrorHandler::unauthorized('Invalid or expired token');
    }
}

// Route matching
$routes = [
    // Health & Root
    ['GET', '/', 'rootHandler'],
    ['GET', '/health', 'healthCheck'],
    ['GET', '/api/health', 'healthCheck'],
    
    // Auth
    ['POST', '/api/auth/register', 'authRegister'],
    ['POST', '/api/auth/login', 'authLogin'],
    ['POST', '/api/auth/logout', 'authLogout'],
    
    // Users
    ['GET', '/api/users/:id', 'getUser'],
    ['GET', '/api/users', 'listUsers'],
    ['PUT', '/api/users/:id', 'updateUser'],
    ['DELETE', '/api/users/:id', 'deleteUser'],
    
    // Exams
    ['GET', '/api/exams', 'getExams'],
    // stats endpoint must be declared before the generic /api/exams/:id route, otherwise "stats"
    // will be treated as an exam id and result in a 404 from getExam.
    ['GET', '/api/exams/stats', 'getExamStats'],
    ['GET', '/api/exams/:id', 'getExam'],
    // user-side "take exam" (requires access or free)
    ['GET', '/api/exams/:id/take-exam', 'getExamQuestionsForTaking'],
    // admin/manager operations
    ['POST', '/api/exams', 'createExam'],
    ['PUT', '/api/exams/:id', 'updateExam'],
    ['PATCH', '/api/exams/:id/activate', 'activateExam'],
    ['PATCH', '/api/exams/:id/deactivate', 'deactivateExam'],
    ['PUT', '/api/exams/:id/toggle-status', 'toggleExamStatus'],
    ['DELETE', '/api/exams/:id', 'deleteExam'],
    // analytics
    ['GET', '/api/exams/:examId/analytics', 'getExamAnalytics'],
    ['GET', '/api/exams/stats', 'getExamStats'],
    
    // Questions
    ['GET', '/api/questions', 'getQuestions'],
    ['GET', '/api/questions/:id', 'getQuestion'],
    ['GET', '/api/exams/:examId/questions', 'getExamQuestions'],
    ['POST', '/api/questions', 'createQuestion'],
    ['PUT', '/api/questions/:id', 'updateQuestion'],
    
    // Exam Results
    ['POST', '/api/exam-results', 'submitExamResult'],
    ['GET', '/api/exam-results/:userId', 'getUserResults'],
    ['GET', '/api/exam-results', 'getAllResults'],
    
    // Access Codes
    ['POST', '/api/access-codes/verify', 'verifyAccessCode'],
    // status must be declared before the generic /api/access-codes route
    ['GET', '/api/access-codes/status', 'getAccessCodeStatus'],
    ['GET', '/api/access-codes', 'listAccessCodes'],
    ['POST', '/api/access-codes', 'generateAccessCode'],
    ['PATCH', '/api/access-codes/:id/block', 'blockAccessCode'],
    ['DELETE', '/api/access-codes/:id', 'deleteAccessCode'],
    
    // Courses
    ['GET', '/api/courses', 'getCourses'],
    ['GET', '/api/courses/:id', 'getCourse'],
    ['POST', '/api/courses', 'createCourse'],
    
    // Payments
    ['POST', '/api/payments/request', 'requestPayment'],
    ['GET', '/api/payments', 'listPayments'],
    
    // Pricing plans (public)
    ['GET', '/api/pricing', 'getPricingPlans'],
    
    // Admin user management
    ['GET', '/api/admin/users', 'adminListUsers'],
    ['PATCH', '/api/admin/users/:userId/block', 'adminBlockUser'],
    ['DELETE', '/api/admin/users/:userId', 'adminDeleteUser'],
    ['POST', '/api/admin/users/:userId/grant-access', 'adminGrantAccess'],
    ['POST', '/api/admin/users/:userId/mark-called', 'adminMarkCalled'],
    
    // Analytics
    ['GET', '/api/analytics/stats', 'getAnalytics'],
    
    // Notifications
    ['GET', '/api/notifications', 'getNotifications'],
    ['POST', '/api/notifications', 'createNotification'],
];

$matched = false;
$params = [];

foreach ($routes as [$route_method, $route_path, $handler]) {
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

// ===== HELPERS =====

function matchRoute($pattern, $uri, &$params) {
    $pattern = preg_replace('/:(\w+)/', '(?P<$1>[^/]+)', $pattern);
    if (preg_match('#^' . $pattern . '$#', $uri, $matches)) {
        $params = array_filter($matches, 'is_string', ARRAY_FILTER_USE_KEY);
        return true;
    }
    return false;
}

function respond($data = [], $status = 200, $message = null) {
    ErrorHandler::respond($data, $status, $message);
}

function error($message = 'An error occurred', $status = 400, $details = null) {
    ErrorHandler::error($message, $status, $details);
}

function getInput() {
    $raw = file_get_contents('php://input');
    $data = json_decode($raw, true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        Logger::error('JSON decode error', ['error' => json_last_error_msg()]);
        ErrorHandler::badRequest('Invalid JSON in request body');
    }
    return $data ?: [];
}

function fullUrl($path) {
    if (!$path) return null;
    if (preg_match('#^https?://#i', $path)) return $path;
    $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
    if (strpos($path, '/') === 0) {
        return $scheme . '://' . $host . $path;
    }
    return $scheme . '://' . $host . '/' . $path;
}

function requireRole($tokenData, $allowedRoles = ['ADMIN']) {
    if (!isset($tokenData['role']) || !in_array($tokenData['role'], $allowedRoles)) {
        Logger::security('Insufficient role for operation', ['required' => $allowedRoles, 'actual' => $tokenData['role'] ?? 'unknown']);
        ErrorHandler::forbidden('Insufficient permissions for this operation');
    }
}

function generateUUID() {
    // Generate a v4 UUID
    $data = random_bytes(16);
    $data[6] = chr(ord($data[6]) & 0x0f | 0x40);
    $data[8] = chr(ord($data[8]) & 0x3f | 0x80);
    return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
}

// ===== MAIN HANDLERS =====

function rootHandler($conn, $params) {
    respond([
        'message' => 'Welcome to Traffic Rules Practice App API',
        'version' => '1.0.0',
        'documentation' => '/api/health'
    ], 200);
}

function healthCheck($conn, $params) {
    $result = Database::fetchOne($conn, 'SELECT 1');
    if ($result !== null) {
        respond(['status' => 'ok', 'database' => 'connected'], 200);
    } else {
        ErrorHandler::serverError('Database connection error');
    }
}

// ===== AUTH =====

function authRegister($conn, $params) {
    $input = getInput();
    
    // Validate required fields
    $validation = SecurityUtils::validateRequired($input, ['phoneNumber', 'fullName', 'deviceId']);
    if ($validation) {
        ErrorHandler::badRequest($validation);
    }
    
    // Sanitize and validate inputs
    $phone = SecurityUtils::sanitizeString($input['phoneNumber']);
    if (!SecurityUtils::isValidPhone($phone)) {
        ErrorHandler::badRequest('Invalid phone number format');
    }
    
    $name = SecurityUtils::sanitizeString($input['fullName']);
    if (!SecurityUtils::validateLength($name, 2, 255)) {
        ErrorHandler::badRequest('Full name must be between 2 and 255 characters');
    }
    
    $device = SecurityUtils::sanitizeString($input['deviceId']);
    if (!SecurityUtils::validateLength($device, 5, 255)) {
        ErrorHandler::badRequest('Device ID must be between 5 and 255 characters');
    }
    
    $role = $input['role'] ?? 'USER';
    if (!SecurityUtils::isValidRole($role)) {
        $role = 'USER';
    }
    
    // Check existing phone
    $existing = Database::fetchOne($conn, 'SELECT id, deviceId FROM users WHERE phoneNumber = ? LIMIT 1', 's', [&$phone]);
    if ($existing) {
        if ($existing['deviceId'] === $device) {
            Logger::info('Registration attempt with existing phone on same device', ['phone' => substr($phone, -4)]);
            ErrorHandler::conflict('Phone already registered on this device. Please login instead.');
        } else {
            Logger::warning('Phone registered on different device', ['phone' => substr($phone, -4)]);
            ErrorHandler::conflict('Phone is registered on a different device. Please use that device or contact support.');
        }
    }

    // Check existing device
    $existingDevice = Database::fetchOne($conn, 'SELECT id, phoneNumber FROM users WHERE deviceId = ? LIMIT 1', 's', [&$device]);
    if ($existingDevice) {
        Logger::warning('Device already registered', ['device' => substr($device, -4)]);
        ErrorHandler::conflict('This device is already registered. Please login or use a different device.');
    }
    
    $id = generateUUID();
    $now = date('Y-m-d H:i:s');
    
    $result = Database::insert($conn, 
        'INSERT INTO users (id, fullName, phoneNumber, deviceId, role, isActive, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, 1, ?, ?)',
        'sssssss',
        [&$id, &$name, &$phone, &$device, &$role, &$now, &$now]
    );
    
    if ($result !== null) {
        $token = SecurityUtils::generateToken([
            'userId' => $id,
            'phoneNumber' => $phone,
            'role' => $role
        ]);

        Logger::info('User registered successfully', ['userId' => $id]);
        respond([
            'id' => $id,
            'phoneNumber' => $phone,
            'fullName' => $name,
            'role' => $role,
            'token' => $token
        ], 201, 'User registered');
    } else {
        Logger::error('User registration failed', ['phone' => substr($phone, -4)]);
        ErrorHandler::serverError('Registration failed');
    }
}

function authLogin($conn, $params) {
    $input = getInput();
    
    // Validate input
    $validation = SecurityUtils::validateRequired($input, ['phoneNumber']);
    if ($validation) {
        ErrorHandler::badRequest($validation);
    }
    
    $phone = SecurityUtils::sanitizeString($input['phoneNumber']);
    if (!SecurityUtils::isValidPhone($phone)) {
        Logger::warning('Login attempt with invalid phone format', ['phone' => substr($phone, -4)]);
        ErrorHandler::badRequest('Invalid phone number format');
    }
    
    $device = isset($input['deviceId']) ? SecurityUtils::sanitizeString($input['deviceId']) : null;
    
    $user = Database::fetchOne($conn, 
        'SELECT id, phoneNumber, fullName, role, deviceId, isActive FROM users WHERE phoneNumber = ? LIMIT 1',
        's',
        [&$phone]
    );
    
    if (!$user) {
        Logger::warning('Login attempt with non-existent user', ['phone' => substr($phone, -4)]);
        ErrorHandler::unauthorized('Invalid phone or password');
    }
    
    // Check if account is active
    if (!$user['isActive']) {
        Logger::security('Login attempt on inactive account', ['userId' => $user['id']]);
        ErrorHandler::forbidden('Account is inactive. Please contact support.');
    }
    
    // Device binding logic: ADMIN can login from any device, USER must use registered device
    if ($user['role'] === 'USER') {
        // USER role: enforce device binding (1 device = 1 phone = 1 account)
        if (!$device) {
            Logger::warning('USER login without deviceId', ['userId' => $user['id']]);
            ErrorHandler::badRequest('Device ID is required for user login');
        }
        if ($user['deviceId'] !== $device) {
            Logger::security('Login device mismatch', ['userId' => $user['id'], 'expected' => substr($user['deviceId'], -4), 'provided' => substr($device, -4)]);
            ErrorHandler::unauthorized('Device not registered for this account');
        }
    } else {
        // ADMIN/MANAGER can login from any device, but we can still log it
        if ($device) {
            Logger::info('Admin login from device', ['userId' => $user['id']]);
        }
    }
    
    // Generate JWT token
    $token = SecurityUtils::generateToken([
        'userId' => $user['id'],
        'phoneNumber' => $user['phoneNumber'],
        'role' => $user['role']
    ]);
    
    Logger::info('User login successful', ['userId' => $user['id'], 'role' => $user['role']]);
    
    respond([
        'id' => $user['id'],
        'phoneNumber' => $user['phoneNumber'],
        'fullName' => $user['fullName'],
        'role' => $user['role'],
        'token' => $token
    ], 200, 'Login successful');
}

function authLogout($conn, $params) {
    // Token is already validated by middleware
    // In a real system, you'd invalidate the token here
    Logger::info('User logout');
    respond(['message' => 'Logged out successfully'], 200);
}

// ===== EXAMS =====

function getExams($conn, $params) {
    // Support optional exam type filter via query string
    $examType = isset($_GET['examType']) ? SecurityUtils::sanitizeString($_GET['examType']) : null;
    
    if ($examType) {
        $exams = Database::fetchAll($conn,
            'SELECT c.id, c.title, c.description, c.category, c.difficulty, c.courseType as examType, c.courseImageUrl as examImgUrl, c.isActive, (SELECT COUNT(*) FROM course_contents cc WHERE cc.courseId = c.id) as questionCount FROM courses c WHERE isActive = 1 AND courseType = ? ORDER BY c.createdAt DESC',
            's',
            [&$examType]
        );
    } else {
        $exams = Database::fetchAll($conn,
            'SELECT c.id, c.title, c.description, c.category, c.difficulty, c.courseType as examType, c.courseImageUrl as examImgUrl, c.isActive, (SELECT COUNT(*) FROM course_contents cc WHERE cc.courseId = c.id) as questionCount FROM courses c WHERE isActive = 1 ORDER BY c.createdAt DESC',
            '',
            []
        );
    }

    if ($exams === null) {
        ErrorHandler::serverError('Failed to fetch exams');
    }

    foreach ($exams as &$exam) {
        $exam['examImgUrl'] = fullUrl($exam['examImgUrl']);
    }
    respond($exams, 200);
}

function getExam($conn, $params) {
    $id = SecurityUtils::sanitizeString($params['id']);
    if (!$id) {
        ErrorHandler::badRequest('Invalid exam ID');
    }
    
    $exam = Database::fetchOne($conn,
        'SELECT c.id, c.title, c.description, c.category, c.difficulty, c.courseType as examType, c.courseImageUrl as examImgUrl, c.isActive, (SELECT COUNT(*) FROM course_contents cc WHERE cc.courseId = c.id) as questionCount FROM courses c WHERE c.id = ? LIMIT 1',
        's',
        [&$id]
    );
    
    if (!$exam) {
        Logger::warning('Exam not found', ['examId' => $id]);
        ErrorHandler::notFound('Exam not found');
    }
    
    $exam['examImgUrl'] = fullUrl($exam['examImgUrl']);
    respond($exam, 200);
}

function activateExam($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN','MANAGER']);
    
    $id = SecurityUtils::sanitizeString($params['id']);
    if (!$id) {
        ErrorHandler::badRequest('Invalid exam ID');
    }
    
    $now = date('Y-m-d H:i:s');
    $affected = Database::query($conn,
        'UPDATE courses SET isActive = 1, updatedAt = ? WHERE id = ?',
        'ss',
        [&$now, &$id]
    );
    
    if ($affected === false) {
        ErrorHandler::serverError('Failed to activate exam');
    }
    if ($affected === 0) {
        ErrorHandler::notFound('Exam not found');
    }
    
    Logger::info('Exam activated', ['examId' => $id, 'userId' => $tokenData['userId']]);
    respond(['id' => $id], 200, 'Exam activated');
}

function deactivateExam($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN','MANAGER']);
    
    $id = SecurityUtils::sanitizeString($params['id']);
    if (!$id) {
        ErrorHandler::badRequest('Invalid exam ID');
    }
    
    $now = date('Y-m-d H:i:s');
    $affected = Database::query($conn,
        'UPDATE courses SET isActive = 0, updatedAt = ? WHERE id = ?',
        'ss',
        [&$now, &$id]
    );
    
    if ($affected === false) {
        ErrorHandler::serverError('Failed to deactivate exam');
    }
    if ($affected === 0) {
        ErrorHandler::notFound('Exam not found');
    }
    
    Logger::info('Exam deactivated', ['examId' => $id, 'userId' => $tokenData['userId']]);
    respond(['id' => $id], 200, 'Exam deactivated');
}

function toggleExamStatus($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN','MANAGER']);
    
    $id = SecurityUtils::sanitizeString($params['id']);
    if (!$id) {
        ErrorHandler::badRequest('Invalid exam ID');
    }
    
    $exam = Database::fetchOne($conn,
        'SELECT isActive FROM courses WHERE id = ? LIMIT 1',
        's',
        [&$id]
    );
    
    if (!$exam) {
        ErrorHandler::notFound('Exam not found');
    }
    
    $new = $exam['isActive'] ? 0 : 1;
    $now = date('Y-m-d H:i:s');
    
    $affected = Database::query($conn,
        'UPDATE courses SET isActive = ?, updatedAt = ? WHERE id = ?',
        'iss',
        [&$new, &$now, &$id]
    );
    
    if ($affected === false) {
        ErrorHandler::serverError('Failed to toggle exam status');
    }
    
    Logger::info('Exam status toggled', ['examId' => $id, 'newStatus' => $new, 'userId' => $tokenData['userId']]);
    respond(['id' => $id, 'isActive' => (bool)$new], 200, 'Status toggled');
}

function createExam($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN','MANAGER']);
    
    $input = getInput();
    
    // Validate required fields
    $validation = SecurityUtils::validateRequired($input, ['title', 'description', 'category', 'difficulty']);
    if ($validation) {
        ErrorHandler::badRequest($validation);
    }
    
    // Sanitize and validate inputs
    $title = SecurityUtils::sanitizeString($input['title']);
    if (!SecurityUtils::validateLength($title, 3, 255)) {
        ErrorHandler::badRequest('Title must be between 3 and 255 characters');
    }
    
    $desc = SecurityUtils::sanitizeString($input['description'] ?? '');
    if (!SecurityUtils::validateLength($desc, 0, 1000)) {
        ErrorHandler::badRequest('Description must not exceed 1000 characters');
    }
    
    $cat = SecurityUtils::sanitizeString($input['category']);
    if (!SecurityUtils::validateLength($cat, 2, 100)) {
        ErrorHandler::badRequest('Category must be between 2 and 100 characters');
    }
    
    $diff = SecurityUtils::sanitizeString($input['difficulty']);
    if (!SecurityUtils::validateLength($diff, 2, 50)) {
        ErrorHandler::badRequest('Difficulty must be between 2 and 50 characters');
    }
    
    $courseType = SecurityUtils::sanitizeString($input['courseType'] ?? 'free');
    $examType = strtolower(SecurityUtils::sanitizeString($input['examType'] ?? 'english'));
    $validExamTypes = ['kinyarwanda', 'english', 'french'];
    if (!in_array($examType, $validExamTypes)) {
        $examType = 'english';
    }
    
    $img = SecurityUtils::sanitizeString($input['imageUrl'] ?? '');
    $id = 'exam_' . generateUUID();
    $now = date('Y-m-d H:i:s');
    
    $result = Database::insert($conn,
        'INSERT INTO courses (id, title, description, category, difficulty, courseType, examType, courseImageUrl, isActive, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)',
        'sssssssss',
        [&$id, &$title, &$desc, &$cat, &$diff, &$courseType, &$examType, &$img, &$now, &$now]
    );
    
    if ($result) {
        Logger::info('Exam created', ['examId' => $id, 'userId' => $tokenData['userId']]);
        respond(['id' => $id], 201, 'Exam created');
    } else {
        Logger::error('Failed to create exam', ['userId' => $tokenData['userId']]);
        ErrorHandler::serverError('Failed to create exam');
    }
}

function updateExam($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN','MANAGER']);
    
    $id = SecurityUtils::sanitizeString($params['id']);
    if (!$id) {
        ErrorHandler::badRequest('Invalid exam ID');
    }
    
    $input = getInput();
    
    // Validate exam exists
    $exam = Database::fetchOne($conn, 'SELECT id FROM courses WHERE id = ? LIMIT 1', 's', [&$id]);
    if (!$exam) {
        ErrorHandler::notFound('Exam not found');
    }
    
    if (empty($input)) {
        ErrorHandler::badRequest('No fields to update');
    }
    
    // Build update query dynamically with prepared statements
    $updates = [];
    $types = '';
    $values = [];
    
    foreach (['title', 'description', 'category', 'difficulty', 'courseType', 'isActive', 'examType'] as $field) {
        if (isset($input[$field])) {
            $val = SecurityUtils::sanitizeString((string)$input[$field]);
            
            // Validate specific fields
            if ($field === 'title' && !SecurityUtils::validateLength($val, 3, 255)) {
                ErrorHandler::badRequest('Title must be between 3 and 255 characters');
            }
            if ($field === 'examType') {
                $valid = ['kinyarwanda', 'english', 'french'];
                $val = in_array(strtolower($val), $valid) ? strtolower($val) : 'english';
            }
            
            $updates[] = "$field = ?";
            $values[] = $val;
            $types .= 's';
        }
    }
    
    if (empty($updates)) {
        ErrorHandler::badRequest('No valid fields to update');
    }
    
    $now = date('Y-m-d H:i:s');
    $updates[] = 'updatedAt = ?';
    $values[] = $now;
    $types .= 's';
    $values[] = $id;
    $types .= 's';
    
    $sql = 'UPDATE courses SET ' . implode(', ', $updates) . ' WHERE id = ?';
    
    // Since we need dynamic prepared statements, we use execute
    $stmt = Database::execute($conn, $sql, $types, $values);
    
    if (!$stmt) {
        Logger::error('Failed to update exam', ['examId' => $id, 'userId' => $tokenData['userId']]);
        ErrorHandler::serverError('Failed to update exam');
    }
    
    Logger::info('Exam updated', ['examId' => $id, 'userId' => $tokenData['userId']]);
    respond(['id' => $id], 200, 'Exam updated');
}

function deleteExam($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN','MANAGER']);
    
    $id = SecurityUtils::sanitizeString($params['id']);
    if (!$id) {
        ErrorHandler::badRequest('Invalid exam ID');
    }
    
    $affected = Database::query($conn, 'DELETE FROM courses WHERE id = ?', 's', [&$id]);
    
    if ($affected === false) {
        ErrorHandler::serverError('Failed to delete exam');
    }
    if ($affected === 0) {
        ErrorHandler::notFound('Exam not found');
    }
    
    Logger::info('Exam deleted', ['examId' => $id, 'userId' => $tokenData['userId']]);
    respond([], 200, 'Exam deleted');
}

// ===== QUESTIONS =====

function getQuestions($conn, $params) {
    $questions = Database::fetchAll($conn,
        'SELECT id, courseId, contentType, content, title, displayOrder FROM course_contents ORDER BY displayOrder ASC',
        '',
        []
    );
    
    if ($questions === null) {
        ErrorHandler::serverError('Failed to fetch questions');
    }
    
    respond($questions, 200);
}

function getQuestion($conn, $params) {
    $id = SecurityUtils::sanitizeString($params['id']);
    if (!$id) {
        ErrorHandler::badRequest('Invalid question ID');
    }
    
    $question = Database::fetchOne($conn,
        'SELECT id, courseId, contentType, content, title FROM course_contents WHERE id = ? LIMIT 1',
        's',
        [&$id]
    );
    
    if (!$question) {
        ErrorHandler::notFound('Question not found');
    }
    
    respond($question, 200);
}

function getExamQuestions($conn, $params) {
    $examId = SecurityUtils::sanitizeString($params['examId']);
    if (!$examId) {
        ErrorHandler::badRequest('Invalid exam ID');
    }
    
    $page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
    $limit = isset($_GET['limit']) ? max(1, min(intval($_GET['limit']), 100)) : 50;
    $offset = ($page - 1) * $limit;

    // Verify exam exists
    $exam = Database::fetchOne($conn, 'SELECT id, courseType FROM courses WHERE id = ? LIMIT 1', 's', [&$examId]);
    if (!$exam) {
        ErrorHandler::notFound('Exam not found');
    }

    // Fetch questions with pagination
    $questions = Database::fetchAll($conn,
        'SELECT id, courseId, contentType, content, title, displayOrder FROM course_contents WHERE courseId = ? ORDER BY displayOrder ASC LIMIT ? OFFSET ?',
        'sii',
        [&$examId, &$limit, &$offset]
    );
    
    if ($questions === null) {
        ErrorHandler::serverError('Failed to fetch exam questions');
    }

    respond($questions, 200);
}

function getExamQuestionsForTaking($conn, $params) {
    // Get exam and verify it exists and user has access
    $examId = SecurityUtils::sanitizeString($params['id']);
    if (!$examId) {
        ErrorHandler::badRequest('Invalid exam ID');
    }

    // Verify exam exists
    $exam = Database::fetchOne($conn, 'SELECT id, courseType FROM courses WHERE id = ? LIMIT 1', 's', [&$examId]);
    if (!$exam) {
        ErrorHandler::notFound('Exam not found');
    }
    
    // Access control for paid exams
    if ($exam['courseType'] !== 'free') {
        if (!isset($_GET['userId'])) {
            ErrorHandler::forbidden('User ID required to access this exam');
        }
        
        $userId = SecurityUtils::sanitizeString($_GET['userId']);
        $now = date('Y-m-d H:i:s');
        
        $accessCode = Database::fetchOne($conn,
            'SELECT id FROM access_codes WHERE userId = ? AND isUsed = 0 AND expiresAt > ? LIMIT 1',
            'ss',
            [&$userId, &$now]
        );
        
        if (!$accessCode) {
            Logger::warning('Unauthorized exam access attempt', ['examId' => $examId, 'userId' => $userId]);
            ErrorHandler::forbidden('You do not have access to this exam. Please purchase an access code.');
        }
    }
    
    $page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
    $limit = isset($_GET['limit']) ? max(1, min(intval($_GET['limit']), 100)) : 50;
    $offset = ($page - 1) * $limit;

    // Fetch questions for taking
    $questions = Database::fetchAll($conn,
        'SELECT id, courseId, contentType, content, title, displayOrder, option1, option2, option3, option4, correctAnswer, points, questionImgUrl FROM course_contents WHERE courseId = ? ORDER BY displayOrder ASC LIMIT ? OFFSET ?',
        'sii',
        [&$examId, &$limit, &$offset]
    );
    
    if ($questions === null) {
        ErrorHandler::serverError('Failed to fetch exam questions');
    }
    
    respond(['questions' => $questions, 'pagination' => ['page' => $page, 'limit' => $limit]], 200);
}

function createQuestion($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN','MANAGER']);
    
    $input = getInput();
    
    $validation = SecurityUtils::validateRequired($input, ['courseId', 'content', 'contentType']);
    if ($validation) {
        ErrorHandler::badRequest($validation);
    }
    
    $courseId = SecurityUtils::sanitizeString($input['courseId']);
    $content = SecurityUtils::sanitizeString($input['content']);
    $contentType = SecurityUtils::sanitizeString($input['contentType']);
    $title = SecurityUtils::sanitizeString($input['title'] ?? '');
    $order = intval($input['displayOrder'] ?? 0);
    
    // Validate course exists
    $course = Database::fetchOne($conn, 'SELECT id FROM courses WHERE id = ? LIMIT 1', 's', [&$courseId]);
    if (!$course) {
        ErrorHandler::badRequest('Invalid course ID');
    }
    
    $id = 'q_' . generateUUID();
    $now = date('Y-m-d H:i:s');
    
    $result = Database::insert($conn,
        'INSERT INTO course_contents (id, courseId, content, contentType, title, displayOrder, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        'ssssiss',
        [&$id, &$courseId, &$content, &$contentType, &$title, &$order, &$now, &$now]
    );
    
    if ($result) {
        Logger::info('Question created', ['questionId' => $id, 'courseId' => $courseId, 'userId' => $tokenData['userId']]);
        respond(['id' => $id], 201, 'Question created');
    } else {
        Logger::error('Failed to create question', ['courseId' => $courseId]);
        ErrorHandler::serverError('Failed to create question');
    }
}

function updateQuestion($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN','MANAGER']);
    
    $id = SecurityUtils::sanitizeString($params['id']);
    if (!$id) {
        ErrorHandler::badRequest('Invalid question ID');
    }
    
    $input = getInput();
    
    // Verify question exists
    $question = Database::fetchOne($conn, 'SELECT id FROM course_contents WHERE id = ? LIMIT 1', 's', [&$id]);
    if (!$question) {
        ErrorHandler::notFound('Question not found');
    }
    
    if (empty($input)) {
        ErrorHandler::badRequest('No fields to update');
    }
    
    $updates = [];
    $types = '';
    $values = [];
    
    foreach (['courseId', 'content', 'contentType', 'title'] as $field) {
        if (isset($input[$field])) {
            $val = SecurityUtils::sanitizeString((string)$input[$field]);
            $updates[] = "$field = ?";
            $values[] = $val;
            $types .= 's';
        }
    }
    
    if (empty($updates)) {
        ErrorHandler::badRequest('No valid fields to update');
    }
    
    $now = date('Y-m-d H:i:s');
    $updates[] = 'updatedAt = ?';
    $values[] = $now;
    $types .= 's';
    $values[] = $id;
    $types .= 's';
    
    $sql = 'UPDATE course_contents SET ' . implode(', ', $updates) . ' WHERE id = ?';
    $stmt = Database::execute($conn, $sql, $types, $values);
    
    if (!$stmt) {
        Logger::error('Failed to update question', ['questionId' => $id]);
        ErrorHandler::serverError('Failed to update question');
    }
    
    Logger::info('Question updated', ['questionId' => $id, 'userId' => $tokenData['userId']]);
    respond(['id' => $id], 200, 'Question updated');
}

// ===== EXAM RESULTS =====

// ===== EXAM RESULTS =====

function submitExamResult($conn, $params) {
    $input = getInput();
    
    $validation = SecurityUtils::validateRequired($input, ['userId', 'examId', 'answers']);
    if ($validation) {
        ErrorHandler::badRequest($validation);
    }
    
    $userId = SecurityUtils::sanitizeString($input['userId']);
    $examId = SecurityUtils::sanitizeString($input['examId']);
    $answers = $input['answers'];
    if (!is_array($answers)) {
        ErrorHandler::badRequest('Answers must be an object/map');
    }
    $timeSpent = intval($input['timeSpent'] ?? 0);
    
    $now = date('Y-m-d H:i:s');

    // Look up exam/course for access and type
    $exam = Database::fetchOne($conn, 'SELECT id, courseType FROM courses WHERE id = ? LIMIT 1', 's', [&$examId]);
    if (!$exam) {
        ErrorHandler::notFound('Exam not found');
    }

    $isFreeExam = ($exam['courseType'] === 'free') ? 1 : 0;
    $accessUsedId = null;
    
    if (!$isFreeExam) {
        $accessCode = isset($input['accessCode']) ? SecurityUtils::sanitizeString($input['accessCode']) : null;
        
        if ($accessCode) {
            $ac = Database::fetchOne($conn,
                'SELECT id FROM access_codes WHERE code = ? AND isUsed = 0 AND expiresAt > ? LIMIT 1',
                'ss',
                [&$accessCode, &$now]
            );
        } else {
            $ac = Database::fetchOne($conn,
                'SELECT id FROM access_codes WHERE userId = ? AND isUsed = 0 AND expiresAt > ? LIMIT 1',
                'ss',
                [&$userId, &$now]
            );
        }
        
        if (!$ac) {
            Logger::warning('Access denied for paid exam submission', ['examId' => $examId, 'userId' => $userId]);
            ErrorHandler::forbidden('You do not have access to this exam');
        }
        $accessUsedId = $ac['id'];
    }

    // Load questions
    $questions = Database::fetchAll($conn,
        'SELECT id, content AS question, option1, option2, option3, option4, correctAnswer, points, questionImgUrl FROM course_contents WHERE courseId = ?',
        's',
        [&$examId]
    );
    
    if ($questions === null) {
        ErrorHandler::serverError('Failed to load exam questions');
    }

    $totalQuestions = count($questions);
    $correctAnswers = 0;
    $questionResults = [];
    
    foreach ($questions as $q) {
        $qid = $q['id'];
        $userAnswer = isset($answers[$qid]) ? $answers[$qid] : null;
        $isCorrect = $userAnswer !== null && $userAnswer === $q['correctAnswer'];
        if ($isCorrect) {
            $correctAnswers++;
        }
        $questionResults[] = [
            'questionId' => $qid,
            'questionText' => $q['question'],
            'options' => ['a' => $q['option1'], 'b' => $q['option2'], 'c' => $q['option3'], 'd' => $q['option4']],
            'userAnswer' => $userAnswer,
            'correctAnswer' => $q['correctAnswer'],
            'isCorrect' => $isCorrect,
            'points' => $isCorrect ? intval($q['points'] ?? 1) : 0,
            'questionImgUrl' => $q['questionImgUrl']
        ];
    }
    
    $score = $totalQuestions > 0 ? round($correctAnswers / $totalQuestions * 100) : 0;
    $passed = $score >= 60 ? 1 : 0;

    $answersJson = json_encode($answers);
    $qresJson = json_encode($questionResults);
    $id = generateUUID();

    $result = Database::insert($conn,
        'INSERT INTO exam_results (id, userId, examId, score, totalQuestions, correctAnswers, timeSpent, answers, passed, completedAt, isFreeExam, createdAt, updatedAt, questionResults) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        'sssiiiisisiiss',
        [&$id, &$userId, &$examId, &$score, &$totalQuestions, &$correctAnswers, &$timeSpent, &$answersJson, &$passed, &$now, &$isFreeExam, &$now, &$now, &$qresJson]
    );
    
    if (!$result) {
        Logger::error('Failed to save exam result', ['userId' => $userId, 'examId' => $examId]);
        ErrorHandler::serverError('Failed to save exam result');
    }

    if ($accessUsedId) {
        Database::query($conn,
            'UPDATE access_codes SET isUsed = 1, usedAt = ? WHERE id = ?',
            'ss',
            [&$now, &$accessUsedId]
        );
    }

    Logger::info('Exam submitted', ['resultId' => $id, 'userId' => $userId, 'examId' => $examId, 'score' => $score]);
    respond(['id' => $id, 'score' => $score, 'passed' => (bool)$passed], 201, 'Exam submitted');
}

function getUserResults($conn, $params) {
    global $tokenData;
    
    if (!$tokenData || !isset($tokenData['userId']) || !isset($tokenData['role'])) {
        ErrorHandler::unauthorized('Invalid or missing token data');
    }
    
    $userId = SecurityUtils::sanitizeString($params['userId']);
    if (!$userId) {
        ErrorHandler::badRequest('Invalid user ID');
    }
    
    // Only allow users to view their own results, unless they're admin
    if ($tokenData['userId'] !== $userId && $tokenData['role'] !== 'ADMIN') {
        Logger::security('Unauthorized attempt to view another user\'s results', ['requestedUserId' => $userId, 'actualUserId' => $tokenData['userId']]);
        ErrorHandler::forbidden('You can only view your own exam results');
    }
    
    $results = Database::fetchAll($conn,
        'SELECT id, userId, examId, score, passed, createdAt FROM exam_results WHERE userId = ? ORDER BY createdAt DESC LIMIT 100',
        's',
        [&$userId]
    );
    
    if ($results === null) {
        ErrorHandler::serverError('Failed to fetch user results');
    }
    
    respond($results, 200);
}

function getAllResults($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN','MANAGER']);
    
    $results = Database::fetchAll($conn,
        'SELECT id, userId, examId, score, passed, createdAt FROM exam_results ORDER BY createdAt DESC LIMIT 100',
        '',
        []
    );
    
    if ($results === null) {
        ErrorHandler::serverError('Failed to fetch results');
    }
    
    respond($results, 200);
}

// ===== USERS =====

function getUser($conn, $params) {
    $id = SecurityUtils::sanitizeString($params['id']);
    if (!$id) {
        ErrorHandler::badRequest('Invalid user ID');
    }
    
    $user = Database::fetchOne($conn,
        'SELECT id, phoneNumber, fullName, role, isActive, createdAt FROM users WHERE id = ? LIMIT 1',
        's',
        [&$id]
    );
    
    if (!$user) {
        ErrorHandler::notFound('User not found');
    }
    
    respond($user, 200);
}

function listUsers($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN','MANAGER']);
    
    $users = Database::fetchAll($conn,
        'SELECT id, phoneNumber, fullName, role, isActive, createdAt FROM users ORDER BY createdAt DESC LIMIT 100',
        '',
        []
    );
    
    if ($users === null) {
        ErrorHandler::serverError('Failed to fetch users');
    }
    
    respond($users, 200);
}

function updateUser($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN','MANAGER']);
    
    $id = SecurityUtils::sanitizeString($params['id']);
    if (!$id) {
        ErrorHandler::badRequest('Invalid user ID');
    }
    
    $input = getInput();
    
    // Verify user exists
    $user = Database::fetchOne($conn, 'SELECT id FROM users WHERE id = ? LIMIT 1', 's', [&$id]);
    if (!$user) {
        ErrorHandler::notFound('User not found');
    }
    
    if (empty($input)) {
        ErrorHandler::badRequest('No fields to update');
    }
    
    $updates = [];
    $types = '';
    $values = [];
    
    $allowedFields = [
        'fullName', 'role', 'isActive',
        'preferredLanguage', 'lastCalledAt', 'lastCalledBy', 'callNotes',
    ];
    
    foreach ($allowedFields as $field) {
        if (isset($input[$field])) {
            $val = SecurityUtils::sanitizeString((string)$input[$field]);
            
            // Validate role if being updated
            if ($field === 'role' && !SecurityUtils::isValidRole($val)) {
                ErrorHandler::badRequest('Invalid role value');
            }
            
            $updates[] = "$field = ?";
            $values[] = $val;
            $types .= 's';
        }
    }
    
    if (empty($updates)) {
        ErrorHandler::badRequest('No valid fields to update');
    }
    
    $now = date('Y-m-d H:i:s');
    $updates[] = 'updatedAt = ?';
    $values[] = $now;
    $types .= 's';
    $values[] = $id;
    $types .= 's';
    
    $sql = 'UPDATE users SET ' . implode(', ', $updates) . ' WHERE id = ?';
    $stmt = Database::execute($conn, $sql, $types, $values);
    
    if (!$stmt) {
        Logger::error('Failed to update user', ['userId' => $id]);
        ErrorHandler::serverError('Failed to update user');
    }
    
    Logger::info('User updated', ['userId' => $id, 'adminId' => $tokenData['userId']]);
    respond(['id' => $id], 200, 'User updated');
}

function deleteUser($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN']);
    
    $id = SecurityUtils::sanitizeString($params['id']);
    if (!$id) {
        ErrorHandler::badRequest('Invalid user ID');
    }
    
    $affected = Database::query($conn, 'DELETE FROM users WHERE id = ?', 's', [&$id]);
    
    if ($affected === false) {
        ErrorHandler::serverError('Failed to delete user');
    }
    if ($affected === 0) {
        ErrorHandler::notFound('User not found');
    }
    
    Logger::info('User deleted', ['userId' => $id, 'adminId' => $tokenData['userId']]);
    respond([], 200, 'User deleted');
}

// ===== ACCESS CODES =====

function verifyAccessCode($conn, $params) {
    $input = getInput();
    
    $validation = SecurityUtils::validateRequired($input, ['code', 'userId']);
    if ($validation) {
        ErrorHandler::badRequest($validation);
    }
    
    $code = SecurityUtils::sanitizeString($input['code']);
    $userId = SecurityUtils::sanitizeString($input['userId']);
    
    $accessCode = Database::fetchOne($conn,
        'SELECT id, code, isUsed, expiresAt FROM access_codes WHERE code = ? AND isUsed = 0 LIMIT 1',
        's',
        [&$code]
    );
    
    if (!$accessCode) {
        Logger::warning('Invalid access code attempt', ['userId' => $userId]);
        ErrorHandler::notFound('Invalid or expired access code');
    }
    
    if (strtotime($accessCode['expiresAt']) < time()) {
        Logger::warning('Expired access code attempt', ['userId' => $userId]);
        ErrorHandler::badRequest('Access code has expired');
    }
    
    $now = date('Y-m-d H:i:s');
    Database::query($conn,
        'UPDATE access_codes SET isUsed = 1, usedAt = ? WHERE code = ?',
        'ss',
        [&$now, &$code]
    );
    
    Logger::info('Access code verified', ['userId' => $userId, 'code' => substr($code, -4)]);
    respond(['message' => 'Access code verified', 'code' => $code], 200);
}

function listAccessCodes($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN','MANAGER']);

    $page      = max(1, intval($_GET['page']   ?? 1));
    $limit     = max(1, min(100, intval($_GET['limit'] ?? 10)));
    $offset    = ($page - 1) * $limit;
    $sortDir   = (strtoupper($_GET['sortDir'] ?? 'DESC') === 'ASC') ? 'ASC' : 'DESC';
    $dateFrom  = SecurityUtils::sanitizeString($_GET['dateFrom'] ?? '');
    $dateTo    = SecurityUtils::sanitizeString($_GET['dateTo']   ?? '');
    $todayOnly = ($_GET['today'] ?? '') === '1';
    $isBlocked = isset($_GET['isBlocked']) ? $_GET['isBlocked'] : null;

    $conditions = [];
    $bindTypes  = '';
    $bindValues = [];

    if ($todayOnly) {
        $conditions[] = 'DATE(ac.createdAt) = CURDATE()';
    } elseif (!empty($dateFrom) && !empty($dateTo)) {
        $conditions[] = 'ac.createdAt BETWEEN ? AND ?';
        $bindTypes  .= 'ss';
        $bindValues[] = $dateFrom . ' 00:00:00';
        $bindValues[] = $dateTo   . ' 23:59:59';
    } elseif (!empty($dateFrom)) {
        $conditions[] = 'ac.createdAt >= ?';
        $bindTypes  .= 's';
        $bindValues[] = $dateFrom . ' 00:00:00';
    }

    if ($isBlocked === 'true' || $isBlocked === '1') {
        $conditions[] = '(ac.isUsed = 1 OR ac.expiresAt <= NOW())';
    } elseif ($isBlocked === 'false' || $isBlocked === '0') {
        $conditions[] = '(ac.isUsed = 0 AND ac.expiresAt > NOW())';
    }

    $where = empty($conditions) ? '' : 'WHERE ' . implode(' AND ', $conditions);

    $countSql = "SELECT COUNT(*) as total FROM access_codes ac $where";
    if (!empty($bindValues)) {
        $countRefs = [];
        foreach ($bindValues as $k => &$v) { $countRefs[] = &$v; }
        unset($v);
        $countRow = Database::fetchOne($conn, $countSql, $bindTypes, $countRefs);
    } else {
        $countRow = Database::fetchOne($conn, $countSql);
    }
    $total = $countRow ? intval($countRow['total']) : 0;

    $pageSql = "SELECT ac.id, ac.code, ac.userId, ac.isUsed, ac.expiresAt, ac.createdAt,
                       ac.paymentTier, ac.paymentAmount, ac.durationDays,
                       ac.generatedByManagerId,
                       u.fullName as userName, u.phoneNumber as userPhone,
                       CASE WHEN ac.isUsed = 1 OR ac.expiresAt <= NOW() THEN 1 ELSE 0 END as isBlocked
                FROM access_codes ac
                LEFT JOIN users u ON u.id = ac.userId
                $where
                ORDER BY ac.createdAt $sortDir
                LIMIT ? OFFSET ?";

    $pageTypes  = $bindTypes . 'ii';
    $pageValues = $bindValues;
    $pageValues[] = $limit;
    $pageValues[] = $offset;

    $pageRefs = [];
    foreach ($pageValues as $k => &$v) { $pageRefs[] = &$v; }
    unset($v);

    $codes = Database::fetchAll($conn, $pageSql, $pageTypes, $pageRefs);

    respond([
        'codes' => $codes ?: [],
        'total' => $total,
        'page'  => $page,
        'limit' => $limit,
    ], 200);
}

function blockAccessCode($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $id = SecurityUtils::sanitizeString($params['id'] ?? '');
    if (!$id) ErrorHandler::badRequest('Invalid access code ID');

    $code = Database::fetchOne($conn, 'SELECT id FROM access_codes WHERE id = ? LIMIT 1', 's', [&$id]);
    if (!$code) ErrorHandler::notFound('Access code not found');

    $now = date('Y-m-d H:i:s');
    $affected = Database::query($conn,
        'UPDATE access_codes SET isUsed = 1, expiresAt = ?, updatedAt = ? WHERE id = ?',
        'sss', [&$now, &$now, &$id]
    );

    if ($affected === false) ErrorHandler::serverError('Failed to block access code');

    Logger::info('Access code blocked', ['codeId' => $id, 'adminId' => $tokenData['userId']]);
    respond(['id' => $id, 'blocked' => true], 200, 'Access code blocked');
}

function deleteAccessCode($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $id = SecurityUtils::sanitizeString($params['id'] ?? '');
    if (!$id) ErrorHandler::badRequest('Invalid access code ID');

    $affected = Database::query($conn, 'DELETE FROM access_codes WHERE id = ?', 's', [&$id]);

    if ($affected === false) ErrorHandler::serverError('Failed to delete access code');
    if ($affected === 0) ErrorHandler::notFound('Access code not found');

    Logger::info('Access code deleted', ['codeId' => $id, 'adminId' => $tokenData['userId']]);
    respond([], 200, 'Access code deleted');
}

function generateAccessCode($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN','MANAGER']);
    
    $input = getInput();
    
    $validation = SecurityUtils::validateRequired($input, ['userId']);
    if ($validation) {
        ErrorHandler::badRequest($validation);
    }
    
    $userId = SecurityUtils::sanitizeString($input['userId']);
    $days = intval($input['durationDays'] ?? 30);
    
    if ($days < 1 || $days > 365) {
        ErrorHandler::badRequest('Duration must be between 1 and 365 days');
    }
    
    $id = 'code_' . generateUUID();
    $code = strtoupper(substr(md5(uniqid(random_bytes(16), true)), 0, 12));
    $expiresAt = date('Y-m-d H:i:s', strtotime("+$days days"));
    $now = date('Y-m-d H:i:s');
    
    $result = Database::insert($conn,
        'INSERT INTO access_codes (id, code, userId, expiresAt, isUsed, createdAt, updatedAt) VALUES (?, ?, ?, ?, 0, ?, ?)',
        'ssssss',
        [&$id, &$code, &$userId, &$expiresAt, &$now, &$now]
    );
    
    if ($result) {
        Logger::info('Access code generated', ['codeId' => $id, 'userId' => $userId, 'createdBy' => $tokenData['userId']]);
        respond(['id' => $id, 'code' => $code, 'expiresAt' => $expiresAt], 201, 'Access code generated');
    } else {
        Logger::error('Failed to generate access code', ['userId' => $userId]);
        ErrorHandler::serverError('Failed to generate access code');
    }
}

// ===== COURSES =====

function getCourses($conn, $params) {
    $courses = Database::fetchAll($conn,
        'SELECT id, title, description, category, difficulty, courseType, courseImageUrl, isActive FROM courses ORDER BY createdAt DESC',
        '',
        []
    );
    
    if ($courses === null) {
        ErrorHandler::serverError('Failed to fetch courses');
    }
    
    foreach ($courses as &$course) {
        $course['courseImageUrl'] = fullUrl($course['courseImageUrl']);
    }
    
    respond($courses, 200);
}

function getCourse($conn, $params) {
    $id = SecurityUtils::sanitizeString($params['id']);
    if (!$id) {
        ErrorHandler::badRequest('Invalid course ID');
    }
    
    $course = Database::fetchOne($conn,
        'SELECT id, title, description, category, difficulty, courseType, courseImageUrl FROM courses WHERE id = ? LIMIT 1',
        's',
        [&$id]
    );
    
    if (!$course) {
        ErrorHandler::notFound('Course not found');
    }
    
    $course['courseImageUrl'] = fullUrl($course['courseImageUrl']);
    respond($course, 200);
}

function createCourse($conn, $params) {
    // Courses and exams are the same in this system
    return createExam($conn, $params);
}

// ===== PAYMENTS =====

function requestPayment($conn, $params) {
    global $tokenData;
    
    $input = getInput();
    Logger::info('Payment request received', ['input' => json_encode($input), 'tokenUserId' => $tokenData['userId'] ?? 'unknown']);
    
    $validation = SecurityUtils::validateRequired($input, ['userId', 'amount']);
    if ($validation) {
        Logger::error('Payment validation failed', ['error' => $validation, 'input' => json_encode($input)]);
        ErrorHandler::badRequest($validation);
    }
    
    $userId = SecurityUtils::sanitizeString($input['userId']);
    $examId = isset($input['examId']) ? SecurityUtils::sanitizeString($input['examId']) : '';
    $amount = floatval($input['amount']);
    $method = SecurityUtils::sanitizeString($input['paymentMethod'] ?? 'mobile_money');
    $paymentTier = SecurityUtils::sanitizeString($input['paymentTier'] ?? '');
    
    if ($amount <= 0 || $amount > 100000) {
        Logger::error('Payment amount out of range', ['amount' => $amount, 'userId' => $userId]);
        ErrorHandler::badRequest('Amount must be between 0.01 and 100000');
    }
    
    // If examId provided, verify it exists
    if ($examId) {
        $exam = Database::fetchOne($conn, 'SELECT id FROM courses WHERE id = ? LIMIT 1', 's', [&$examId]);
        if (!$exam) {
            Logger::error('Invalid exam ID in payment', ['examId' => $examId, 'userId' => $userId]);
            ErrorHandler::badRequest('Invalid exam ID');
        }
    }

    // Prevent duplicate pending requests for the same user
    $existing = Database::fetchOne(
        $conn,
        'SELECT id FROM payment_requests WHERE userId = ? AND status = ? LIMIT 1',
        'ss',
        [&$userId, 'PENDING']
    );
    if ($existing) {
        Logger::info('Duplicate payment request blocked', ['userId' => $userId]);
        http_response_code(409);
        echo json_encode([
            'success' => false,
            'message' => 'A payment request is already pending for your account. Please wait for activation or pay manually: MoMo Pay 323294 / Mobile Money 0788657595 / Help: 0788657595',
            'code'    => 'DUPLICATE_REQUEST',
        ]);
        exit;
    }
    
    // Check for duplicate pending request for same tier
    if (!empty($paymentTier)) {
        $existing = Database::fetchOne($conn,
            'SELECT id FROM payment_requests WHERE userId = ? AND paymentMethod = ? AND status = ? ORDER BY createdAt DESC LIMIT 1',
            'sss',
            [&$userId, &$paymentTier, 'PENDING']
        );
        if ($existing) {
            Logger::info('Duplicate payment request blocked', ['userId' => $userId, 'tier' => $paymentTier, 'existingId' => $existing['id']]);
            http_response_code(409);
            echo json_encode([
                'success' => false,
                'message' => 'A payment request for this plan is already pending. Please wait for confirmation or contact support: MoMo Pay 323294 / Mobile Money 0788657595 / Help: 0788657595',
                'code'    => 'DUPLICATE_TIER_REQUEST',
                'id'      => $existing['id'],
            ]);
            exit;
        }
    }
    
    $id = 'pay_' . generateUUID();
    $now = date('Y-m-d H:i:s');
    $status = 'PENDING';
    
    // Store paymentTier in paymentMethod field for tracking
    $methodWithTier = !empty($paymentTier) ? $paymentTier : $method;
    
    $result = Database::insert($conn,
        'INSERT INTO payment_requests (id, userId, examId, amount, paymentMethod, status, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        'sssdssss',
        [&$id, &$userId, &$examId, &$amount, &$methodWithTier, &$status, &$now, &$now]
    );
    
    if ($result) {
        Logger::info('Payment request created', ['paymentId' => $id, 'userId' => $userId, 'amount' => $amount, 'tier' => $paymentTier]);
        respond(['id' => $id, 'amount' => $amount, 'status' => 'PENDING', 'tier' => $paymentTier], 201, 'Payment request created successfully');
    } else {
        Logger::error('Failed to create payment request', ['userId' => $userId, 'amount' => $amount, 'tier' => $paymentTier, 'mysqlError' => $conn->error]);
        ErrorHandler::serverError('Failed to create payment request. Please try again.');
    }
}

function listPayments($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN','MANAGER']);
    
    $payments = Database::fetchAll($conn,
        'SELECT id, userId, examId, amount, paymentMethod, status, createdAt FROM payment_requests ORDER BY createdAt DESC LIMIT 100',
        '',
        []
    );
    
    if ($payments === null) {
        ErrorHandler::serverError('Failed to fetch payments');
    }
    
    respond($payments, 200);
}

// ===== ANALYTICS =====

function getAnalytics($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN','MANAGER']);
    
    $userCount = Database::fetchOne($conn, 'SELECT COUNT(*) as count FROM users', '', []);
    $examCount = Database::fetchOne($conn, 'SELECT COUNT(*) as count FROM courses', '', []);
    $resultCount = Database::fetchOne($conn, 'SELECT COUNT(*) as count FROM exam_results', '', []);
    
    respond([
        'totalUsers' => intval($userCount['count'] ?? 0),
        'totalExams' => intval($examCount['count'] ?? 0),
        'totalResults' => intval($resultCount['count'] ?? 0),
        'timestamp' => date('Y-m-d H:i:s')
    ], 200);
}

function getExamAnalytics($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN','MANAGER']);
    
    $examId = SecurityUtils::sanitizeString($params['examId']);
    if (!$examId) {
        ErrorHandler::badRequest('Invalid exam ID');
    }
    
    $days = isset($_GET['days']) ? intval($_GET['days']) : 30;
    if ($days < 1 || $days > 365) {
        ErrorHandler::badRequest('Days must be between 1 and 365');
    }
    
    $startDate = date('Y-m-d H:i:s', strtotime("-$days days"));
    
    $exam = Database::fetchOne($conn,
        'SELECT id, title, category, difficulty FROM courses WHERE id = ? LIMIT 1',
        's',
        [&$examId]
    );
    
    if (!$exam) {
        ErrorHandler::notFound('Exam not found');
    }
    
    $stats = Database::fetchOne($conn,
        'SELECT COUNT(*) as total, AVG(score) as avgScore, SUM(passed) as passes FROM exam_results WHERE examId = ? AND completedAt >= ?',
        'ss',
        [&$examId, &$startDate]
    );
    
    if (!$stats) {
        $stats = ['total' => 0, 'avgScore' => 0, 'passes' => 0];
    }
    
    respond(['exam' => $exam, 'stats' => $stats], 200);
}

function getExamStats($conn, $params) {
    $stats = Database::fetchAll($conn,
        'SELECT c.id, c.title, c.category, c.difficulty, (SELECT COUNT(*) FROM course_contents cc WHERE cc.courseId = c.id) as questionCount FROM courses c WHERE c.isActive = 1',
        '',
        []
    );
    
    if ($stats === null) {
        ErrorHandler::serverError('Failed to fetch statistics');
    }
    
    respond($stats, 200);
}

// ===== NOTIFICATIONS =====

function getNotifications($conn, $params) {
    global $tokenData;
    
    // Stub endpoint for notifications
    respond(['message' => 'Notifications endpoint', 'userId' => $tokenData['userId']], 200);
}

function createNotification($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN','MANAGER']);
    
    // Stub endpoint for creating notifications
    respond(['message' => 'Notification created'], 201);
}


// ===== ACCESS CODE STATUS =====

function getAccessCodeStatus($conn, $params) {
    global $tokenData;
    
    $userId = SecurityUtils::sanitizeString($_GET['userId'] ?? '');
    if (!$userId) {
        $userId = $tokenData['userId'];
    }
    
    $row = Database::fetchOne(
        $conn,
        'SELECT code, expiresAt, paymentTier, paymentAmount FROM access_codes WHERE userId = ? AND expiresAt > NOW() ORDER BY createdAt DESC LIMIT 1',
        's',
        [&$userId]
    );
    
    if ($row) {
        respond([
            'hasActiveAccess' => true,
            'expiresAt'       => $row['expiresAt'],
            'paymentTier'     => $row['paymentTier'],
            'code'            => $row['code'],
        ], 200);
    } else {
        respond(['hasActiveAccess' => false], 200);
    }
}

// ===== PRICING PLANS =====

function getPricingPlans($conn, $params) {
    $language = SecurityUtils::sanitizeString($_GET['language'] ?? 'rw');
    
    if ($language === 'rw') {
        $plans = [
            ['tier' => '1_MONTH',  'durationDays' => 30,  'price' => 1500,  'label' => '1 Month'],
            ['tier' => '3_MONTHS', 'durationDays' => 90,  'price' => 3000,  'label' => '3 Months'],
            ['tier' => '6_MONTHS', 'durationDays' => 180, 'price' => 5000,  'label' => '6 Months'],
        ];
    } else {
        $plans = [
            ['tier' => '1_MONTH',  'durationDays' => 30,  'price' => 3000,  'label' => '1 Month'],
            ['tier' => '3_MONTHS', 'durationDays' => 90,  'price' => 5000,  'label' => '3 Months'],
            ['tier' => '6_MONTHS', 'durationDays' => 180, 'price' => 10000, 'label' => '6 Months'],
        ];
    }
    
    respond([
        'language' => $language,
        'currency' => 'RWF',
        'plans'    => $plans,
    ], 200);
}

// ===== ADMIN USER MANAGEMENT =====

function adminListUsers($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $page      = max(1, intval($_GET['page']   ?? 1));
    $limit     = max(1, min(100, intval($_GET['limit'] ?? 10)));
    $offset    = ($page - 1) * $limit;
    $search    = SecurityUtils::sanitizeString($_GET['search']    ?? '');
    $hasAccess = $_GET['hasAccess'] ?? null;
    $language  = SecurityUtils::sanitizeString($_GET['language']  ?? '');
    $role      = SecurityUtils::sanitizeString($_GET['role']      ?? '');
    $sortDir   = (strtoupper($_GET['sortDir'] ?? 'DESC') === 'ASC') ? 'ASC' : 'DESC';
    $dateFrom  = SecurityUtils::sanitizeString($_GET['dateFrom']  ?? '');
    $dateTo    = SecurityUtils::sanitizeString($_GET['dateTo']    ?? '');
    $todayOnly = ($_GET['today'] ?? '') === '1';

    $conditions = [];
    $bindTypes  = '';
    $bindValues = [];

    if (!empty($search)) {
        $conditions[] = '(u.fullName LIKE ? OR u.phoneNumber LIKE ?)';
        $like = '%' . $search . '%';
        $bindTypes  .= 'ss';
        $bindValues[] = $like;
        $bindValues[] = $like;
    }

    if ($hasAccess === 'true' || $hasAccess === '1') {
        $conditions[] = 'ac.expiresAt > NOW()';
    } elseif ($hasAccess === 'false' || $hasAccess === '0') {
        $conditions[] = '(ac.expiresAt IS NULL OR ac.expiresAt <= NOW())';
    }

    if (!empty($language)) {
        $conditions[] = 'u.preferredLanguage = ?';
        $bindTypes  .= 's';
        $bindValues[] = $language;
    }

    if (!empty($role)) {
        $conditions[] = 'u.role = ?';
        $bindTypes  .= 's';
        $bindValues[] = strtoupper($role);
    }

    if ($todayOnly) {
        $conditions[] = 'DATE(u.createdAt) = CURDATE()';
    } elseif (!empty($dateFrom) && !empty($dateTo)) {
        $conditions[] = 'u.createdAt BETWEEN ? AND ?';
        $bindTypes  .= 'ss';
        $bindValues[] = $dateFrom . ' 00:00:00';
        $bindValues[] = $dateTo   . ' 23:59:59';
    } elseif (!empty($dateFrom)) {
        $conditions[] = 'u.createdAt >= ?';
        $bindTypes  .= 's';
        $bindValues[] = $dateFrom . ' 00:00:00';
    }

    $where = empty($conditions) ? '' : 'WHERE ' . implode(' AND ', $conditions);

    $joinSql = 'LEFT JOIN (
        SELECT ac1.* FROM access_codes ac1
        INNER JOIN (
            SELECT userId, MAX(createdAt) as maxCreated
            FROM access_codes
            GROUP BY userId
        ) ac2 ON ac1.userId = ac2.userId AND ac1.createdAt = ac2.maxCreated
    ) ac ON u.id = ac.userId';

    // Count total
    $countSql = "SELECT COUNT(*) as total FROM users u $joinSql $where";
    if (!empty($bindValues)) {
        $countRefs = [];
        foreach ($bindValues as $k => &$v) { $countRefs[] = &$v; }
        unset($v);
        $countRow = Database::fetchOne($conn, $countSql, $bindTypes, $countRefs);
    } else {
        $countRow = Database::fetchOne($conn, $countSql);
    }
    $total = $countRow ? intval($countRow['total']) : 0;

    // Fetch page with LIMIT/OFFSET
    $pageSql = "SELECT u.id, u.fullName, u.phoneNumber, u.role, u.isActive,
                       u.preferredLanguage, u.lastCalledAt, u.lastCalledBy, u.callNotes, u.createdAt,
                       ac.code as accessCode, ac.expiresAt as accessExpiresAt,
                       ac.paymentTier, ac.paymentAmount,
                       CASE WHEN ac.expiresAt > NOW() THEN 1 ELSE 0 END as hasActiveAccess
                FROM users u
                $joinSql
                $where
                ORDER BY u.createdAt $sortDir
                LIMIT ? OFFSET ?";

    $pageTypes  = $bindTypes . 'ii';
    $pageValues = $bindValues;
    $pageValues[] = $limit;
    $pageValues[] = $offset;

    $pageRefs = [];
    foreach ($pageValues as $k => &$v) { $pageRefs[] = &$v; }
    unset($v);

    $rows = Database::fetchAll($conn, $pageSql, $pageTypes, $pageRefs);

    respond([
        'users' => $rows ?: [],
        'total' => $total,
        'page'  => $page,
        'limit' => $limit,
    ], 200);
}

function adminBlockUser($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $userId = SecurityUtils::sanitizeString($params['userId'] ?? '');
    if (!$userId) ErrorHandler::badRequest('Invalid user ID');

    $user = Database::fetchOne($conn, 'SELECT id, isActive FROM users WHERE id = ? LIMIT 1', 's', [&$userId]);
    if (!$user) ErrorHandler::notFound('User not found');

    $input     = getInput();
    $isActive  = isset($input['isActive']) ? (intval($input['isActive']) ? 1 : 0) : 0;
    $now       = date('Y-m-d H:i:s');

    Database::query($conn, 'UPDATE users SET isActive = ?, updatedAt = ? WHERE id = ?', 'iss', [&$isActive, &$now, &$userId]);

    $status = $isActive ? 'unblocked' : 'blocked';
    Logger::info("User $status", ['userId' => $userId, 'adminId' => $tokenData['userId']]);
    respond(['id' => $userId, 'isActive' => $isActive], 200, "User $status successfully");
}

function adminDeleteUser($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN']);

    $userId = SecurityUtils::sanitizeString($params['userId'] ?? '');
    if (!$userId) ErrorHandler::badRequest('Invalid user ID');

    $user = Database::fetchOne($conn, 'SELECT id, isActive FROM users WHERE id = ? LIMIT 1', 's', [&$userId]);
    if (!$user) ErrorHandler::notFound('User not found');

    // Must be blocked first
    if (intval($user['isActive']) !== 0) {
        http_response_code(422);
        respond(['error' => 'User must be blocked before deletion. Block the user first.', 'code' => 'BLOCK_FIRST'], 422);
        exit;
    }

    // Delete in order to respect FK constraints
    Database::query($conn, 'DELETE FROM access_codes WHERE userId = ?', 's', [&$userId]);
    Database::query($conn, 'DELETE FROM exam_results WHERE userId = ?', 's', [&$userId]);
    $affected = Database::query($conn, 'DELETE FROM users WHERE id = ?', 's', [&$userId]);

    if ($affected === false) ErrorHandler::serverError('Failed to delete user');
    if ($affected === 0)    ErrorHandler::notFound('User not found');

    Logger::info('User deleted by admin', ['userId' => $userId, 'adminId' => $tokenData['userId']]);
    respond([], 200, 'User deleted successfully');
}

function adminGrantAccess($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $userId = SecurityUtils::sanitizeString($params['userId'] ?? '');
    if (!$userId) {
        ErrorHandler::badRequest('Invalid user ID');
    }

    $user = Database::fetchOne($conn, 'SELECT id FROM users WHERE id = ? LIMIT 1', 's', [&$userId]);
    if (!$user) {
        ErrorHandler::notFound('User not found');
    }

    $input = getInput();

    $paymentTier   = SecurityUtils::sanitizeString($input['paymentTier'] ?? '');
    $paymentAmount = isset($input['paymentAmount']) ? intval($input['paymentAmount']) : 0;
    $customDays    = isset($input['durationDays'])  ? intval($input['durationDays'])  : 0;

    // Map tier to days
    $tierMap = ['1_MONTH' => 30, '3_MONTHS' => 90, '6_MONTHS' => 180];

    if ($customDays > 0) {
        $durationDays = $customDays;
        if (empty($paymentTier)) {
            // Default to nearest tier for custom durations
            $paymentTier = $customDays <= 30 ? '1_MONTH' : ($customDays <= 90 ? '3_MONTHS' : '6_MONTHS');
        }
    } elseif (isset($tierMap[$paymentTier])) {
        $durationDays = $tierMap[$paymentTier];
    } else {
        ErrorHandler::badRequest('Provide paymentTier (1_MONTH|3_MONTHS|6_MONTHS) or durationDays');
    }

    if ($paymentAmount <= 0) {
        ErrorHandler::badRequest('paymentAmount must be greater than 0');
    }

    $id        = generateUUID();
    $code      = strtoupper(bin2hex(random_bytes(6)));
    $managerId = $tokenData['userId'];
    $expiresAt = date('Y-m-d H:i:s', strtotime("+{$durationDays} days"));
    $now       = date('Y-m-d H:i:s');

    // Types: id(s) userId(s) code(s) managerId(s) amount(i) days(i) tier(s) expiresAt(s) createdAt(s) updatedAt(s)
    $result = Database::insert(
        $conn,
        'INSERT INTO access_codes (id, userId, code, generatedByManagerId, paymentAmount, durationDays, paymentTier, expiresAt, isUsed, createdAt, updatedAt) VALUES (?,?,?,?,?,?,?,?,0,?,?)',
        'ssssiissss',
        [&$id, &$userId, &$code, &$managerId, &$paymentAmount, &$durationDays, &$paymentTier, &$expiresAt, &$now, &$now]
    );

    if (!$result) {
        Logger::error('Failed to grant access', ['userId' => $userId]);
        ErrorHandler::serverError('Failed to grant access');
    }

    Logger::info('Access granted', ['userId' => $userId, 'adminId' => $managerId, 'tier' => $paymentTier]);
    respond([
        'id'            => $id,
        'code'          => $code,
        'userId'        => $userId,
        'paymentTier'   => $paymentTier,
        'paymentAmount' => $paymentAmount,
        'durationDays'  => $durationDays,
        'expiresAt'     => $expiresAt,
        'message'       => 'Access granted successfully',
    ], 201);
}

function adminMarkCalled($conn, $params) {
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $userId = SecurityUtils::sanitizeString($params['userId'] ?? '');
    if (!$userId) {
        ErrorHandler::badRequest('Invalid user ID');
    }

    $user = Database::fetchOne($conn, 'SELECT id FROM users WHERE id = ? LIMIT 1', 's', [&$userId]);
    if (!$user) {
        ErrorHandler::notFound('User not found');
    }

    $input    = getInput();
    $notes    = SecurityUtils::sanitizeString($input['notes'] ?? '');
    $adminId  = $tokenData['userId'];
    $calledAt = date('Y-m-d H:i:s');

    $stmt = Database::execute(
        $conn,
        'UPDATE users SET lastCalledAt = ?, lastCalledBy = ?, callNotes = ?, updatedAt = ? WHERE id = ?',
        'sssss',
        [&$calledAt, &$adminId, &$notes, &$calledAt, &$userId]
    );

    if (!$stmt) {
        Logger::error('Failed to mark called', ['userId' => $userId]);
        ErrorHandler::serverError('Failed to log call');
    }

    Logger::info('Call logged', ['userId' => $userId, 'adminId' => $adminId]);
    respond([
        'userId'       => $userId,
        'lastCalledAt' => $calledAt,
        'lastCalledBy' => $adminId,
        'callNotes'    => $notes,
        'message'      => 'Call logged successfully',
    ], 200);
}
