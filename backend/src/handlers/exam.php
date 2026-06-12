<?php
/**
 * Exam (course) route handlers.
 */

function getExams($conn, $params): void
{
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

function getExam($conn, $params): void
{
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

function activateExam($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

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

function deactivateExam($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

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

function toggleExamStatus($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

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

function createExam($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $input = getInput();

    $validation = SecurityUtils::validateRequired($input, ['title', 'description', 'category', 'difficulty']);
    if ($validation) {
        ErrorHandler::badRequest($validation);
    }

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

function updateExam($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

    $id = SecurityUtils::sanitizeString($params['id']);
    if (!$id) {
        ErrorHandler::badRequest('Invalid exam ID');
    }

    $input = getInput();

    $exam = Database::fetchOne($conn, 'SELECT id FROM courses WHERE id = ? LIMIT 1', 's', [&$id]);
    if (!$exam) {
        ErrorHandler::notFound('Exam not found');
    }

    if (empty($input)) {
        ErrorHandler::badRequest('No fields to update');
    }

    $updates = [];
    $types = '';
    $values = [];

    foreach (['title', 'description', 'category', 'difficulty', 'courseType', 'isActive', 'examType'] as $field) {
        if (isset($input[$field])) {
            $val = SecurityUtils::sanitizeString((string)$input[$field]);

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
    $stmt = Database::execute($conn, $sql, $types, $values);

    if (!$stmt) {
        Logger::error('Failed to update exam', ['examId' => $id, 'userId' => $tokenData['userId']]);
        ErrorHandler::serverError('Failed to update exam');
    }

    Logger::info('Exam updated', ['examId' => $id, 'userId' => $tokenData['userId']]);
    respond(['id' => $id], 200, 'Exam updated');
}

function deleteExam($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

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

// Course alias handlers
function getCourses($conn, $params): void
{
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

function getCourse($conn, $params): void
{
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

function createCourse($conn, $params): void
{
    createExam($conn, $params);
}
