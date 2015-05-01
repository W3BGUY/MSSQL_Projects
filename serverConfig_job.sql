/*
 * Author: Robert Caddell
 * 
 * Create a job called server_config that runs weekly with the following:
 * 
*/

USE BaselineData;
GO

SET NOCOUNT ON;

BEGIN TRANSACTION;
INSERT  INTO [dbo].[ServerConfig]
        ( [Property] ,
          [Value]
        )
        EXEC xp_instance_regread N'HKEY_LOCAL_MACHINE',
            N'HARDWARE\DESCRIPTION\System\CentralProcessor\0',
            N'ProcessorNameString';
UPDATE  [dbo].[ServerConfig]
SET     [CaptureDate] = GETDATE()
WHERE   [Property] = N'ProcessorNameString'
        AND [CaptureDate] IS NULL;
COMMIT;

INSERT  INTO [dbo].[ServerConfig]
        ( [Property] ,
          [Value] ,
          [CaptureDate]
        )
        SELECT  N'MachineName' ,
                SERVERPROPERTY('MachineName') ,
                GETDATE();
INSERT  INTO [dbo].[ServerConfig]
        ( [Property] ,
          [Value] ,
          [CaptureDate]
        )
        SELECT  N'ServerName' ,
                SERVERPROPERTY('ServerName') ,
                GETDATE();
INSERT  INTO [dbo].[ServerConfig]
        ( [Property] ,
          [Value] ,
          [CaptureDate]
        )
        SELECT  N'InstanceName' ,
                SERVERPROPERTY('InstanceName') ,
                GETDATE();
INSERT  INTO [dbo].[ServerConfig]
        ( [Property] ,
          [Value] ,
          [CaptureDate]
        )
        SELECT  N'IsClustered' ,
                SERVERPROPERTY('IsClustered') ,
                GETDATE();
INSERT  INTO [dbo].[ServerConfig]
        ( [Property] ,
          [Value] ,
          [CaptureDate]
        )
        SELECT  N'ComputerNamePhysicalNetBios' ,
                SERVERPROPERTY('ComputerNamePhysicalNetBIOS') ,
                GETDATE();
INSERT  INTO [dbo].[ServerConfig]
        ( [Property] ,
          [Value] ,
          [CaptureDate]
        )
        SELECT  N'Edition' ,
                SERVERPROPERTY('Edition') ,
                GETDATE();
INSERT  INTO [dbo].[ServerConfig]
        ( [Property] ,
          [Value] ,
          [CaptureDate]
        )
        SELECT  N'ProductLevel' ,
                SERVERPROPERTY('ProductLevel') ,
                GETDATE();
INSERT  INTO [dbo].[ServerConfig]
        ( [Property] ,
          [Value] ,
          [CaptureDate]
        )
       SELECT  N'ProductVersion' ,
                SERVERPROPERTY('ProductVersion') ,
                GETDATE();

DECLARE @TRACESTATUS TABLE
    (
      [TraceFlag] SMALLINT ,
      [Status] BIT ,
      [Global] BIT ,
      [Session] BIT
    );

INSERT  INTO @TRACESTATUS
        EXEC ( 'DBCC TRACESTATUS (-1)'
            );

IF ( SELECT COUNT(*)
     FROM   @TRACESTATUS
   ) > 0 
    BEGIN;
        INSERT  INTO [dbo].[ServerConfig]
                ( [Property] ,
                  [Value] ,
                  [CaptureDate]
                )
                SELECT  N'DBCC_TRACESTATUS' ,
                        'TF ' + CAST([TraceFlag] AS VARCHAR(5))
                        + ': Status = ' + CAST([Status] AS VARCHAR(1))
                        + ', Global = ' + CAST([Global] AS VARCHAR(1))
                        + ', Session = ' + CAST([Session] AS VARCHAR(1)) ,
                        GETDATE()
                FROM    @TRACESTATUS
                ORDER BY [TraceFlag];
    END;
ELSE 
    BEGIN;
        INSERT  INTO [dbo].[ServerConfig]
                ( [Property] ,
                  [Value] ,
                  [CaptureDate]
                )
                SELECT  N'DBCC_TRACESTATUS' ,
                        'No trace flags enabled' ,
                        GETDATE()
    END;
