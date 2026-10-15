-- ==============================================================================
-- DIGITAL INERTIA ERP - COMPREHENSIVE CORPORATE ENTERPRISE DATASET
-- Database: digital_inertia_erp
-- Structure: 5 Departments, 25 Classified Employees (+ CEO), 6 Projects
-- Projects: 4 In Progress / Ongoing (incl. Digital Marketing), 2 Completed
-- All Corporate Accounts: password123!
-- Real-Time Responsive Syncing
-- ==============================================================================

-- Clean existing data in order of foreign key dependencies
TRUNCATE TABLE audit_logs CASCADE;
TRUNCATE TABLE users CASCADE;
TRUNCATE TABLE intern_daily_updates CASCADE;
TRUNCATE TABLE tasks CASCADE;
TRUNCATE TABLE leads CASCADE;
TRUNCATE TABLE projects CASCADE;
TRUNCATE TABLE interns CASCADE;
TRUNCATE TABLE employees CASCADE;
TRUNCATE TABLE intern_batches CASCADE;
TRUNCATE TABLE teams CASCADE;
TRUNCATE TABLE company_roles CASCADE;

-- ------------------------------------------------------------------------------
-- 1. CONFIGURABLE ROLES (10 Technical + 8 Non-Technical Tracks)
-- ------------------------------------------------------------------------------
INSERT INTO company_roles (id, name, category, description) VALUES
('ROLE-FE', 'Frontend', 'technical', 'Web client architecture, React/Flutter UI, state machines and micro-frontends'),
('ROLE-BE', 'Backend', 'technical', 'High-throughput APIs, PostgreSQL data persistence, distributed services and microservices'),
('ROLE-FS', 'Full Stack', 'technical', 'End-to-end full stack application development across web and mobile services'),
('ROLE-MO', 'Mobile App', 'technical', 'Cross-platform native mobile applications in Flutter and Android/iOS toolchains'),
('ROLE-AI', 'AI / ML', 'technical', 'Predictive modeling, deep learning inference pipelines, telemetry analysis and LLM workflows'),
('ROLE-DE', 'Data Engineering', 'technical', 'ETL pipelines, schema migrations, stream processing, Apache Kafka and data lakes'),
('ROLE-QA', 'QA / Testing', 'technical', 'Automated regression test suites, Locust load benchmarking and end-to-end QA'),
('ROLE-DO', 'DevOps / Cloud', 'technical', 'Docker containerization, Kubernetes orchestration, CI/CD pipelines and cloud security'),
('ROLE-CS', 'Cybersecurity', 'technical', 'Zero-trust architecture, identity & access management, penetration testing and compliance'),
('ROLE-UX', 'UI/UX Engineering', 'technical', 'Design systems, human-centered UX design, design tokens and interactive Figma prototypes'),
('ROLE-HR', 'HR / Recruitment', 'non_technical', 'Campus talent acquisition, intern onboarding, culture and employee lifecycle management'),
('ROLE-SL', 'Sales / Business Development', 'non_technical', 'Enterprise pipeline development, B2B deal negotiation and client relationship management'),
('ROLE-MK', 'Marketing', 'non_technical', 'Growth marketing, technical product marketing, brand positioning and digital outreach'),
('ROLE-OP', 'Operations', 'non_technical', 'Resource capacity planning, company logistics, operational rhythm and process excellence'),
('ROLE-FN', 'Finance / Accounts', 'non_technical', 'Financial forecasting, revenue recognition, client invoicing, payroll and compliance audits'),
('ROLE-CSU', 'Customer Support', 'non_technical', 'Enterprise client SLAs, tier-2 technical support escalations and customer success'),
('ROLE-CC', 'Content / Communications', 'non_technical', 'Technical documentation, press releases, corporate whitepapers and stakeholder memos'),
('ROLE-AD', 'Administration', 'non_technical', 'Executive office operations, vendor management, workplace facilities and legal policies');

-- ------------------------------------------------------------------------------
-- 2. THE 5 CORPORATE OPERATING DEPARTMENTS
-- ------------------------------------------------------------------------------
INSERT INTO teams (id, name, category, description) VALUES
('DEPT-TECH', 'Technical', 'technical', 'Software engineering, system architecture, mobile apps, backend APIs, cloud, and QA'),
('DEPT-SM', 'Sales & Marketing', 'non_technical', 'Enterprise sales pipeline, client partnerships, B2B deal negotiation, and revenue growth'),
('DEPT-DM', 'Digital Marketing', 'non_technical', 'Omnichannel growth, PPC advertising, SEO architecture, brand engagement, and conversion tracking'),
('DEPT-HR', 'HR', 'non_technical', 'Talent acquisition, university recruitment cohorts, employee culture, performance, and compliance'),
('DEPT-FIN', 'Finance', 'non_technical', 'Financial planning, accounting ledgers, client invoicing, budget allocations, and audits');

