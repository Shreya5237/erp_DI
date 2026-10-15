-- ==============================================================================
-- DIGITAL INERTIA ERP — LOCAL DEVELOPMENT & TEST SEED USERS
-- File: R__seed_dev_users.sql (Repeatable Flyway Migration)
-- Location: classpath:db/dev-seeds
-- 
-- Default password for all dev/corporate accounts: 'password123!'
-- BCrypt Hash: $2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK
-- ==============================================================================

INSERT INTO users (id, email, password_hash, full_name, role, employee_id) VALUES
-- 1. Executive Leadership
('USR-001', 'laven@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Laven Lokesh', 'ROLE_CEO', NULL),

-- 2. Technical Employees & POCs
('USR-101', 'arjun.sharma@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Arjun Sharma', 'ROLE_POC', 'EMP-101'),
('USR-102', 'priya.nair@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Priya Nair', 'ROLE_POC', 'EMP-102'),
('USR-103', 'karthik.r@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Karthik R', 'ROLE_EMPLOYEE', 'EMP-103'),
('USR-104', 'sneha.v@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Sneha V', 'ROLE_EMPLOYEE', 'EMP-104'),
('USR-105', 'rohan.mehta@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Rohan Mehta', 'ROLE_EMPLOYEE', 'EMP-105'),
('USR-106', 'ananya.deshmukh@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Ananya Deshmukh', 'ROLE_EMPLOYEE', 'EMP-106'),
('USR-107', 'vikram.singh@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Vikram Singh', 'ROLE_EMPLOYEE', 'EMP-107'),
('USR-108', 'neha.patel@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Neha Patel', 'ROLE_EMPLOYEE', 'EMP-108'),
('USR-109', 'rahul.verma@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Rahul Verma', 'ROLE_EMPLOYEE', 'EMP-109'),
('USR-110', 'divya.iyer@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Divya Iyer', 'ROLE_EMPLOYEE', 'EMP-110'),

-- 3. HR Department
('USR-111', 'meera.joshi@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Meera Joshi', 'ROLE_HR', 'EMP-111'),
('USR-118', 'shreya.kulkarni@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Shreya Kulkarni', 'ROLE_TECH', 'EMP-118'),

-- 4. Sales & Marketing Department
('USR-112', 'rajesh.kumar@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Rajesh Kumar', 'ROLE_SALES_MARKETING', 'EMP-112'),
('USR-116', 'kavita.rao@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Kavita Rao', 'ROLE_SALES_MARKETING', 'EMP-116'),

-- 5. Digital Marketing Department
('USR-113', 'sanjay.menon@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Sanjay Menon', 'ROLE_DIGITAL_MARKETING', 'EMP-113'),
('USR-117', 'aditya.sen@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Aditya Sen', 'ROLE_DIGITAL_MARKETING', 'EMP-117'),

-- 6. Finance Department
('USR-114', 'pooja.hegde@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Pooja Hegde', 'ROLE_FINANCE', 'EMP-114'),
('USR-115', 'siddharth.roy@digitalinertia.com', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Siddharth Roy', 'ROLE_FINANCE', 'EMP-115'),

-- 6. Intern Cohort
('USR-201', 'aarav.gupta@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Aarav Gupta', 'ROLE_INTERN', 'INT-201'),
('USR-202', 'bhavya.shah@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Bhavya Shah', 'ROLE_INTERN', 'INT-202'),
('USR-203', 'chirag.mathur@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Chirag Mathur', 'ROLE_INTERN', 'INT-203'),
('USR-204', 'deepika.pillai@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Deepika Pillai', 'ROLE_INTERN', 'INT-204'),
('USR-205', 'eshan.kulkarni@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Eshan Kulkarni', 'ROLE_INTERN', 'INT-205'),
('USR-206', 'falguni.das@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Falguni Das', 'ROLE_INTERN', 'INT-206'),
('USR-207', 'gautam.nambiar@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Gautam Nambiar', 'ROLE_INTERN', 'INT-207'),
('USR-208', 'harini.s@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Harini Swaminathan', 'ROLE_INTERN', 'INT-208'),
('USR-209', 'ishaan.saxena@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Ishaan Saxena', 'ROLE_INTERN', 'INT-209'),
('USR-210', 'jayati.bose@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Jayati Bose', 'ROLE_INTERN', 'INT-210'),
('USR-211', 'kunal.trivedi@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Kunal Trivedi', 'ROLE_INTERN', 'INT-211'),
('USR-212', 'lavanya.s@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Lavanya Sundaram', 'ROLE_INTERN', 'INT-212'),
('USR-213', 'manish.chawla@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Manish Chawla', 'ROLE_INTERN', 'INT-213'),
('USR-214', 'nandini.rao@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Nandini Rao', 'ROLE_INTERN', 'INT-214'),
('USR-215', 'omkar.jadhav@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Omkar Jadhav', 'ROLE_INTERN', 'INT-215'),
('USR-216', 'parul.s@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Parul Singhania', 'ROLE_INTERN', 'INT-216'),
('USR-217', 'qasim.rizvi@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Qasim Rizvi', 'ROLE_INTERN', 'INT-217'),
('USR-218', 'ritika.kaul@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Ritika Kaul', 'ROLE_INTERN', 'INT-218'),
('USR-219', 'siddhant.b@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Siddhant Bakshi', 'ROLE_INTERN', 'INT-219'),
('USR-220', 'tanvi.m@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Tanvi Mahajan', 'ROLE_INTERN', 'INT-220'),
('USR-221', 'udayan.sen@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Udayan Sen', 'ROLE_INTERN', 'INT-221'),
('USR-222', 'varun.somani@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Varun Somani', 'ROLE_INTERN', 'INT-222'),
('USR-223', 'waseem.akram@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Waseem Akram', 'ROLE_INTERN', 'INT-223'),
('USR-224', 'yamini.reddy@collegemail.edu', '$2a$10$7J3NSDKmdXX/Ir3l/T4BLeMtcM2QrOtWgb18WM5BCRID7A4tp6FwK', 'Yamini Reddy', 'ROLE_INTERN', 'INT-224')
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  password_hash = EXCLUDED.password_hash,
  full_name = EXCLUDED.full_name,
  role = EXCLUDED.role,
  employee_id = EXCLUDED.employee_id;
