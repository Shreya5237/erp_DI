-- ==============================================================================
-- DIGITAL INERTIA ERP — LOCAL DEVELOPMENT SEED DATA
-- File: R__seed_dev_users.sql (Repeatable Flyway Migration)
-- Location: classpath:db/dev-seeds
-- 
-- WARNING / SECURITY NOTICE:
-- These accounts are strictly intended for LOCAL DEVELOPMENT and INTEGRATION TESTING.
-- This file must NEVER be included in production Flyway migration paths.
-- Default password for all dev accounts: 'password123'
-- ==============================================================================

INSERT INTO users (id, email, password_hash, full_name, role, employee_id) VALUES
('USR-001', 'laven@digitalinertia.com', '$2a$10$w8TlhjHhA4f2i31m0kQo5eI6Y21uNfR8w2w2iV2EaHh4VlDk/u7.W', 'Laven Lokesh', 'ROLE_CEO', NULL),
('USR-101', 'arjun.sharma@digitalinertia.com', '$2a$10$w8TlhjHhA4f2i31m0kQo5eI6Y21uNfR8w2w2iV2EaHh4VlDk/u7.W', 'Arjun Sharma', 'ROLE_POC', 'EMP-101'),
('USR-102', 'priya.nair@digitalinertia.com', '$2a$10$w8TlhjHhA4f2i31m0kQo5eI6Y21uNfR8w2w2iV2EaHh4VlDk/u7.W', 'Priya Nair', 'ROLE_POC', 'EMP-102')
ON CONFLICT (id) DO NOTHING;
