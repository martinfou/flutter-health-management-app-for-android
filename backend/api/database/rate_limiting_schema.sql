-- Rate limiting tables for security middleware

-- Rate limit requests tracking
CREATE TABLE rate_limit_requests (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    client_ip VARCHAR(45) NOT NULL, -- IPv4/IPv6 support
    route VARCHAR(255) NOT NULL,
    method VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_client_ip_time (client_ip, created_at),
    INDEX idx_cleanup (created_at)
);

-- Rate limit blocks for blocked clients
CREATE TABLE rate_limit_blocks (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    client_ip VARCHAR(45) NOT NULL,
    blocked_until TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_client_ip (client_ip),
    INDEX idx_blocked_until (blocked_until)
);

-- Add cleanup procedure for old rate limit data
DELIMITER $$
CREATE PROCEDURE cleanup_rate_limit_data()
BEGIN
    -- Remove old request records (older than 1 hour)
    DELETE FROM rate_limit_requests WHERE created_at < DATE_SUB(NOW(), INTERVAL 1 HOUR);

    -- Remove expired blocks
    DELETE FROM rate_limit_blocks WHERE blocked_until < NOW();
END$$
DELIMITER ;