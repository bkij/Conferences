USE master
GO

IF EXISTS(SELECT * FROM master..syslogins WHERE name = 'sampleLogin')
DROP LOGIN sampleLogin
CREATE LOGIN sampleLogin WITH PASSWORD = 'samplePassword',
DEFAULT_DATABASE = Conferences,
DEFAULT_LANGUAGE = Polish,
CHECK_EXPIRATION = OFF,
CHECK_POLICY = OFF;

-- Programista aplikacji wewnętrznych, do użytku
-- przez organizatorów konferencji (zarządzanie konferencjami i analiza danych)
CREATE USER innerDeveloper FOR LOGIN sampleLogin;


-- Programista aplikacji do zewnętrznych i wewnętrznych
-- do użytku klientów (aplikacje webowe, mobilne) oraz konsulatntów
-- firmy (aplikacje wewnętrzne)
CREATE USER appDeveloper FOR LOGIN sampleLogin;

-- Procdeury
GRANT EXEC ON Conferences.CREATE_RESERVATION TO appDeveloper;
GRANT EXEC ON Conferences.NUM_SPOTS_RESERVATION_CHANGE TO appDeveloper;
GRANT EXEC ON Conferences.RESERVATION_CANCELLATION_CR TO appDeveloper;
GRANT EXEC ON Conferences.RESERVATION_CANCELLATION_WS TO appDeveloper;
GRANT EXEC ON Conferences.ADD_RESERVATION_LIST TO appDeveloper;

-- Widoki
GRANT SELECT ON Conferences.PAYMENTS_HISTORY TO appDeveloper;

-- Funkcje
GRANT EXEC ON Conferences.FREE_SPOTS_FOR_WS TO appDeveloper;
GRANT EXEC ON Conferences.FREE_SPOTS_FOR_CONFDAY TO appDeveloper;