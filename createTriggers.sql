USE Conferences



GO
CREATE TRIGGER WORKSHOPS_NUM_SPOTS_GTE_RESERVATION_SUM
ON dbo.WorkshopReservations
AFTER INSERT AS
BEGIN
	DECLARE @totalReservationSpots int;
	DECLARE @thisReservationSpots int;
	DECLARE @otherReservationSpots int;
	DECLARE @workshopID int;

	SELECT @thisReservationSpots = rd.num_spots
		FROM inserted
		INNER JOIN ReservationDetails as rd ON inserted.reservation_details_id = rd.reservation_details_id;

	SELECT @workshopID = workshop_id
		FROM inserted;

	SELECT @otherReservationSpots = SUM(num_spots)
		FROM WorkshopReservations AS wr
		INNER JOIN ReservationDetails AS rd ON wr.reservation_details_id = rd.reservation_details_id
		WHERE wr.workshop_id = @workshopID;

	SELECT @totalReservationSpots = num_spots
		FROM Workshops
		WHERE workshop_id = @workshopID;
	
	IF @totalReservationSpots < @thisReservationSpots + @otherReservationSpots
		ROLLBACK TRANSACTION;
		THROW 50001, 'Error - Total amount of attendees from reservation would be greater than spots for the workshop', 16;
END



GO
CREATE TRIGGER CONFERENCES_NUM_SPOTS_GTE_RESERVATION_SUM
ON dbo.ConferenceReservations
AFTER INSERT AS
BEGIN
	DECLARE @totalReservationSpots int;
	DECLARE @thisReservationSpots int;
	DECLARE @otherReservationSpots int;
	DECLARE @conferenceDayID int;

	SELECT @thisReservationSpots = rd.num_spots
		FROM inserted
		INNER JOIN ReservationDetails as rd ON inserted.reservation_details_id = rd.reservation_details_id;

	SELECT @conferenceDayID = conference_day_id
		FROM inserted;

	SELECT @otherReservationSpots = SUM(num_spots)
		FROM ConferenceReservations AS cr
		INNER JOIN ReservationDetails AS rd ON cr.reservation_details_id = rd.reservation_details_id
		WHERE cr.conference_day_id = @conferenceDayID;

	SELECT @totalReservationSpots = num_spots
		FROM ConferenceDays
		WHERE conference_day_id = @conferenceDayID;
	
	IF @totalReservationSpots < @thisReservationSpots + @otherReservationSpots
		ROLLBACK TRANSACTION;
		THROW 50001, 'Error - Total amount of attendees from reservation would be greater than spots for the conference day', 16;
END



-- Trigger: sprawdza, czy nie zostanie przekroczony limit miejsc po zmniejszeniu liczby miejsc na dany warsztat
GO
CREATE TRIGGER NUM_SPOTS_LIMIT
ON dbo.WORKSHOPS
AFTER UPDATE AS
BEGIN
IF EXISTS (
	select 'exists'
		from inserted
		inner join dbo.WorkshopReservations
			on dbo.WorkshopReservations.workshop_id = inserted.workshop_id
		inner join dbo.Workshops 
			on dbo.Workshops.workshop_id = dbo.WorkshopReservations.workshop_id
		inner join dbo.ReservationDetails 
			on dbo.ReservationDetails.reservation_details_id = dbo.WorkshopReservations.reservation_details_id
		group by dbo.workshopreservations.reservation_details_id, inserted.num_spots
		having sum(dbo.reservationdetails.num_spots) > inserted.num_spots
	)
BEGIN
RAISERROR('The number of spots concerning the workshop cannot be changed since the number of booked spots is higher than implemented value.',16,1)	;
ROLLBACK TRANSACTION
END
END

-- Trigger: sprawdza, czy nie zostanie przekroczony limit miejsc po zmniejszeniu liczby miejsc w dany dzien konferencji


GO
CREATE TRIGGER NUM_SPOTS_LIMIT_CF
ON dbo.ConferenceDays
AFTER UPDATE AS
BEGIN
IF EXISTS (
	select 'exists'
		from inserted 
		inner join dbo.ConferenceReservations on
			dbo.ConferenceReservations.conference_day_id = inserted.conference_day_id
		inner join dbo.ReservationDetails on
			dbo.ReservationDetails.reservation_details_id = dbo.ConferenceReservations.reservation_details_id
		group by dbo.ConferenceReservations.conference_day_id, inserted.num_spots 
		having sum(dbo.reservationdetails.num_spots) > inserted.num_spots
	)
