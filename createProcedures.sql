USE CONFERENCES

CREATE PROCEDURE NUM_SPOTS_CHANGE (@newNumSpots smallINT, @workshopID INT)
AS
BEGIN
	SET NOCOUNT ON ;
	UPDATE WORKSHOPS
	SET WORKSHOPS.num_spots = @newNumSpots
	WHERE WORKSHOPS.WORKSHOP_ID = @workshopID
END


-- zmieñ iloœæ miejsc w rezerwacji

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

CREATE PROCEDURE NUM_SPOTS_CONFERENCE_DAY (@newNumSpots smallint , @ConferenceDayId INT)
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE ConferenceDays
	SET ConferenceDays.num_spots = @newNumSpots
	WHERE conferencedays.conference_day_id = @conferenceDayId
END



-- anulowanie rezerwacji : konferencja

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





