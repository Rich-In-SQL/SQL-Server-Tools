-- =============================================
-- Origional Author: Cody Konior (codykonior.com)
-- Editing Author: Bonza Owl
-- Create date: 28/09/2018
-- =============================================

CREATE PROCEDURE p_db_mail_check
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT,
        QUOTED_IDENTIFIER,
        ANSI_NULLS,
        ANSI_PADDING,
        ANSI_WARNINGS,
        ARITHABORT,
        CONCAT_NULL_YIELDS_NULL ON;
    SET NUMERIC_ROUNDABORT OFF;
 
    DECLARE @localTran bit
    IF @@TRANCOUNT = 0
    BEGIN
        SET @localTran = 1
        BEGIN TRANSACTION LocalTran
    END
 
    BEGIN TRY       

		IF Object_Id('tempdb..#Status') IS NOT NULL
			DROP TABLE #Status
		Go

		CREATE TABLE #Status 
		(
			[Status] Nvarchar(7)
		)

		INSERT INTO #Status
		EXEC msdb.dbo.sysmail_help_status_sp

		IF NOT EXISTS (
			SELECT TOP 1
					0
			FROM 
				#Status
			WHERE 
				STATUS = 'STARTED'
		)
		BEGIN

			EXEC msdb.dbo.sysmail_start_sp
		END
 
        IF @localTran = 1 AND XACT_STATE() = 1
            COMMIT TRAN LocalTran
 
    END TRY
    BEGIN CATCH
 
        DECLARE @ErrorMessage NVARCHAR(4000)
        DECLARE @ErrorSeverity INT
        DECLARE @ErrorState INT
 
        SELECT  @ErrorMessage = ERROR_MESSAGE(),
                @ErrorSeverity = ERROR_SEVERITY(),
                @ErrorState = ERROR_STATE()
 
        IF @localTran = 1 AND XACT_STATE() <> 0
            ROLLBACK TRAN
 
        RAISERROR ( @ErrorMessage, @ErrorSeverity, @ErrorState)
 
    END CATCH
 
END