<?php

class Logger
{
    private static $logFile = null;
    private static $initialized = false;

    public static function init($logPath = null)
    {
        if (!$logPath) {
            $logDir = __DIR__ . '/../logs';
            if (!is_dir($logDir)) {
                mkdir($logDir, 0755, true);
            }
            $logPath = $logDir . '/app.log';
        }
        self::$logFile = $logPath;
        self::$initialized = true;
    }

    public static function log($message, $level = 'INFO', $context = [])
    {
        if (!self::$initialized) {
            self::init();
        }

        $timestamp = date('Y-m-d H:i:s');
        $contextStr = !empty($context) ? ' | ' . json_encode($context) : '';
        $logMessage = "[$timestamp] [$level] $message$contextStr\n";

        error_log($logMessage, 3, self::$logFile);
    }

    public static function info($message, $context = [])
    {
        self::log($message, 'INFO', $context);
    }

    public static function warning($message, $context = [])
    {
        self::log($message, 'WARNING', $context);
    }

    public static function error($message, $context = [])
    {
        self::log($message, 'ERROR', $context);
    }

    public static function debug($message, $context = [])
    {
        if (getenv('DEBUG') === 'true' || getenv('APP_ENV') === 'development') {
            self::log($message, 'DEBUG', $context);
        }
    }

    public static function security($message, $context = [])
    {
        self::log($message, 'SECURITY', $context);
    }
}

Logger::init();
