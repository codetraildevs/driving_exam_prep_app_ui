<?php
// Disposable test database only. Never deploy backend/tests.
if (PHP_SAPI !== 'cli' || getenv('REFERRAL_TEST_MODE') !== '1') { if (PHP_SAPI === 'cli') exit(1); }
$port = getenv('REFERRAL_TEST_DB_PORT') ?: '3306';
$password = getenv('REFERRAL_TEST_DB_PASSWORD');
if ($password === false || $password === '') $password = '';
$db = new PDO("mysql:host=127.0.0.1;port=$port;charset=utf8mb4", 'root', $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
$db->exec('CREATE DATABASE IF NOT EXISTS referral_test');
$db->exec('USE referral_test');
// Reset only our explicitly named, disposable test tables.
foreach (['referral_registration_receipts', 'referrals', 'referral_codes', 'refresh_tokens', 'users'] as $table) $db->exec("DROP TABLE IF EXISTS $table");
$db->exec("CREATE TABLE users (id VARCHAR(36) PRIMARY KEY, fullName VARCHAR(255), phoneNumber VARCHAR(20) UNIQUE, deviceId VARCHAR(255) UNIQUE, role VARCHAR(16), isActive TINYINT DEFAULT 1, preferredLanguage VARCHAR(2), createdAt DATETIME, updatedAt DATETIME) ENGINE=InnoDB");
$db->exec("INSERT INTO users (id, fullName, phoneNumber, deviceId, role) VALUES ('inviter', 'Inviter', '0788111111', 'device-inviter', 'USER'), ('existing', 'Existing', '0788222222', 'device-existing', 'USER')");
$db->exec("INSERT INTO users (id, fullName, phoneNumber, deviceId, role) VALUES ('admin', 'Referral Admin', '0788999999', 'device-admin', 'ADMIN')");
$contents = file_get_contents(__DIR__ . '/../migrations/20261028_referrals.sql');
if ($contents === false) { echo "migration_missing\n"; exit(1); }
$db->exec($contents);
echo "Referral test database ready\n";
