/*
 * Author: Robert Caddell
 * 
 * Create a database [BaselineData] for these tables. 
 * The stored procedures are optional.
*/

/****** Object:  StoredProcedure [dbo].[usp_ServerConfigReport]    Script Date: 5/1/2015 9:57:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_ServerConfigReport]
    (
      @Property NVARCHAR(128) = NULL
    )
AS 
    BEGIN;
        IF @Property NOT IN ( N'ComputerNamePhysicalNetBios',
                              N'DBCC_TRACESTATUS', N'Edition',
                              N'InstanceName',
                              N'IsClustered', N'MachineName',
                              N'ProcessorNameString', N'ProductLevel',
                              N'ProductVersion', N'ServerName' ) 
            BEGIN;
                RAISERROR(N'Valid values for @Property are:
                            ComputerNamePhysicalNetBios, DBCC_TRACESTATUS,
                            Edition, InstanceName, IsClustered,
                            MachineName, ProcessorNameString,
                            ProductLevel, ProductVersion, or ServerName',
                         16, 1);
                RETURN;
            END;

        SELECT  *
        FROM    [dbo].[ServerConfig]
        WHERE   [Property] = ISNULL(@Property, Property)
        ORDER BY [Property] ,
                [CaptureDate]
    END;


GO
/****** Object:  StoredProcedure [dbo].[usp_SysConfigReport]    Script Date: 5/1/2015 9:57:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_SysConfigReport] 
(
       @RecentDate DATETIME,
       @OlderDate DATETIME
)
AS

BEGIN;

       IF
              @RecentDate IS NULL
              OR @OlderDate IS NULL
       BEGIN;
              RAISERROR('Input parameters cannot be NULL', 16, 1);
              RETURN;
       END;
       
       SELECT 
              [O].[Name], 
              [O].[Value] AS "OlderValue", 
              [O].[ValueInUse] AS"OlderValueInUse",
              [R].[Value] AS "RecentValue", 
              [R].[ValueInUse] AS "RecentValueInUse"

       FROM [dbo].[ConfigData] O
       JOIN
              (SELECT [ConfigurationID], [Value], [ValueInUse]
              FROM [dbo].[ConfigData]
              WHERE [CaptureDate] = @RecentDate) R on [O].[ConfigurationID] = [R].[ConfigurationID]
       WHERE [O].[CaptureDate] = @OlderDate
       AND (([R].[Value] <> [O].[Value]) OR ([R].[ValueInUse] <> [O].[ValueInUse]))

END;

GO
/****** Object:  Table [dbo].[ConfigData]    Script Date: 5/1/2015 9:57:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConfigData](
       [ConfigurationID] [int] NOT NULL,
       [Name] [nvarchar](35) NOT NULL,
       [Value] [sql_variant] NULL,
       [ValueInUse] [sql_variant] NULL,
       [CaptureDate] [datetime] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ServerConfig]    Script Date: 5/1/2015 9:57:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServerConfig](
       [Property] [nvarchar](128) NULL,
       [Value] [sql_variant] NULL,
       [CaptureDate] [datetime] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[WaitStats]    Script Date: 5/1/2015 9:57:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WaitStats](
       [RowNum] [bigint] IDENTITY(1,1) NOT NULL,
       [CaptureDate] [datetime] NULL,
       [WaitType] [nvarchar](120) NULL,
       [Wait_S] [decimal](14, 2) NULL,
       [Resource_S] [decimal](14, 2) NULL,
       [Signal_S] [decimal](14, 2) NULL,
       [WaitCount] [bigint] NULL,
       [Percentage] [decimal](4, 2) NULL,
       [AvgWait_S] [decimal](14, 2) NULL,
       [AvgRes_S] [decimal](14, 2) NULL,
       [AvgSig_S] [decimal](14, 2) NULL
) ON [PRIMARY]

GO
/****** Object:  Index [CI_ConfigData]    Script Date: 5/1/2015 9:57:11 AM ******/
CREATE CLUSTERED INDEX [CI_ConfigData] ON [dbo].[ConfigData]
(
       [CaptureDate] ASC,
       [ConfigurationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [CI_ServerConfig]    Script Date: 5/1/2015 9:57:11 AM ******/
CREATE CLUSTERED INDEX [CI_ServerConfig] ON [dbo].[ServerConfig]
(
       [CaptureDate] ASC,
       [Property] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [CI_WaitStats]    Script Date: 5/1/2015 9:57:11 AM ******/
CREATE CLUSTERED INDEX [CI_WaitStats] ON [dbo].[WaitStats]
(
       [RowNum] ASC,
       [CaptureDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
