<?php
/**
 * Utility class to handle environment variable loading and retrieval reliably.
 */
class Env {
    private static $loaded = false;

    /**
     * Load environment variables from .env file
     */
    public static function load($path) {
        if (self::$loaded) return;
        
        if (file_exists($path)) {
            $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
            foreach ($lines as $line) {
                if (strpos($line, '=') !== false && strpos($line, '#') !== 0) {
                    list($key, $value) = explode('=', $line, 2);
                    $key = trim($key);
                    $value = trim($value);
                    
                    // Try to set environment variable
                    @putenv("$key=$value");
                    $_ENV[$key] = $value;
                    $_SERVER[$key] = $value;
                }
            }
        }
        self::$loaded = true;
    }

    /**
     * Get environment variable reliably
     */
    public static function get($key, $default = null) {
        // Try getenv
        $val = getenv($key);
        if ($val !== false) return $val;
        
        // Try $_ENV
        if (isset($_ENV[$key])) return $_ENV[$key];
        
        // Try $_SERVER
        if (isset($_SERVER[$key])) return $_SERVER[$key];
        
        return $default;
    }
}
