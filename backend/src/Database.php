<?php

class Database
{
    private static $connection = null;

    public static function connect()
    {
        if (self::$connection !== null) {
            return self::$connection;
        }

        $host = getenv('DB_HOST') ?: '127.0.0.1';
        $port = getenv('DB_PORT') ?: '3306';
        $db   = getenv('DB_NAME') ?: 'traffic_rules_db';
        $user = getenv('DB_USER') ?: 'root';
        $pass = getenv('DB_PASS') ?: '';

        self::$connection = mysqli_connect($host, $user, $pass, $db, intval($port));

        if (!self::$connection) {
            Logger::error('Database connection failed', ['error' => mysqli_connect_error()]);
            ErrorHandler::serverError('Database connection failed');
        }

        mysqli_set_charset(self::$connection, 'utf8mb4');

        return self::$connection;
    }

    public static function getConnection()
    {
        return self::connect();
    }

    /**
     * Execute prepared statement with parameters
     */
    public static function execute($conn, $sql, $types, $params)
    {
        $stmt = mysqli_prepare($conn, $sql);
        if (!$stmt) {
            Logger::error('Prepare failed', ['sql' => $sql, 'error' => mysqli_error($conn)]);
            return null;
        }

        if (!empty($params)) {
            if (!mysqli_stmt_bind_param($stmt, $types, ...$params)) {
                Logger::error('Bind param failed', ['error' => mysqli_error($conn)]);
                return null;
            }
        }

        if (!mysqli_stmt_execute($stmt)) {
            Logger::error('Execute failed', ['sql' => $sql, 'error' => mysqli_error($conn)]);
            return null;
        }

        return $stmt;
    }

    /**
     * Fetch a single row
     */
    public static function fetchOne($conn, $sql, $types = '', $params = [])
    {
        $stmt = self::execute($conn, $sql, $types, $params);
        if (!$stmt) {
            return null;
        }

        $result = mysqli_stmt_get_result($stmt);
        $row = mysqli_fetch_assoc($result);
        mysqli_stmt_close($stmt);

        return $row;
    }

    /**
     * Fetch all rows
     */
    public static function fetchAll($conn, $sql, $types = '', $params = [])
    {
        $stmt = self::execute($conn, $sql, $types, $params);
        if (!$stmt) {
            return [];
        }

        $result = mysqli_stmt_get_result($stmt);
        $rows = [];
        while ($row = mysqli_fetch_assoc($result)) {
            $rows[] = $row;
        }
        mysqli_stmt_close($stmt);

        return $rows;
    }

    /**
     * Insert/Update/Delete and return affected rows
     */
    public static function query($conn, $sql, $types = '', $params = [])
    {
        $stmt = self::execute($conn, $sql, $types, $params);
        if (!$stmt) {
            return false;
        }

        $affected = mysqli_stmt_affected_rows($stmt);
        mysqli_stmt_close($stmt);

        return $affected;
    }

    /**
     * Insert and return last insert id
     */
    public static function insert($conn, $sql, $types = '', $params = [])
    {
        $stmt = self::execute($conn, $sql, $types, $params);
        if (!$stmt) {
            return null;
        }

        $lastId = mysqli_stmt_insert_id($stmt);
        $affected = mysqli_stmt_affected_rows($stmt);
        mysqli_stmt_close($stmt);

        // UUID/string primary-key tables return insert_id=0 even on success.
        // Return a positive affected-row count in that case so callers can
        // reliably detect successful inserts using truthy checks.
        if ($lastId > 0) {
            return $lastId;
        }

        return $affected > 0 ? $affected : null;
    }
}

