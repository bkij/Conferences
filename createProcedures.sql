USE CONFERENCES



-- Tworzenie rezerwacji
-- entityID - ID dnia konferencji lub warsztatu (w zaleznosci od wartosci isConference)
GO
CREATE PROCEDURE CREATE_RESERVATION (@entityID int, @isConferenceDay bit, @clientID int, @companyID int, @numSpots int, @numStudents int)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @entityPrice money;
	DECLARE @entityDate date;
	DECLARE @cost money;
	DECLARE @discount float;
	DECLARE @resDetailsID table(ID int);
	DECLARE @ID int;

	IF @isConferenceDay = 1
		BEGIN
		
		SELECT @entityPrice = confDay.price, @entityDate = confDay.date
		FROM ConferenceDays AS confDay
		WHERE confDay.conference_day_id = @entityID;

		IF DATEADD(month, 3, GETDATE()) < @entityDate
			SET @discount = 0.15
		ELSE IF DATEADD(month, 2, GETDATE()) < @entityDate
			SET @discount = 0.10
		ELSE IF DATEADD(month, 1, GETDATE()) < @entityDate
			SET @discount = 0.05

		SET @cost = (1 - @discount) * ( @entityPrice * (@numSpots - @numStudents) + @entityPrice * 0.9 * @numStudents);

		INSERT INTO ReservationDetails (client_id, company_id, num_spots, num_students, cost, reservation_date)
		OUTPUT INSERTED.reservation_details_id INTO @resDetailsID(ID)
			VALUES (@clientID, @companyID, @numSpots, @numStudents, @cost, GETDATE());

		SELECT @ID = ID FROM @resDetailsID;

		INSERT INTO ConferenceReservations(conference_day_id, reservation_details_id)
			VALUES (@entityID, @ID);
		
		END
	ELSE
		BEGIN

		SELECT @entityPrice = w.price, @entityDate = w.date
		FROM Workshops AS w
		WHERE w.workshop_id = @entityID;

		IF DATEADD(month, 3, GETDATE()) < @entityDate
			SET @discount = 0.15
		ELSE IF DATEADD(month, 2, GETDATE()) < @entityDate
			SET @discount = 0.10
		ELSE IF DATEADD(month, 1, GETDATE()) < @entityDate
			SET @discount = 0.05

		SET @cost = (1 - @discount) * ( @entityPrice * (@numSpots - @numStudents) + @entityPrice * 0.9 * @numStudents);

		INSERT INTO ReservationDetails (client_id, company_id, num_spots, num_students, cost, reservation_date)
		OUTPUT INSERTED.reservation_details_id INTO @resDetailsID(ID)
			VALUES (@clientID, @companyID, @numSpots, @numStudents, @cost, GETDATE());

		SELECT @ID = ID FROM @resDetailsID;

		INSERT INTO WorkshopReservations(workshop_id, reservation_details_id)
			VALUES (@entityID, @ID);

		END

END

-- podanie listy gosci zwiazanych z rezerwacja
GO
CREATE TYPE dbo.ClientInfo AS TABLE
	(firstname nvarchar(50), lastname nvarchar(50), initial nchar(1), studentcard_number int);

GO
CREATE PROCEDURE ADD_RESERVATION_LIST(@reservationID int, @clients dbo.ClientInfo READONLY)
AS
BEGIN
	DECLARE @numSpotsRes int;
	DECLARE @numSpots int;
	DECLARE @numStudentsRes int;
	DECLARE @numStudents int;

	SELECT @numSpotsRes = num_spots FROM ReservationDetails WHERE reservation_details_id = @reservationID;
	SELECT @numSpots = COUNT(1) FROM @clients;
	SELECT @numStudentsRes = num_students FROM ReservationDetails WHERE reservation_details_id = @reservationID;
	SELECT @numStudents = COUNT(1) from @clients WHERE studentcard_number IS NOT NULL;

	IF @numSpots != @numSpotsRes
		THROW 50001, 'Client count differs from reservation spot count', 16;
	IF @numStudents != @numStudentsRes
		THROW 50001, 'Student count differs from reservation student count', 16;
	
	-- Insert new Clients
	INSERT INTO Clients(firstname, lastname, initial, studentcard_number)
	SELECT firstname, lastname, initial, studentcard_number FROM @clients;

	INSERT INTO StudentcardPool(reservation_details_id, studentcard_number)
	SELECT @reservationID, studentcard_number FROM @clients;
