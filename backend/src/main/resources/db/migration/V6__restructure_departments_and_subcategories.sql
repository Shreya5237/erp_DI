-- ==============================================================================
-- DIGITAL INERTIA ERP — MIGRATION V6
-- File: V6__restructure_departments_and_subcategories.sql
-- Description: Restructure employee departments into exactly 5 top-level root
--              departments with parent-child subcategories and referential integrity.
-- ==============================================================================

-- 1. Create departments table with hierarchical parent-child relationship
CREATE TABLE IF NOT EXISTS departments (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(50) NOT NULL UNIQUE,
    parent_id VARCHAR(32) REFERENCES departments(id) ON DELETE RESTRICT,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_dept_name_parent UNIQUE (name, parent_id)
);

-- Index on parent_id for efficient hierarchy lookups
CREATE INDEX IF NOT EXISTS idx_departments_parent ON departments(parent_id);
CREATE INDEX IF NOT EXISTS idx_departments_active ON departments(is_active);

-- Ensure top-level department names are unique among root nodes
CREATE UNIQUE INDEX IF NOT EXISTS uq_root_department_name
ON departments (name)
WHERE parent_id IS NULL;

-- Enforce strictly the 5 approved root departments: Finance, Sales, Marketing, HR, Technical
ALTER TABLE departments
ADD CONSTRAINT chk_approved_root_departments
CHECK (
    parent_id IS NOT NULL OR
    name IN ('Finance', 'Sales', 'Marketing', 'HR', 'Technical')
);

-- Trigger for updated_at on departments
DROP TRIGGER IF EXISTS trg_touch_departments ON departments;
CREATE TRIGGER trg_touch_departments
BEFORE UPDATE ON departments
FOR EACH ROW EXECUTE FUNCTION fn_touch_updated_at();

-- 2. Seed the 5 approved root departments
INSERT INTO departments (id, name, code, parent_id, description) VALUES
('DEPT-FIN',  'Finance',   'FIN',  NULL, 'Financial forecasting, revenue recognition, client invoicing, payroll, and compliance audits'),
('DEPT-SAL',  'Sales',     'SAL',  NULL, 'Enterprise pipeline development, B2B deal negotiation, and client relationship management'),
('DEPT-MKT',  'Marketing', 'MKT',  NULL, 'Growth marketing, technical product marketing, brand positioning, and digital outreach'),
('DEPT-HR',   'HR',        'HR',   NULL, 'Campus talent acquisition, intern onboarding, culture, and employee lifecycle management'),
('DEPT-TECH', 'Technical', 'TECH', NULL, 'Web and mobile client architecture, backend APIs, cloud infrastructure, QA, and AI/ML')
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    code = EXCLUDED.code,
    description = EXCLUDED.description;

-- 3. Seed standard subcategories under each of the 5 approved departments
-- Finance subcategories
INSERT INTO departments (id, name, code, parent_id, description) VALUES
('DEPT-FIN-ACC', 'Accounts',  'FIN-ACC', 'DEPT-FIN', 'Corporate general ledger, bookkeeping, and account reconciliations'),
('DEPT-FIN-PAY', 'Payroll',   'FIN-PAY', 'DEPT-FIN', 'Employee payroll processing, compensation, and tax withholdings'),
('DEPT-FIN-BUD', 'Budgeting', 'FIN-BUD', 'DEPT-FIN', 'Project cost estimation, department budgets, and variance analysis'),
('DEPT-FIN-INV', 'Invoicing', 'FIN-INV', 'DEPT-FIN', 'Client billings, invoice lifecycle, and accounts receivable')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, code = EXCLUDED.code, parent_id = EXCLUDED.parent_id;

-- Sales subcategories
INSERT INTO departments (id, name, code, parent_id, description) VALUES
('DEPT-SAL-BD',   'Business Development', 'SAL-BD',   'DEPT-SAL', 'Strategic partnerships, outbound enterprise sales, and B2B growth'),
('DEPT-SAL-LEAD', 'Lead Management',      'SAL-LEAD', 'DEPT-SAL', 'Lead scoring, prospect qualification, and cold outreach'),
('DEPT-SAL-ACQ',  'Client Acquisition',   'SAL-ACQ',  'DEPT-SAL', 'Client discovery sessions, RFP responses, and deal negotiations'),
('DEPT-SAL-ACC',  'Account Management',   'SAL-ACC',  'DEPT-SAL', 'Key account governance, customer success, and SLA retention')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, code = EXCLUDED.code, parent_id = EXCLUDED.parent_id;

