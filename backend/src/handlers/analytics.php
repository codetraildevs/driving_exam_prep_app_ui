<?php
/**
 * Analytics route handlers.
 */

function getAnalytics($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $userCount = Database::fetchOne($conn, 'SELECT COUNT(*) as count FROM users', '', []);
    $examCount = Database::fetchOne($conn, 'SELECT COUNT(*) as count FROM courses', '', []);
    $resultCount = Database::fetchOne($conn, 'SELECT COUNT(*) as count FROM exam_results', '', []);

    respond([
        'totalUsers'   => intval($userCount['count'] ?? 0),
        'totalExams'   => intval($examCount['count'] ?? 0),
        'totalResults' => intval($resultCount['count'] ?? 0),
        'timestamp'    => date('Y-m-d H:i:s'),
    ], 200);
}

function getExamAnalytics($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

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

function getExamStats($conn, $params): void
{
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
