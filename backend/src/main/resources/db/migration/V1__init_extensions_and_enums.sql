-- ==============================================================================
-- V1: Extensions and PostgreSQL Custom Enums
-- ==============================================================================

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
