-- ==============================================================================
-- V5: Safe Seed Data (Idempotent: Uses ON CONFLICT DO NOTHING - Zero Truncates)
-- ==============================================================================

-- 1. CONFIGURABLE ROLES (10 Technical + 8 Non-Technical)
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
('ROLE-AD', 'Administration', 'non_technical', 'Executive office operations, vendor management, workplace facilities and legal policies')
ON CONFLICT (id) DO NOTHING;

-- 2. TEAMS
INSERT INTO teams (id, name, category, description) VALUES
('TEAM-ENG', 'Core Platform Engineering', 'technical', 'Core backend infrastructure, multi-tenant databases and core API services'),
('TEAM-FE', 'Client Experience Engineering', 'technical', 'Mobile and web frontend user interfaces and design systems'),
('TEAM-AI', 'Applied Intelligence Lab', 'technical', 'Machine learning telemetry engines, pattern recognition and edge models'),
('TEAM-QA', 'Quality & Reliability', 'technical', 'Automated QA testing, regression cycles and security compliance audits'),
('TEAM-GROWTH', 'Corporate Growth & Sales', 'non_technical', 'Enterprise sales, strategic partnerships and solution consulting'),
('TEAM-PEOPLE', 'People & Workplace', 'non_technical', 'Human resources, talent scouting, intern mentorship and campus relations'),
('TEAM-OPS', 'Financial & Business Ops', 'non_technical', 'Accounting, regulatory compliance, executive operations and contract governance')
ON CONFLICT (id) DO NOTHING;

-- 3. EMPLOYEES
INSERT INTO employees (id, name, email, phone, role_id, role_title, team_id, team_name, category, is_active, is_poc, max_task_capacity, current_active_tasks, joined_date) VALUES
('EMP-101', 'Arjun Sharma', 'arjun.sharma@digitalinertia.com', '+91 98201 14521', 'ROLE-FE', 'Frontend Developer', 'TEAM-FE', 'Client Experience Engineering', 'technical', TRUE, TRUE, 5, 2, '2023-04-15'),
('EMP-102', 'Priya Nair', 'priya.nair@digitalinertia.com', '+91 98450 78210', 'ROLE-BE', 'Backend Developer', 'TEAM-ENG', 'Core Platform Engineering', 'technical', TRUE, TRUE, 5, 5, '2023-06-01'),
('EMP-103', 'Karthik R', 'karthik.r@digitalinertia.com', '+91 97112 65430', 'ROLE-FS', 'Full Stack Developer', 'TEAM-ENG', 'Core Platform Engineering', 'technical', TRUE, TRUE, 5, 2, '2023-08-10'),
('EMP-104', 'Sneha V', 'sneha.v@digitalinertia.com', '+91 99304 98124', 'ROLE-FE', 'Frontend Developer', 'TEAM-FE', 'Client Experience Engineering', 'technical', TRUE, TRUE, 5, 3, '2023-09-01'),
('EMP-105', 'Rohan Mehta', 'rohan.mehta@digitalinertia.com', '+91 98214 33219', 'ROLE-MO', 'Mobile App Developer', 'TEAM-FE', 'Client Experience Engineering', 'technical', TRUE, TRUE, 4, 5, '2023-11-15'),
('EMP-106', 'Ananya Deshmukh', 'ananya.deshmukh@digitalinertia.com', '+91 98190 22345', 'ROLE-AI', 'AI / ML Engineer', 'TEAM-AI', 'Applied Intelligence Lab', 'technical', TRUE, FALSE, 5, 1, '2024-01-10'),
('EMP-107', 'Vikram Singh', 'vikram.singh@digitalinertia.com', '+91 97401 88320', 'ROLE-DE', 'Data Engineer', 'TEAM-ENG', 'Core Platform Engineering', 'technical', TRUE, FALSE, 5, 1, '2024-02-01'),
('EMP-108', 'Neha Patel', 'neha.patel@digitalinertia.com', '+91 98331 44590', 'ROLE-QA', 'QA / Testing Lead', 'TEAM-QA', 'Quality & Reliability', 'technical', TRUE, FALSE, 5, 1, '2024-03-01'),
('EMP-109', 'Rahul Verma', 'rahul.verma@digitalinertia.com', '+91 98110 99450', 'ROLE-DO', 'DevOps / Cloud Specialist', 'TEAM-ENG', 'Core Platform Engineering', 'technical', TRUE, FALSE, 5, 1, '2024-04-15'),
('EMP-110', 'Divya Iyer', 'divya.iyer@digitalinertia.com', '+91 98402 11234', 'ROLE-UX', 'UI/UX Engineering Lead', 'TEAM-FE', 'Client Experience Engineering', 'technical', TRUE, FALSE, 5, 1, '2024-05-01'),
('EMP-111', 'Meera Joshi', 'meera.joshi@digitalinertia.com', '+91 98205 66780', 'ROLE-HR', 'HR / Recruitment Specialist', 'TEAM-PEOPLE', 'People & Workplace', 'non_technical', TRUE, FALSE, 5, 1, '2023-05-10'),
('EMP-112', 'Rajesh Kumar', 'rajesh.kumar@digitalinertia.com', '+91 98101 44321', 'ROLE-SL', 'Sales / Business Development', 'TEAM-GROWTH', 'Corporate Growth & Sales', 'non_technical', TRUE, FALSE, 5, 2, '2023-07-20'),
('EMP-113', 'Sanjay Menon', 'sanjay.menon@digitalinertia.com', '+91 98410 77650', 'ROLE-MK', 'Marketing Strategist', 'TEAM-GROWTH', 'Corporate Growth & Sales', 'non_technical', TRUE, FALSE, 5, 1, '2023-10-01'),
('EMP-114', 'Pooja Hegde', 'pooja.hegde@digitalinertia.com', '+91 98211 22390', 'ROLE-OP', 'Operations Manager', 'TEAM-OPS', 'Financial & Business Ops', 'non_technical', TRUE, FALSE, 5, 1, '2023-12-05'),
('EMP-115', 'Siddharth Roy', 'siddharth.roy@digitalinertia.com', '+91 98300 88710', 'ROLE-FN', 'Finance / Accounts Lead', 'TEAM-OPS', 'Financial & Business Ops', 'non_technical', TRUE, FALSE, 5, 1, '2024-02-15'),
('EMP-116', 'Kavita Rao', 'kavita.rao@digitalinertia.com', '+91 98452 33410', 'ROLE-CSU', 'Customer Support Manager', 'TEAM-GROWTH', 'Corporate Growth & Sales', 'non_technical', TRUE, FALSE, 5, 1, '2024-03-20'),
('EMP-117', 'Aditya Sen', 'aditya.sen@digitalinertia.com', '+91 98115 55620', 'ROLE-CC', 'Content / Communications', 'TEAM-GROWTH', 'Corporate Growth & Sales', 'non_technical', TRUE, FALSE, 5, 0, '2024-06-01'),
('EMP-118', 'Shreya Kulkarni', 'shreya.kulkarni@digitalinertia.com', '+91 98204 11980', 'ROLE-AD', 'Administration Lead', 'TEAM-OPS', 'Financial & Business Ops', 'non_technical', TRUE, FALSE, 5, 0, '2024-07-01')
ON CONFLICT (id) DO NOTHING;


