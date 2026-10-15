-- ==============================================================================
-- DIGITAL INERTIA ERP - POSTGRESQL DATABASE SCHEMA
-- Database: digital_inertia_erp
-- Version: 1.0.0
-- Architecture: Normalized Multi-Domain Corporate ERP Schema
-- ==============================================================================

-- 1. EXTENSIONS & ENUMS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Role Category Enum (Technical vs Non-Technical)
DO $$ BEGIN
    CREATE TYPE role_category_enum AS ENUM ('technical', 'non_technical');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- Task Priority Enum
DO $$ BEGIN
    CREATE TYPE task_priority_enum AS ENUM ('low', 'medium', 'high', 'urgent');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- Task Status Enum (Matches CEO Dashboard & Donut Chart Breakdown)
DO $$ BEGIN
    CREATE TYPE task_status_enum AS ENUM ('todo', 'in_progress', 'needs_rework', 'completed');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- Assignee Type Enum
DO $$ BEGIN
    CREATE TYPE assignee_type_enum AS ENUM ('employee', 'intern');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- Intern Decision Enum
DO $$ BEGIN
    CREATE TYPE intern_decision_enum AS ENUM ('under_review', 'absorbed', 'extended', 'rejected');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- Project Status Enum
DO $$ BEGIN
    CREATE TYPE project_status_enum AS ENUM ('planning', 'in_progress', 'on_hold', 'completed');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- Lead Pipeline Stage Enum
DO $$ BEGIN
    CREATE TYPE lead_stage_enum AS ENUM ('new', 'contacted', 'proposal', 'qualified', 'won', 'lost');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- Alert Severity Enum
DO $$ BEGIN
    CREATE TYPE alert_severity_enum AS ENUM ('info', 'warning', 'critical');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- ==============================================================================
-- 2. CORE MASTER TABLES
-- ==============================================================================

