
CREATE DATABASE IF NOT EXISTS hospital_mgmt;
USE hospital_mgmt;
DROP TABLE IF EXISTS bill_items;
DROP TABLE IF EXISTS bills;
DROP TABLE IF EXISTS medications;
DROP TABLE IF EXISTS treatments;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS rooms;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS doctors;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS patients;

CREATE TABLE departments (
    dept_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80),
    dob DATE,
    gender ENUM('M','F','Other') DEFAULT 'Other',
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80),
    dept_id INT,
    specialization VARCHAR(120),
    phone VARCHAR(20),
    email VARCHAR(100),
    consult_fee DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE SET NULL
);

CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80),
    role VARCHAR(80),
    phone VARCHAR(20),
    email VARCHAR(100),
    hired_on DATE
);

CREATE TABLE rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(20) NOT NULL UNIQUE,
    room_type ENUM('General','Semi-Private','Private','ICU') DEFAULT 'General',
    capacity INT DEFAULT 1,
    occupied INT DEFAULT 0,
    rate_per_day DECIMAL(10,2) DEFAULT 0
);

CREATE TABLE appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_datetime DATETIME NOT NULL,
    duration_minutes INT DEFAULT 30,
    reason VARCHAR(255),
    status ENUM('Scheduled','Completed','Cancelled','No-Show') DEFAULT 'Scheduled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE CASCADE
);

CREATE TABLE treatments (
    treatment_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT,
    patient_id INT NOT NULL,
    doctor_id INT,
    treatment_code VARCHAR(50),
    description TEXT,
    cost DECIMAL(10,2) DEFAULT 0,
    performed_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE SET NULL,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE SET NULL
);

CREATE TABLE medications (
    med_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT,
    name VARCHAR(150),
    dosage VARCHAR(100),
    qty INT DEFAULT 1,
    price_per_unit DECIMAL(10,2) DEFAULT 0,
    issued_on DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE SET NULL
);

CREATE TABLE bills (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(12,2) DEFAULT 0,
    paid_amount DECIMAL(12,2) DEFAULT 0,
    status ENUM('Unpaid','Partially Paid','Paid','Cancelled') DEFAULT 'Unpaid',
    notes TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE
);

CREATE TABLE bill_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    bill_id INT NOT NULL,
    item_type ENUM('Consult','Treatment','Medication','Room','Other') DEFAULT 'Other',
    description VARCHAR(255),
    amount DECIMAL(12,2) NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bill_id) REFERENCES bills(bill_id) ON DELETE CASCADE
);

INSERT INTO departments (name, description) VALUES
('General Medicine','General medical care'),
('Cardiology','Heart and vascular system care'),
('Emergency','Emergency and trauma treatment');

INSERT INTO doctors (first_name, last_name, dept_id, specialization, phone, email, consult_fee)
VALUES
('Amit','Khan',1,'Physician','9876543210','amit.khan@hospital.com',300.00),
('Neha','Singh',2,'Cardiologist','9123456780','neha.singh@hospital.com',800.00);

INSERT INTO patients (first_name, last_name, dob, gender, phone, email, address)
VALUES
('Ravi','Verma','1990-02-10','M','9999999999','ravi.verma@gmail.com','Delhi'),
('Sita','Sharma','1985-07-01','F','8888888888','sita.sharma@gmail.com','Mumbai'),
('Anita','Kumar','1992-05-12','F','7777777777','anita.kumar@gmail.com','Bangalore');

INSERT INTO rooms (room_number, room_type, capacity, rate_per_day)
VALUES
('101','General',2,1000.00),
('201','Private',1,3500.00),
('ICU-1','ICU',1,8000.00);

INSERT INTO appointments (patient_id, doctor_id, appointment_datetime, duration_minutes, reason)
VALUES
(1,1,'2025-11-10 10:00:00',30,'Fever and cold'),
(2,2,'2025-11-10 11:30:00',45,'Chest pain');