-- 5. INTERN INTAKE BATCHES
INSERT INTO intern_batches (id, code, start_date, end_date, total_interns) VALUES
('BATCH-2025-W12', 'Batch Apr-A (2025)', '2025-04-01', '2025-06-30', 14),
('BATCH-2025-W14', 'Batch Apr-B (2025)', '2025-04-15', '2025-07-15', 10)
ON CONFLICT (id) DO NOTHING;

-- 6. INTERNS (24 Active Interns)
INSERT INTO interns (id, name, email, phone, college, category, domain, team_id, team_name, batch_id, assigned_poc_id, interview_score, performance_score, missed_updates_days, selection_date, final_decision) VALUES
('INT-201', 'Aarav Gupta', 'aarav.gupta@collegemail.edu', '+91 98111 20001', 'IIT Bombay', 'technical', 'Backend', 'TEAM-ENG', 'Core Platform Engineering', 'BATCH-2025-W12', 'EMP-102', 9.2, 8.8, 0, '2025-03-20', 'absorbed'),
('INT-202', 'Bhavya Shah', 'bhavya.shah@collegemail.edu', '+91 98111 20002', 'BITS Pilani', 'technical', 'Frontend', 'TEAM-FE', 'Client Experience Engineering', 'BATCH-2025-W12', 'EMP-101', 8.9, 8.4, 0, '2025-03-20', 'under_review'),
('INT-203', 'Chirag Mathur', 'chirag.mathur@collegemail.edu', '+91 98111 20003', 'NIT Trichy', 'technical', 'Full Stack', 'TEAM-ENG', 'Core Platform Engineering', 'BATCH-2025-W12', 'EMP-103', 8.5, 7.8, 2, '2025-03-21', 'under_review'),
('INT-204', 'Deepika Pillai', 'deepika.pillai@collegemail.edu', '+91 98111 20004', 'VIT Vellore', 'technical', 'Mobile App', 'TEAM-FE', 'Client Experience Engineering', 'BATCH-2025-W12', 'EMP-105', 8.8, 8.2, 0, '2025-03-21', 'under_review'),
('INT-205', 'Eshan Kulkarni', 'eshan.kulkarni@collegemail.edu', '+91 98111 20005', 'IIIT Hyderabad', 'technical', 'AI / ML', 'TEAM-AI', 'Applied Intelligence Lab', 'BATCH-2025-W12', 'EMP-106', 9.5, 9.1, 0, '2025-03-22', 'absorbed'),
('INT-206', 'Falguni Das', 'falguni.das@collegemail.edu', '+91 98111 20006', 'Delhi Tech University', 'technical', 'Data Engineering', 'TEAM-ENG', 'Core Platform Engineering', 'BATCH-2025-W12', 'EMP-107', 8.2, 7.5, 0, '2025-03-22', 'under_review'),
('INT-207', 'Gautam Nambiar', 'gautam.nambiar@collegemail.edu', '+91 98111 20007', 'RV College Bangalore', 'technical', 'QA / Testing', 'TEAM-QA', 'Quality & Reliability', 'BATCH-2025-W12', 'EMP-108', 7.9, 7.1, 3, '2025-03-23', 'under_review'),
('INT-208', 'Harini Swaminathan', 'harini.s@collegemail.edu', '+91 98111 20008', 'PSG Tech Coimbatore', 'technical', 'DevOps / Cloud', 'TEAM-ENG', 'Core Platform Engineering', 'BATCH-2025-W12', 'EMP-109', 9.0, 8.7, 0, '2025-03-23', 'absorbed'),
('INT-209', 'Ishaan Saxena', 'ishaan.saxena@collegemail.edu', '+91 98111 20009', 'IIT Madras', 'technical', 'Cybersecurity', 'TEAM-ENG', 'Core Platform Engineering', 'BATCH-2025-W12', 'EMP-102', 8.7, 8.1, 0, '2025-03-24', 'under_review'),
('INT-210', 'Jayati Bose', 'jayati.bose@collegemail.edu', '+91 98111 20010', 'National Inst of Design', 'technical', 'UI/UX Engineering', 'TEAM-FE', 'Client Experience Engineering', 'BATCH-2025-W12', 'EMP-110', 9.3, 8.9, 0, '2025-03-24', 'absorbed'),
('INT-211', 'Kunal Trivedi', 'kunal.trivedi@collegemail.edu', '+91 98111 20011', 'Symbiosis Pune', 'non_technical', 'HR / Recruitment', 'TEAM-PEOPLE', 'People & Workplace', 'BATCH-2025-W12', 'EMP-111', 8.4, 7.9, 0, '2025-03-25', 'under_review'),
('INT-212', 'Lavanya Sundaram', 'lavanya.s@collegemail.edu', '+91 98111 20012', 'NMIMS Mumbai', 'non_technical', 'Sales / Business Development', 'TEAM-GROWTH', 'Corporate Growth & Sales', 'BATCH-2025-W12', 'EMP-112', 8.6, 8.0, 0, '2025-03-25', 'under_review'),
('INT-213', 'Manish Chawla', 'manish.chawla@collegemail.edu', '+91 98111 20013', 'MICA Ahmedabad', 'non_technical', 'Marketing', 'TEAM-GROWTH', 'Corporate Growth & Sales', 'BATCH-2025-W12', 'EMP-113', 8.1, 7.4, 2, '2025-03-26', 'under_review'),
('INT-214', 'Nandini Rao', 'nandini.rao@collegemail.edu', '+91 98111 20014', 'Loyola Chennai', 'non_technical', 'Operations', 'TEAM-OPS', 'Financial & Business Ops', 'BATCH-2025-W12', 'EMP-114', 8.3, 7.7, 0, '2025-03-26', 'under_review'),
('INT-215', 'Omkar Jadhav', 'omkar.jadhav@collegemail.edu', '+91 98111 20015', 'IIT Roorkee', 'technical', 'Backend', 'TEAM-ENG', 'Core Platform Engineering', 'BATCH-2025-W14', 'EMP-102', 8.9, 8.3, 0, '2025-04-02', 'under_review'),
('INT-216', 'Parul Singhania', 'parul.s@collegemail.edu', '+91 98111 20016', 'BITS Goa', 'technical', 'Frontend', 'TEAM-FE', 'Client Experience Engineering', 'BATCH-2025-W14', 'EMP-104', 8.6, 8.1, 0, '2025-04-02', 'under_review'),
('INT-217', 'Qasim Rizvi', 'qasim.rizvi@collegemail.edu', '+91 98111 20017', 'Manipal Institute of Tech', 'technical', 'Full Stack', 'TEAM-ENG', 'Core Platform Engineering', 'BATCH-2025-W14', 'EMP-103', 8.0, 7.3, 0, '2025-04-03', 'under_review'),
('INT-218', 'Ritika Kaul', 'ritika.kaul@collegemail.edu', '+91 98111 20018', 'Thapar University', 'technical', 'Mobile App', 'TEAM-FE', 'Client Experience Engineering', 'BATCH-2025-W14', 'EMP-105', 8.5, 7.9, 0, '2025-04-03', 'under_review'),
('INT-219', 'Siddhant Bakshi', 'siddhant.b@collegemail.edu', '+91 98111 20019', 'IIIT Bangalore', 'technical', 'AI / ML', 'TEAM-AI', 'Applied Intelligence Lab', 'BATCH-2025-W14', 'EMP-106', 9.4, 8.9, 0, '2025-04-04', 'absorbed'),
('INT-220', 'Tanvi Mahajan', 'tanvi.m@collegemail.edu', '+91 98111 20020', 'SRM University', 'technical', 'Data Engineering', 'TEAM-ENG', 'Core Platform Engineering', 'BATCH-2025-W14', 'EMP-107', 8.1, 7.2, 0, '2025-04-04', 'under_review'),
('INT-221', 'Udayan Sen', 'udayan.sen@collegemail.edu', '+91 98111 20021', 'Jadavpur University', 'technical', 'QA / Testing', 'TEAM-QA', 'Quality & Reliability', 'BATCH-2025-W14', 'EMP-108', 8.3, 7.6, 0, '2025-04-05', 'under_review'),
('INT-222', 'Varun Somani', 'varun.somani@collegemail.edu', '+91 98111 20022', 'NIT Surathkal', 'technical', 'DevOps / Cloud', 'TEAM-ENG', 'Core Platform Engineering', 'BATCH-2025-W14', 'EMP-109', 8.7, 8.0, 0, '2025-04-05', 'under_review'),
('INT-223', 'Waseem Akram', 'waseem.akram@collegemail.edu', '+91 98111 20023', 'Aligarh Muslim Univ', 'technical', 'Cybersecurity', 'TEAM-ENG', 'Core Platform Engineering', 'BATCH-2025-W14', 'EMP-102', 8.2, 7.5, 0, '2025-04-06', 'under_review'),
('INT-224', 'Yamini Reddy', 'yamini.reddy@collegemail.edu', '+91 98111 20024', 'Srishti Inst of Art & Tech', 'technical', 'UI/UX Engineering', 'TEAM-FE', 'Client Experience Engineering', 'BATCH-2025-W14', 'EMP-110', 9.1, 8.7, 0, '2025-04-06', 'absorbed')
ON CONFLICT (id) DO NOTHING;

