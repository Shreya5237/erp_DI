-- ==============================================================================
-- V3: Performance Indexes & Real-time Analytical Views
-- ==============================================================================

-- 1. Performance Indexes
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

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- 2. Extended Views

-- View: vw_tasks_extended
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

-- View: vw_leads_extended
CREATE OR REPLACE VIEW vw_leads_extended AS
SELECT
    l.*,
    CASE
        WHEN l.stage NOT IN ('won', 'lost') AND l.next_follow_up < CURRENT_DATE THEN TRUE
        ELSE FALSE
    END AS is_follow_up_missed
FROM leads l;

-- View: vw_dashboard_kpis
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

-- View: vw_tasks_overview
CREATE OR REPLACE VIEW vw_tasks_overview AS
SELECT
    COUNT(*) AS total_tasks,
    COUNT(*) FILTER (WHERE status = 'completed') AS completed_count,
    COUNT(*) FILTER (WHERE status = 'in_progress') AS in_progress_count,
    COUNT(*) FILTER (WHERE status = 'todo') AS todo_count,
    COUNT(*) FILTER (WHERE status != 'completed' AND due_date < CURRENT_DATE) AS overdue_count,
    COUNT(*) FILTER (WHERE status = 'needs_rework') AS needs_rework_count
FROM tasks;

-- View: vw_active_threshold_alerts
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
