<?php

class ErrorHandler
{
    public static function respond($data = [], $status = 200, $message = null)
    {
        http_response_code($status);
        $response = [
            'success' => $status < 400,
            'data' => $data
        ];
        if ($message) {
            $response['message'] = $message;
        }
        echo json_encode($response);
        exit();
    }

    public static function error($message = 'An error occurred', $status = 400, $details = null)
    {
        http_response_code($status);
        $response = [
            'success' => false,
            'message' => $message,
            'code' => $status
        ];

        // Only include error details in development mode
        if ($details && (getenv('APP_ENV') === 'development' || getenv('DEBUG') === 'true')) {
            $response['error'] = $details;
        }

        echo json_encode($response);
        exit();
    }

    public static function badRequest($message = 'Bad request', $details = null)
    {
        self::error($message, 400, $details);
    }

    public static function unauthorized($message = 'Unauthorized', $details = null)
    {
        self::error($message, 401, $details);
    }

    public static function forbidden($message = 'Forbidden', $details = null)
    {
        self::error($message, 403, $details);
    }

    public static function notFound($message = 'Not found', $details = null)
    {
        self::error($message, 404, $details);
    }

    public static function conflict($message = 'Conflict', $details = null)
    {
        self::error($message, 409, $details);
    }

    public static function serverError($message = 'Internal server error', $details = null)
    {
        Logger::error($message, ['details' => $details]);
        self::error($message, 500);
    }

    public static function getDatabaseError($error)
    {
        Logger::error('Database error', ['error' => $error]);
        // Don't expose database details in production
        if (getenv('APP_ENV') === 'production') {
            return 'Database error occurred';
        }
        return $error;
    }
}
