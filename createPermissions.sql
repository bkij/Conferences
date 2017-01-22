USE master
GO

IF EXISTS(SELECT * FROM master..syslogins WHERE name = 'innerDev')
DROP LOGIN innerDev
CREATE LOGIN innerDev WITH PASSWORD = 'password',
DEFAULT_DATABASE = Conferences,
DEFAULT_LANGUAGE = Polish,
CHECK_EXPIRATION = OFF,
CHECK_POLICY = OFF;

IF EXISTS(SELECT * FROM master..syslogins WHERE name = 'appDev')
DROP LOGIN appDev
CREATE LOGIN appDev WITH PASSWORD = 'password',
DEFAULT_DATABASE = Conferences,
DEFAULT_LANGUAGE = Polish,
CHECK_EXPIRATION = OFF,
CHECK_POLICY = OFF;

-- Programista aplikacji wewnętrznych, do użytku
-- przez organizatorów konferencji (zarządzanie konferencjami i analiza danych)
CREATE USER innerDeveloper FOR LOGIN innerDev;

-- Procedury
GRANT EXEC ON Conferences.dbo.NUM_SPOTS_WS_CHANGE TO innerDeveloper;
GRANT EXEC ON Conferences.dbo.PAYMENTS_LIST_PER_CLIENT TO innerDeveloper;
GRANT EXEC ON Conferences.dbo.PAYMENTS_LIST_PER_COMPANY TO innerDeveloper;
GRANT EXEC ON Conferences.dbo.NUM_SPOTS_CONFDAY_CHANGE TO innerDeveloper;
GRANT EXEC ON Conferences.dbo.CONFERENCE_ATTENDEES_PER_DAY TO innerDeveloper;
GRANT EXEC ON Conferences.dbo.WORKSHOP_ATTENDEES_PER_DAY TO innerDeveloper;

-- Widoki
GRANT SELECT ON Conferences.dbo.[Cancelled reservations] TO innerDeveloper;
GRANT SELECT ON Conferences.dbo.[The most popular conferences] TO innerDeveloper;
GRANT SELECT ON Conferences.dbo.[The most popular workshops] TO innerDeveloper;
GRANT SELECT ON Conferences.dbo.[THE LIST OF MOST FREQUENT CLIENTS GETING THE SERVICES] TO innerDeveloper;
GRANT SELECT ON Conferences.dbo.[THE LIST OF MOST FREQUENT COMPANIES GETTING THE SERVICES] TO innerDeveloper;

-- Programista aplikacji do zewnętrznych i wewnętrznych
-- do użytku klientów (aplikacje webowe, mobilne) oraz konsulatntów
-- firmy (aplikacje wewnętrzne)
CREATE USER appDeveloper FOR LOGIN appDev;

-- Procdeury
GRANT EXEC ON Conferences.dbo.CREATE_RESERVATION TO appDeveloper;
GRANT EXEC ON Conferences.dbo.NUM_SPOTS_RESERVATION_CHANGE TO appDeveloper;
GRANT EXEC ON Conferences.dbo.RESERVATION_CANCELLATION_CR TO appDeveloper;
GRANT EXEC ON Conferences.dbo.RESERVATION_CANCELLATION_WS TO appDeveloper;
GRANT EXEC ON Conferences.dbo.ADD_RESERVATION_LIST TO appDeveloper;
GRANT EXEC ON Conferences.dbo.PAY_FOR_RESERVATION TO appDeveloper;
GRANT EXEC ON Conferences.dbo.PAYMENTS_HISTORY TO appDeveloper;
GRANT EXEC ON Conferences.dbo.RESERVATION_LIST TO appDeveloper;

-- Funkcje
GRANT EXEC ON Conferences.dbo.FREE_SPOTS_FOR_WS TO appDeveloper;
GRANT EXEC ON Conferences.dbo.FREE_SPOTS_FOR_CONFDAY TO appDeveloper;