-- 7. PROJECTS (6 Active Projects)
INSERT INTO projects (id, name, client_name, domain, status, progress_percent, planned_progress_percent, owner_id, team_id, budget, start_date, deadline, has_blockers, blocker_details) VALUES
('PRJ-301', 'EcoTrack App', 'CleanTech Innovations', 'Mobile App', 'in_progress', 75, 75, 'EMP-105', 'TEAM-FE', 45000.00, '2025-01-15', '2025-05-15', FALSE, NULL),
('PRJ-302', 'Green Energy Dashboard', 'Enel Horizon Grid', 'Web Platform', 'in_progress', 40, 45, 'EMP-101', 'TEAM-FE', 60000.00, '2025-02-01', '2025-06-30', FALSE, NULL),
('PRJ-303', 'AI Analytics Platform', 'Quantra BioSciences', 'AI / ML', 'in_progress', 90, 90, 'EMP-106', 'TEAM-AI', 85000.00, '2024-11-01', '2025-04-30', FALSE, NULL),
('PRJ-304', 'FinTech Payment Gateway', 'PulsePay Global', 'Backend', 'in_progress', 15, 35, 'EMP-102', 'TEAM-ENG', 120000.00, '2025-03-01', '2025-07-31', TRUE, 'PCI-DSS hardware security module HSM integration delay from bank sponsor'),
('PRJ-305', 'Fleet Logistics Mobile', 'SwiftLogistics Express', 'Mobile App', 'in_progress', 30, 30, 'EMP-105', 'TEAM-FE', 50000.00, '2025-02-15', '2025-06-15', FALSE, NULL),
('PRJ-306', 'Digital Inertia ERP Core', 'Digital Inertia Holdings', 'Web Platform', 'in_progress', 85, 85, 'EMP-103', 'TEAM-ENG', 75000.00, '2024-12-01', '2025-05-01', FALSE, NULL)
ON CONFLICT (id) DO NOTHING;