-- Marketing subcategories
INSERT INTO departments (id, name, code, parent_id, description) VALUES
('DEPT-MKT-DIG', 'Digital Marketing', 'MKT-DIG', 'DEPT-MKT', 'Performance ad campaigns, conversions, and web analytics'),
('DEPT-MKT-SEO', 'SEO',               'MKT-SEO', 'DEPT-MKT', 'Search engine optimization, keyword strategy, and backlinks'),
('DEPT-MKT-SOC', 'Social Media',      'MKT-SOC', 'DEPT-MKT', 'Social channel engagement, community management, and announcements'),
('DEPT-MKT-CNT', 'Content Marketing', 'MKT-CNT', 'DEPT-MKT', 'Technical blogs, whitepapers, case studies, and documentation'),
('DEPT-MKT-BRD', 'Branding',          'MKT-BRD', 'DEPT-MKT', 'Brand positioning, visual design tokens, and media press kit')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, code = EXCLUDED.code, parent_id = EXCLUDED.parent_id;

-- HR subcategories
INSERT INTO departments (id, name, code, parent_id, description) VALUES
('DEPT-HR-REC', 'Recruitment',            'HR-REC', 'DEPT-HR', 'Campus talent scouting, technical screenings, and hiring pipelines'),
('DEPT-HR-ONB', 'Onboarding',             'HR-ONB', 'DEPT-HR', 'New joiner onboarding, workspace setup, and intern cohort orientation'),
('DEPT-HR-TRN', 'Training',               'HR-TRN', 'DEPT-HR', 'Skill development workshops, mentoring tracks, and certifications'),
('DEPT-HR-LEV', 'Leave Management',        'HR-LEV', 'DEPT-HR', 'Paid time off approvals, sick leaves, and attendance auditing'),
('DEPT-HR-PRF', 'Performance Management',  'HR-PRF', 'DEPT-HR', 'Quarterly performance reviews, KPIs, and appraisal cycles')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, code = EXCLUDED.code, parent_id = EXCLUDED.parent_id;

-- Technical subcategories
INSERT INTO departments (id, name, code, parent_id, description) VALUES
('DEPT-TEC-FE',  'Frontend',           'TEC-FE',  'DEPT-TECH', 'React, Flutter UI, design tokens, and web client applications'),
('DEPT-TEC-BE',  'Backend',            'TEC-BE',  'DEPT-TECH', 'Spring Boot APIs, PostgreSQL architecture, and distributed services'),
('DEPT-TEC-FS',  'Full-stack',         'TEC-FS',  'DEPT-TECH', 'End-to-end full stack web applications and micro-services'),
('DEPT-TEC-MOB', 'Mobile Development', 'TEC-MOB', 'DEPT-TECH', 'Cross-platform native mobile applications in Flutter'),
('DEPT-TEC-UIX', 'UI/UX',              'TEC-UIX', 'DEPT-TECH', 'User interface design, Figma prototypes, and human factors UX'),
('DEPT-TEC-QA',  'QA',                 'TEC-QA',  'DEPT-TECH', 'Automated regression test suites and end-to-end quality assurance'),
('DEPT-TEC-OPS', 'DevOps',             'TEC-OPS', 'DEPT-TECH', 'Docker, Kubernetes, cloud CI/CD pipelines, and site reliability'),
('DEPT-TEC-AI',  'AI/ML',              'TEC-AI',  'DEPT-TECH', 'Machine learning telemetry, predictive modeling, and AI workflows')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, code = EXCLUDED.code, parent_id = EXCLUDED.parent_id;

-- 4. Alter employees table to add department_id and sub_department_id columns
ALTER TABLE employees
ADD COLUMN IF NOT EXISTS department_id VARCHAR(32) REFERENCES departments(id) ON DELETE RESTRICT,
ADD COLUMN IF NOT EXISTS sub_department_id VARCHAR(32) REFERENCES departments(id) ON DELETE RESTRICT;

-- Index for foreign keys
CREATE INDEX IF NOT EXISTS idx_employees_department ON employees(department_id);
CREATE INDEX IF NOT EXISTS idx_employees_sub_department ON employees(sub_department_id);

