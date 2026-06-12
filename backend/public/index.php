<?php
/**
 * API Entry Point
 *
 * All bootstrap logic, authentication, and routing has been moved to
 * modular files under backend/src/ and backend/src/handlers/.
 *
 * This file is kept minimal — it just sets a constant and delegates.
 */

define('API_ROOT', __DIR__ . '/..');
require_once API_ROOT . '/src/init.php';