-- ------------------------------------------------------------------------------
-- 3. EMPLOYEES (25 Employees Classified Exactly 5 Per Department + CEO & Specialist)
-- ------------------------------------------------------------------------------
INSERT INTO employees (id, name, email, phone, role_id, role_title, team_id, team_name, category, is_active, is_poc, max_task_capacity, current_active_tasks, joined_date) VALUES
-- DEPARTMENT 1: Technical (5 Employees)
('EMP-101', 'Arjun Sharma', 'arjun.sharma@digitalinertia.com', '+91 98201 14521', 'ROLE-FE', 'Lead Frontend Developer & Architect', 'DEPT-TECH', 'Technical', 'technical', TRUE, TRUE, 5, 2, '2023-04-15'),
('EMP-102', 'Priya Nair', 'priya.nair@digitalinertia.com', '+91 98450 78210', 'ROLE-BE', 'Senior Backend Developer & Database Lead', 'DEPT-TECH', 'Technical', 'technical', TRUE, TRUE, 5, 3, '2023-06-01'),
('EMP-103', 'Karthik R', 'karthik.r@digitalinertia.com', '+91 97112 65430', 'ROLE-FS', 'Full Stack Engineer & Cloud Integrations', 'DEPT-TECH', 'Technical', 'technical', TRUE, TRUE, 5, 2, '2023-08-10'),
('EMP-104', 'Sneha V', 'sneha.v@digitalinertia.com', '+91 99304 98124', 'ROLE-UX', 'Frontend UI & Design Systems Engineer', 'DEPT-TECH', 'Technical', 'technical', TRUE, FALSE, 5, 2, '2023-09-01'),
('EMP-105', 'Rohan Mehta', 'rohan.mehta@digitalinertia.com', '+91 98214 33219', 'ROLE-MO', 'Mobile App Lead (Flutter & Native)', 'DEPT-TECH', 'Technical', 'technical', TRUE, TRUE, 5, 2, '2023-11-15'),

-- DEPARTMENT 2: Sales & Marketing (5 Employees)
('EMP-201', 'Rajesh Kumar', 'rajesh.kumar@digitalinertia.com', '+91 98101 44321', 'ROLE-SL', 'VP Enterprise Sales & Client Partnerships', 'DEPT-SM', 'Sales & Marketing', 'non_technical', TRUE, TRUE, 5, 2, '2023-07-20'),
('EMP-202', 'Meera Sen', 'meera.sen@digitalinertia.com', '+91 98452 33410', 'ROLE-SL', 'Senior Account Executive & Enterprise Deals', 'DEPT-SM', 'Sales & Marketing', 'non_technical', TRUE, FALSE, 5, 2, '2023-09-12'),
('EMP-203', 'Vikram Malhotra', 'vikram.malhotra@digitalinertia.com', '+91 98203 77412', 'ROLE-SL', 'Business Development Manager', 'DEPT-SM', 'Sales & Marketing', 'non_technical', TRUE, TRUE, 5, 2, '2024-01-15'),
('EMP-204', 'Ananya Kapoor', 'ananya.kapoor@digitalinertia.com', '+91 98190 22345', 'ROLE-SL', 'Solutions Consultant & Deal Strategist', 'DEPT-SM', 'Sales & Marketing', 'non_technical', TRUE, FALSE, 5, 1, '2024-02-01'),
('EMP-205', 'Aditya Joshi', 'aditya.joshi@digitalinertia.com', '+91 98115 55620', 'ROLE-SL', 'Sales Operations & Inbound Lead Specialist', 'DEPT-SM', 'Sales & Marketing', 'non_technical', TRUE, FALSE, 5, 1, '2024-03-10'),

-- DEPARTMENT 3: Digital Marketing (5 Employees)
('EMP-301', 'Kavita Reddy', 'kavita.reddy@digitalinertia.com', '+91 98410 77650', 'ROLE-MK', 'Head of Digital Marketing & Growth', 'DEPT-DM', 'Digital Marketing', 'non_technical', TRUE, TRUE, 5, 2, '2023-10-01'),
('EMP-302', 'Sameer Deshmukh', 'sameer.deshmukh@digitalinertia.com', '+91 98210 99012', 'ROLE-MK', 'Performance Ads & PPC Campaign Manager', 'DEPT-DM', 'Digital Marketing', 'non_technical', TRUE, FALSE, 5, 2, '2023-11-20'),
('EMP-303', 'Pooja Hegde', 'pooja.hegde@digitalinertia.com', '+91 98211 22390', 'ROLE-MK', 'SEO & Organic Search Strategist', 'DEPT-DM', 'Digital Marketing', 'non_technical', TRUE, FALSE, 5, 2, '2023-12-05'),
('EMP-304', 'Naveen Chandra', 'naveen.chandra@digitalinertia.com', '+91 98300 88710', 'ROLE-CC', 'Social Media & Brand Engagement Lead', 'DEPT-DM', 'Digital Marketing', 'non_technical', TRUE, FALSE, 5, 1, '2024-02-15'),
('EMP-305', 'Rhea Pillai', 'rhea.pillai@digitalinertia.com', '+91 98402 11234', 'ROLE-UX', 'Creative Visual & Content Marketing Specialist', 'DEPT-DM', 'Digital Marketing', 'non_technical', TRUE, FALSE, 5, 2, '2024-04-01'),

-- DEPARTMENT 4: HR (5 Employees)
('EMP-401', 'Sunita Verma', 'sunita.verma@digitalinertia.com', '+91 98205 66780', 'ROLE-HR', 'Director of People & Culture', 'DEPT-HR', 'HR', 'non_technical', TRUE, TRUE, 5, 2, '2023-05-10'),
('EMP-402', 'Amitabh Roy', 'amitabh.roy@digitalinertia.com', '+91 98331 44590', 'ROLE-HR', 'Lead Talent Acquisition & University Hiring', 'DEPT-HR', 'HR', 'non_technical', TRUE, FALSE, 5, 2, '2023-08-25'),
('EMP-403', 'Neha Bansal', 'neha.bansal@digitalinertia.com', '+91 98110 99450', 'ROLE-HR', 'HR Operations & People Compliance', 'DEPT-HR', 'HR', 'non_technical', TRUE, FALSE, 5, 1, '2023-10-18'),
('EMP-404', 'Karan Singhania', 'karan.singhania@digitalinertia.com', '+91 98720 33008', 'ROLE-HR', 'Employee Experience & Learning Specialist', 'DEPT-HR', 'HR', 'non_technical', TRUE, FALSE, 5, 1, '2024-01-20'),
('EMP-405', 'Divya Nambiar', 'divya.nambiar@digitalinertia.com', '+91 98300 22009', 'ROLE-HR', 'Workforce Analytics & HR Business Partner', 'DEPT-HR', 'HR', 'non_technical', TRUE, FALSE, 5, 1, '2024-03-05'),