INSERT INTO treatments (appointment_id, patient_id, doctor_id, treatment_code, description, cost)
VALUES
(1,1,1,'T101','Routine checkup and prescription',300.00),
(2,2,2,'C201','ECG and heart diagnosis',800.00);


INSERT INTO medications (patient_id, doctor_id, name, dosage, qty, price_per_unit)
VALUES
(1,1,'Paracetamol 500mg','1 tablet twice daily',10,2.00),
(2,2,'Aspirin 75mg','1 tablet daily',15,3.00);


INSERT INTO bills (patient_id, notes) VALUES
(1,'Consultation with Dr. Amit'),
(2,'Cardiology appointment with Dr. Neha');

INSERT INTO bill_items (bill_id, item_type, description, amount)
VALUES
(1,'Consult','Consultation Fee - Dr. Amit',300.00),
(2,'Consult','Consultation Fee - Dr. Neha',800.00);


UPDATE bills b
JOIN (SELECT bill_id, SUM(amount) AS total FROM bill_items GROUP BY bill_id) s
  ON b.bill_id = s.bill_id
SET b.total_amount = s.total;


DELIMITER //
CREATE TRIGGER trg_add_treatment_to_bill
AFTER INSERT ON treatments
FOR EACH ROW
BEGIN
  DECLARE open_bill INT;

  SELECT bill_id INTO open_bill
  FROM bills
  WHERE patient_id = NEW.patient_id AND status <> 'Paid'
  ORDER BY created_on DESC
  LIMIT 1;

  IF open_bill IS NULL THEN
    INSERT INTO bills (patient_id, notes)
    VALUES (NEW.patient_id, CONCAT('Auto bill for treatment on ', NEW.performed_on));
    SET open_bill = LAST_INSERT_ID();
  END IF;

  INSERT INTO bill_items (bill_id, item_type, description, amount)
  VALUES (open_bill, 'Treatment', NEW.description, NEW.cost);

  UPDATE bills b
  JOIN (SELECT bill_id, SUM(amount) AS total FROM bill_items WHERE bill_id = open_bill GROUP BY bill_id) s
  ON b.bill_id = s.bill_id
  SET b.total_amount = s.total
  WHERE b.bill_id = open_bill;
END;


CREATE PROCEDURE sp_schedule_appointment(
  IN p_patient_id INT,
  IN p_doctor_id INT,
  IN p_datetime DATETIME,
  IN p_duration INT,
  IN p_reason VARCHAR(255),
  OUT p_result VARCHAR(255)
)
BEGIN
  DECLARE conflict INT;
  SELECT COUNT(*) INTO conflict
  FROM appointments
  WHERE doctor_id = p_doctor_id
  AND status = 'Scheduled'
  AND (
    (p_datetime BETWEEN appointment_datetime AND DATE_ADD(appointment_datetime, INTERVAL duration_minutes MINUTE))
    OR (DATE_ADD(p_datetime, INTERVAL p_duration MINUTE) BETWEEN appointment_datetime AND DATE_ADD(appointment_datetime, INTERVAL duration_minutes MINUTE))
  );

  IF conflict > 0 THEN
    SET p_result = 'Doctor not available at this time';
  ELSE
    INSERT INTO appointments (patient_id, doctor_id, appointment_datetime, duration_minutes, reason)
    VALUES (p_patient_id, p_doctor_id, p_datetime, p_duration, p_reason);
    SET p_result = CONCAT('Appointment Scheduled. ID: ', LAST_INSERT_ID());
  END IF;
END;


CREATE OR REPLACE VIEW vw_patient_bills AS
SELECT 
  p.patient_id,
  CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
  b.bill_id,
  b.total_amount,
  b.paid_amount,
  b.status,
  b.created_on
FROM patients p
LEFT JOIN bills b ON p.patient_id = b.patient_id;

SELECT * FROM vw_patient_bills;

CALL sp_schedule_appointment(3,1,'2025-11-11 09:30:00',30,'Routine checkup',@msg);
SELECT @msg;
