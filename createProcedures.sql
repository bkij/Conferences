USE CONFERENCES



-- Tworzenie rezerwacji
-- entityID - ID konferencji lub warsztatu (w zaleznosci od wartosci isConference)
GO
CREATE PROCEDURE CREATE_RESERVATION (@entityID int, @isConference bit, @clientID int, @companyID int, @numSpots int, @numStudents int)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @entityPrice money;
	DECLARE @entityDate date;
	DECLARE @cost money;
	DECLARE @discount float;
	DECLARE @resDetailsID table(ID int);
	DECLARE @ID int;

	IF @isConference = 1
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

		INSERT INTO ConferenceReservations(conference_id, reservation_details_id)
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