END


-- zmiana ilosci miejsc na warsztatach
GO
CREATE PROCEDURE NUM_SPOTS_WS_CHANGE (@newNumSpots smallINT, @workshopID INT)
AS
BEGIN
	SET NOCOUNT ON ;
	UPDATE WORKSHOPS
	SET WORKSHOPS.num_spots = @newNumSpots
	WHERE WORKSHOPS.WORKSHOP_ID = @workshopID
END

-- zmieñ iloœæ miejsc w rezerwacji
GO
CREATE PROCEDURE NUM_SPOTS_RESERVATION_CHANGE (@newNumSpots smallint, @reservationID int)
AS 
BEGIN 
	SET NOCOUNT ON ;
	UPDATE ReservationDetails
	SET ReservationDetails.num_spots = @newNumSpots
		FROM ReservationDetails
	 inner JOIN ConferenceReservations 
		ON ConferenceReservations.reservation_details_id = ReservationDetails.reservation_details_id
	WHERE conferencereservations.reservation_id = @reservationID
END


-- zmieñ limit miejsc w danym dniu konferencji
GO
CREATE PROCEDURE NUM_SPOTS_CONFDAY_CHANGE (@newNumSpots smallint , @ConferenceDayId INT)
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE ConferenceDays
	SET ConferenceDays.num_spots = @newNumSpots
	WHERE conferencedays.conference_day_id = @conferenceDayId
END

-- anulowanie rezerwacji : konferencja
GO
CREATE PROCEDURE RESERVATION_CANCELLATION_CR @ReservationID INT
AS BEGIN 
SET NOCOUNT ON;
UPDATE RESERVATIONDETAILS
SET RESERVATIONDETAILS.RESERVATION_CANCELLATION_DATE = GETDATE()
from reservationdetails 
	inner join conferencereservations 
		on reservationdetails.reservation_details_id = conferencereservations.reservation_details_id
	where conferencereservations.reservation_id = @reservationID
END

-- anulowanie rezerwacji : warsztaty
GO
CREATE PROCEDURE RESERVATION_CANCELLATION_WS @ReservationID INT
AS BEGIN 
SET NOCOUNT ON;
UPDATE RESERVATIONDETAILS
SET RESERVATIONDETAILS.RESERVATION_Cancellation_Date = GETDATE()
from reservationdetails 
	inner join workshopreservations 
		on reservationdetails.reservation_details_id = workshopreservations.reservation_details_id
	where workshopreservations.reservation_id = @ReservationID
END

-- Opłacenie rezerwacji
GO
CREATE PROCEDURE PAY_FOR_RESERVATION (@resId int, @amountPaid money)
AS 
BEGIN
	SET NOCOUNT ON;
	DECLARE @paymentID int;
	DECLARE	@ID table(ID int)

	INSERT INTO Payments (date_paid, amount_paid)
	OUTPUT INSERTED.payment_id INTO @ID(ID)
		VALUES(GETDATE(), @amountPaid);

	UPDATE ReservationDetails
	SET payment_id = (SELECT ID FROM @ID)
	WHERE reservation_details_id = @resId;
END


-- WIDOK (JAKO PROCEDURA): Listy osobowe uczestników konferencji na ka¿dy dzieñ
GO
CREATE PROCEDURE CONFERENCE_ATTENDEES_PER_DAY (@ConferenceDayId int) 
AS
SELECT dbo.Clients.client_id, dbo.Clients.company_id, dbo.Clients.firstname, dbo.Clients.lastname, dbo.Clients.initial
from dbo.Clients
	inner join dbo.ConferenceAttendees
		on dbo.Clients.client_id = dbo.ConferenceAttendees.client_id
	inner join dbo.ConferenceDays
		on dbo.ConferenceDays.conference_day_id = dbo.ConferenceAttendees.conference_day_id 
where dbo.ConferenceDays.conference_day_id =  @ConferenceDayId

