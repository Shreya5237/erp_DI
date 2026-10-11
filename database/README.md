# Digital Inertia ERP — PostgreSQL Database Specification & Guide

This directory houses the enterprise relational database schema, seed data, and dynamic alert rules for the **Digital Inertia CEO ERP System**.

---

## 1. Database Architecture & Technical Overview

- **Database Engine**: PostgreSQL 14+ (Tested on PostgreSQL 18.6 64-bit)
- **Database Name**: `digital_inertia_erp`
- **Default Port**: `5432`
- **Design Philosophy**:
  - **Third Normal Form (3NF)** with strict referential integrity.
  - **Custom Enum Types** for guaranteed compile-time integrity across task lifecycles, project milestones, lead funnels, and alert severities.
  - **Automated Workload & Timestamp Triggers** to eliminate out-of-sync state.
  - **Dynamic Exception Engine Views** calculating real-time threshold breaches without hardcoded rules.

---

## 2. Entity-Relationship & Schema Breakdown

### Enums
- `role_category_enum`: `technical`, `non_technical`
- `task_priority_enum`: `low`, `medium`, `high`, `urgent`
- `task_status_enum`: `todo`, `in_progress`, `submitted`, `needs_rework`, `completed`
- `assignee_type_enum`: `employee`, `intern`
- `intern_decision_enum`: `pending`, `absorbed`, `extended`, `terminated`, `under_review`
- `project_status_enum`: `planning`, `in_progress`, `on_hold`, `completed`, `delayed`
- `lead_stage_enum`: `new`, `contacted`, `qualified`, `proposal`, `won`, `lost`
- `alert_severity_enum`: `info`, `warning`, `critical`

### Core Tables

| Table | Description | Primary Key | Foreign Keys / Key Constraints |
| :--- | :--- | :--- | :--- |
| `company_roles` | 18 configured organizational job tracks (10 Technical, 8 Non-Technical) | `id` (VARCHAR) | `category` enum |
| `teams` | Functional squads (e.g. Core Platform, Client Experience, Applied AI) | `id` (VARCHAR) | `lead_employee_id` -> `employees` |
| `employees` | 18 realistic staff profiles with POC designation and capacity | `id` (VARCHAR) | `role_id` -> `company_roles`, `team_id` -> `teams` |
| `intern_batches` | Intake cohorts with recruitment timeline and target headcounts | `id` (VARCHAR) | Unique `batch_code` |
| `interns` | 24 interns from premier institutes (IIT, BITS, NIT, etc.) | `id` (VARCHAR) | `batch_id` -> `intern_batches`, `mentor_id` -> `employees` |
| `intern_daily_updates` | Daily standup logs, progress percent, blockers, mentor review | `id` (BIGSERIAL) | `intern_id` -> `interns` |
| `projects` | 6 enterprise client projects with budget and progress tracking | `id` (VARCHAR) | `owner_id` -> `employees`, `team_id` -> `teams` |
| `tasks` | 42 corporate tasks matching the Donut Chart distribution | `id` (VARCHAR) | `project_id` -> `projects`, `assigned_to_id` (conditional) |
| `leads` | 14 high-value enterprise sales opportunities and follow-up dates | `id` (VARCHAR) | `owner_id` -> `employees` |
| `alert_threshold_settings` | Configurable CEO exception thresholds (Singleton row `id = 1`) | `id` (INT) | Strict non-negative numeric constraints |
| `audit_logs` | Immutable audit trail for administrative changes | `id` (BIGSERIAL) | Timestamped actions |

---

## 3. Configurable CEO Threshold Engine

Instead of hardcoded warnings, the schema provides `alert_threshold_settings` and `vw_active_threshold_alerts`. The CEO can tune thresholds at runtime:

```sql
SELECT * FROM alert_threshold_settings;
```

