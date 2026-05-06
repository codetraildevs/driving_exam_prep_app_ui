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
            $bind_params = array();
            $bind_params[] = $stmt;
            $bind_params[] = $types;
            foreach ($params as $key => &$val) {
                $bind_params[] = &$val;
            }
            if (!call_user_func_array('mysqli_stmt_bind_param', $bind_params)) {
                Logger::error('Bind param failed', array('error' => mysqli_error($conn)));
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

        $row = null;
        if (function_exists('mysqli_stmt_get_result')) {
            $result = mysqli_stmt_get_result($stmt);
            if ($result) {
                $row = mysqli_fetch_assoc($result);
            }
        } else {
            // Fallback for environments without mysqlnd
            $row = self::fetchManual($stmt);
        }

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

        $rows = [];
        if (function_exists('mysqli_stmt_get_result')) {
            $result = mysqli_stmt_get_result($stmt);
            if ($result) {
                while ($row = mysqli_fetch_assoc($result)) {
                    $rows[] = $row;
                }
            }
        } else {
            // Fallback for environments without mysqlnd
            while ($row = self::fetchManual($stmt)) {
                $rows[] = $row;
            }
        }

        mysqli_stmt_close($stmt);
        return $rows;
    }

    /**
     * Fallback for mysqli_stmt_get_result using bind_result
     * Necessary for servers without mysqlnd driver
     */
    private static function fetchManual($stmt)
    {
        $meta = mysqli_stmt_result_metadata($stmt);
        if (!$meta) {
            return null;
        }

        $fields = mysqli_fetch_fields($meta);
        $data = [];
        $params = [];

        foreach ($fields as $field) {
            $params[] = &$data[$field->name];
        }

        if (!call_user_func_array([$stmt, 'bind_result'], $params)) {
            return null;
        }

        if (mysqli_stmt_fetch($stmt)) {
            $row = [];
            foreach ($data as $key => $val) {
                $row[$key] = $val;
            }
            return $row;
        }

        return null;
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

