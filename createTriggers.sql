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
		group by dbo.workshopreservations.reservation_id, inserted.num_spots
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
		group by dbo.ConferenceReservations.conference_id, inserted.num_spots 
		having sum(dbo.reservationdetails.num_spots) > inserted.num_spots
	)
BEGIN
RAISERROR('The number of spots of conference day cannot be changed since the number of booked spots is higher than implemented value.',16,1)	;
ROLLBACK TRANSACTION
END
END