-- 8. TASKS (42 Corporate Tasks)
INSERT INTO tasks (id, title, description, domain, status, priority, assigned_to_id, assigned_to_name, assignee_type, assigned_by_id, assigned_by_name, project_id, project_name, due_date, awaiting_review) VALUES
('TSK-401', 'Database setup', 'Provision PostgreSQL 18 HA replication cluster and execute initial DDL scripts', 'Backend', 'todo', 'urgent', 'INT-203', 'Chirag Sethi', 'intern', 'EMP-102', 'Priya Nair', 'PRJ-304', 'FinTech Payment Gateway', '2026-10-09', FALSE),
('TSK-402', 'Fix authentication gateway timeout', 'Resolve 504 gateway timeout under 2,000 concurrent OAuth authorization code grants', 'Backend', 'in_progress', 'urgent', 'EMP-102', 'Priya Nair', 'employee', 'EMP-102', 'Priya Nair', 'PRJ-304', 'FinTech Payment Gateway', '2026-10-08', FALSE),
('TSK-403', 'Optimize state tree rebuilds', 'Profile widget subtree renders in Flutter and eliminate unneeded RepaintBoundary redraws', 'Mobile App', 'todo', 'high', 'EMP-105', 'Rohan Mehta', 'employee', 'EMP-105', 'Rohan Mehta', 'PRJ-301', 'EcoTrack App', '2026-10-09', FALSE),
('TSK-404', 'Update client SLA contract addendum', 'Incorporate Tier-1 99.95% uptime guarantees and incident escalation workflow', 'Sales / Business Development', 'todo', 'high', 'EMP-112', 'Rajesh Kumar', 'employee', 'EMP-112', 'Rajesh Kumar', 'PRJ-304', 'FinTech Payment Gateway', '2026-10-08', FALSE),
('TSK-405', 'Patch OpenSSL vulnerabilities on production edge', 'Apply CVE-2024 security updates across reverse proxy ingress pods', 'DevOps / Cloud', 'in_progress', 'urgent', 'EMP-102', 'Priya Nair', 'employee', 'EMP-102', 'Priya Nair', 'PRJ-306', 'Digital Inertia ERP Core', '2026-10-09', FALSE),
('TSK-406', 'Build login API', 'Implement JWT token exchange, refresh tokens and bcrypt password verification endpoints', 'Backend', 'in_progress', 'high', 'INT-201', 'Aarav Sharma', 'intern', 'EMP-102', 'Priya Nair', 'PRJ-306', 'Digital Inertia ERP Core', '2026-10-12', FALSE),
('TSK-407', 'Refactor state provider architecture', 'Decouple view controllers and establish centralized Provider tree for real-time reactivity', 'Backend', 'in_progress', 'high', 'EMP-102', 'Priya Nair', 'employee', 'EMP-102', 'Priya Nair', 'PRJ-302', 'Green Energy Dashboard', '2026-10-13', FALSE),
('TSK-408', 'Integrate biometric local authentication', 'Implement LocalAuthentication on Android BiometricPrompt and iOS LocalAuthentication FaceID', 'Mobile App', 'in_progress', 'high', 'EMP-105', 'Rohan Mehta', 'employee', 'EMP-105', 'Rohan Mehta', 'PRJ-301', 'EcoTrack App', '2026-10-14', FALSE),
('TSK-409', 'Deploy Prometheus and Grafana alerts', 'Set up metrics scraping for PostgreSQL connection pools and p99 latency thresholds', 'DevOps / Cloud', 'in_progress', 'medium', 'EMP-109', 'Rahul Verma', 'employee', 'EMP-102', 'Priya Nair', 'PRJ-306', 'Digital Inertia ERP Core', '2026-10-15', FALSE),
('TSK-410', 'Train sensor anomaly autoencoder model', 'Extract historical energy telemetry and train PyTorch autoencoder for voltage spike prediction', 'AI / ML', 'in_progress', 'high', 'EMP-106', 'Ananya Deshmukh', 'employee', 'EMP-106', 'Ananya Deshmukh', 'PRJ-303', 'AI Analytics Platform', '2026-10-16', FALSE),
('TSK-411', 'Draft campus hiring assessment rubrics', 'Compile technical interview grading rubric for Q3 engineering campus drive', 'Backend', 'in_progress', 'medium', 'EMP-102', 'Priya Nair', 'employee', 'EMP-102', 'Priya Nair', NULL, NULL, '2026-10-14', FALSE),
('TSK-412', 'Coordinate Q3 sales outreach webinar', 'Produce demonstration deck for CleanTech and solar energy enterprise prospects', 'Mobile App', 'in_progress', 'medium', 'EMP-105', 'Rohan Mehta', 'employee', 'EMP-105', 'Rohan Mehta', NULL, NULL, '2026-10-15', FALSE),
('TSK-413', 'Reconcile Q3 enterprise client receivables', 'Verify Stripe and wire transfer settlement statements with bank accounts', 'Finance / Accounts', 'in_progress', 'high', 'EMP-115', 'Siddharth Roy', 'employee', 'EMP-115', 'Siddharth Roy', NULL, NULL, '2026-10-16', FALSE),
('TSK-414', 'Design dashboard UI', 'Produce Figma vector components for executive KPI cards and Tasks Donut Chart', 'Frontend', 'todo', 'medium', 'INT-202', 'Bhavna Kulkarni', 'intern', 'EMP-110', 'Divya Iyer', 'PRJ-306', 'Digital Inertia ERP Core', '2026-10-15', FALSE),
('TSK-415', 'Implement Locust load benchmarking', 'Script realistic user journeys to stress-test 10,000 concurrent requests against GraphQL gateway', 'Mobile App', 'todo', 'high', 'EMP-105', 'Rohan Mehta', 'employee', 'EMP-105', 'Rohan Mehta', 'PRJ-304', 'FinTech Payment Gateway', '2026-10-17', FALSE),
('TSK-416', 'Configure AWS WAF managed rules', 'Protect payment API endpoints against SQL injection, cross-site scripting and bot attacks', 'Cybersecurity', 'todo', 'high', 'EMP-102', 'Priya Nair', 'employee', 'EMP-102', 'Priya Nair', 'PRJ-304', 'FinTech Payment Gateway', '2026-10-18', FALSE),
('TSK-417', 'Setup multi-region Kafka mirrors', 'Establish MirrorMaker 2 cluster between AWS Mumbai and Singapore for disaster recovery', 'Data Engineering', 'todo', 'medium', 'EMP-107', 'Vikram Singh', 'employee', 'EMP-107', 'Vikram Singh', 'PRJ-303', 'AI Analytics Platform', '2026-10-19', FALSE),
('TSK-418', 'Create client onboarding playbook', 'Write step-by-step documentation for SaaS tenant setup and DNS verification', 'Customer Support', 'todo', 'medium', 'EMP-116', 'Kavita Rao', 'employee', 'EMP-116', 'Kavita Rao', 'PRJ-306', 'Digital Inertia ERP Core', '2026-10-20', FALSE),
('TSK-419', 'Update employee handbook policies', 'Revise remote work security guidelines and intellectual property clauses', 'Administration', 'todo', 'low', 'EMP-114', 'Pooja Hegde', 'employee', 'EMP-114', 'Pooja Hegde', NULL, NULL, '2026-10-22', FALSE),
('TSK-420', 'Deliverable revision #1 - Lead detail dialog', 'Address missing responsive layout constraints on small viewport screens', 'Frontend', 'needs_rework', 'medium', 'INT-202', 'Bhavna Kulkarni', 'intern', 'EMP-104', 'Sneha V', 'PRJ-306', 'Digital Inertia ERP Core', '2026-10-12', TRUE),
('TSK-421', 'Deliverable revision #2 - SQL index optimization', 'Index coverage failed benchmark on multi-tenant partition key scans', 'Backend', 'needs_rework', 'high', 'EMP-103', 'Karthik R', 'employee', 'EMP-102', 'Priya Nair', 'PRJ-304', 'FinTech Payment Gateway', '2026-10-13', TRUE),
('TSK-422', 'Deliverable revision #3 - Mobile push notification handler', 'Silent background push notification fails on iOS 18 power-save mode', 'Mobile App', 'needs_rework', 'high', 'EMP-105', 'Rohan Mehta', 'employee', 'EMP-105', 'Rohan Mehta', 'PRJ-305', 'Fleet Logistics Mobile', '2026-10-14', TRUE),
('TSK-423', 'Implement CEO executive dashboard layout', 'Render responsive cards and high-contrast dark visual components', 'Frontend', 'completed', 'high', 'EMP-101', 'Arjun Sharma', 'employee', 'EMP-101', 'Arjun Sharma', 'PRJ-306', 'Digital Inertia ERP Core', '2026-10-05', FALSE),
('TSK-424', 'Implement custom Tasks Donut Chart painter', 'Draw animated SVG/Canvas circular ring with center total counter', 'Frontend', 'completed', 'high', 'EMP-104', 'Sneha V', 'employee', 'EMP-101', 'Arjun Sharma', 'PRJ-306', 'Digital Inertia ERP Core', '2026-10-05', FALSE),
('TSK-425', 'Design dark navigation drawer matching mockups', 'Create drawer layout with CEO profile header and routing shortcuts', 'Frontend', 'completed', 'medium', 'EMP-110', 'Divya Iyer', 'employee', 'EMP-110', 'Divya Iyer', 'PRJ-306', 'Digital Inertia ERP Core', '2026-10-06', FALSE),
('TSK-426', 'Setup PostgreSQL 18 master configuration', 'Configure shared_buffers, work_mem and max_connections for workload', 'Backend', 'completed', 'urgent', 'EMP-102', 'Priya Nair', 'employee', 'EMP-102', 'Priya Nair', 'PRJ-304', 'FinTech Payment Gateway', '2026-10-04', FALSE),
('TSK-427', 'Implement password hashing with Argon2id', 'Replace legacy SHA-256 with Argon2id cryptographic salt and key stretching', 'Backend', 'completed', 'high', 'EMP-103', 'Karthik R', 'employee', 'EMP-102', 'Priya Nair', 'PRJ-306', 'Digital Inertia ERP Core', '2026-10-04', FALSE),
('TSK-428', 'Build unified Filter Bottom Sheet modal', 'Create domain, role, team and status filter controls with reset action', 'Frontend', 'completed', 'medium', 'EMP-101', 'Arjun Sharma', 'employee', 'EMP-101', 'Arjun Sharma', 'PRJ-306', 'Digital Inertia ERP Core', '2026-10-06', FALSE),
('TSK-429', 'Configure iOS Runner bundle identifiers', 'Update CFBundleIdentifier and FaceID privacy descriptions in Info.plist', 'Mobile App', 'completed', 'medium', 'EMP-105', 'Rohan Mehta', 'employee', 'EMP-105', 'Rohan Mehta', 'PRJ-301', 'EcoTrack App', '2026-10-05', FALSE),
('TSK-430', 'Configure Android Gradle 8.13 dependencies', 'Update AndroidManifest.xml permissions and configure minSdk 24', 'Mobile App', 'completed', 'medium', 'EMP-105', 'Rohan Mehta', 'employee', 'EMP-105', 'Rohan Mehta', 'PRJ-301', 'EcoTrack App', '2026-10-05', FALSE),
('TSK-431', 'Deploy Redis cache cluster on AWS ElastiCache', 'Setup 3-node Redis cluster with automatic failover and read replicas', 'DevOps / Cloud', 'completed', 'high', 'EMP-109', 'Rahul Verma', 'employee', 'EMP-102', 'Priya Nair', 'PRJ-304', 'FinTech Payment Gateway', '2026-10-03', FALSE),
('TSK-432', 'Conduct intern Batch Apr-A orientation', 'Host onboarding session covering code standards, Git branches and PR reviews', 'HR / Recruitment', 'completed', 'medium', 'EMP-111', 'Meera Joshi', 'employee', 'EMP-111', 'Meera Joshi', NULL, NULL, '2026-10-01', FALSE),
('TSK-433', 'Finalize EcoTrack sensor protocol specs', 'Document Bluetooth Low Energy GATT characteristics for solar telemetry', 'Mobile App', 'completed', 'high', 'EMP-105', 'Rohan Mehta', 'employee', 'EMP-105', 'Rohan Mehta', 'PRJ-301', 'EcoTrack App', '2026-10-02', FALSE),
('TSK-434', 'Verify payment gateway webhooks idempotency', 'Implement database unique constraint and Redis lock for order IDs', 'Backend', 'completed', 'urgent', 'EMP-102', 'Priya Nair', 'employee', 'EMP-102', 'Priya Nair', 'PRJ-304', 'FinTech Payment Gateway', '2026-10-03', FALSE),
('TSK-435', 'Automate CI test execution in GitHub Actions', 'Create parallel test matrices for unit, widget and integration tests', 'QA / Testing', 'completed', 'medium', 'EMP-108', 'Neha Patel', 'employee', 'EMP-108', 'Neha Patel', 'PRJ-306', 'Digital Inertia ERP Core', '2026-10-04', FALSE),
('TSK-436', 'Publish Q3 company press release', 'Highlight Digital Inertia AI telemetry suite expansion and customer wins', 'Content / Communications', 'completed', 'low', 'EMP-117', 'Aditya Sen', 'employee', 'EMP-117', 'Aditya Sen', NULL, NULL, '2026-10-02', FALSE),
('TSK-437', 'Prepare GreenTech enterprise quotation', 'Assemble bill of materials and tiered cloud licensing proposal', 'Sales / Business Development', 'completed', 'high', 'EMP-112', 'Rajesh Kumar', 'employee', 'EMP-112', 'Rajesh Kumar', NULL, NULL, '2026-10-04', FALSE),
('TSK-438', 'Audit AWS VPC security group ingress rules', 'Close unnecessary inbound ports and restrict SSH to Bastion VPN tunnel', 'Cybersecurity', 'completed', 'high', 'EMP-102', 'Priya Nair', 'employee', 'EMP-102', 'Priya Nair', 'PRJ-306', 'Digital Inertia ERP Core', '2026-10-03', FALSE),
('TSK-439', 'Build lead pipeline Kanban card components', 'Design responsive status pill badges and quick contact action buttons', 'Frontend', 'completed', 'medium', 'EMP-104', 'Sneha V', 'employee', 'EMP-101', 'Arjun Sharma', 'PRJ-306', 'Digital Inertia ERP Core', '2026-10-06', FALSE),
('TSK-440', 'Review Fleet Logistics GPS ping frequency', 'Optimize location telemetry throttling to conserve 35% battery consumption', 'Mobile App', 'completed', 'medium', 'EMP-105', 'Rohan Mehta', 'employee', 'EMP-105', 'Rohan Mehta', 'PRJ-305', 'Fleet Logistics Mobile', '2026-10-05', FALSE),
('TSK-441', 'Setup daily automated PostgreSQL backups', 'Configure pg_dump scheduled snapshots to S3 bucket with 30-day lifecycle rule', 'DevOps / Cloud', 'completed', 'high', 'EMP-109', 'Rahul Verma', 'employee', 'EMP-102', 'Priya Nair', 'PRJ-306', 'Digital Inertia ERP Core', '2026-10-04', FALSE),
('TSK-442', 'Conduct quarterly financial forecast review', 'Review burn rate, recurring ARR and contractor disbursements with executive board', 'Finance / Accounts', 'completed', 'high', 'EMP-115', 'Siddharth Roy', 'employee', 'EMP-115', 'Siddharth Roy', NULL, NULL, '2026-10-03', FALSE)
ON CONFLICT (id) DO NOTHING;