BEGIN
RAISERROR('The number of spots of conference day cannot be changed since the number of booked spots is higher than implemented value.',16,1)	;
ROLLBACK TRANSACTION
END
END

-- Trigger: anuluje rezerwacje klienta na warsztaty w danym dniu, jeśli anulował rezerwację na dzień konferencji

GO
CREATE TRIGGER CANCEL_WSHOP_AFTER_CONF_CANCEL
ON dbo.ReservationDetails
AFTER UPDATE AS
BEGIN
	SET NOCOUNT ON;
	IF UPDATE(reservation_cancellation_date) AND EXISTS (
		SELECT 'exists'
		FROM inserted
		INNER JOIN ReservationDetails rd ON rd.reservation_details_id = inserted.reservation_details_id
		INNER JOIN WorkshopReservations wr ON wr.reservation_details_id = rd.reservation_details_id
		WHERE rd.reservation_cancellation_date IS NOT NULL
	)
	BEGIN
		UPDATE ReservationDetails
		SET reservation_cancellation_date = GETDATE()
		WHERE reservation_details_id IN (
			SELECT rd.reservation_details_id
			FROM ReservationDetails rd
			INNER JOIN inserted ON inserted.client_id = rd.client_id OR inserted.company_id = rd.company_id
			INNER JOIN WorkshopReservations wr ON rd.reservation_details_id = wr.reservation_details_id
			INNER JOIN Workshops w ON w.workshop_id = wr.workshop_id
			INNER JOIN ConferenceDays cd ON cd.conference_day_id = w.conference_day_id
		)
	END
END

-- Trigger brak możliwości rezerwacji na kilka warsztatów w tym samym czasie
GO
CREATE TRIGGER CHECK_NO_SIMULTANEOUS_WORSKHOPS
ON dbo.WorkshopReservations
AFTER INSERT AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS (
		SELECT 'exists'
		FROM inserted
		INNER JOIN ReservationDetails rd ON inserted.reservation_details_id = rd.reservation_details_id
		INNER JOIN ReservationDetails rd2 ON rd.client_id = rd2.client_id OR rd.company_id = rd2.company_id
		INNER JOIN WorkshopReservations wr ON rd2.reservation_details_id = wr.reservation_details_id
		INNER JOIN Workshops w ON wr.workshop_id = w.workshop_id
		WHERE w.[date] = (
			SELECT sub_w.[date]
			FROM Workshops sub_w
			INNER JOIN inserted ON sub_w.workshop_id = inserted.workshop_id 
		)
	)
	BEGIN
		ROLLBACK TRANSACTION;
		THROW 50001, 'Error - cannot reserve two workshops sharing a time slot', 16;
	END
END

-- Trigger: przy dodawaniu dnia konferencji daty muszo się zgadzać
GO
CREATE TRIGGER CHECK_DATE_COMPATIBILITY_CONF_CONF_DAY
ON dbo.ConferenceDays
AFTER INSERT AS
BEGIN
	SET NOCOUNT ON;
	IF NOT ( SELECT inserted.date FROM inserted ) BETWEEN (SELECT c.date_start FROM Conferences c INNER JOIN inserted i ON c.conference_id = i.conference_id)
												  AND     (SELECT c.date_end FROM Conferences c INNER JOIN inserted i ON c.conference_id = i.conference_id)
	BEGIN
		ROLLBACK TRANSACTION;
		THROW 50001, 'Error - invalid conference day date', 16;
	END
END

-- Triger: przy dodoawaniu warsztatu daty muszą się zgadzać
GO
CREATE TRIGGER CHECK_DATE_COMPAT_CONF_DAY_WSHOP
ON dbo.Workshops
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
	IF NOT ( SELECT YEAR(inserted.date) FROM inserted ) = (SELECT YEAR(cd.date) FROM ConferenceDays cd INNER JOIN inserted i ON cd.conference_day_id = i.conference_day_id)
	AND ( SELECT MONTH(inserted.date) FROM inserted ) = (SELECT MONTH(cd.date) FROM ConferenceDays cd INNER JOIN inserted i ON cd.conference_day_id = i.conference_day_id)
	AND ( SELECT DAY(inserted.date) FROM inserted ) = (SELECT DAY(cd.date) FROM ConferenceDays cd INNER JOIN inserted i ON cd.conference_day_id = i.conference_day_id)
	BEGIN
		ROLLBACK TRANSACTION;
		THROW 50001, 'Error - invalid conference day date', 16;
	END
END