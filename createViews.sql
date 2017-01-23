USE CONFERENCES


-- TODO: poprawic ponizszy widok?
-- WIDOK: NAJPOPULARNIEJSZE KONFERENCJE - pokazuje listê 10 konferencji najbardziej obleganych
GO
CREATE VIEW [The most popular conferences] AS
SELECT  TOP 10 PERCENT SUM(dbo.reservationdetails.num_spots) as [The number of takers], dbo.Conferences.conference_id,  dbo.Conferences.title,
	dbo.Conferences.date_start, dbo.Conferences.date_end
FROM dbo.CONFERENCES
	inner join dbo.ConferenceDays
		on dbo.ConferenceDays.conference_id = dbo.Conferences.conference_id
	inner join dbo.conferencereservations 
		on dbo.ConferenceDays.conference_day_id = dbo.ConferenceReservations.conference_day_id
	inner join dbo.reservationdetails 
		on dbo.reservationdetails.reservation_details_id = dbo.ConferenceReservations.reservation_details_id
where dbo.reservationdetails.reservation_cancellation_date IS NULL 
group by dbo.Conferences.conference_id,  dbo.Conferences.title,
		dbo.Conferences.date_start, dbo.Conferences.date_end
order by [The number of takers] desc



-- WIDOK: NAJPOPULARNIEJSZE WARSZTATY - pokazuje listê 10 warsztatów najbardziej obleganych
GO
CREATE VIEW [The most popular workshops] AS
SELECT TOP 10 PERCENT SUM(dbo.reservationdetails.num_spots) as [The number of takers], dbo.Workshops.workshop_id, 
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
GO
CREATE VIEW [Cancelled Reservations] AS
SELECT dbo.ConferenceReservations.reservation_details_id, dbo.ConferenceReservations.conference_day_id, 'CONFERENCE' as [Conference/Workshop]
FROM dbo.ConferenceReservations
	inner join dbo.ReservationDetails 
		on dbo.ConferenceReservations.reservation_details_id = dbo.ReservationDetails.reservation_details_id
	where dbo.ReservationDetails.reservation_cancellation_date IS NOT NULL
UNION
SELECT dbo.WorkshopReservations.reservation_details_id, dbo.WorkshopReservations.workshop_id, 'WORKSHOP' as [Conference/Workshop]
FROM dbo.WorkshopReservations
	inner join dbo.ReservationDetails 
		on dbo.WorkshopReservations.reservation_details_id = dbo.ReservationDetails.reservation_details_id
	where dbo.ReservationDetails.reservation_cancellation_date IS NOT NULL


-- WIDOK : Lista 20 najczêœciej korzystaj¹cych z us³ug firm
GO
CREATE VIEW [THE LIST OF MOST FREQUENT COMPANIES GETTING THE SERVICES] AS
SELECT TOP 20 dbo.Companies.company_id, dbo.Companies.company_name
from Companies 
	inner join dbo.Clients on
		dbo.Clients.company_id = dbo.Companies.company_id
	inner join dbo.ConferenceAttendees on 
		dbo.ConferenceAttendees.client_id = dbo.Clients.client_id
GROUP BY dbo.Companies.company_id, dbo.Companies.company_name
ORDER BY count(dbo.Companies.company_id) desc




-- WIDOK : Lista 20 najczêœciej korzystaj¹cych z us³ug klientów
GO
CREATE VIEW [THE LIST OF MOST FREQUENT CLIENTS GETING THE SERVICES] AS
SELECT TOP 20 dbo.Clients.client_id, dbo.Clients.firstname, dbo.Clients.lastname
from Clients
	inner join dbo.ConferenceAttendees on dbo.ConferenceAttendees.client_id = dbo.Clients.client_id
group by dbo.Clients.client_id, dbo.Clients.firstname, dbo.Clients.lastname
order by count(dbo.Clients.client_id) desc