-- WIDOK (jako procedura): Listy osobowe uczestników warsztatu na ka¿dy dzieñ
GO
CREATE PROCEDURE WORKSHOP_ATTENDEES_PER_DAY (@ConferenceDayId int)
AS
SELECT dbo.Clients.client_id, dbo.Clients.company_id, dbo.Clients.firstname, dbo.Clients.lastname, dbo.Clients.initial
	from dbo.Clients 
		inner join dbo.WorkshopAttendees
			on dbo.Clients.client_id = dbo.WorkshopAttendees.client_id
        inner join  dbo.Workshops
			on dbo.Workshops.workshop_id = dbo.WorkshopAttendees.workshop_id
		inner join dbo.ConferenceDays
			on dbo.ConferenceDays.conference_day_id = dbo.Workshops.conference_day_id
where dbo.ConferenceDays.conference_day_id =  @ConferenceDayId


-- WIDOK (jako procedura): Listy p³atnoœci per klient 
GO
CREATE PROCEDURE PAYMENTS_LIST_PER_CLIENT (@client_id int)
AS
SELECT * from dbo.Payments
	inner join dbo.ReservationDetails
		on dbo.ReservationDetails.payment_id = dbo.Payments.payment_id
	inner join dbo.Clients
		on dbo.ReservationDetails.client_id = dbo.Clients.client_id
where dbo.Clients.client_id = @client_id


-- WIDOK (jako procedura): Listy p³atnoœæ per firma
GO
CREATE PROCEDURE PAYMENTS_LIST_PER_COMPANY (@company_id int)
AS
SELECT * from dbo.Payments
	inner join dbo.ReservationDetails
		on dbo.ReservationDetails.payment_id = dbo.Payments.payment_id
	inner join dbo.Companies
		on dbo.ReservationDetails.client_id = dbo.Companies.company_id
where dbo.Companies.company_id = @company_id


-- WIDOK jako procedura : Historia p³atnoœci danego klienta
GO
CREATE PROCEDURE PAYMENTS_HISTORY (@clientID int)
AS 
SELECT dbo.Payments.payment_id, dbo.Payments.amount_paid, dbo.Payments.date_paid
from Payments
	inner join dbo.ReservationDetails
		on dbo.Payments.payment_id = dbo.ReservationDetails.payment_id
	inner join dbo.Clients
		on dbo.ReservationDetails.client_id = dbo.Clients.client_id
where dbo.Clients.client_id = @clientID

-- Procedura wykonywana okresowo, anulowanie rezerwacji nieopłaconych na tydzień od rezerwacji
GO
CREATE PROCEDURE CHECK_RESERVATIONS_FOR_CANCELLING
AS
UPDATE dbo.ReservationDetails
SET reservation_cancellation_date = GETDATE()
WHERE DATEADD(week, 1, reservation_date) >= GETDATE()

-- Stworzenie konferencji
GO
CREATE PROCEDURE CREATE_CONFERENCE(@dateStart datetime, @dateEnd datetime, @title nvarchar(100), @ID int OUTPUT)
AS
BEGIN
	DECLARE @IDTbl TABLE(ID int)

	INSERT INTO Conferences(date_start, date_end, title)
	OUTPUT inserted.conference_id INTO @IDTbl(ID)
	VALUES(@dateStart, @dateEnd, @title)

	SELECT @ID = ID FROM @IDTbl;
END

-- Stworzenie dnia konferencji
GO
CREATE PROCEDURE CREATE_CONFERENCE_DAY(@conferenceId int, @date datetime, @numSpots int, @price money, @ID int OUTPUT)
AS
BEGIN
	DECLARE @IDTbl TABLE(ID int)

	INSERT INTO ConferenceDays(conference_id, date, num_spots, price)
	OUTPUT inserted.conference_day_id INTO @IDTbl(ID)
	VALUES(@conferenceId, @date, @numSpots, @price)

	SELECT @ID = ID FROM @IDTbl;
END

-- Stworzenie warsztatu
GO
CREATE PROCEDURE CREATE_WORKSHOP(@conferenceDayId int, @date datetime, @numSpots int, @price money, @title nvarchar(100), @ID int OUTPUT)
AS
BEGIN
	DECLARE @IDTbl TABLE(ID int)

	INSERT INTO Workshops(conference_day_id, date, num_spots, price, title)
	OUTPUT inserted.workshop_id INTO @IDTbl(ID)
	VALUES(@conferenceDayId, @date, @numSpots, @price, @title)

	SELECT @ID = ID FROM @IDTbl;
END