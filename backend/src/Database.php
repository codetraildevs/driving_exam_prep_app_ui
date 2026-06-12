<?php

class Database
{
    private static $connection = null;

    public static function connect()
    {
        if (self::$connection !== null) {
            return self::$connection;
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
        } catch (PDOException $e) {
            Logger::error('Database connection failed', ['error' => $e->getMessage()]);
            ErrorHandler::serverError('Database connection failed');
        }

        return self::$connection;
    }

    public static function getConnection()
    {
        return self::connect();
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
        } catch (PDOException $e) {
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
        } catch (PDOException $e) {
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
        } catch (PDOException $e) {
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
        } catch (PDOException $e) {
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
        } catch (PDOException $e) {
            Logger::error('Query failed', ['sql' => $sql, 'error' => $e->getMessage()]);
            return null;
        }
    }
}
