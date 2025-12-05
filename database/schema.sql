-- Database
CREATE DATABASE IF NOT EXISTS attendance;
USE attendance;

-- Students Table
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    roll_no VARCHAR(50) UNIQUE NOT NULL,
    qr_code VARCHAR(255) UNIQUE NOT NULL,
    department VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Attendance Table
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    date DATE NOT NULL,
    meal_type ENUM('Breakfast', 'Lunch', 'Tea', 'Dinner') NOT NULL,
    status ENUM('Present', 'Absent') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

-- Rebate Table
CREATE TABLE rebates (
    rebate_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    date DATE NOT NULL,
    rebate_amount DECIMAL(10,2) NOT NULL,
    rebate_status ENUM('Full', 'Half', 'None') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);
