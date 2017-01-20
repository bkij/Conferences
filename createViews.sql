-- WIDOK: NAJPOPULARNIEJSZE KONFERENCJE - pokazuje listê konferencji najbardziej obleganych
CREATE VIEW [The most popular conferences] AS
SELECT SUM(dbo.reservationdetails.num_spots) as [The number of takers], dbo.Conferences.conference_id,  dbo.Conferences.title,
	dbo.Conferences.date_start, dbo.Conferences.date_end
FROM dbo.CONFERENCES
	inner join dbo.conferencereservations 
		on dbo.Conferences.conference_id = dbo.ConferenceReservations.conference_id
	inner join dbo.reservationdetails 
		on dbo.reservationdetails.reservation_details_id = dbo.ConferenceReservations.reservation_details_id
where dbo.reservationdetails.reservation_cancellation_date IS NULL 
group by dbo.Conferences.conference_id,  dbo.Conferences.title,
		dbo.Conferences.date_start, dbo.Conferences.date_end
order by [The number of takers] desc



-- WIDOK: NAJPOPULARNIEJSZE WARSZTATY - pokazuje listê warsztatów najbardziej obleganych
CREATE VIEW [The most popular workshops] AS
SELECT SUM(dbo.reservationdetails.num_spots) as [The number of takers], dbo.Workshops.workshop_id, 
	dbo.Workshops.conference_day_id, dbo.Workshops.title, dbo.Workshops.num_spots, dbo.Workshops.date, dbo.Workshops.price
FROM dbo.WORKSHOPS
	inner join dbo.workshopreservations 
		on dbo.workshops.workshop_id = dbo.WorkshopReservations.workshop_id
	inner join dbo.reservationdetails 
		on dbo.reservationdetails.reservation_details_id = dbo.workshopreservations.reservation_details_id
where dbo.reservationdetails.reservation_cancellation_date IS NULL 
group by dbo.Workshops.workshop_id, dbo.Workshops.conference_day_id,
		dbo.Workshops.title, dbo.Workshops.num_spots, dbo.Workshops.date, dbo.Workshops.price
order by [The number of takers] desc 


-- WIDOK: POKA¯ ANULOWANE REZERWACJE 
CREATE VIEW [Cancelled Reservations] AS
SELECT dbo.ConferenceReservations.reservation_id, dbo.ConferenceReservations.conference_id, 'CONFERENCE' as [Conference/Workshop]
FROM dbo.ConferenceReservations
	inner join dbo.ReservationDetails 
		on dbo.ConferenceReservations.reservation_details_id = dbo.ReservationDetails.reservation_details_id
	where dbo.ReservationDetails.reservation_cancellation_date IS NOT NULL
UNION
SELECT dbo.WorkshopReservations.reservation_id, dbo.WorkshopReservations.workshop_id, 'WORKSHOP' as [Conference/Workshop]
FROM dbo.WorkshopReservations
	inner join dbo.ReservationDetails 
		on dbo.WorkshopReservations.reservation_details_id = dbo.ReservationDetails.reservation_details_id
	where dbo.ReservationDetails.reservation_cancellation_date IS NOT NULL

