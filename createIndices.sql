USE CONFERENCES

CREATE INDEX ConferenceDayID_INDEX
ON WORKSHOPS (conference_day_id) -- jakie warsztaty w danym dniu konferencji

CREATE INDEX ConferenceID_INDEX
ON CONFERENCEDAYS (conference_id)

CREATE INDEX ConfResID_INDEX
ON CONFERENCERESERVATIONS (conference_id)

CREATE INDEX ClientID_INDEX
ON CONFERENCEATTENDEES (client_id)

CREATE INDEX CompanyID_INDEX
ON CLIENTS (company_id)

CREATE INDEX WorkshopId_INDEX
ON WORKSHOPATTENDEES (workshop_id)

CREATE INDEX WorkshopReservationID_INDEX
ON WORKSHOPRESERVATIONS (workshop_id, reservation_id)