-- 9. LEADS (14 Prospects)
INSERT INTO leads (id, company_name, client_name, domain, email, phone, stage, deal_value, owner_id, owner_name, next_follow_up, source, notes) VALUES
('LED-501', 'GreenTech Solutions', 'Vikramaditya Rao', 'IT Consulting', 'vikram@greentech.in', '+91 98450 12001', 'new', 35000.00, 'EMP-112', 'Rajesh Kumar', '2026-10-12', 'Inbound Enterprise Lead', 'Interested in building unified carbon offset tracking software for solar farms'),
('LED-502', 'InnovortX', 'Sarah Al-Mansoor', 'Mobile App', 'sarah.m@innovortx.ae', '+971 50 123 4567', 'contacted', 48000.00, 'EMP-112', 'Rajesh Kumar', '2026-10-11', 'Dubai Tech Summit Inbound', 'Requires cross-platform Flutter consumer app with payment gateway integration'),
('LED-503', 'Skyline Infra', 'Ramesh Namboodiri', 'Web Platform', 'ramesh@skylineinfra.com', '+91 98200 45003', 'proposal', 62000.00, 'EMP-112', 'Rajesh Kumar', '2026-10-14', 'Direct Executive Outreach', 'Smart city IoT asset monitoring portal. Proposal submitted on Oct 4.'),
('LED-504', 'SolarEase', 'Kavitha Balasubramanian', 'Solar Solutions', 'kavitha@solarease.com', '+91 98410 78004', 'qualified', 28000.00, 'EMP-112', 'Rajesh Kumar', '2026-10-16', 'Industry Conference Referral', 'B2B distributor portal for rooftop solar installations and inverter telemetry'),
('LED-505', 'CyberShield Corp', 'Marcus Vance', 'Cloud Services', 'm.vance@cybershield.us', '+1 415 889 0105', 'contacted', 85000.00, 'EMP-112', 'Rajesh Kumar', '2026-10-09', 'AWS Partner Network', 'Missed follow-up: Follow-up call requested on Cloud Security Posture Management engine'),
('LED-506', 'Nexus Health Systems', 'Dr. Arvind Swaminathan', 'Cloud Services', 'arvind@nexushealth.org', '+91 98110 56006', 'contacted', 95000.00, 'EMP-112', 'Rajesh Kumar', '2026-10-09', 'Direct Executive Outreach', 'Missed follow-up: HIPAA-compliant patient diagnostics archive and HL7 FHIR sync API'),
('LED-507', 'Quantra Analytics', 'Dr. Elena Rostova', 'Web Platform', 'elena@quantra.ch', '+41 22 767 0107', 'proposal', 55000.00, 'EMP-112', 'Rajesh Kumar', '2026-10-08', 'Webinar Attendee Lead', 'Missed follow-up: Quantitative risk analytics dashboard. Revised timeline required.'),
('LED-508', 'Apex Cold-Chain Logistics', 'Harpreet Singh Gill', 'Mobile App', 'harpreet@apexlogistics.in', '+91 98720 33008', 'new', 42000.00, 'EMP-112', 'Rajesh Kumar', '2026-10-09', 'Cold Outreach Campaign', 'Missed follow-up: Fleet temperature monitoring sensor app for refrigerated pharma trucks'),
('LED-509', 'Aura Retail Tech', 'Natasha Sen', 'Mobile App', 'natasha@auraretail.com', '+91 98300 22009', 'new', 38000.00, 'EMP-112', 'Rajesh Kumar', '2026-10-18', 'Shopify Plus Partner Directory', 'Omnichannel inventory sync and POS companion mobile app for lifestyle stores'),
('LED-510', 'BlueWave Maritime', 'Capt. Alistair Finch', 'IT Consulting', 'finch@bluewave.uk', '+44 20 7946 0110', 'proposal', 72000.00, 'EMP-112', 'Rajesh Kumar', '2026-10-17', 'London Shipping Summit', 'Vessel tracking, crew rotation and bunkering fuel cost optimization platform'),
('LED-511', 'Vertex Robotics', 'Chen Wei', 'AI / ML', 'chen.wei@vertexrobotics.sg', '+65 6789 0111', 'qualified', 88000.00, 'EMP-112', 'Rajesh Kumar', '2026-10-19', 'RoboAsia Exhibition', 'Computer vision automated inspection engine for surface defect classification'),
('LED-512', 'ZenMatrix AI', 'Amitabh Ghosh', 'AI / ML', 'amitabh@zenmatrix.ai', '+91 98210 99012', 'qualified', 64000.00, 'EMP-112', 'Rajesh Kumar', '2026-10-20', 'AngelList Syndicate Lead', 'LLM semantic search engine and RAG pipeline for internal legal document analysis'),
('LED-513', 'CloudSprint Networks', 'David K. O''Connor', 'Cloud Services', 'david@cloudsprint.io', '+1 206 555 0113', 'contacted', 50000.00, 'EMP-112', 'Rajesh Kumar', '2026-10-15', 'Kubernetes Community Day', 'Multi-tenant Kubernetes ingress billing and bandwidth utilization reporter'),
('LED-514', 'TerraWatt CleanTech', 'Suresh Poddar', 'Solar Solutions', 'suresh@terrawatt.co.in', '+91 98311 44014', 'won', 110000.00, 'EMP-112', 'Rajesh Kumar', '2026-10-01', 'Direct Executive Outreach', 'Won enterprise contract: National solar farm supervisory control and telemetry gateway')
ON CONFLICT (id) DO NOTHING;

