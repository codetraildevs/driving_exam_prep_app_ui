<?php
/**
 * Payment route handlers.
 */

function requestPayment($conn, $params): void
{
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
            'message' => 'A payment request is already pending for your account. Please wait for activation or pay manually: MoMo Pay 323294 / Mobile Money 0788659575 / Help: 0788659575',
            'code'    => 'DUPLICATE_REQUEST',
        ]);
        exit;
    }

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
                'message' => 'A payment request for this plan is already pending. Please wait for confirmation or contact support: MoMo Pay 323294 / Mobile Money 0788659575 / Help: 0788659575',
                'code'    => 'DUPLICATE_TIER_REQUEST',
                'id'      => $existing['id'],
            ]);
            exit;
        }
    }

    $id = generateUUID();
    $now = date('Y-m-d H:i:s');
    $status = 'PENDING';

    $methodWithTier = !empty($paymentTier) ? $paymentTier : $method;

    if (!empty($examId)) {
        $result = Database::insert($conn,
            'INSERT INTO payment_requests (id, userId, examId, amount, paymentMethod, status, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            'sssdssss',
            [&$id, &$userId, &$examId, &$amount, &$methodWithTier, &$status, &$now, &$now]
        );
    } else {
        $result = Database::insert($conn,
            'INSERT INTO payment_requests (id, userId, amount, paymentMethod, status, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?, ?)',
            'ssdssss',
            [&$id, &$userId, &$amount, &$methodWithTier, &$status, &$now, &$now]
        );
    }

    if ($result) {
        Logger::info('Payment request created', ['paymentId' => $id, 'userId' => $userId, 'amount' => $amount, 'tier' => $paymentTier]);
        respond(['id' => $id, 'amount' => $amount, 'status' => 'PENDING', 'tier' => $paymentTier], 201, 'Payment request created successfully');
    } else {
        $errInfo = $conn->errorInfo();
        Logger::error('Failed to create payment request', ['userId' => $userId, 'amount' => $amount, 'tier' => $paymentTier, 'pdoError' => $errInfo[2] ?? 'Unknown']);
        ErrorHandler::serverError('Failed to create payment request. Please try again.');
    }
}

function listPayments($conn, $params): void
{
    global $tokenData;
    requireRole($tokenData, ['ADMIN', 'MANAGER']);

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
