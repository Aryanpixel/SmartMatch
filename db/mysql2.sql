-- =============================================
-- UPDATED DATABASE SCHEMA FOR RECRUITER MATCHING
-- =============================================

USE user_profiles;

-- =============================================
-- 1. JOB POSTINGS TABLE (Extended)
-- =============================================
-- DROP TABLE IF EXISTS job_postings;
-- CREATE TABLE job_postings (
--     id INT AUTO_INCREMENT PRIMARY KEY,
--     recruiter_id INT NOT NULL,
--     job_domain VARCHAR(50) NOT NULL,  -- 'cse-it', 'ece', 'eee', 'mechanical', 'mba', 'ca'
--     job_post VARCHAR(255) NOT NULL,   -- Specific role like 'SDE', 'Data Scientist', etc.
--     job_title VARCHAR(255) NOT NULL,
--     job_description TEXT,
--     location VARCHAR(255),
--     salary_range VARCHAR(100),
--     
--     -- Main Weights (must sum to 100)
--     weight_education INT NOT NULL DEFAULT 25,
--     weight_experience INT NOT NULL DEFAULT 25,
--     weight_skills INT NOT NULL DEFAULT 25,
--     weight_projects INT NOT NULL DEFAULT 25,
--     
--     -- Education Thresholds
--     cgpa_threshold DECIMAL(4,2),
--     qualification_threshold VARCHAR(50),  -- 'any', 'bachelors', 'masters', 'phd'
--     
--     -- Experience Thresholds
--     experience_min_years INT,
--     experience_max_years INT,
--     
--     -- Status
--     is_active BOOLEAN DEFAULT TRUE,
--     posted_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--     
--     FOREIGN KEY (recruiter_id) REFERENCES recruiters(id) ON DELETE CASCADE,
--     
--     -- Ensure weights sum to 100
--     CONSTRAINT check_weights_sum CHECK (
--         weight_education + weight_experience + weight_skills + weight_projects = 100
--     )
-- );

