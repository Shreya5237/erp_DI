-- ==============================================================================
-- DIGITAL INERTIA ERP — MIGRATION V7
-- File: V7__sales_workspace_and_activities.sql
-- Description: Safe additive enhancements for Sales Workspace:
--              1. Pipeline tracking fields on leads table (finance approval, lost reason, handover project).
--              2. Dedicated sales_activities table for calls, meetings, follow-ups.
-- ==============================================================================

-- 1. Additive fields on leads
ALTER TABLE leads ADD COLUMN IF NOT EXISTS finance_approved BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE leads ADD COLUMN IF NOT EXISTS lost_reason TEXT;
ALTER TABLE leads ADD COLUMN IF NOT EXISTS handover_project_id VARCHAR(32) REFERENCES projects(id) ON DELETE SET NULL;

-- 2. Dedicated sales activities table
CREATE TABLE IF NOT EXISTS sales_activities (
    id VARCHAR(32) PRIMARY KEY,
    lead_id VARCHAR(32) REFERENCES leads(id) ON DELETE CASCADE,
    activity_type VARCHAR(50) NOT NULL DEFAULT 'call', -- 'call', 'meeting', 'follow_up', 'note'
    title VARCHAR(200) NOT NULL,
    description TEXT,
    contact_name VARCHAR(100),
    contact_phone VARCHAR(30),
    scheduled_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    outcome VARCHAR(50),
    deal_value NUMERIC(12, 2) DEFAULT 0.00,
    priority VARCHAR(20) DEFAULT 'medium',
    performed_by_id VARCHAR(32) REFERENCES employees(id),
    performed_by_name VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sales_activities_lead ON sales_activities(lead_id);
CREATE INDEX IF NOT EXISTS idx_sales_activities_type ON sales_activities(activity_type);
CREATE INDEX IF NOT EXISTS idx_sales_activities_performer ON sales_activities(performed_by_id);
CREATE INDEX IF NOT EXISTS idx_sales_activities_scheduled ON sales_activities(scheduled_at);

-- 3. Initial seed of sales activities for existing leads (idempotent)
INSERT INTO sales_activities (id, lead_id, activity_type, title, description, contact_name, contact_phone, scheduled_at, is_completed, outcome, deal_value, priority, performed_by_id, performed_by_name)
VALUES
('ACT-701', 'LED-501', 'call', 'Introductory Discovery Call', 'Discussed unified carbon offset tracking software for solar farms', 'Vikramaditya Rao', '+91 98450 12001', NOW() - INTERVAL '2 days', TRUE, 'interested', 35000.00, 'high', 'EMP-112', 'Rajesh Kumar'),
('ACT-702', 'LED-502', 'meeting', 'Architecture Alignment Meeting', 'Flutter mobile integration scope and PCI payment gateway requirements', 'Sarah Al-Mansoor', '+971 50 123 4567', NOW() - INTERVAL '1 day', TRUE, 'completed', 48000.00, 'high', 'EMP-112', 'Rajesh Kumar'),
('ACT-703', 'LED-503', 'follow_up', 'Proposal Commercial Review', 'Follow-up regarding IoT asset monitoring portal commercial proposal', 'Ramesh Namboodiri', '+91 98200 45003', NOW() + INTERVAL '1 day', FALSE, 'pending', 62000.00, 'urgent', 'EMP-112', 'Rajesh Kumar'),
('ACT-704', 'LED-505', 'call', 'Security Engine Inquiry Call', 'Follow-up call on AWS Cloud Security Posture Management engine', 'Marcus Vance', '+1 415 889 0105', NOW() - INTERVAL '3 days', FALSE, 'overdue', 85000.00, 'urgent', 'EMP-112', 'Rajesh Kumar'),
('ACT-705', 'LED-504', 'meeting', 'Strategy Review & Feasibility Check', 'Reviewing rooftop solar installation partner telemetry feasibility', 'Kavitha Balasubramanian', '+91 98410 78004', NOW() + INTERVAL '2 days', FALSE, 'scheduled', 28000.00, 'medium', 'EMP-112', 'Rajesh Kumar')
ON CONFLICT (id) DO NOTHING;
