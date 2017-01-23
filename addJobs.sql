-- Okresowo wykonywane procedury
USE msdb;
GO
EXEC dbo.sp_add_job
	@job_name = N'CancelReservationIfNotPaidWeekBefore'
GO
EXEC sp_add_jobstep
	@job_name = N'CancelReservationIfNotPaidWeekBefore',
	@step_name = N'CheckAndCancel',
	@subsystem = N'TSQL',
	@command = N'EXEC dbo.CHECK_RESERVATIONS_FOR_CANCELLING';
GO
EXEC dbo.sp_add_schedule
	@schedule_name = N'RunDaily',
	@freq_type = 4,
	@active_start_time = 060000;
GO
EXEC sp_attach_schedule
	@job_name = N'CancelReservationIfNotPaidWeekBefore',
	@schedule_name = N'RunDaily';
GO
EXEC dbo.sp_add_jobserver
	@job_name = N'CancelReservationIfNotPaidWeekBefore';
