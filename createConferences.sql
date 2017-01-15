-- Create an empty database
USE master
IF EXISTS(SELECT * FROM sys.databases WHERE name = 'Conferences')
DROP DATABASE Conferences
CREATE DATABASE Conferences

-- Create tables
USE Conferences

CREATE TABLE Clients (
	client_id int PRIMARY KEY IDENTITY(1,1),
	company_id int,
	firstname nvarchar(50) NOT NULL,
	lastname nvarchar(50) NOT NULL,
	initial nvarchar(1)
)

CREATE TABLE Companies (
	company_id int PRIMARY KEY IDENTITY(1,1),
	company_name nvarchar(50) NOT NULL,
	address nvarchar(50) NOT NULL,
	city nvarchar(50) NOT NULL,
	country nvarchar(50) NOT NULL,
	zip_code varchar(8)
)

CREATE TABLE Conferences (
	conference_id int PRIMARY KEY IDENTITY(1,1),
	date_start datetime NOT NULL,
	date_end datetime NOT NULL,
	name nvarchar(50) NOT NULL,
	price money
)

CREATE TABLE ConferenceDays (
	conference_day_id int PRIMARY KEY IDENTITY(1,1),
	conference_id int NOT NULL,
	date datetime NOT NULL,
	num_spots int NOT NULL
)

CREATE TABLE ConferenceAttendees (
	client_id int NOT NULL,
	conference_day_id int NOT NULL
)

CREATE TABLE WorkshopAttendees (
	client_id int NOT NULL,
	workshop_id int NOT NULL
)

-- TODO: constraint/trigger - day & year of workshop.date == day & year of conference_day.date
CREATE TABLE Workshops (
	workshop_id int PRIMARY KEY IDENTITY(1,1),
	conference_day_id int NOT NULL,
	title nvarchar(50) NOT NULL,
	num_spots int NOT NULL,
	date datetime NOT NULL,
	price money
)

CREATE TABLE ConferenceReservations (
	reservation_id int PRIMARY KEY IDENTITY(1,1),
	conference_id int NOT NULL,
	reservation_details_id int NOT NULL
)

CREATE TABLE WorkshopReservations (
	reservation_id int PRIMARY KEY IDENTITY(1,1),
	workshop_id int NOT NULL,
	reservation_details_id int NOT NULL
)

CREATE TABLE ReservationDetails (
	reservation_details_id int PRIMARY KEY IDENTITY(1,1),
	client_id int,
	company_id int,
	payment_id int,
	num_spots int NOT NULL,
	reservation_date datetime NOT NULL,
	reservation_cancellation_date datetime
)

-- TODO: check - amount_paid == price of workshop/conference
CREATE TABLE Payments (
	payment_id int PRIMARY KEY IDENTITY(1,1),
	client_id int,
	company_id int,
	date_paid datetime,
	amount_paid money,
	category varchar(10) NOT NULL
)

-- TODO: Constraints, defaults, uniques

-- Relations
ALTER TABLE Clients
	ADD CONSTRAINT fk_client_company
	FOREIGN KEY (company_id) REFERENCES Companies(company_id)

ALTER TABLE ConferenceDays
	ADD CONSTRAINT fk_conference_day_conference
	FOREIGN KEY (conference_id) REFERENCES Conferences(conference_id)

ALTER TABLE ConferenceAttendees
	ADD CONSTRAINT fk_c_attendee_client
	FOREIGN KEY (client_id) REFERENCES Clients(client_id)
ALTER TABLE ConferenceAttendees
	ADD CONSTRAINT fk_c_attendee_conference_day
	FOREIGN KEY (conference_day_id) REFERENCES ConferenceDays(conference_day_id)

ALTER TABLE WorkshopAttendees
	ADD CONSTRAINT fk_w_attendee_client 
	FOREIGN KEY (client_id) REFERENCES Clients(client_id)
ALTER TABLE WorkshopAttendees
	ADD CONSTRAINT fk_w_attendee_workshop
	FOREIGN KEY (workshop_id) REFERENCES Workshops(workshop_id)

ALTER TABLE Workshops
	ADD CONSTRAINT fk_workshop_conference_day
	FOREIGN KEY (conference_day_id) REFERENCES ConferenceDays(conference_day_id)

ALTER TABLE ConferenceReservations
	ADD CONSTRAINT fk_c_reservation_conference
	FOREIGN KEY (conference_id) REFERENCES Conferences(conference_id)
ALTER TABLE ConferenceReservations
	ADD CONSTRAINT fk_c_reservation_details
	FOREIGN KEY (reservation_details_id) REFERENCES ReservationDetails(reservation_details_id)

ALTER TABLE WorkshopReservations
	ADD CONSTRAINT fk_w_reservation_workshop
	FOREIGN KEY (workshop_id) REFERENCES Workshops(workshop_id)
ALTER TABLE WorkshopReservations
	ADD CONSTRAINT fk_w_reservation_details
	FOREIGN KEY (reservation_details_id) REFERENCES ReservationDetails(reservation_details_id)

ALTER TABLE ReservationDetails
	ADD CONSTRAINT fk_reservation_payment
	FOREIGN KEY (payment_id) REFERENCES Payments(payment_id)
ALTER TABLE ReservationDetails
	ADD CONSTRAINT fk_reservation_client
	FOREIGN KEY (client_id) REFERENCES Clients(client_id)
ALTER TABLE ReservationDetails
	ADD CONSTRAINT fk_reservation_company
	FOREIGN KEY (company_id) REFERENCES Companies(company_id)

ALTER TABLE Payments
	ADD CONSTRAINT fk_payment_client
	FOREIGN KEY (client_id) REFERENCES Clients(client_id)
ALTER TABLE Payments
	ADD CONSTRAINT fk_payment_company
	FOREIGN KEY (company_id) REFERENCES Companies(company_id) 

-- Constraints

ALTER TABLE Conferences
	ADD CONSTRAINT ck_date_start
	CHECK(date_start > GETDATE())
ALTER TABLE Conferences
	ADD CONSTRAINT ck_date_end
	CHECK(date_start > GETDATE())
ALTER TABLE Conferences
	ADD CONSTRAINT ck_date_end_gt_date_start
	CHECK(date_end >= DATEADD(day, 1, date_start))

ALTER TABLE ConferenceDays
	ADD CONSTRAINT ck_uniq_date
	UNIQUE (date)

ALTER TABLE ReservationDetails
	ADD CONSTRAINT ck_reservation_date
	CHECK(reservation_date > GETDATE())
ALTER TABLE ReservationDetails
	ADD CONSTRAINT ck_cancellation_date
	CHECK(reservation_cancellation_date > reservation_date)

	
ALTER TABLE Payments
	ADD CONSTRAINT ck_payment_date
	CHECK(date_paid > GETDATE())