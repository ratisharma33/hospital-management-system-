# hospital-management-system-
hospital Management system using sql and dbms concepts 
The Hospital Management System (HMS) is a Database Management System (DBMS) project designed to efficiently manage hospital operations such as patient registration, doctor management, appointments, billing, medications, and room allocation.
It ensures smooth data flow between departments and provides reliable and secure storage of hospital records using SQL-based database management.


👩‍⚕️ Patient Management

Register and update patient details (personal info, contact, medical history)

Track admitted and discharged patients

🧑‍⚕️ Doctor Management

Store doctor profiles with specialization, department, and consultation fees

Manage doctor schedules and appointments

📅 Appointment Scheduling

Create and manage appointments between patients and doctors

Prevent double-booking using stored procedures and triggers

💊 Medications & Treatments

Maintain records of prescribed medicines and treatments performed

Automatically generate bill items when new treatments are added

💰 Billing System

Generate detailed bills for patients (consultation, treatment, room, medicine)

Track total, paid, and pending payments

🏠 Room Management

Allocate and release rooms (ICU, General, Private)

Track room occupancy and rate per day

⚙️ Database Logic

Triggers for auto billing after treatments

Stored Procedures for appointment conflict checking

Views for quick reporting of patient bills

🧩 Database Structure

Main Tables:

patients – Stores patient details

doctors – Stores doctor profiles

departments – Hospital departments

appointments – Doctor-patient appointment data

treatments – Records of treatments provided

medications – Issued medicines

bills & bill_items – Billing information

rooms – Room details and occupancy status

staff – Non-medical staff details

Supporting Objects:

trg_add_treatment_to_bill – Trigger for auto billing

sp_schedule_appointment – Stored procedure for scheduling appointments

vw_patient_bills – View for consolidated patient billing report