-- DEPARTMENT 5: Finance (5 Employees)
('EMP-501', 'Rameshwar Gupta', 'rameshwar.gupta@digitalinertia.com', '+91 98111 20005', 'ROLE-FN', 'Chief Financial Officer', 'DEPT-FIN', 'Finance', 'non_technical', TRUE, TRUE, 5, 1, '2023-03-01'),
('EMP-502', 'Shalini Rao', 'shalini.rao@digitalinertia.com', '+91 98200 45003', 'ROLE-FN', 'Financial Controller & Head of Accounts', 'DEPT-FIN', 'Finance', 'non_technical', TRUE, TRUE, 5, 2, '2023-06-15'),
('EMP-503', 'Manish Aggarwal', 'manish.aggarwal@digitalinertia.com', '+91 98410 78004', 'ROLE-FN', 'Senior Corporate Accountant & Ledger', 'DEPT-FIN', 'Finance', 'non_technical', TRUE, FALSE, 5, 1, '2023-09-01'),
('EMP-504', 'Deepak Chawla', 'deepak.chawla@digitalinertia.com', '+91 98450 12001', 'ROLE-FN', 'Financial Analyst & Budget Planning', 'DEPT-FIN', 'Finance', 'non_technical', TRUE, FALSE, 5, 2, '2024-01-10'),
('EMP-505', 'Tanvi Mathur', 'tanvi.mathur@digitalinertia.com', '+91 98311 44014', 'ROLE-FN', 'Billing, Payroll & Invoicing Specialist', 'DEPT-FIN', 'Finance', 'non_technical', TRUE, FALSE, 5, 2, '2024-02-28'),

-- Technical Specialist & Executive
('EMP-118', 'Shreya Kulkarni', 'shreya.kulkarni@digitalinertia.com', '+91 98204 11980', 'ROLE-FS', 'Technical Specialist & Full Stack Engineer', 'DEPT-TECH', 'Technical', 'technical', TRUE, TRUE, 5, 3, '2024-07-01');

-- ------------------------------------------------------------------------------
-- 4. INTERN INTAKE BATCHES
-- ------------------------------------------------------------------------------
INSERT INTO intern_batches (id, code, start_date, end_date, total_interns) VALUES
('BATCH-2025-W12', 'Batch Apr-A (2025)', '2025-04-01', '2025-06-30', 14),
('BATCH-2025-W14', 'Batch Apr-B (2025)', '2025-04-15', '2025-07-15', 10);

-- ------------------------------------------------------------------------------
-- 5. INTERNS
-- ------------------------------------------------------------------------------
INSERT INTO interns (id, name, email, phone, college, category, domain, team_id, team_name, batch_id, assigned_poc_id, interview_score, performance_score, missed_updates_days, selection_date, final_decision) VALUES
('INT-201', 'Aarav Gupta', 'aarav.gupta@collegemail.edu', '+91 98111 20001', 'IIT Bombay', 'technical', 'Backend', 'DEPT-TECH', 'Technical', 'BATCH-2025-W12', 'EMP-102', 9.2, 8.8, 0, '2025-03-20', 'absorbed'),
('INT-202', 'Bhavya Shah', 'bhavya.shah@collegemail.edu', '+91 98111 20002', 'BITS Pilani', 'technical', 'Frontend', 'DEPT-TECH', 'Technical', 'BATCH-2025-W12', 'EMP-101', 8.9, 8.4, 0, '2025-03-20', 'under_review'),
('INT-203', 'Chirag Mathur', 'chirag.mathur@collegemail.edu', '+91 98111 20003', 'NIT Trichy', 'technical', 'Full Stack', 'DEPT-TECH', 'Technical', 'BATCH-2025-W12', 'EMP-103', 8.5, 7.8, 2, '2025-03-21', 'under_review'),
('INT-204', 'Deepika Pillai', 'deepika.pillai@collegemail.edu', '+91 98111 20004', 'VIT Vellore', 'technical', 'Mobile App', 'DEPT-TECH', 'Technical', 'BATCH-2025-W12', 'EMP-105', 8.8, 8.2, 0, '2025-03-21', 'under_review');

-- ------------------------------------------------------------------------------
-- 6. PROJECTS (Exactly 6 Projects: 4 In Progress, 2 Completed; Incl. Digital Marketing)
-- ------------------------------------------------------------------------------
INSERT INTO projects (id, name, client_name, domain, status, progress_percent, planned_progress_percent, owner_id, team_id, budget, start_date, deadline, has_blockers, blocker_details) VALUES
-- Project 1 (Ongoing - The Digital Marketing Project)
('PRJ-401', 'Digital Marketing & Growth Engine', 'OmniSphere Retail', 'Digital Marketing', 'in_progress', 70, 75, 'EMP-301', 'DEPT-DM', 65000.00, '2026-08-01', '2026-12-15', FALSE, NULL),

