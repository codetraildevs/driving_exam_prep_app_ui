-- Additive migration. Run once in the application's existing MySQL database.
CREATE TABLE IF NOT EXISTS irembo_requests (
 id VARCHAR(36) PRIMARY KEY,
 reference VARCHAR(40) NOT NULL UNIQUE,
 userId VARCHAR(36) NOT NULL,
 requestKey VARCHAR(36) NOT NULL,
 payloadHash CHAR(64) NOT NULL,
 fullName VARCHAR(150) NOT NULL,
 phoneNumber VARCHAR(20) NOT NULL,
 nationalId VARCHAR(32) NOT NULL,
 dob DATE NOT NULL,
 service VARCHAR(20) NOT NULL,
 permisOption VARCHAR(20) NULL,
 category VARCHAR(1) NULL,
 provisoireCode VARCHAR(80) NULL,
 examLanguage VARCHAR(2) NOT NULL,
 district VARCHAR(40) NOT NULL,
 preferredExamDate DATE NULL,
 status VARCHAR(24) NOT NULL DEFAULT 'Pending',
 assignedStaffId VARCHAR(36) NULL,
 version INT NOT NULL DEFAULT 1,
 createdAt DATETIME NOT NULL,
 updatedAt DATETIME NOT NULL,
 UNIQUE KEY irembo_request_retry (userId, requestKey),
 KEY irembo_owner (userId, createdAt),
 KEY irembo_assigned (assignedStaffId, status, createdAt),
 KEY irembo_status (status, createdAt),
 KEY irembo_service (service, permisOption, category),
 KEY irembo_location (district, examLanguage)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS irembo_messages (
 id VARCHAR(36) PRIMARY KEY,
 requestId VARCHAR(36) NOT NULL,
 staffId VARCHAR(36) NOT NULL,
 applicantVisible TINYINT NOT NULL DEFAULT 0,
 body TEXT NOT NULL,
 createdAt DATETIME NOT NULL,
 KEY irembo_message_request (requestId, createdAt),
 CONSTRAINT irembo_message_parent FOREIGN KEY (requestId) REFERENCES irembo_requests(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS irembo_audit (
 id VARCHAR(36) PRIMARY KEY,
 requestId VARCHAR(36) NOT NULL,
 actorId VARCHAR(36) NOT NULL,
 changesJson LONGTEXT NOT NULL,
 createdAt DATETIME NOT NULL,
 KEY irembo_audit_request (requestId, createdAt),
 CONSTRAINT irembo_audit_parent FOREIGN KEY (requestId) REFERENCES irembo_requests(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