-- 10. THRESHOLD SETTINGS (Singleton id = 1)
INSERT INTO alert_threshold_settings (id, task_overdue_days, intern_missed_update_days, project_behind_schedule_percent, employee_capacity_max_tasks, intern_low_score_cutoff)
VALUES (1, 1, 2, 15, 4, 6.0)
ON CONFLICT (id) DO NOTHING;

-- 11. AUDIT LOGS (Idempotent: Inserts only if matching log entry is not already present)
INSERT INTO audit_logs (action, module, details, performed_by)
SELECT v.action, v.module, v.details, v.performed_by
FROM (VALUES
    ('Database Initialized', 'System', 'Provisioned PostgreSQL 18 enterprise schema with multi-domain tables', 'Laven Lokesh (CEO)'),
    ('Roles Provisioned', 'Admin', 'Configured 10 technical and 8 non-technical corporate tracks', 'Laven Lokesh (CEO)'),
    ('Batch Intake Synchronized', 'People', 'Imported Batch Apr-A (14 interns) and Batch Apr-B (10 interns)', 'Meera Joshi (HR)'),
    ('Thresholds Applied', 'Admin', 'Set task overdue tolerance (1d), intern inactivity (2d), project lag (15%)', 'Laven Lokesh (CEO)')
) AS v(action, module, details, performed_by)
WHERE NOT EXISTS (
    SELECT 1 FROM audit_logs a
    WHERE a.action = v.action
      AND a.module = v.module
      AND a.details = v.details
);