-- Project 2 (Ongoing)
('PRJ-402', 'Digital Inertia ERP Core', 'DI Strategic Holdings', 'Web Platform', 'in_progress', 85, 85, 'EMP-102', 'DEPT-TECH', 120000.00, '2026-06-01', '2026-11-30', FALSE, NULL),

-- Project 3 (Ongoing)
('PRJ-403', 'EcoTrack IoT Mobile Platform', 'CleanTech Innovations', 'Mobile App', 'in_progress', 58, 60, 'EMP-105', 'DEPT-TECH', 95000.00, '2026-07-15', '2027-01-31', FALSE, NULL),

-- Project 4 (Ongoing)
('PRJ-404', 'OmniChannel Enterprise Sales Rollout', 'Zenith Global Logistics', 'Sales & CRM', 'in_progress', 44, 50, 'EMP-201', 'DEPT-SM', 80000.00, '2026-09-01', '2027-03-31', FALSE, NULL),

-- Project 5 (Completed)
('PRJ-405', 'FinTech Payment Gateway Microservices', 'PulsePay Global', 'Backend', 'completed', 100, 100, 'EMP-102', 'DEPT-TECH', 150000.00, '2026-01-10', '2026-09-28', FALSE, NULL),

-- Project 6 (Completed)
('PRJ-406', 'Corporate People Hub & Workforce System', 'Inertia Talent Consortium', 'HR & Recruitment', 'completed', 100, 100, 'EMP-401', 'DEPT-HR', 45000.00, '2026-02-01', '2026-08-30', FALSE, NULL);

-- ------------------------------------------------------------------------------
-- 7. TASKS (Split Across the 5 Departments, 6 Projects, and 25 Employees)
-- ------------------------------------------------------------------------------
INSERT INTO tasks (id, title, description, domain, status, priority, assigned_to_id, assigned_to_name, assignee_type, assigned_by_id, assigned_by_name, project_id, project_name, due_date, completed_at) VALUES
-- === PROJECT 1: Digital Marketing & Growth Engine (PRJ-401) ===
-- Technical Department Part:
('TSK-101', 'Conversion Pixel & Telemetry SDK Integration', 'Embed Meta CAPI, Google Ads Tag, and server-side tracking pipelines with sub-millisecond response', 'Technical', 'in_progress', 'urgent', 'EMP-101', 'Arjun Sharma', 'employee', 'EMP-301', 'Kavita Reddy', 'PRJ-401', 'Digital Marketing & Growth Engine', '2026-10-18', NULL),
('TSK-102', 'Real-time Marketing Attribution API', 'Build high-throughput event ingestion endpoint to reconcile multi-touch campaign attribution IDs', 'Technical', 'in_progress', 'high', 'EMP-102', 'Priya Nair', 'employee', 'EMP-301', 'Kavita Reddy', 'PRJ-401', 'Digital Marketing & Growth Engine', '2026-10-19', NULL),

-- Digital Marketing Department Part:
('TSK-103', 'Google & Meta Omnichannel PPC Campaign Launch', 'Configure high-intent search ads, dynamic remarketing catalog, and target ROAS bid strategy', 'Digital Marketing', 'in_progress', 'urgent', 'EMP-302', 'Sameer Deshmukh', 'employee', 'EMP-301', 'Kavita Reddy', 'PRJ-401', 'Digital Marketing & Growth Engine', '2026-10-17', NULL),
('TSK-104', 'Organic Keyword Silo & Technical SEO Overhaul', 'Implement Core Web Vitals audit, schema structured data, and high-volume pillar content clusters', 'Digital Marketing', 'in_progress', 'high', 'EMP-303', 'Pooja Hegde', 'employee', 'EMP-301', 'Kavita Reddy', 'PRJ-401', 'Digital Marketing & Growth Engine', '2026-10-20', NULL),
('TSK-105', 'High-Converting Ad Creatives & Brand Video Assets', 'Deliver motion graphics, responsive display banners, and TikTok/Reels product showcases', 'Digital Marketing', 'completed', 'medium', 'EMP-305', 'Rhea Pillai', 'employee', 'EMP-301', 'Kavita Reddy', 'PRJ-401', 'Digital Marketing & Growth Engine', '2026-10-12', '2026-10-12 17:30:00+00'),

-- Sales & Marketing Department Part:
('TSK-106', 'Inbound Lead Qualification & CRM Attribution Sync', 'Configure automated HubSpot webhook triggers to route marketing-qualified leads to sales reps', 'Sales & Marketing', 'in_progress', 'high', 'EMP-203', 'Vikram Malhotra', 'employee', 'EMP-201', 'Rajesh Kumar', 'PRJ-401', 'Digital Marketing & Growth Engine', '2026-10-21', NULL),

-- Finance Department Part:
('TSK-107', 'Marketing Ad Spend & CAC Financial Audit', 'Reconcile prepaid ad network invoices against monthly burn rate and audit blended CAC metrics', 'Finance', 'in_progress', 'high', 'EMP-504', 'Deepak Chawla', 'employee', 'EMP-501', 'Rameshwar Gupta', 'PRJ-401', 'Digital Marketing & Growth Engine', '2026-10-22', NULL),

-- HR Department Part:
('TSK-108', 'Creative Agency & Freelance Contractor Onboarding', 'Execute master services agreements and compliance NDAs for external video production team', 'HR', 'completed', 'medium', 'EMP-404', 'Karan Singhania', 'employee', 'EMP-401', 'Sunita Verma', 'PRJ-401', 'Digital Marketing & Growth Engine', '2026-10-10', '2026-10-10 14:00:00+00'),

