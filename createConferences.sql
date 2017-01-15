-- Create an empty database
USE master
IF EXISTS(SELECT * FROM sys.databases WHERE name = 'Conferences')
DROP DATABASE Conferences
CREATE DATABASE Conferences

-- Create tables
USE Conferences

-- TODO: Do we need object id checks on empty database?
-- TODO: Foreign keys by alter table -> constraints

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
	client_id int PRIMARY KEY IDENTITY(1,1),
	conference_day_id int NOT NULL
)

CREATE TABLE WorkshopAttendees (
	client_id int PRIMARY KEY IDENTITY(1,1),
	workshop_id int NOT NULL
)

CREATE TABLE Workshops (
	workshop_id int PRIMARY KEY IDENTITY(1,1),
	conference_id int NOT NULL,
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

CREATE TABLE WorkshopsReservations (
	reservation_id int PRIMARY KEY IDENTITY(1,1),
	workshop_id int NOT NULL,
	reservation_details_id int NOT NULL
)

-- TODO: some other configuration rather than id depending on a boolean?
CREATE TABLE ReservationDetails (
	reservation_details_id int PRIMARY KEY IDENTITY(1,1),
	reservee_id int NOT NULL,
	payment_id int,
	is_reservee_company bit NOT NULL,
	num_spots int NOT NULL,
	reservation_date datetime NOT NULL,
	reservation_cancellation_date datetime
)

CREATE TABLE Payments (
	payment_id int PRIMARY KEY IDENTITY(1,1),
	payer_id int NOT NULL,
	date_paid datetime,
	amount_paid money,
	category varchar(10) NOT NULL
)

-- TODO: Constrainty, defaulty, unikalnosc