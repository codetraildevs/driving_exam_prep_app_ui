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

    private static $isLogging = false;

    public static function log($message, $level = 'INFO', $context = [])
    {
        if (!self::$initialized) {
            self::init();
        }

        // Prevent infinite recursion if logging itself fails
        if (self::$isLogging) {
            return;
        }
        self::$isLogging = true;

        $timestamp = date('Y-m-d H:i:s');
        $contextStr = !empty($context) ? ' | ' . json_encode($context) : '';
        $logMessage = "[$timestamp] [$level] $message$contextStr\n";

        // Try to write to file, fallback to system error_log if it fails
        if (self::$logFile) {
            // Check if directory is writable if we need to create the file
            $logDir = dirname(self::$logFile);
            if (is_writable($logDir) || (!file_exists(self::$logFile) && is_writable($logDir))) {
                @error_log($logMessage, 3, self::$logFile);
            } else {
                @error_log("FALLBACK: " . $logMessage);
            }
        } else {
            @error_log($logMessage);
        }

        self::$isLogging = false;
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
        if (Env::get('DEBUG') === 'true' || Env::get('APP_ENV') === 'development') {
            self::log($message, 'DEBUG', $context);
        }
    }

    public static function security($message, $context = [])
    {
        self::log($message, 'SECURITY', $context);
    }
}

Logger::init();