-- === PROJECT 2: Digital Inertia ERP Core (PRJ-402) ===
-- Technical Department Part:
('TSK-201', 'Client Pitch Deck Finalization (DI Rebrand & Strategy)', 'Finalize executive presentation deck, brand identity system, and SLA architectures', 'Technical', 'in_progress', 'urgent', 'EMP-101', 'Arjun Sharma', 'employee', 'EMP-201', 'Rajesh Kumar', 'PRJ-402', 'Digital Inertia ERP Core', '2026-10-18', NULL),
('TSK-202', 'PostgreSQL 18 Query Latency Optimization', 'Optimize execution plans for employee task rollups and add composite indexes for multi-tenant queries', 'Technical', 'in_progress', 'high', 'EMP-102', 'Priya Nair', 'employee', 'EMP-102', 'Priya Nair', 'PRJ-402', 'Digital Inertia ERP Core', '2026-10-19', NULL),
('TSK-203', 'Centralized State Provider Architecture', 'Refactor state machines to broadcast granular updates via ChangeNotifier across all department screens', 'Technical', 'in_progress', 'high', 'EMP-103', 'Karthik R', 'employee', 'EMP-101', 'Arjun Sharma', 'PRJ-402', 'Digital Inertia ERP Core', '2026-10-20', NULL),
('TSK-204', 'Design Tokens & 2x3 Grid Layout Standard', 'Implement monochrome theme tokens and uniform childAspectRatio grids across dashboard cards', 'Technical', 'completed', 'high', 'EMP-104', 'Sneha V', 'employee', 'EMP-101', 'Arjun Sharma', 'PRJ-402', 'Digital Inertia ERP Core', '2026-10-13', '2026-10-13 18:00:00+00'),
('TSK-205', 'Technical Deliverables & Sub-Task Partitioning', 'Decompose quarterly sprint objectives into actionable individual developer work packages', 'Technical', 'in_progress', 'high', 'EMP-118', 'Shreya Kulkarni', 'employee', 'EMP-101', 'Arjun Sharma', 'PRJ-402', 'Digital Inertia ERP Core', '2026-10-19', NULL),

-- Sales & Marketing Department Part:
('TSK-206', 'Executive Sales Dashboard Requirements Sign-off', 'Review pipeline funnel analytics, deal stage transitions, and quarterly quota projections', 'Sales & Marketing', 'completed', 'medium', 'EMP-204', 'Ananya Kapoor', 'employee', 'EMP-201', 'Rajesh Kumar', 'PRJ-402', 'Digital Inertia ERP Core', '2026-10-11', '2026-10-11 11:30:00+00'),

-- HR Department Part:
('TSK-207', 'Employee Directory & Leave Balance Integration', 'Verify 25 employee profiles, reporting chains, and automated annual leave quota deductions', 'HR', 'in_progress', 'high', 'EMP-403', 'Neha Bansal', 'employee', 'EMP-401', 'Sunita Verma', 'PRJ-402', 'Digital Inertia ERP Core', '2026-10-20', NULL),

-- Finance Department Part:
('TSK-208', 'Enterprise General Ledger Chart of Accounts Validation', 'Audit journal voucher posting rules, cost center tagging, and depreciation schedule tables', 'Finance', 'in_progress', 'high', 'EMP-502', 'Shalini Rao', 'employee', 'EMP-501', 'Rameshwar Gupta', 'PRJ-402', 'Digital Inertia ERP Core', '2026-10-21', NULL),

-- Digital Marketing Department Part:
('TSK-209', 'Corporate Brand Identity & Typography Guidelines', 'Publish Instrument Sans font styling rules, SVG logo assets, and social badge components', 'Digital Marketing', 'completed', 'medium', 'EMP-304', 'Naveen Chandra', 'employee', 'EMP-301', 'Kavita Reddy', 'PRJ-402', 'Digital Inertia ERP Core', '2026-10-09', '2026-10-09 16:00:00+00'),

-- === PROJECT 3: EcoTrack IoT Mobile Platform (PRJ-403) ===
-- Technical Department Part:
('TSK-301', 'BLE Inverter Telemetry Companion App', 'Implement Bluetooth Low Energy GATT characteristic listener in Flutter for solar inverters', 'Technical', 'in_progress', 'urgent', 'EMP-105', 'Rohan Mehta', 'employee', 'EMP-105', 'Rohan Mehta', 'PRJ-403', 'EcoTrack IoT Mobile Platform', '2026-10-22', NULL),
('TSK-302', 'Edge Telemetry Time-Series Pipeline', 'Process 5,000 pings/sec of power, voltage, and temperature metrics with TimescaleDB retention', 'Technical', 'in_progress', 'high', 'EMP-103', 'Karthik R', 'employee', 'EMP-105', 'Rohan Mehta', 'PRJ-403', 'EcoTrack IoT Mobile Platform', '2026-10-23', NULL),

-- Sales & Marketing Department Part:
('TSK-303', 'CleanTech Enterprise Trial & Demo Coordination', 'Coordinate on-site hardware pilot demonstration for 3 commercial solar farm operators', 'Sales & Marketing', 'in_progress', 'high', 'EMP-205', 'Aditya Joshi', 'employee', 'EMP-201', 'Rajesh Kumar', 'PRJ-403', 'EcoTrack IoT Mobile Platform', '2026-10-24', NULL),

-- Digital Marketing Department Part:
('TSK-304', 'CleanTech Case Study & Green Energy Whitepaper', 'Publish joint case study detailing 34% reduction in downtime through automated alerts', 'Digital Marketing', 'in_progress', 'medium', 'EMP-302', 'Sameer Deshmukh', 'employee', 'EMP-301', 'Kavita Reddy', 'PRJ-403', 'EcoTrack IoT Mobile Platform', '2026-10-25', NULL),

