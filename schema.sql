-- MySQL schema derived from Prisma schema (initial subset focusing on core tables)
CREATE DATABASE IF NOT EXISTS postiz_mysql DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE postiz_mysql;

-- Organization
CREATE TABLE IF NOT EXISTS organization (
  id VARCHAR(50) NOT NULL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  api_key VARCHAR(255),
  payment_id VARCHAR(255),
  allow_trial BOOLEAN DEFAULT FALSE,
  is_trailing BOOLEAN DEFAULT FALSE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- User
CREATE TABLE IF NOT EXISTS user_account (
  id VARCHAR(50) NOT NULL PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  password VARCHAR(255),
  provider_name VARCHAR(50),
  name VARCHAR(255),
  last_name VARCHAR(255),
  is_super_admin BOOLEAN DEFAULT FALSE,
  bio TEXT,
  audience INT DEFAULT 0,
  picture_id VARCHAR(50),
  provider_id VARCHAR(255),
  timezone INT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  last_read_notifications DATETIME DEFAULT CURRENT_TIMESTAMP,
  activated BOOLEAN DEFAULT TRUE,
  connected_account BOOLEAN DEFAULT FALSE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE UNIQUE INDEX ux_user_email_provider ON user_account(email, provider_name);

-- Integration
CREATE TABLE IF NOT EXISTS integration (
  id VARCHAR(50) NOT NULL PRIMARY KEY,
  internal_id VARCHAR(255) NOT NULL,
  organization_id VARCHAR(50) NOT NULL,
  name VARCHAR(255),
  picture VARCHAR(2083),
  provider_identifier VARCHAR(255) NOT NULL,
  type VARCHAR(50),
  token TEXT,
  disabled BOOLEAN DEFAULT FALSE,
  token_expiration DATETIME NULL,
  refresh_token TEXT,
  profile VARCHAR(255),
  deleted_at DATETIME NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  in_between_steps BOOLEAN DEFAULT FALSE,
  refresh_needed BOOLEAN DEFAULT FALSE,
  posting_times TEXT DEFAULT '[{"time":120}, {"time":400}, {"time":700}]',
  additional_settings TEXT,
  root_internal_id VARCHAR(255),
  customer_id VARCHAR(50),
  CONSTRAINT fk_integration_org FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE UNIQUE INDEX ux_integration_org_internal ON integration(organization_id, internal_id);
CREATE INDEX idx_integration_provider ON integration(provider_identifier);
CREATE INDEX idx_integration_refresh_needed ON integration(refresh_needed);

-- Post (simplified)
CREATE TABLE IF NOT EXISTS post (
  id VARCHAR(50) NOT NULL PRIMARY KEY,
  state VARCHAR(50) DEFAULT 'QUEUE',
  publish_date DATETIME,
  organization_id VARCHAR(50),
  integration_id VARCHAR(50),
  content TEXT,
  title VARCHAR(255),
  description TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_post_org FOREIGN KEY (organization_id) REFERENCES organization(id) ON DELETE SET NULL,
  CONSTRAINT fk_post_integration FOREIGN KEY (integration_id) REFERENCES integration(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Additional tables can be added in later iterations (full Prisma conversion planned)