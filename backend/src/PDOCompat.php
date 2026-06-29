<?php
/**
 * PDOCompat — A drop-in PDO replacement backed by mysqli.
 *
 * Exposes the same method signatures and constants used by the rest of the
 * codebase so it works transparently when the native PDO extension is not
 * installed.
 *
 * IMPORTANT: Does NOT use mysqli type hints in signatures so this file
 * compiles safely even when the mysqli extension is missing.  mysqli
 * availability is checked at runtime instead.
 */

// Only define if PDO is not already available
if (!class_exists('PDO', false)) {

    // ── Constants matching native PDO ──────────────────────────────
    define('PDO_FETCH_ASSOC', 2);
    define('PDO_ATTR_ERRMODE', 3);
    define('PDO_ERRMODE_EXCEPTION', 2);
    define('PDO_ATTR_DEFAULT_FETCH_MODE', 19);
    define('PDO_ATTR_EMULATE_PREPARES', 22);

    class PDO
    {
        public const FETCH_ASSOC            = 2;
        public const ATTR_ERRMODE           = 3;
        public const ERRMODE_EXCEPTION      = 2;
        public const ATTR_DEFAULT_FETCH_MODE = 19;
        public const ATTR_EMULATE_PREPARES  = 22;

        private $conn = null;
        private $errorMode = self::ERRMODE_EXCEPTION;

        /**
         * Connect using mysqli (checked at runtime).
         */
        public function __construct($dsn, $user, $pass, $options = [])
        {
            // Runtime check for mysqli
            if (!function_exists('mysqli_connect')) {
                throw new PDOException(
                    'PHP extension "mysqli" is not installed/enabled. ' .
                    'Please enable it in your hosting control panel (cPanel → Select PHP Version → check mysqli).'
                );
            }

            // Parse DSN
            $dsnParts = [];
            $dsnClean = substr($dsn, 6);
            foreach (explode(';', $dsnClean) as $part) {
                if (strpos($part, '=') !== false) {
                    [$k, $v] = explode('=', $part, 2);
                    $dsnParts[trim($k)] = trim($v);
                }
            }

            $host = $dsnParts['host'] ?? '127.0.0.1';
            $port = isset($dsnParts['port']) ? (int)$dsnParts['port'] : 3306;
            $dbname = $dsnParts['dbname'] ?? '';
            $charset = $dsnParts['charset'] ?? 'utf8mb4';

            $this->conn = @new mysqli($host, $user, $pass, $dbname, $port);

            if ($this->conn->connect_error) {
                throw new PDOException(
                    'mysqli: ' . $this->conn->connect_error,
                    $this->conn->connect_errno
                );
            }

            $this->conn->set_charset($charset);

            if (isset($options[self::ATTR_ERRMODE])) {
                $this->errorMode = $options[self::ATTR_ERRMODE];
            }
        }

        public function prepare($sql)
        {
            if (!$this->conn) {
                throw new PDOException('No database connection');
            }
            $stmt = @$this->conn->prepare($sql);
            if (!$stmt) {
                throw new PDOException($this->conn->error, $this->conn->errno);
            }
            return new PDOStatement($stmt, $this);
        }

        public function exec($sql)
        {
            if (!$this->conn) {
                throw new PDOException('No database connection');
            }
            if ($this->conn->query($sql) === false) {
                throw new PDOException($this->conn->error, $this->conn->errno);
            }
            return $this->conn->affected_rows;
        }

        public function lastInsertId($name = null)
        {
            return (string)$this->conn->insert_id;
        }

        public function setAttribute($attribute, $value)
        {
            if ($attribute === self::ATTR_ERRMODE) {
                $this->errorMode = $value;
            }
            return true;
        }

        public function errorInfo()
        {
            return [$this->conn->sqlstate, $this->conn->errno, $this->conn->error];
        }

        public function quote($value, $type = 2)
        {
            return "'" . $this->conn->real_escape_string($value) . "'";
        }

        public function handleError($message, $code = 0)
        {
            if ($this->errorMode === self::ERRMODE_EXCEPTION) {
                throw new PDOException($message, $code);
            }
        }
    }

    class PDOStatement
    {
        private $stmt;
        private $pdo;

        public function __construct($stmt, $pdo)
        {
            $this->stmt = $stmt;
            $this->pdo = $pdo;
        }

        public function execute($params = null)
        {
            if (!empty($params)) {
                $types = '';
                $bindValues = [];
                foreach ($params as $param) {
                    if (is_int($param) || is_float($param)) {
                        $types .= 'd';
                    } elseif (is_null($param)) {
                        $types .= 's';
                    } else {
                        $types .= 's';
                    }
                    $bindValues[] = $param;
                }

                if (!empty($bindValues)) {
                    $bindArgs = [$types];
                    $bindArgs = array_merge($bindArgs, $bindValues);
                    $refs = [];
                    foreach ($bindArgs as $i => $v) {
                        $refs[$i] = &$bindArgs[$i];
                    }
                    call_user_func_array([$this->stmt, 'bind_param'], $refs);
                }
            }

            $result = $this->stmt->execute();
            if (!$result) {
                $this->pdo->handleError($this->stmt->error, $this->stmt->errno);
                return false;
            }
            return true;
        }

        public function fetch($mode = 2)
        {
            if ($mode === 2) {
                $result = @$this->stmt->get_result();
                if (!$result) {
                    return null;
                }
                $row = $result->fetch_assoc();
                $result->free();
                return ($row !== null && $row !== false) ? $row : null;
            }
            return null;
        }

        public function fetchAll($mode = 2)
        {
            if ($mode === 2) {
                $result = @$this->stmt->get_result();
                if (!$result) {
                    return [];
                }
                $rows = $result->fetch_all(MYSQLI_ASSOC);
                $result->free();
                return $rows ?: [];
            }
            return [];
        }

        public function rowCount()
        {
            return $this->stmt->affected_rows;
        }

        public function closeCursor()
        {
            @$this->stmt->free_result();
            return true;
        }
    }

    if (!class_exists('PDOException', false)) {
        class PDOException extends Exception
        {
        }
    }
}
