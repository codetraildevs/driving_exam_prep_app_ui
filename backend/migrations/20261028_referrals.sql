-- Run before deploying referral-enabled registration. All participating tables
-- (including users) must use InnoDB. No subscription/reward grants are created.
CREATE TABLE IF NOT EXISTS referral_codes (
 userId VARCHAR(36) NOT NULL PRIMARY KEY,
 code CHAR(18) CHARACTER SET ascii COLLATE ascii_bin NOT NULL UNIQUE,
 createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS referrals (
 id VARCHAR(36) NOT NULL PRIMARY KEY,
 referrerId VARCHAR(36) NOT NULL,
 referredUserId VARCHAR(36) NOT NULL UNIQUE,
 code CHAR(18) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
 status VARCHAR(16) NOT NULL DEFAULT 'confirmed',
 rewardStatus VARCHAR(16) NOT NULL DEFAULT 'not_configured',
 createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 KEY referral_history (referrerId, createdAt, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- A random registration secret permits safe retries after a lost response.
-- Store only its hash. It cannot be used to change an attribution.
CREATE TABLE IF NOT EXISTS referral_registration_receipts (
 keyHash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL PRIMARY KEY,
 payloadHash CHAR(64) NOT NULL,
 userId VARCHAR(36) NOT NULL UNIQUE,
 referralStatus VARCHAR(16) NOT NULL,
 createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO referral_codes (userId, code)
 SELECT u.id, CONCAT('RW', UPPER(SUBSTRING(SHA2(CONCAT(UUID(), u.id), 256), 1, 16)))
 FROM users u LEFT JOIN referral_codes c ON c.userId = u.id
 WHERE c.userId IS NULL;
