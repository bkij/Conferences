USE Conferences



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
RAISERROR('Changes cannot be made.',16,1)	;
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
		inner join dbo.ConferenceDays on 
			dbo.ConferenceDays.conference_day_id = inserted.conference_day_id
		inner join dbo.ConferenceReservations on
			dbo.ConferenceReservations.conference_id = dbo.ConferenceDays.conference_id
		inner join dbo.ReservationDetails on
			dbo.ReservationDetails.reservation_details_id = dbo.ConferenceReservations.reservation_details_id
		group by dbo.ConferenceReservations.conference_id, inserted.num_spots 
		having sum(dbo.reservationdetails.num_spots) > inserted.num_spots
	)
BEGIN
RAISERROR('Changes cannot be made.',16,1)	;
ROLLBACK TRANSACTION
END
END