-- Finance Department Part:
('TSK-305', 'IoT Sensor Hardware Bill of Materials Audit', 'Reconcile procurement purchase orders for IoT gateways, sensors, and customs duty fees', 'Finance', 'completed', 'high', 'EMP-503', 'Manish Aggarwal', 'employee', 'EMP-502', 'Shalini Rao', 'PRJ-403', 'EcoTrack IoT Mobile Platform', '2026-10-08', '2026-10-08 15:45:00+00'),

-- HR Department Part:
('TSK-306', 'Embedded Systems Firmware Staffing Requisition', 'Interview 4 senior embedded C++ and RTOS engineers for Phase 2 hardware integration sprint', 'HR', 'in_progress', 'medium', 'EMP-402', 'Amitabh Roy', 'employee', 'EMP-401', 'Sunita Verma', 'PRJ-403', 'EcoTrack IoT Mobile Platform', '2026-10-26', NULL),

-- === PROJECT 4: OmniChannel Enterprise Sales Rollout (PRJ-404) ===
-- Sales & Marketing Department Part:
('TSK-401', 'Zenith Logistics Enterprise Master Service Contract', 'Negotiate master terms, SLA penalty schedules, and multi-year maintenance tiers with client counsel', 'Sales & Marketing', 'in_progress', 'urgent', 'EMP-201', 'Rajesh Kumar', 'employee', 'EMP-201', 'Rajesh Kumar', 'PRJ-404', 'OmniChannel Enterprise Sales Rollout', '2026-10-21', NULL),
('TSK-402', 'Territory Account Mapping & Sales Rep Quota Allocation', 'Distribute regional enterprise target accounts across 5 enterprise sales account executives', 'Sales & Marketing', 'in_progress', 'high', 'EMP-202', 'Meera Sen', 'employee', 'EMP-201', 'Rajesh Kumar', 'PRJ-404', 'OmniChannel Enterprise Sales Rollout', '2026-10-22', NULL),

-- Technical Department Part:
('TSK-403', 'Sales Companion Offline Field App', 'Implement local SQLite database caching and optimistic sync for field sales reps in transit', 'Technical', 'in_progress', 'high', 'EMP-104', 'Sneha V', 'employee', 'EMP-101', 'Arjun Sharma', 'PRJ-404', 'OmniChannel Enterprise Sales Rollout', '2026-10-24', NULL),

-- Digital Marketing Department Part:
('TSK-404', 'B2B Sales Enablement Collateral & Interactive Calculator', 'Produce interactive ROI savings calculator web widget and enterprise product one-pagers', 'Digital Marketing', 'in_progress', 'medium', 'EMP-305', 'Rhea Pillai', 'employee', 'EMP-301', 'Kavita Reddy', 'PRJ-404', 'OmniChannel Enterprise Sales Rollout', '2026-10-25', NULL),

-- Finance Department Part:
('TSK-405', 'Recurring Enterprise Invoicing & Milestone Milestone Schedule', 'Configure automated recurring billing for quarterly software licenses and bank wire instructions', 'Finance', 'in_progress', 'high', 'EMP-505', 'Tanvi Mathur', 'employee', 'EMP-502', 'Shalini Rao', 'PRJ-404', 'OmniChannel Enterprise Sales Rollout', '2026-10-23', NULL),

-- HR Department Part:
('TSK-406', 'Sales Incentive & Commission Policy Framework', 'Draft quarterly performance incentive tiers, accelerated attainment accelerators, and SPIFFs', 'HR', 'in_progress', 'high', 'EMP-405', 'Divya Nambiar', 'employee', 'EMP-401', 'Sunita Verma', 'PRJ-404', 'OmniChannel Enterprise Sales Rollout', '2026-10-26', NULL),

-- === PROJECT 5: FinTech Payment Gateway Microservices (PRJ-405 - Completed) ===
('TSK-501', 'PCI-DSS HSM Hardware Security Module Attestation', 'Deploy Argon2id password hashing, hardware token signing, and SOC-2 Type II audit logs', 'Technical', 'completed', 'urgent', 'EMP-102', 'Priya Nair', 'employee', 'EMP-102', 'Priya Nair', 'PRJ-405', 'FinTech Payment Gateway Microservices', '2026-09-15', '2026-09-15 18:00:00+00'),
('TSK-502', 'High-Frequency Multi-Currency Clearing Ledger', 'Engineered double-entry bookkeeping engine supporting EUR, USD, INR, and SGD currency pairs', 'Technical', 'completed', 'high', 'EMP-103', 'Karthik R', 'employee', 'EMP-102', 'Priya Nair', 'PRJ-405', 'FinTech Payment Gateway Microservices', '2026-09-20', '2026-09-20 16:30:00+00'),
('TSK-503', 'Banking Settlement & Escrow Account Reconciliation', 'Automated reconciliation routines matching 100,000 daily transaction batches with central banks', 'Finance', 'completed', 'urgent', 'EMP-501', 'Rameshwar Gupta', 'employee', 'EMP-501', 'Rameshwar Gupta', 'PRJ-405', 'FinTech Payment Gateway Microservices', '2026-09-25', '2026-09-25 19:15:00+00'),
('TSK-504', 'Compliance & Infosec Security Training Cohort', 'Conducted mandatory ISO 27001 zero-trust training and secure coding assessment for engineers', 'HR', 'completed', 'medium', 'EMP-401', 'Sunita Verma', 'employee', 'EMP-401', 'Sunita Verma', 'PRJ-405', 'FinTech Payment Gateway Microservices', '2026-09-18', '2026-09-18 12:00:00+00'),
('TSK-505', 'Global Fintech Launch PR & Media Wire Release', 'Published press release across Bloomberg, TechCrunch, and Financial Express on launch', 'Digital Marketing', 'completed', 'medium', 'EMP-304', 'Naveen Chandra', 'employee', 'EMP-301', 'Kavita Reddy', 'PRJ-405', 'FinTech Payment Gateway Microservices', '2026-09-28', '2026-09-28 10:00:00+00'),