-- 5. Backfill department and subcategory assignments for existing employees
-- Technical staff (EMP-101 through EMP-110)
UPDATE employees SET department_id = 'DEPT-TECH', sub_department_id = 'DEPT-TEC-FE'  WHERE id = 'EMP-101'; -- Arjun Sharma (Frontend)
UPDATE employees SET department_id = 'DEPT-TECH', sub_department_id = 'DEPT-TEC-BE'  WHERE id = 'EMP-102'; -- Priya Nair (Backend)
UPDATE employees SET department_id = 'DEPT-TECH', sub_department_id = 'DEPT-TEC-FS'  WHERE id = 'EMP-103'; -- Karthik R (Full Stack)
UPDATE employees SET department_id = 'DEPT-TECH', sub_department_id = 'DEPT-TEC-FE'  WHERE id = 'EMP-104'; -- Sneha V (Frontend)
UPDATE employees SET department_id = 'DEPT-TECH', sub_department_id = 'DEPT-TEC-MOB' WHERE id = 'EMP-105'; -- Rohan Mehta (Mobile)
UPDATE employees SET department_id = 'DEPT-TECH', sub_department_id = 'DEPT-TEC-AI'  WHERE id = 'EMP-106'; -- Ananya Deshmukh (AI/ML)
UPDATE employees SET department_id = 'DEPT-TECH', sub_department_id = 'DEPT-TEC-BE'  WHERE id = 'EMP-107'; -- Vikram Singh (Data Eng / Backend)
UPDATE employees SET department_id = 'DEPT-TECH', sub_department_id = 'DEPT-TEC-QA'  WHERE id = 'EMP-108'; -- Neha Patel (QA)
UPDATE employees SET department_id = 'DEPT-TECH', sub_department_id = 'DEPT-TEC-OPS' WHERE id = 'EMP-109'; -- Rahul Verma (DevOps)
UPDATE employees SET department_id = 'DEPT-TECH', sub_department_id = 'DEPT-TEC-UIX' WHERE id = 'EMP-110'; -- Divya Iyer (UI/UX)

-- HR staff
UPDATE employees SET department_id = 'DEPT-HR', sub_department_id = 'DEPT-HR-REC'     WHERE id = 'EMP-111'; -- Meera Joshi (HR/Recruitment)

-- Sales staff
UPDATE employees SET department_id = 'DEPT-SAL', sub_department_id = 'DEPT-SAL-BD'    WHERE id = 'EMP-112'; -- Rajesh Kumar (Sales/BD)

-- Marketing staff
UPDATE employees SET department_id = 'DEPT-MKT', sub_department_id = 'DEPT-MKT-DIG'   WHERE id = 'EMP-113'; -- Sanjay Menon (Marketing)

-- Finance staff (EMP-115) & Mapped operational staff (EMP-114)
UPDATE employees SET department_id = 'DEPT-FIN', sub_department_id = 'DEPT-FIN-BUD'   WHERE id = 'EMP-114'; -- Pooja Hegde (Operations Manager -> Finance Budgeting)
UPDATE employees SET department_id = 'DEPT-FIN', sub_department_id = 'DEPT-FIN-ACC'   WHERE id = 'EMP-115'; -- Siddharth Roy (Finance Lead -> Finance Accounts)

-- Customer Support / Growth (EMP-116 mapped to Sales Account Management)
UPDATE employees SET department_id = 'DEPT-SAL', sub_department_id = 'DEPT-SAL-ACC'   WHERE id = 'EMP-116'; -- Kavita Rao (Customer Support -> Sales Account Management)

-- Content / Communications (EMP-117 mapped to Marketing Content Marketing)
UPDATE employees SET department_id = 'DEPT-MKT', sub_department_id = 'DEPT-MKT-CNT'   WHERE id = 'EMP-117'; -- Aditya Sen (Communications -> Marketing Content)

-- Administration Lead (EMP-118 mapped to HR Onboarding & Workplace Operations)
UPDATE employees SET department_id = 'DEPT-HR', sub_department_id = 'DEPT-HR-ONB'     WHERE id = 'EMP-118'; -- Shreya Kulkarni (Admin Lead -> HR Onboarding)

-- 6. Enforce that department_id is NOT NULL for all active employees
ALTER TABLE employees
ALTER COLUMN department_id SET NOT NULL;

-- 7. Trigger to validate that employee.department_id is a root department,
--    and employee.sub_department_id (if present) is a child of employee.department_id.
CREATE OR REPLACE FUNCTION fn_validate_employee_department_assignment()
RETURNS TRIGGER AS $$
DECLARE
    v_dept_parent VARCHAR(32);
    v_sub_parent VARCHAR(32);
BEGIN
    -- department_id MUST be a top-level department (parent_id IS NULL)
    SELECT parent_id INTO v_dept_parent
    FROM departments
    WHERE id = NEW.department_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Department with ID "%" does not exist.', NEW.department_id;
    END IF;

    IF v_dept_parent IS NOT NULL THEN
        RAISE EXCEPTION 'Primary department assignment "%" must be a top-level department, not a subcategory.', NEW.department_id;
    END IF;

    -- sub_department_id (if specified) MUST have parent_id == department_id
    IF NEW.sub_department_id IS NOT NULL THEN
        SELECT parent_id INTO v_sub_parent
        FROM departments
        WHERE id = NEW.sub_department_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Subcategory department with ID "%" does not exist.', NEW.sub_department_id;
        END IF;

        IF v_sub_parent IS NULL OR v_sub_parent != NEW.department_id THEN
            RAISE EXCEPTION 'Subcategory "%" does not belong to the assigned primary department "%".', NEW.sub_department_id, NEW.department_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validate_employee_department ON employees;
CREATE TRIGGER trg_validate_employee_department
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW EXECUTE FUNCTION fn_validate_employee_department_assignment();
