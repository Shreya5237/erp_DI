-- ==============================================================================
-- V4: Stored Functions & Triggers
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
