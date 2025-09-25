# hospital-management-system-
hospital Management system using sql and dbms concepts 
-- 1. Create Database
CREATE DATABASE IF NOT EXISTS HospitalDB;
USE HospitalDB;

-- 2. Create Tables

-- Patients Table
CREATE TABLE IF NOT EXISTS Patients (
    PatientID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Age INT,
    Gender VARCHAR(10),
    Phone VARCHAR(20),
    Disease VARCHAR(100)
);

-- Doctors Table
CREATE TABLE IF NOT EXISTS Doctors (
    DoctorID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Specialization VARCHAR(100),
    Phone VARCHAR(20)
);

-- Appointments Table
CREATE TABLE IF NOT EXISTS Appointments (
    AppointmentID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT,
    DoctorID INT,
    AppointmentDate DATE,
    AppointmentTime TIME,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

-- 3. Insert Sample Data

-- Patients
INSERT INTO Patients (Name, Age, Gender, Phone, Disease) VALUES
('Rati Sharma', 21, 'Female', '9876543210', 'Fever'),
('Rahul Kumar', 30, 'Male', '9123456780', 'Cold');

-- Doctors
INSERT INTO Doctors (Name, Specialization, Phone) VALUES
('Dr. Anil', 'Cardiologist', '9876501234'),
('Dr. Priya', 'Neurologist', '9123409876');

-- Appointments
INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, AppointmentTime) VALUES
(1, 1, '2025-09-26', '10:30:00'),
(2, 2, '2025-09-27', '14:00:00');

-- 4. Select Data

-- View all patients
SELECT * FROM Patients;

-- View all doctors
SELECT * FROM Doctors;

-- View all appointments with patient and doctor names
SELECT a.AppointmentID, p.Name AS PatientName, d.Name AS DoctorName, a.AppointmentDate, a.AppointmentTime
FROM Appointments a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Doctors d ON a.DoctorID = d.DoctorID;

-- 5. Update Data

-- Update patient phone
UPDATE Patients
SET Phone = '9998887776'
WHERE PatientID = 1;

-- Update doctor specialization
UPDATE Doctors
SET Specialization = 'General Physician'
WHERE DoctorID = 2;

-- 6. Delete Data

-- Delete an appointment
DELETE FROM Patients
WHERE PatientID = 2;
