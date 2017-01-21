USE CONFERENCES

-- Funkcja zwracaj¹ca iloœæ wolnych miejsc na dany dzieñ konferencji
GO
CREATE FUNCTION dbo.FREE_SPOTS_FOR_CONFDAY (@dayID int)
RETURNS INT
AS
BEGIN
	Declare @totalNum int;
	Set @totalNum = (select dbo.ConferenceDays.num_spots 
						from dbo.ConferenceDays 
							where dbo.ConferenceDays.conference_day_id = @dayID)
	Declare @takenNum int;
	Set @takenNum = (select sum(dbo.ReservationDetails.num_spots)
							from dbo.ReservationDetails
							inner join dbo.ConferenceReservations on
								dbo.ConferenceReservations.reservation_details_id = dbo.ReservationDetails.reservation_details_id
							inner join dbo.ConferenceDays on
								dbo.ConferenceDays.conference_id = dbo.ConferenceReservations.conference_id
							where dbo.ConferenceDays.conference_day_id = @dayID and dbo.ReservationDetails.reservation_cancellation_date is NULL)
	RETURN (@totalNum - @takenNum);

END


-- Funkcja zwracaj¹ca iloœæ wolnych miejsc na dany warsztat

GO
CREATE FUNCTION dbo.FREE_SPOTS_FOR_WS (@workshopID int)
RETURNS INT
AS 
BEGIN	
		Declare @totalNum int;
		Set @totalNum = (select dbo.Workshops.num_spots 
							from Workshops 
							where dbo.Workshops.workshop_id = @workshopID)
		Declare @takenNum int;
		Set @takenNum = (select sum(dbo.ReservationDetails.num_spots) 
							from dbo.ReservationDetails
							inner join dbo.WorkshopReservations on
								dbo.WorkshopReservations.reservation_details_id = dbo.ReservationDetails.reservation_details_id 
							inner join dbo.Workshops on
									dbo.Workshops.workshop_id = dbo.WorkshopReservations.workshop_id
							where dbo.Workshops.workshop_id = @workshopID
								 and dbo.ReservationDetails.reservation_cancellation_date is NULL)
		RETURN (@totalNum - @takenNum);
END




