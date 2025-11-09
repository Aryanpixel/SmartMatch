-- =============================================
-- EMPLOYEE TABLES (Already exists)
-- =============================================
CREATE database user_profiles;

USE user_profiles;

-- Users table (already created)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    dob DATE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Profiles table (already created)
CREATE TABLE IF NOT EXISTS profiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    domain VARCHAR(100) NOT NULL,
    qualification VARCHAR(100) NOT NULL,
    cgpa DECIMAL(4,2),
    grad_year INT NOT NULL,
    current_designation VARCHAR(100),
    current_company VARCHAR(100),
    current_ctc DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Courses table (already created)
CREATE TABLE IF NOT EXISTS courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    profile_id INT NOT NULL,
    course_name VARCHAR(255) NOT NULL,
    FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE
);

-- Skills table (already created)
CREATE TABLE IF NOT EXISTS skills (
    id INT AUTO_INCREMENT PRIMARY KEY,
    profile_id INT NOT NULL,
    skill_name VARCHAR(100) NOT NULL,
    years_experience DECIMAL(4,1),
    FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE
);

-- Projects table (already created)
CREATE TABLE IF NOT EXISTS projects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    profile_id INT NOT NULL,
    project_name VARCHAR(255) NOT NULL,
    description TEXT,
    link VARCHAR(500),
    FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE
);

-- =============================================
-- RECRUITER TABLES (New)
-- =============================================

-- Recruiters table
CREATE TABLE IF NOT EXISTS recruiters (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    position VARCHAR(100) NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    company_location VARCHAR(255) NOT NULL,
    udyam_file_name VARCHAR(500),
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Job postings by recruiters
CREATE TABLE job_postings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    recruiter_id INT NOT NULL,
    job_domain VARCHAR(50) NOT NULL,  -- 'cse-it', 'ece', 'eee', 'mechanical', 'mba', 'ca'
    job_post VARCHAR(255) NOT NULL,   -- Specific role like 'SDE', 'Data Scientist', etc.
    job_title VARCHAR(255) NOT NULL,
    job_description TEXT,
    location VARCHAR(255),
    salary_range VARCHAR(100),
    
    -- Main Weights (must sum to 100)
    weight_education INT NOT NULL DEFAULT 25,
    weight_experience INT NOT NULL DEFAULT 25,
    weight_skills INT NOT NULL DEFAULT 25,
    weight_projects INT NOT NULL DEFAULT 25,
    
    -- Education Thresholds
    cgpa_threshold DECIMAL(4,2),
    qualification_threshold VARCHAR(50),  -- 'any', 'bachelors', 'masters', 'phd'
    
    -- Experience Thresholds
    experience_min_years INT,
    experience_max_years INT,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    posted_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (recruiter_id) REFERENCES recruiters(id) ON DELETE CASCADE,
    
    -- Ensure weights sum to 100
    CONSTRAINT check_weights_sum CHECK (
        weight_education + weight_experience + weight_skills + weight_projects = 100
	)
);

-- Applications tracking
CREATE TABLE IF NOT EXISTS applications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    user_id INT NOT NULL,
    recruiter_id INT NOT NULL,
    status ENUM('pending', 'reviewed', 'shortlisted', 'rejected', 'hired') DEFAULT 'pending',
    applied_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES job_postings(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (recruiter_id) REFERENCES recruiters(id) ON DELETE CASCADE
);

-- =============================================
-- COMMUNITY/SOCIAL FEATURES (For LinkedIn-like feed)
-- =============================================

-- Posts table (for community feed)
CREATE TABLE IF NOT EXISTS posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    author_type ENUM('employee', 'recruiter') NOT NULL,
    author_id INT NOT NULL,
    content TEXT NOT NULL,
    image_url VARCHAR(500),
    likes_count INT DEFAULT 0,
    comments_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Likes table
CREATE TABLE IF NOT EXISTS post_likes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_type ENUM('employee', 'recruiter') NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    UNIQUE KEY unique_like (post_id, user_type, user_id)
);

-- Comments table
CREATE TABLE IF NOT EXISTS comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_type ENUM('employee', 'recruiter') NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);