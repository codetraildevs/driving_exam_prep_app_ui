<?php

// Load PDO compatibility shim (uses mysqli when PDO extension is missing)
require_once __DIR__ . '/PDOCompat.php';

class Database
{
    private static $connection = null;

    public static function connect()
    {
        if (self::$connection !== null) {
            return self::$connection;
        }

        // Check that either PDO or mysqli extension is actually loaded
        // (class_exists('PDO') is unreliable here because PDOCompat.php defines a fallback PDO class)
        if (!extension_loaded('pdo') && !extension_loaded('mysqli')) {
            $msg = 'Server configuration error: PHP extension "pdo_mysql" or "mysqli" is not installed/enabled. ' .
                   'Please enable it in your hosting control panel (e.g. cPanel -> Select PHP Version -> enable pdo_mysql and mysqli).';
            Logger::error('No database driver available');
            ErrorHandler::serverError($msg);
        }

        $host = Env::get('DB_HOST', '127.0.0.1');
        $port = Env::get('DB_PORT', '3306');
        $db   = Env::get('DB_NAME', 'traffic_rules_db');
        $user = Env::get('DB_USER', 'root');
        $pass = Env::get('DB_PASS', '');

        $dsn = "mysql:host=$host;port=$port;dbname=$db;charset=utf8mb4";

        try {
            self::$connection = new PDO($dsn, $user, $pass, [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
            ]);
        } catch (\Throwable $e) {
            $errMsg = $e->getMessage();
            Logger::error('Database connection failed', ['error' => $errMsg]);
            ErrorHandler::serverError("Database connection failed: $errMsg");
        }

        return self::$connection;
    }

    public static function getConnection()
    {
        $conn = self::connect();
        self::_ensureUserConstraints($conn);
        return $conn;
    }

    /**
     * Ensure unique constraints exist on users table.
     * Idempotent: only adds if they don't already exist.
     */
    private static function _ensureUserConstraints($conn): void
    {
        try {
            // Check if UNIQUE constraint on phoneNumber already exists
            $stmt = $conn->prepare("SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_NAME = 'users' AND COLUMN_NAME = 'phoneNumber' AND CONSTRAINT_NAME != 'PRIMARY'");
            $stmt->execute();
            $phoneExists = $stmt->rowCount() > 0;

            // Check if UNIQUE constraint on deviceId already exists
            $stmt = $conn->prepare("SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_NAME = 'users' AND COLUMN_NAME = 'deviceId' AND CONSTRAINT_NAME != 'PRIMARY'");
            $stmt->execute();
            $deviceExists = $stmt->rowCount() > 0;

            // Add phoneNumber constraint if missing
            if (!$phoneExists) {
                try {
                    $conn->exec("ALTER TABLE users ADD UNIQUE KEY phoneNumber (phoneNumber)");
                    Logger::info('Added UNIQUE constraint on users.phoneNumber');
                } catch (\Throwable $e) {
                    if (strpos($e->getMessage(), 'already exists') === false) {
                        Logger::warning('Failed to add phoneNumber constraint', ['error' => $e->getMessage()]);
                    }
                }
            }

            // Add deviceId constraint if missing
            if (!$deviceExists) {
                try {
                    $conn->exec("ALTER TABLE users ADD UNIQUE KEY deviceId (deviceId)");
                    Logger::info('Added UNIQUE constraint on users.deviceId');
                } catch (\Throwable $e) {
                    if (strpos($e->getMessage(), 'already exists') === false) {
                        Logger::warning('Failed to add deviceId constraint', ['error' => $e->getMessage()]);
                    }
                }
            }
        } catch (\Throwable $e) {
            Logger::warning('Could not verify user constraints', ['error' => $e->getMessage()]);
        }
    }


    /**
     * Execute a prepared statement and return the statement handle.
     *
     * @param PDO    $conn   PDO connection
     * @param string $sql    SQL query with ? placeholders
     * @param string $types  (Unused — accepted for backward compatibility with PDO)
     * @param array  $params Parameter values
     * @return PDOStatement|null
     */
    public static function execute($conn, $sql, $types = '', $params = [])
    {
        try {
            $stmt = $conn->prepare($sql);
            $stmt->execute($params);
            return $stmt;
        } catch (\Throwable $e) {
            Logger::error('Query failed', ['sql' => $sql, 'error' => $e->getMessage()]);
            return null;
        }
    }

    /**
     * Fetch a single row.
     *
     * @param PDO    $conn   PDO connection
     * @param string $sql    SQL query with ? placeholders
     * @param string $types  (Unused — accepted for backward compatibility)
     * @param array  $params Parameter values
     * @return array|null
     */
    public static function fetchOne($conn, $sql, $types = '', $params = [])
    {
        try {
            $stmt = $conn->prepare($sql);
            $stmt->execute($params);
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return $row !== false ? $row : null;
        } catch (\Throwable $e) {
            Logger::error('Query failed', ['sql' => $sql, 'error' => $e->getMessage()]);
            return null;
        }
    }

    /**
     * Fetch all rows.
     *
     * @param PDO    $conn   PDO connection
     * @param string $sql    SQL query with ? placeholders
     * @param string $types  (Unused — accepted for backward compatibility)
     * @param array  $params Parameter values
     * @return array
     */
    public static function fetchAll($conn, $sql, $types = '', $params = [])
    {
        try {
            $stmt = $conn->prepare($sql);
            $stmt->execute($params);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return $rows;
        } catch (\Throwable $e) {
            Logger::error('Query failed', ['sql' => $sql, 'error' => $e->getMessage()]);
            return [];
        }
    }

    /**
     * Execute an INSERT/UPDATE/DELETE and return the number of affected rows.
     *
     * @param PDO    $conn   PDO connection
     * @param string $sql    SQL query with ? placeholders
     * @param string $types  (Unused — accepted for backward compatibility)
     * @param array  $params Parameter values
     * @return int|false  Number of affected rows, or false on failure
     */
    public static function query($conn, $sql, $types = '', $params = [])
    {
        try {
            $stmt = $conn->prepare($sql);
            $stmt->execute($params);
            $affected = $stmt->rowCount();
            $stmt->closeCursor();
            return $affected;
        } catch (\Throwable $e) {
            Logger::error('Query failed', ['sql' => $sql, 'error' => $e->getMessage()]);
            return false;
        }
    }

    /**
     * Insert a row and return the last insert ID or the number of affected rows.
     *
     * For tables with an auto-increment integer primary key, returns the new ID.
     * For tables with a UUID/string primary key, returns the affected-row count
     * (truthy on success, null on failure).
     *
     * @param PDO    $conn   PDO connection
     * @param string $sql    SQL query with ? placeholders
     * @param string $types  (Unused — accepted for backward compatibility)
     * @param array  $params Parameter values
     * @return int|string|null
     */
    public static function insert($conn, $sql, $types = '', $params = [])
    {
        try {
            $stmt = $conn->prepare($sql);
            $stmt->execute($params);
            $lastId = $conn->lastInsertId();
            $affected = $stmt->rowCount();
            $stmt->closeCursor();

            // Auto-increment integer PK — return the generated ID
            if ($lastId && $lastId !== '0') {
                return $lastId;
            }

            // UUID/string PK — return affected rows so callers can check success
            return $affected > 0 ? $affected : null;
        } catch (\Throwable $e) {
            Logger::error('Query failed', ['sql' => $sql, 'error' => $e->getMessage()]);
            return null;
        }
    }
}
