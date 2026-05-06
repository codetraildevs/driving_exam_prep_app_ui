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
        if ($details && (Env::get('APP_ENV') === 'development' || Env::get('DEBUG') === 'true')) {
            $response['error'] = $details;
        }

        $json = json_encode($response);
        if ($json === false) {
            echo '{"success":false,"message":"Internal Server Error (JSON encoding failed)"}';
        } else {
            echo $json;
        }
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
        // Recursion guard for logger
        static $inError = false;
        if (!$inError) {
            $inError = true;
            Logger::error($message, ['details' => $details]);
            $inError = false;
        }
        
        self::error($message, 500);
    }

    public static function getDatabaseError($error)
    {
        Logger::error('Database error', ['error' => $error]);
        // Don't expose database details in production
        if (Env::get('APP_ENV') === 'production') {
            return 'Database error occurred';
        }
        return $error;
    }
}
