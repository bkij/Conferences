USE Conferences

--TODO: Some kind of error here, investigate
SET DATEFORMAT dmy

BULK INSERT Clients 
FROM 'C:\Users\kveld\Desktop\Conferences\clientData.csv'
WITH (
	FIELDTERMINATOR = '~',
	KEEPIDENTITY,
	KEEPNULLS,
	ROWTERMINATOR = '\r\n',
	DATAFILETYPE = 'widechar'
)

BULK INSERT Companies
FROM 'C:\Users\kveld\Desktop\Conferences\companyData.csv'
WITH (
	FIELDTERMINATOR = '~',
	KEEPIDENTITY,
	KEEPNULLS,
	ROWTERMINATOR = '\r\n',
	DATAFILETYPE = 'widechar'
)

BULK INSERT Conferences
FROM 'C:\Users\kveld\Desktop\Conferences\conferenceData.csv'
WITH (
	FIELDTERMINATOR = '~',
	KEEPIDENTITY,
	KEEPNULLS,
	ROWTERMINATOR = '\r\n',
	DATAFILETYPE = 'widechar'
)

BULK INSERT ConferenceDays
FROM 'C:\Users\kveld\Desktop\Conferences\conferenceDaysData.csv'
WITH (
	FIELDTERMINATOR = '~',
	KEEPIDENTITY,
	KEEPNULLS,
	ROWTERMINATOR = '\r\n',
	DATAFILETYPE = 'widechar'
)

BULK INSERT ConferenceAttendees
FROM 'C:\Users\kveld\Desktop\Conferences\conferenceAttendees.csv'
WITH (
	FIELDTERMINATOR = '~',
	KEEPIDENTITY,
	KEEPNULLS,
	ROWTERMINATOR = '\r\n',
	DATAFILETYPE = 'widechar'
)

BULK INSERT WorkshopAttendees
FROM 'C:\Users\kveld\Desktop\Conferences\workshopAttendees.csv'
WITH (
	FIELDTERMINATOR = '~',
	KEEPIDENTITY,
	KEEPNULLS,
	ROWTERMINATOR = '\r\n',
	DATAFILETYPE = 'widechar'
)

BULK INSERT Workshops
FROM 'C:\Users\kveld\Desktop\Conferences\workshops.csv'
WITH (
	FIELDTERMINATOR = '~',
	KEEPIDENTITY,
	KEEPNULLS,
	ROWTERMINATOR = '\r\n',
	DATAFILETYPE = 'widechar'
)

BULK INSERT ConferenceReservations
FROM 'C:\Users\kveld\Desktop\Conferences\conferenceReservations.csv'
WITH (
	FIELDTERMINATOR = '~',
	KEEPIDENTITY,
	KEEPNULLS,
	ROWTERMINATOR = '\r\n',
	DATAFILETYPE = 'widechar'
)

BULK INSERT WorkshopReservations
FROM 'C:\Users\kveld\Desktop\Conferences\workshopReservations.csv'
WITH (
	FIELDTERMINATOR = '~',
	KEEPIDENTITY,
	KEEPNULLS,
	ROWTERMINATOR = '\r\n',
	DATAFILETYPE = 'widechar'
)

BULK INSERT ReservationDetails
FROM 'C:\Users\kveld\Desktop\Conferences\reservationDetails.csv'
WITH (
	FIELDTERMINATOR = '~',
	KEEPIDENTITY,
	KEEPNULLS,
	ROWTERMINATOR = '\r\n',
	DATAFILETYPE = 'widechar'
)


SET DATEFORMAT dmy
BULK INSERT Payments
FROM 'C:\Users\kveld\Desktop\Conferences\payments.csv'
WITH (
	FIELDTERMINATOR = '~',
	KEEPIDENTITY,
	KEEPNULLS,
	ROWTERMINATOR = '\r\n',
	DATAFILETYPE = 'widechar'
)