<?php
/**
 * Exam & practice result route handlers.
 */

function submitExamResult($conn, $params): void
{
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
        $userAnswer = $answers[$qid] ?? null;
        $isCorrect = $userAnswer !== null && $userAnswer === $q['correctAnswer'];
        if ($isCorrect) {
            $correctAnswers++;
        }
        $questionResults[] = [
            'questionId'    => $qid,
            'questionText'  => $q['question'],
            'options'       => ['a' => $q['option1'], 'b' => $q['option2'], 'c' => $q['option3'], 'd' => $q['option4']],
            'userAnswer'    => $userAnswer,
            'correctAnswer' => $q['correctAnswer'],
            'isCorrect'     => $isCorrect,
            'points'        => $isCorrect ? intval($q['points'] ?? 1) : 0,
            'questionImgUrl' => $q['questionImgUrl'],
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

function submitPracticeResult($conn, $params): void
{
    global $tokenData;

    $input = getInput();

    $validation = SecurityUtils::validateRequired($input, ['userId', 'examId', 'score', 'totalQuestions', 'correctAnswers']);
    if ($validation) {
        ErrorHandler::badRequest($validation);
    }

    $userId = SecurityUtils::sanitizeString($input['userId']);
    $examId = SecurityUtils::sanitizeString($input['examId']);

    if ($tokenData['userId'] !== $userId && $tokenData['role'] !== 'ADMIN') {
        ErrorHandler::forbidden('You can only submit your own practice results');
    }

    $score = intval($input['score']);
    $totalQuestions = intval($input['totalQuestions']);
    $correctAnswers = intval($input['correctAnswers']);
    $timeSpent = intval($input['timeSpent'] ?? 0);
    $passed = ($score >= 60) ? 1 : 0;

    if ($totalQuestions <= 0 || $correctAnswers < 0 || $correctAnswers > $totalQuestions) {
        ErrorHandler::badRequest('Invalid question/answer counts');
    }
    if ($score < 0 || $score > 100) {
        ErrorHandler::badRequest('Score must be between 0 and 100');
    }

    $id = generateUUID();
    $now = date('Y-m-d H:i:s');
    $answersJson = json_encode([]);
    $qresJson = json_encode([]);
    $isFreeExam = 1;

    $result = Database::insert($conn,
        'INSERT INTO exam_results (id, userId, examId, score, totalQuestions, correctAnswers, timeSpent, answers, passed, completedAt, isFreeExam, createdAt, updatedAt, questionResults) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        'sssiiiisisiiss',
        [&$id, &$userId, &$examId, &$score, &$totalQuestions, &$correctAnswers, &$timeSpent, &$answersJson, &$passed, &$now, &$isFreeExam, &$now, &$now, &$qresJson]
    );

    if (!$result) {
        Logger::error('Failed to save practice result', ['userId' => $userId, 'examId' => $examId]);
        ErrorHandler::serverError('Failed to save practice result');
    }

    Logger::info('Practice result submitted', ['resultId' => $id, 'userId' => $userId, 'examId' => $examId, 'score' => $score]);
    respond(['id' => $id, 'score' => $score, 'passed' => (bool)$passed], 201, 'Practice result saved');
}

function resetPracticeResults($conn, $params): void
{
    global $tokenData;

    $input = getInput();

    $validation = SecurityUtils::validateRequired($input, ['userId']);
    if ($validation) {
        ErrorHandler::badRequest($validation);
    }

    $userId = SecurityUtils::sanitizeString($input['userId']);

    if ($tokenData['userId'] !== $userId && $tokenData['role'] !== 'ADMIN') {
        ErrorHandler::forbidden('You can only reset your own practice results');
    }

    $stmt = $conn->prepare('DELETE FROM exam_results WHERE userId = ?');
    $stmt->execute([$userId]);
    $deleted = $stmt->rowCount();
    $stmt->closeCursor();

    Logger::info('Practice results reset', ['userId' => $userId, 'deleted' => $deleted]);
    respond(['deleted' => $deleted], 200, 'Practice results reset successfully');
}

function getUserResults($conn, $params): void
{
    global $tokenData;

    if (!$tokenData || !isset($tokenData['userId']) || !isset($tokenData['role'])) {
        ErrorHandler::unauthorized('Invalid or missing token data');
    }

    $userId = SecurityUtils::sanitizeString($params['userId']);
    if (!$userId) {
        ErrorHandler::badRequest('Invalid user ID');
    }

    if ($tokenData['userId'] !== $userId && $tokenData['role'] !== 'ADMIN') {
        Logger::security("Unauthorized attempt to view another user's results", [
            'requestedUserId' => $userId,
            'actualUserId'    => $tokenData['userId'],
        ]);
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

function getAllResults($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

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