-- Table: company_roles (Configurable role registry)
CREATE TABLE IF NOT EXISTS company_roles (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    category role_category_enum NOT NULL,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: teams
CREATE TABLE IF NOT EXISTS teams (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    category role_category_enum NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: employees (People Management - Full-time Staff)
CREATE TABLE IF NOT EXISTS employees (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(30),
    role_id VARCHAR(32) NOT NULL REFERENCES company_roles(id),
    role_title VARCHAR(100) NOT NULL,
    team_id VARCHAR(32) REFERENCES teams(id),
    team_name VARCHAR(100) NOT NULL,
    category role_category_enum NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_poc BOOLEAN NOT NULL DEFAULT FALSE,
    max_task_capacity INT NOT NULL DEFAULT 5 CHECK (max_task_capacity > 0),
    current_active_tasks INT NOT NULL DEFAULT 0 CHECK (current_active_tasks >= 0),
    avatar_url TEXT,
    joined_date DATE NOT NULL DEFAULT CURRENT_DATE,
    last_active_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: users (Authentication and Role-Based Authorization)
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(32) PRIMARY KEY,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(32) NOT NULL DEFAULT 'ROLE_TECH',
    employee_id VARCHAR(32) REFERENCES employees(id) ON DELETE SET NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: intern_batches (Intake Batches)
CREATE TABLE IF NOT EXISTS intern_batches (
    id VARCHAR(32) PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_interns INT NOT NULL DEFAULT 0 CHECK (total_interns >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: interns (People Management - Intern Cohort)
CREATE TABLE IF NOT EXISTS interns (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(30),
    college VARCHAR(150) NOT NULL,
    category role_category_enum NOT NULL DEFAULT 'technical',
    domain VARCHAR(100) NOT NULL,
    team_id VARCHAR(32) REFERENCES teams(id),
    team_name VARCHAR(100) NOT NULL,
    batch_id VARCHAR(32) NOT NULL REFERENCES intern_batches(id),
    assigned_poc_id VARCHAR(32) REFERENCES employees(id),
    interview_score NUMERIC(3, 1) NOT NULL CHECK (interview_score >= 0.0 AND interview_score <= 10.0),
    performance_score NUMERIC(3, 1) NOT NULL DEFAULT 7.5 CHECK (performance_score >= 0.0 AND performance_score <= 10.0),
    missed_updates_days INT NOT NULL DEFAULT 0 CHECK (missed_updates_days >= 0),
    selection_date DATE NOT NULL DEFAULT CURRENT_DATE,
    final_decision intern_decision_enum NOT NULL DEFAULT 'under_review',
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: intern_daily_updates
CREATE TABLE IF NOT EXISTS intern_daily_updates (
    id BIGSERIAL PRIMARY KEY,
    intern_id VARCHAR(32) NOT NULL REFERENCES interns(id) ON DELETE CASCADE,
    update_date DATE NOT NULL DEFAULT CURRENT_DATE,
    tasks_completed TEXT NOT NULL,
    blockers TEXT,
    hours_logged NUMERIC(4, 1) NOT NULL DEFAULT 8.0 CHECK (hours_logged >= 0.0 AND hours_logged <= 24.0),
    status VARCHAR(20) NOT NULL DEFAULT 'submitted',
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_intern_daily_date UNIQUE (intern_id, update_date)
);

-- Table: projects
CREATE TABLE IF NOT EXISTS projects (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    client_name VARCHAR(150) NOT NULL,
    domain VARCHAR(100) NOT NULL,
    status project_status_enum NOT NULL DEFAULT 'in_progress',
    progress_percent INT NOT NULL DEFAULT 0 CHECK (progress_percent >= 0 AND progress_percent <= 100),
    planned_progress_percent INT NOT NULL DEFAULT 0 CHECK (planned_progress_percent >= 0 AND planned_progress_percent <= 100),
    behind_schedule_percent INT GENERATED ALWAYS AS (GREATEST(0, planned_progress_percent - progress_percent)) STORED,
    owner_id VARCHAR(32) REFERENCES employees(id),
    team_id VARCHAR(32) REFERENCES teams(id),
    budget NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (budget >= 0.00),
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    deadline DATE NOT NULL,
    has_blockers BOOLEAN NOT NULL DEFAULT FALSE,
    blocker_details TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: tasks
CREATE TABLE IF NOT EXISTS tasks (
    id VARCHAR(32) PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    domain VARCHAR(100) NOT NULL,
    status task_status_enum NOT NULL DEFAULT 'todo',
    priority task_priority_enum NOT NULL DEFAULT 'medium',
    assigned_to_id VARCHAR(32) NOT NULL,
    assigned_to_name VARCHAR(100) NOT NULL,
    assignee_type assignee_type_enum NOT NULL DEFAULT 'employee',
    assigned_by_id VARCHAR(32) REFERENCES employees(id),
    assigned_by_name VARCHAR(100),
    project_id VARCHAR(32) REFERENCES projects(id) ON DELETE SET NULL,
    project_name VARCHAR(150),
    due_date DATE NOT NULL,
    awaiting_review BOOLEAN NOT NULL DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: leads
CREATE TABLE IF NOT EXISTS leads (
    id VARCHAR(32) PRIMARY KEY,
    company_name VARCHAR(150) NOT NULL,
    client_name VARCHAR(100) NOT NULL,
    domain VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    phone VARCHAR(30),
    stage lead_stage_enum NOT NULL DEFAULT 'new',
    deal_value NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (deal_value >= 0.00),
    owner_id VARCHAR(32) REFERENCES employees(id),
    owner_name VARCHAR(100) NOT NULL,
    next_follow_up DATE NOT NULL,
    source VARCHAR(100) NOT NULL DEFAULT 'Direct Outreach',
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: alert_threshold_settings (Configurable corporate thresholds)
CREATE TABLE IF NOT EXISTS alert_threshold_settings (
    id INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    task_overdue_days INT NOT NULL DEFAULT 1 CHECK (task_overdue_days >= 0),
    intern_missed_update_days INT NOT NULL DEFAULT 2 CHECK (intern_missed_update_days >= 0),
    project_behind_schedule_percent INT NOT NULL DEFAULT 15 CHECK (project_behind_schedule_percent >= 0 AND project_behind_schedule_percent <= 100),
    employee_capacity_max_tasks INT NOT NULL DEFAULT 4 CHECK (employee_capacity_max_tasks >= 1),
    intern_low_score_cutoff NUMERIC(3, 1) NOT NULL DEFAULT 6.0 CHECK (intern_low_score_cutoff >= 0.0 AND intern_low_score_cutoff <= 10.0),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Table: audit_logs
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGSERIAL PRIMARY KEY,
    action VARCHAR(100) NOT NULL,
    module VARCHAR(50) NOT NULL,
    details TEXT NOT NULL,
    performed_by VARCHAR(100) NOT NULL DEFAULT 'Laven Lokesh (CEO)',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- 3. PERFORMANCE INDEXES
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_employees_role ON employees(role_id);
CREATE INDEX IF NOT EXISTS idx_employees_team ON employees(team_id);
CREATE INDEX IF NOT EXISTS idx_employees_category ON employees(category);
CREATE INDEX IF NOT EXISTS idx_employees_is_active ON employees(is_active);

CREATE INDEX IF NOT EXISTS idx_interns_batch ON interns(batch_id);
CREATE INDEX IF NOT EXISTS idx_interns_assigned_poc ON interns(assigned_poc_id);
CREATE INDEX IF NOT EXISTS idx_interns_category ON interns(category);
CREATE INDEX IF NOT EXISTS idx_interns_domain ON interns(domain);
CREATE INDEX IF NOT EXISTS idx_interns_missed_updates ON interns(missed_updates_days);

CREATE INDEX IF NOT EXISTS idx_tasks_assigned_to ON tasks(assigned_to_id, assignee_type);
CREATE INDEX IF NOT EXISTS idx_tasks_project ON tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_tasks_domain ON tasks(domain);

CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS idx_projects_owner ON projects(owner_id);

CREATE INDEX IF NOT EXISTS idx_leads_stage ON leads(stage);
CREATE INDEX IF NOT EXISTS idx_leads_owner ON leads(owner_id);
CREATE INDEX IF NOT EXISTS idx_leads_follow_up ON leads(next_follow_up);

-- ==============================================================================
-- 4. REAL-TIME EXTENDED VIEWS
-- ==============================================================================

-- View: vw_tasks_extended (Includes dynamically computed overdue days)
CREATE OR REPLACE VIEW vw_tasks_extended AS
SELECT
    t.*,
    CASE
        WHEN t.status != 'completed' AND t.due_date < CURRENT_DATE THEN (CURRENT_DATE - t.due_date)
        ELSE 0
    END AS days_overdue,
    CASE
        WHEN t.status != 'completed' AND t.due_date < CURRENT_DATE THEN TRUE
        ELSE FALSE
    END AS is_overdue
FROM tasks t;

-- View: vw_leads_extended (Includes dynamically computed missed follow-up flag)
CREATE OR REPLACE VIEW vw_leads_extended AS
SELECT
    l.*,
    CASE
        WHEN l.stage NOT IN ('won', 'lost') AND l.next_follow_up < CURRENT_DATE THEN TRUE
        ELSE FALSE
    END AS is_follow_up_missed
FROM leads l;

-- View: vw_dashboard_kpis (CEO Dashboard Top Metrics)
CREATE OR REPLACE VIEW vw_dashboard_kpis AS
SELECT
    (SELECT COUNT(*) FROM employees WHERE is_active = TRUE) AS total_employees,
    (SELECT COUNT(*) FROM interns WHERE is_active = TRUE) AS active_interns,
    (SELECT COUNT(*) FROM tasks WHERE status IN ('todo', 'in_progress', 'needs_rework')) AS pending_tasks,
    (SELECT COUNT(*) FROM projects WHERE status IN ('planning', 'in_progress', 'on_hold')) AS active_projects,
    (SELECT COUNT(*) FROM leads WHERE is_active = TRUE AND stage NOT IN ('lost')) AS active_leads,
    (SELECT COUNT(*) FROM tasks WHERE status != 'completed' AND due_date < CURRENT_DATE) AS overdue_tasks,
    (
        SELECT COUNT(*)
        FROM projects p, alert_threshold_settings t
        WHERE p.behind_schedule_percent >= t.project_behind_schedule_percent
          AND p.status IN ('planning', 'in_progress')
    ) AS delayed_projects;

-- View: vw_tasks_overview (CEO Donut Chart Distribution)
CREATE OR REPLACE VIEW vw_tasks_overview AS
SELECT
    COUNT(*) AS total_tasks,
    COUNT(*) FILTER (WHERE status = 'completed') AS completed_count,
    COUNT(*) FILTER (WHERE status = 'in_progress') AS in_progress_count,
    COUNT(*) FILTER (WHERE status = 'todo') AS todo_count,
    COUNT(*) FILTER (WHERE status != 'completed' AND due_date < CURRENT_DATE) AS overdue_count,
    COUNT(*) FILTER (WHERE status = 'needs_rework') AS needs_rework_count
FROM tasks;

-- View: vw_active_threshold_alerts (Executive Exception Engine)
CREATE OR REPLACE VIEW vw_active_threshold_alerts AS
WITH cfg AS (
    SELECT * FROM alert_threshold_settings WHERE id = 1
)
-- 1. Overdue Tasks Alert
SELECT
    'ALERT-TSK'::VARCHAR AS alert_id,
    'Tasks'::VARCHAR AS module,
    (COUNT(*) || ' tasks are overdue')::VARCHAR AS title,
    'Needs immediate attention.'::VARCHAR AS description,
    'critical'::alert_severity_enum AS severity,
    COUNT(*)::INT AS affected_count,
    NOW() AS triggered_at
FROM tasks t, cfg c
WHERE t.status != 'completed' AND t.due_date <= (CURRENT_DATE - (c.task_overdue_days || ' days')::INTERVAL)
HAVING COUNT(*) > 0

UNION ALL

-- 2. Inactive Interns Alert
SELECT
    'ALERT-INT'::VARCHAR AS alert_id,
    'Interns'::VARCHAR AS module,
    (COUNT(*) || ' interns inactive')::VARCHAR AS title,
    ('No updates for ' || (c.intern_missed_update_days) || '+ days.')::VARCHAR AS description,
    'warning'::alert_severity_enum AS severity,
    COUNT(*)::INT AS affected_count,
    NOW() AS triggered_at
FROM interns i, cfg c
WHERE i.is_active = TRUE AND i.missed_updates_days >= c.intern_missed_update_days
GROUP BY c.intern_missed_update_days
HAVING COUNT(*) > 0

UNION ALL

-- 3. Delayed Projects Alert
SELECT
    'ALERT-PRJ'::VARCHAR AS alert_id,
    'Projects'::VARCHAR AS module,
    (COUNT(*) || ' project delayed')::VARCHAR AS title,
    ('Milestone behind schedule (' || c.project_behind_schedule_percent || '%+ behind).')::VARCHAR AS description,
    'critical'::alert_severity_enum AS severity,
    COUNT(*)::INT AS affected_count,
    NOW() AS triggered_at
FROM projects p, cfg c
WHERE p.status IN ('planning', 'in_progress') AND p.behind_schedule_percent >= c.project_behind_schedule_percent
GROUP BY c.project_behind_schedule_percent
HAVING COUNT(*) > 0

UNION ALL

-- 4. Leads Requiring Follow-up Alert
SELECT
    'ALERT-LED'::VARCHAR AS alert_id,
    'Leads'::VARCHAR AS module,
    (COUNT(*) || ' leads need follow-up')::VARCHAR AS title,
    'Next contact date missed.'::VARCHAR AS description,
    'warning'::alert_severity_enum AS severity,
    COUNT(*)::INT AS affected_count,
    NOW() AS triggered_at
FROM leads l
WHERE l.stage NOT IN ('won', 'lost') AND l.next_follow_up < CURRENT_DATE
HAVING COUNT(*) > 0

UNION ALL

-- 5. Employee Capacity Alerts
SELECT
    'ALERT-EMP'::VARCHAR AS alert_id,
    'Employees'::VARCHAR AS module,
    (COUNT(*) || ' employees over capacity')::VARCHAR AS title,
    ('Workload > ' || c.employee_capacity_max_tasks || ' tasks assigned.')::VARCHAR AS description,
    'warning'::alert_severity_enum AS severity,
    COUNT(*)::INT AS affected_count,
    NOW() AS triggered_at
FROM employees e, cfg c
WHERE e.is_active = TRUE AND e.current_active_tasks > c.employee_capacity_max_tasks
GROUP BY c.employee_capacity_max_tasks
HAVING COUNT(*) > 0;

-- ==============================================================================
-- 5. STORED FUNCTIONS & TRIGGERS
-- ==============================================================================

-- Automatic updated_at timestamp refresher
CREATE OR REPLACE FUNCTION fn_touch_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_touch_employees ON employees;
CREATE TRIGGER trg_touch_employees BEFORE UPDATE ON employees
FOR EACH ROW EXECUTE FUNCTION fn_touch_updated_at();

DROP TRIGGER IF EXISTS trg_touch_interns ON interns;
CREATE TRIGGER trg_touch_interns BEFORE UPDATE ON interns
FOR EACH ROW EXECUTE FUNCTION fn_touch_updated_at();

DROP TRIGGER IF EXISTS trg_touch_projects ON projects;
CREATE TRIGGER trg_touch_projects BEFORE UPDATE ON projects
FOR EACH ROW EXECUTE FUNCTION fn_touch_updated_at();

DROP TRIGGER IF EXISTS trg_touch_tasks ON tasks;
CREATE TRIGGER trg_touch_tasks BEFORE UPDATE ON tasks
FOR EACH ROW EXECUTE FUNCTION fn_touch_updated_at();

DROP TRIGGER IF EXISTS trg_touch_leads ON leads;
CREATE TRIGGER trg_touch_leads BEFORE UPDATE ON leads
FOR EACH ROW EXECUTE FUNCTION fn_touch_updated_at();

-- Synchronize employee task count on task assignment changes
CREATE OR REPLACE FUNCTION fn_sync_employee_task_count()
RETURNS TRIGGER AS $$
BEGIN
    -- Update previous assignee if employee
    IF (TG_OP = 'UPDATE' OR TG_OP = 'DELETE') THEN
        IF OLD.assignee_type = 'employee' THEN
            UPDATE employees
            SET current_active_tasks = (
                SELECT COUNT(*)
                FROM tasks
                WHERE assigned_to_id = OLD.assigned_to_id
                  AND assignee_type = 'employee'
                  AND status != 'completed'
            )
            WHERE id = OLD.assigned_to_id;
        END IF;
    END IF;

    -- Update new assignee if employee
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        IF NEW.assignee_type = 'employee' THEN
            UPDATE employees
            SET current_active_tasks = (
                SELECT COUNT(*)
                FROM tasks
                WHERE assigned_to_id = NEW.assigned_to_id
                  AND assignee_type = 'employee'
                  AND status != 'completed'
            )
            WHERE id = NEW.assigned_to_id;
        END IF;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_sync_task_count ON tasks;
CREATE TRIGGER trg_sync_task_count
AFTER INSERT OR UPDATE OR DELETE ON tasks
FOR EACH ROW EXECUTE FUNCTION fn_sync_employee_task_count();