-- =============================================
-- 2. CANDIDATE MATCHES TABLE (Store calculated matches)
-- =============================================
CREATE TABLE IF NOT EXISTS candidate_matches (
    id INT AUTO_INCREMENT PRIMARY KEY,
    job_posting_id INT NOT NULL,
    user_id INT NOT NULL,
    
    -- Individual Scores (0-10 scale)
    education_score DECIMAL(5,2),
    experience_score DECIMAL(5,2),
    skills_score DECIMAL(5,2),
    projects_score DECIMAL(5,2),
    
    -- Weighted Scores
    education_weighted DECIMAL(5,2),
    experience_weighted DECIMAL(5,2),
    skills_weighted DECIMAL(5,2),
    projects_weighted DECIMAL(5,2),
    
    -- Final Composite Score (0-100)
    composite_score DECIMAL(5,2) NOT NULL,
    
    -- Match Rank
    match_rank INT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (job_posting_id) REFERENCES job_postings(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Prevent duplicate matches
    UNIQUE KEY unique_match (job_posting_id, user_id)
);

-- =============================================
-- 3. DOMAIN-POST WEIGHTINGS (Hardcoded for now)
-- =============================================
CREATE TABLE IF NOT EXISTS domain_post_weights (
    id INT AUTO_INCREMENT PRIMARY KEY,
    domain VARCHAR(50) NOT NULL,
    post_name VARCHAR(255) NOT NULL,
    weight_value DECIMAL(4,2) NOT NULL DEFAULT 10.00,
    
    UNIQUE KEY unique_domain_post (domain, post_name)
);

-- Insert hardcoded weights for CSE/IT domain
INSERT INTO domain_post_weights (domain, post_name, weight_value) VALUES
('cse-it', 'Software Development Engineer (SDE)', 10.00),
('cse-it', 'Data Scientist', 9.50),
('cse-it', 'DevOps Engineer', 9.00),
('cse-it', 'Machine Learning Engineer', 9.50),
('cse-it', 'Full Stack Developer', 9.00),
('cse-it', 'Backend Developer', 8.50),
('cse-it', 'Frontend Developer', 8.00),
('cse-it', 'Cloud Engineer', 8.50),
('cse-it', 'Database Administrator', 7.50),
('cse-it', 'Cybersecurity Analyst', 8.00);

-- Insert weights for ECE domain
INSERT INTO domain_post_weights (domain, post_name, weight_value) VALUES
('ece', 'Electronics Engineer', 10.00),
('ece', 'VLSI Engineer', 9.50),
('ece', 'Hardware Engineer', 9.00),
('ece', 'Telecommunications Engineer', 8.50),
('ece', 'Embedded Systems Engineer', 9.00),
('ece', 'Network Engineer', 8.00),
('ece', 'RF Engineer', 8.50),
('ece', 'Systems Analyst', 7.50),
('ece', 'Instrumentation Engineer', 7.50),
('ece', 'Signal Processing Engineer', 8.50);

-- Insert weights for EEE domain
INSERT INTO domain_post_weights (domain, post_name, weight_value) VALUES
('eee', 'Electrical Engineer', 10.00),
('eee', 'Power Systems Engineer', 9.50),
('eee', 'Control Systems Engineer', 9.00),
('eee', 'Renewable Energy Engineer', 9.00),
('eee', 'Electronics Engineer', 8.50),
('eee', 'Substation Engineer', 8.00),
('eee', 'Electrical Design Engineer', 8.50),
('eee', 'Automation Engineer', 8.50),
('eee', 'Instrumentation Engineer', 7.50),
('eee', 'Project Engineer (Electrical)', 7.50);

-- Insert weights for Mechanical domain
INSERT INTO domain_post_weights (domain, post_name, weight_value) VALUES
('mechanical', 'Mechanical Engineer', 10.00),
('mechanical', 'Design Engineer', 9.50),
('mechanical', 'Manufacturing Engineer', 9.00),
('mechanical', 'Automotive Engineer', 9.00),
('mechanical', 'HVAC Engineer', 8.00),
('mechanical', 'Robotics Engineer', 9.50),
('mechanical', 'Aerospace Engineer', 9.50),
('mechanical', 'Thermal Engineer', 8.50),
('mechanical', 'QA/QC Engineer', 7.50),
('mechanical', 'Maintenance Engineer', 7.00);

-- Insert weights for MBA domain
INSERT INTO domain_post_weights (domain, post_name, weight_value) VALUES
('mba', 'Management Consultant', 10.00),
('mba', 'Product Manager', 9.50),
('mba', 'Marketing Manager', 9.00),
('mba', 'Financial Analyst', 9.00),
('mba', 'HR Manager', 8.50),
('mba', 'Business Development Manager', 9.00),
('mba', 'Operations Manager', 8.50),
('mba', 'Supply Chain Manager', 8.50),
('mba', 'Project Manager', 8.50),
('mba', 'Investment Banker', 9.50);

-- Insert weights for CA domain
INSERT INTO domain_post_weights (domain, post_name, weight_value) VALUES
('ca', 'Chartered Accountant', 10.00),
('ca', 'Finance Manager', 9.50),
('ca', 'Audit Manager', 9.00),
('ca', 'Tax Consultant', 9.00),
('ca', 'Statutory Auditor', 8.50),
('ca', 'Internal Auditor', 8.00),
('ca', 'Financial Controller', 9.00),
('ca', 'Forensic Accountant', 8.50),
('ca', 'Risk Manager', 8.50),
('ca', 'Accounts Executive', 7.00);

-- =============================================
-- 4. SKILL TREE STRUCTURE (For CSE/IT initially)
-- =============================================
CREATE TABLE IF NOT EXISTS skill_hierarchy (
    id INT AUTO_INCREMENT PRIMARY KEY,
    domain VARCHAR(50) NOT NULL,
    parent_skill VARCHAR(100),
    skill_name VARCHAR(100) NOT NULL,
    skill_level INT NOT NULL, -- 1=root, 2=branch, 3=leaf
    weight_multiplier DECIMAL(4,2) DEFAULT 1.00,
    
    UNIQUE KEY unique_skill (domain, skill_name)
);

-- Insert CSE/IT skill tree
INSERT INTO skill_hierarchy (domain, parent_skill, skill_name, skill_level, weight_multiplier) VALUES
-- Level 1: Root categories
('cse-it', NULL, 'DSA', 1, 1.00),
('cse-it', NULL, 'Development', 1, 1.00),

-- Level 2: Development branches
('cse-it', 'Development', 'Web Development', 2, 1.00),
('cse-it', 'Development', 'App Development', 2, 0.95),

-- Level 3: Web Development leaves
('cse-it', 'Web Development', 'Frontend', 3, 1.00),
('cse-it', 'Web Development', 'Backend', 3, 1.00),
('cse-it', 'Web Development', 'Full Stack', 3, 1.10),

-- Level 4: Frontend specific skills
('cse-it', 'Frontend', 'React', 4, 1.20),
('cse-it', 'Frontend', 'HTML', 4, 1.00),
('cse-it', 'Frontend', 'CSS', 4, 1.00),
('cse-it', 'Frontend', 'JavaScript', 4, 1.20),

-- Level 4: Backend specific skills
('cse-it', 'Backend', 'Node.js', 4, 1.20),
('cse-it', 'Backend', 'Express', 4, 1.10),
('cse-it', 'Backend', 'MongoDB', 4, 1.00),
('cse-it', 'Backend', 'SQL', 4, 1.10);

-- =============================================
-- 5. INDEXES FOR PERFORMANCE
-- =============================================
CREATE INDEX idx_job_domain ON job_postings(job_domain);
CREATE INDEX idx_job_active ON job_postings(is_active);
CREATE INDEX idx_match_score ON candidate_matches(composite_score DESC);
CREATE INDEX idx_match_job ON candidate_matches(job_posting_id, composite_score DESC);
CREATE INDEX idx_profile_domain ON profiles(domain);
CREATE INDEX idx_skills_profile ON skills(profile_id, skill_name);