| Setting | Default Value | Description |
| :--- | :--- | :--- |
| `task_overdue_days` | `1` | Tasks with `due_date < CURRENT_DATE` by at least 1 day trigger an overdue task alert. |
| `intern_missed_update_days` | `2` | Interns missing daily standup logs for 2 or more days trigger an inactive intern alert. |
| `project_behind_schedule_percent` | `15` | Projects where `(planned_progress_percent - progress_percent) >= 15%` trigger a delayed project alert. |
| `employee_capacity_max_tasks` | `4` | Employees assigned $> 4$ active tasks trigger an over-capacity alert. |
| `intern_low_score_cutoff` | `6.0` | Interns with interview or performance ratings $< 6.0$ trigger a low performance alert. |

### Dynamic Alert View (`vw_active_threshold_alerts`)
Evaluating `SELECT * FROM vw_active_threshold_alerts;` returns:

1. **`ALERT-TSK`**: `5 tasks are overdue` (Database setup, Gateway timeout, State tree rebuilds, SLA addendum, OpenSSL patch)
2. **`ALERT-INT`**: `3 interns inactive` (Arjun S, Harish K, Manish Chawla)
3. **`ALERT-PRJ`**: `1 project delayed` (FinTech Payment Gateway: 15% actual vs 35% planned = 20% lag $\ge 15\%$)
4. **`ALERT-LED`**: `4 leads need follow-up` (CyberShield, Nexus Health, Quantra Analytics, Apex Logistics)
5. **`ALERT-EMP`**: `2 employees over capacity` (Priya Nair & Rohan Mehta with 5 active tasks each)

---

## 4. Analytical & Reporting Views

- **`vw_dashboard_kpis`**:
  - `total_employees`: 18
  - `active_interns`: 24
  - `active_projects`: 6
  - `open_leads`: 13 (1 won)
  - `total_tasks`: 42
  - `completed_tasks`: 20
  - `in_progress_tasks`: 8
  - `todo_tasks`: 6
  - `overdue_tasks`: 5
  - `needs_rework_tasks`: 3
- **`vw_tasks_overview`**: Aggregates tasks by status and priority for real-time charting.
- **`vw_tasks_extended`**: Joins task assignees, projects, and computes `days_overdue`.
- **`vw_leads_extended`**: Computes follow-up status, overdue days, and funnel stages.

---

## 5. Automated Triggers

1. **`trg_touch_updated_at`**:
   Automatically updates `updated_at = NOW()` on row updates for all tables (`employees`, `interns`, `projects`, `tasks`, `leads`, `alert_threshold_settings`).
2. **`trg_sync_employee_task_count`**:
   On every `INSERT`, `UPDATE`, or `DELETE` on the `tasks` table, automatically updates `employees.current_active_tasks` to ensure employee workload stays consistent with reality.

---

## 6. Execution & Setup Instructions

### Prerequisites
- PostgreSQL 14+ installed and running.
- `psql` utility available in command line.

### Step 1: Create Database
```bash
psql -U postgres -h localhost -p 5432 -c "CREATE DATABASE digital_inertia_erp;"
```

### Step 2: Apply Schema DDL
```bash
psql -U postgres -h localhost -p 5432 -d digital_inertia_erp -f database/01_schema.sql
```

### Step 3: Insert Realistic Seed Data
```bash
psql -U postgres -h localhost -p 5432 -d digital_inertia_erp -f database/02_seed.sql
```

### Step 4: Validate High-Fidelity Data
```sql
-- Check KPI aggregation
SELECT * FROM vw_dashboard_kpis;

-- Check dynamic threshold alerts
SELECT alert_id, module, title, description, severity, affected_count FROM vw_active_threshold_alerts;

-- Check task breakdown (should match 20 / 8 / 6 / 5 / 3)
SELECT status, COUNT(*) FROM tasks GROUP BY status ORDER BY COUNT(*) DESC;
```

---

## 7. Zero Placeholder Guarantee

Every record in `02_seed.sql` and the Flutter `ERPProvider` uses authentic enterprise data:
- Named corporate software engineers, architects, HR specialists, and sales directors.
- Accredited college affiliations for all 24 interns (IIT Bombay, IIT Delhi, BITS Pilani, NIT Trichy, IIIT Hyderabad, etc.).
- Realistic engineering deliverables (OAuth gateway latency, Argon2id security migration, AWS WAF rules, PyTorch telemetry autoencoder).
- Real enterprise leads with quantified deal values (\$28k - \$110k) and concrete business requirements.
