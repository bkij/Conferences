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
								dbo.ConferenceDays.conference_day_id = dbo.ConferenceReservations.conference_day_id
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


-- FUNKCJA zwracajaca informacje o nieoplaconych rezerwacjach

GO
CREATE FUNCTION dbo.RESERVATION_LIST (@entityId int, @isCompany bit)
RETURNS @rtnTable TABLE (
	id int,
	cost money,
	num_spots int,
	num_students int,
	reservation_date datetime,
	paid char(1)
)
AS
BEGIN
	IF @isCompany = 1
	BEGIN
		INSERT INTO @rtnTable
		SELECT rd.reservation_details_id, rd.cost, rd.num_spots, rd.num_students, rd.reservation_date, '1'
			FROM ReservationDetails as rd
			WHERE payment_id IS NOT NULL AND rd.company_id = @entityId
		UNION
		SELECT rd.reservation_details_id, rd.cost, rd.num_spots, rd.num_students, rd.reservation_date, '0'
			FROM ReservationDetails as rd
			WHERE payment_id IS NULL AND rd.company_id = @entityId;
	END
	ELSE
	BEGIN
		INSERT INTO @rtnTable
		SELECT rd.reservation_details_id, rd.cost, rd.num_spots, rd.num_students, rd.reservation_date, '1'
			FROM ReservationDetails as rd
			WHERE payment_id IS NOT NULL AND rd.client_id = @entityId
		UNION
		SELECT rd.reservation_details_id, rd.cost, rd.num_spots, rd.num_students, rd.reservation_date, '0'
			FROM ReservationDetails as rd
			WHERE payment_id IS NULL AND rd.client_id = @entityId;
	END
	RETURN;
END