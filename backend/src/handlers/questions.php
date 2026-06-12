<?php
/**
 * Question (course_contents) route handlers.
 */

function getQuestions($conn, $params): void
{
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

function getQuestion($conn, $params): void
{
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

function getExamQuestions($conn, $params): void
{
    $examId = SecurityUtils::sanitizeString($params['examId']);
    if (!$examId) {
        ErrorHandler::badRequest('Invalid exam ID');
    }

    $page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
    $limit = isset($_GET['limit']) ? max(1, min(intval($_GET['limit']), 100)) : 50;
    $offset = ($page - 1) * $limit;

    $exam = Database::fetchOne($conn, 'SELECT id, courseType FROM courses WHERE id = ? LIMIT 1', 's', [&$examId]);
    if (!$exam) {
        ErrorHandler::notFound('Exam not found');
    }

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

function getExamQuestionsForTaking($conn, $params): void
{
    $examId = SecurityUtils::sanitizeString($params['id']);
    if (!$examId) {
        ErrorHandler::badRequest('Invalid exam ID');
    }

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

function createQuestion($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

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

function updateQuestion($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $id = SecurityUtils::sanitizeString($params['id']);
    if (!$id) {
        ErrorHandler::badRequest('Invalid question ID');
    }

    $input = getInput();

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