-- === PROJECT 6: Corporate People Hub & Workforce System (PRJ-406 - Completed) ===
('TSK-601', 'Campus University Recruitment Funnel Automation', 'Built automated screening portal evaluating 2,400 engineering candidates across 12 universities', 'HR', 'completed', 'high', 'EMP-401', 'Sunita Verma', 'employee', 'EMP-401', 'Sunita Verma', 'PRJ-406', 'Corporate People Hub & Workforce System', '2026-08-15', '2026-08-15 17:00:00+00'),
('TSK-602', 'University Campus Drives & Interview Panel Rostering', 'Scheduled 68 technical rounds and selected 26 top candidates for Batch Apr-A and Apr-B cohorts', 'HR', 'completed', 'high', 'EMP-402', 'Amitabh Roy', 'employee', 'EMP-401', 'Sunita Verma', 'PRJ-406', 'Corporate People Hub & Workforce System', '2026-08-20', '2026-08-20 15:00:00+00'),
('TSK-603', 'Employee Self-Service Profile & Leave Ledger Portal', 'Created mobile self-service portal for leave applications, attendance, and emergency contacts', 'Technical', 'completed', 'medium', 'EMP-104', 'Sneha V', 'employee', 'EMP-101', 'Arjun Sharma', 'PRJ-406', 'Corporate People Hub & Workforce System', '2026-08-25', '2026-08-25 14:30:00+00'),
('TSK-604', 'Intern Stipend & Campus Travel Expense Audit', 'Disbursed quarterly intern stipends and audited university career fair travel expenses', 'Finance', 'completed', 'medium', 'EMP-504', 'Deepak Chawla', 'employee', 'EMP-502', 'Shalini Rao', 'PRJ-406', 'Corporate People Hub & Workforce System', '2026-08-28', '2026-08-28 16:45:00+00'),
('TSK-605', 'Employer Brand Campus Social Campaign', 'Launched "Code at Digital Inertia" recruitment campaign reaching 150,000 student engineers', 'Digital Marketing', 'completed', 'low', 'EMP-303', 'Pooja Hegde', 'employee', 'EMP-301', 'Kavita Reddy', 'PRJ-406', 'Corporate People Hub & Workforce System', '2026-08-30', '2026-08-30 11:00:00+00');

-- ------------------------------------------------------------------------------
-- 8. LEADS (14 Realistic Prospects)
-- ------------------------------------------------------------------------------
INSERT INTO leads (id, company_name, client_name, domain, email, phone, stage, deal_value, owner_id, owner_name, next_follow_up, source, notes) VALUES
('LED-501', 'GreenTech Solutions', 'Vikramaditya Rao', 'IT Consulting', 'vikram@greentech.in', '+91 98450 12001', 'new', 35000.00, 'EMP-201', 'Rajesh Kumar', '2026-10-12', 'Inbound Enterprise Lead', 'Unified carbon offset tracking software for commercial solar farms'),
('LED-502', 'OmniSphere Retail Group', 'Sarah Al-Mansoor', 'Digital Marketing', 'sarah.m@omnisphere.ae', '+971 50 123 4567', 'won', 65000.00, 'EMP-201', 'Rajesh Kumar', '2026-10-14', 'Dubai Retail Summit Inbound', 'Converted into active PRJ-401 Digital Marketing project'),
('LED-503', 'Skyline Infra', 'Ramesh Namboodiri', 'Web Platform', 'ramesh@skylineinfra.com', '+91 98200 45003', 'proposal', 62000.00, 'EMP-203', 'Vikram Malhotra', '2026-10-14', 'Direct Executive Outreach', 'Smart city asset monitoring portal. Proposal submitted.'),
('LED-504', 'SolarEase Systems', 'Kavitha Balasubramanian', 'Solar Solutions', 'kavitha@solarease.com', '+91 98410 78004', 'qualified', 28000.00, 'EMP-202', 'Meera Sen', '2026-10-16', 'Industry Conference Referral', 'B2B distributor portal for rooftop solar installations');

-- ------------------------------------------------------------------------------
-- 9. CONFIGURABLE THRESHOLD ALERT SETTINGS
-- ------------------------------------------------------------------------------
INSERT INTO alert_threshold_settings (id, task_overdue_days, intern_missed_update_days, project_behind_schedule_percent, employee_capacity_max_tasks, intern_low_score_cutoff)
VALUES (1, 1, 2, 15, 4, 6.0)
ON CONFLICT (id) DO UPDATE SET
    task_overdue_days = EXCLUDED.task_overdue_days,
    intern_missed_update_days = EXCLUDED.intern_missed_update_days,
    project_behind_schedule_percent = EXCLUDED.project_behind_schedule_percent,
    employee_capacity_max_tasks = EXCLUDED.employee_capacity_max_tasks,
    intern_low_score_cutoff = EXCLUDED.intern_low_score_cutoff,
    updated_at = NOW();

