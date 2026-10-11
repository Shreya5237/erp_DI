-- ==============================================================================
-- V2: Core Master and Operational Tables
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
    role VARCHAR(32) NOT NULL DEFAULT 'ROLE_POC', -- ROLE_CEO, ROLE_POC, ROLE_INTERN
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
