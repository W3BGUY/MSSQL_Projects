/*
 * Author: Robert Caddell
 * 
 * Create a job called server_config_data that runs nightly with the following:
 * 
*/

USE [BaselineData];
GO

INSERT  INTO [dbo].[ConfigData]
        ( [ConfigurationID] ,
          [Name] ,
          [Value] ,
          [ValueInUse] ,
          [CaptureDate]
        )
        SELECT  [configuration_id] ,
                [name] ,
                [value] ,
                [value_in_use] ,
                GETDATE()
        FROM    [sys].[configurations];