-- ------------------------------------------------------------------------------
-- 10. REFRESH EMPLOYEE TASK COUNTS
-- ------------------------------------------------------------------------------
UPDATE employees e
SET current_active_tasks = (
    SELECT COUNT(*)
    FROM tasks t
    WHERE t.assigned_to_id = e.id
      AND t.assignee_type = 'employee'
      AND t.status != 'completed'
);

-- ------------------------------------------------------------------------------
-- 11. AUDIT LOGS
-- ------------------------------------------------------------------------------
INSERT INTO audit_logs (action, module, details, performed_by) VALUES
('Database Initialized', 'System', 'Provisioned PostgreSQL enterprise schema with 5 departments and 25 employees', 'Laven Lokesh (CEO)'),
('Projects Synchronized', 'Projects', 'Configured 4 in-progress projects (incl. Digital Marketing) and 2 completed projects', 'Laven Lokesh (CEO)'),
('Task Partitioning', 'Tasks', 'Decomposed multi-department parts and assigned work packages to all employees', 'Laven Lokesh (CEO)');

-- ------------------------------------------------------------------------------
-- 12. USERS (Authentication Credentials - Default Password: password123!)
-- Hash: $2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK
-- ------------------------------------------------------------------------------
INSERT INTO users (id, email, password_hash, full_name, role, employee_id) VALUES
-- CEO Executive Leadership
('USR-001', 'laven@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Laven Lokesh', 'ROLE_CEO', NULL),

-- 1. Technical Department (5 Employees + Specialist)
('USR-101', 'arjun.sharma@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Arjun Sharma', 'ROLE_POC', 'EMP-101'),
('USR-102', 'priya.nair@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Priya Nair', 'ROLE_POC', 'EMP-102'),
('USR-103', 'karthik.r@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Karthik R', 'ROLE_TECH', 'EMP-103'),
('USR-104', 'sneha.v@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Sneha V', 'ROLE_TECH', 'EMP-104'),
('USR-105', 'rohan.mehta@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Rohan Mehta', 'ROLE_POC', 'EMP-105'),
('USR-118', 'shreya.kulkarni@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Shreya Kulkarni', 'ROLE_TECH', 'EMP-118'),

-- 2. Sales & Marketing Department (5 Employees)
('USR-201', 'rajesh.kumar@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Rajesh Kumar', 'ROLE_SALES_MARKETING', 'EMP-201'),
('USR-202', 'meera.sen@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Meera Sen', 'ROLE_SALES_MARKETING', 'EMP-202'),
('USR-203', 'vikram.malhotra@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Vikram Malhotra', 'ROLE_SALES_MARKETING', 'EMP-203'),
('USR-204', 'ananya.kapoor@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Ananya Kapoor', 'ROLE_SALES_MARKETING', 'EMP-204'),
('USR-205', 'aditya.joshi@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Aditya Joshi', 'ROLE_SALES_MARKETING', 'EMP-205'),

-- 3. Digital Marketing Department (5 Employees)
('USR-301', 'kavita.reddy@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Kavita Reddy', 'ROLE_DIGITAL_MARKETING', 'EMP-301'),
('USR-302', 'sameer.deshmukh@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Sameer Deshmukh', 'ROLE_DIGITAL_MARKETING', 'EMP-302'),
('USR-303', 'pooja.hegde@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Pooja Hegde', 'ROLE_DIGITAL_MARKETING', 'EMP-303'),
('USR-304', 'naveen.chandra@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Naveen Chandra', 'ROLE_DIGITAL_MARKETING', 'EMP-304'),
('USR-305', 'rhea.pillai@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Rhea Pillai', 'ROLE_DIGITAL_MARKETING', 'EMP-305'),

-- 4. HR Department (5 Employees)
('USR-401', 'sunita.verma@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Sunita Verma', 'ROLE_HR', 'EMP-401'),
('USR-402', 'amitabh.roy@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Amitabh Roy', 'ROLE_HR', 'EMP-402'),
('USR-403', 'neha.bansal@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Neha Bansal', 'ROLE_HR', 'EMP-403'),
('USR-404', 'karan.singhania@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Karan Singhania', 'ROLE_HR', 'EMP-404'),
('USR-405', 'divya.nambiar@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Divya Nambiar', 'ROLE_HR', 'EMP-405'),

-- 5. Finance Department (5 Employees)
('USR-501', 'rameshwar.gupta@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Rameshwar Gupta', 'ROLE_FINANCE', 'EMP-501'),
('USR-502', 'shalini.rao@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Shalini Rao', 'ROLE_FINANCE', 'EMP-502'),
('USR-503', 'manish.aggarwal@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Manish Aggarwal', 'ROLE_FINANCE', 'EMP-503'),
('USR-504', 'deepak.chawla@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Deepak Chawla', 'ROLE_FINANCE', 'EMP-504'),
('USR-505', 'tanvi.mathur@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Tanvi Mathur', 'ROLE_FINANCE', 'EMP-505'),

-- Interns
('USR-201', 'aarav.gupta@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Aarav Gupta', 'ROLE_INTERN', 'INT-201'),
('USR-202', 'bhavya.shah@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Bhavya Shah', 'ROLE_INTERN', 'INT-202'),
('USR-203', 'chirag.mathur@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Chirag Mathur', 'ROLE_INTERN', 'INT-203'),
('USR-204', 'deepika.pillai@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Deepika Pillai', 'ROLE_INTERN', 'INT-204')

ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  password_hash = EXCLUDED.password_hash,
  full_name = EXCLUDED.full_name,
  role = EXCLUDED.role,
  employee_id = EXCLUDED.employee_id;
