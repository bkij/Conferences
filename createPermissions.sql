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
-- głównie przez konsultantów telefonicznych
CREATE USER innerDeveloper FOR LOGIN sampleLogin;

-- Programista aplikacji zewnętrznych (webowych, mobilnych)
-- do korzystania przez klientów
CREATE USER outerDeveloper FOR LOGIN sampleLogin;