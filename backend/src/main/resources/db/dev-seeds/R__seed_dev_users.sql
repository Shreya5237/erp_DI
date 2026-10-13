-- ==============================================================================
-- DIGITAL INERTIA ERP — LOCAL DEVELOPMENT SEED DATA
-- File: R__seed_dev_users.sql (Repeatable Flyway Migration)
-- Location: classpath:db/dev-seeds
-- 
-- WARNING / SECURITY NOTICE:
-- These accounts are strictly intended for LOCAL DEVELOPMENT and INTEGRATION TESTING.
-- This file must NEVER be included in production Flyway migration paths.
-- Default password for all dev accounts: 'password123'
--
-- Demonstration Accounts (PRD Section 2):
-- 1. CEO Account: Laven Lokesh (ROLE_CEO)
-- 2. Technical Employee Account: Arjun Sharma (ROLE_POC / Tech Lead)
-- 3. Sales Employee Account: Rajesh Kumar (ROLE_SALES / BD Associate)
-- ==============================================================================

INSERT INTO users (id, email, password_hash, full_name, role, employee_id) VALUES
('USR-001', 'laven@digitalinertia.com', '$2a$10$UDQwnLwb6Mo8bpaU4/kK.OoJkInDIPdLjRv7VwPNDXE5lNc3gYtPu', 'Laven Lokesh', 'ROLE_CEO', NULL),
('USR-101', 'arjun.sharma@digitalinertia.com', '$2a$10$UDQwnLwb6Mo8bpaU4/kK.OoJkInDIPdLjRv7VwPNDXE5lNc3gYtPu', 'Arjun Sharma', 'ROLE_POC', 'EMP-101'),
('USR-102', 'rajesh.kumar@digitalinertia.com', '$2a$10$UDQwnLwb6Mo8bpaU4/kK.OoJkInDIPdLjRv7VwPNDXE5lNc3gYtPu', 'Rajesh Kumar', 'ROLE_SALES', 'EMP-112')
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  password_hash = EXCLUDED.password_hash,
  full_name = EXCLUDED.full_name,
  role = EXCLUDED.role,
  employee_id = EXCLUDED.employee_id;
