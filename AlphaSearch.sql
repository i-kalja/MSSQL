


/*

-- ######################################################################################
-- ##################                                                  ##################
-- ##################   Instructions about installation & run, BEGIN   ##################
-- ##################                                                  ##################
-- ######################################################################################

Before executing the script, create a directory D:\AlphaSearch\
Grant the access rights to this directory for the current user.
A database AlphaSearch will be created there.  
Or enter your path in the line
FILENAME = N'D:\AlphaSearch\AlphaSearch.mdf'
Put the Test.csv file in D:\AlphaSearch\Test.csv

The script was created and tested in the MS SQL Server 2012 R2 x64 version, but should work from version MS SQL Server 2008.

List of stored procedures:
[dbo].[AlphaSearch_Initialization]
[dbo].[AlphaSearch]
[dbo].[RebuildsIndexesUpdatesStatistics]

Database maintenance:
RebuildsIndexesUpdatesStatistics -- no comments, must have

Examples of a call:
EXEC [AlphaSearch].[dbo].[AlphaSearch_Initialization]
EXEC [AlphaSearch].[dbo].[AlphaSearch]
EXEC [AlphaSearch].[dbo].[RebuildsIndexesUpdatesStatistics]


After you have created the database with this script, execute the procedure
EXEC [AlphaSearch].[dbo].[AlphaSearch_Initialization]

After that, execute the procedure
EXEC [AlphaSearch].[dbo].[AlphaSearch]

Update the list of tables in the database.
Check the data in the tables.
Carefully review and read all the information in the Results and Messages tabs.


-- ####################################################################################
-- ##################                                                ##################
-- ##################   Instructions about installation & run, END   ##################
-- ##################                                                ##################
-- ####################################################################################

*/



-- Create DB, IF NOT EXISTS, BEGIN 

USE [master]
GO

IF NOT EXISTS (select * from sys.databases where name = 'AlphaSearch')
	BEGIN
		CREATE DATABASE [AlphaSearch]
		 CONTAINMENT = NONE
		 ON  PRIMARY 
		( NAME = N'AlphaSearch', FILENAME = N'D:\AlphaSearch\AlphaSearch.mdf' , SIZE = 107520KB , MAXSIZE = UNLIMITED, FILEGROWTH = 102400KB )
		 LOG ON 
		( NAME = N'AlphaSearch_log', FILENAME = N'D:\AlphaSearch\AlphaSearch_log.ldf' , SIZE = 3840KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)

	END
GO

USE [AlphaSearch]
GO

ALTER DATABASE [AlphaSearch] SET COMPATIBILITY_LEVEL = 100
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
BEGIN
	EXEC [AlphaSearch].[dbo].[sp_fulltext_database] @action = 'enable'
END
GO

ALTER DATABASE [AlphaSearch] SET  READ_WRITE 
GO

-- ########################################################################################



USE AlphaSearch
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RebuildsIndexesUpdatesStatistics]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[RebuildsIndexesUpdatesStatistics]
GO

-- =============================================
-- Author:		Ihor Kalchuk
-- Create date: 12 October 2017
-- Description:	Test task
-- =============================================

CREATE PROCEDURE [dbo].[RebuildsIndexesUpdatesStatistics]
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @Database VARCHAR(255)   
DECLARE @Table VARCHAR(255)  
DECLARE @cmd NVARCHAR(500)  
DECLARE @fillfactor INT 

SET @fillfactor = 90 

DECLARE DatabaseCursor CURSOR FOR  
SELECT name FROM master.dbo.sysdatabases   
WHERE name = 'AlphaSearch' 


OPEN DatabaseCursor  

FETCH NEXT FROM DatabaseCursor INTO @Database  
WHILE @@FETCH_STATUS = 0  
BEGIN  

   SET @cmd = 'DECLARE TableCursor CURSOR FOR SELECT ''['' + table_catalog + ''].['' + table_schema + ''].['' + 
  table_name + '']'' as tableName FROM [' + @Database + '].INFORMATION_SCHEMA.TABLES 
  WHERE table_type = ''BASE TABLE'''   

   -- create table cursor  
   EXEC (@cmd)  
   OPEN TableCursor   

   FETCH NEXT FROM TableCursor INTO @Table   
   WHILE @@FETCH_STATUS = 0   
   BEGIN   

       IF (@@MICROSOFTVERSION / POWER(2, 24) >= 9)
       BEGIN
           -- SQL 2005 or higher command 
           SET @cmd = 'ALTER INDEX ALL ON ' + @Table + ' REBUILD WITH (FILLFACTOR = ' + CONVERT(VARCHAR(3),@fillfactor) + ')' 
           EXEC (@cmd) 

		   SET @cmd = 'UPDATE STATISTICS ' + @Table + ' WITH FULLSCAN'
		   EXEC (@cmd) 

       END
       ELSE
       BEGIN
          -- SQL 2000 command 
          DBCC DBREINDEX(@Table,' ',@fillfactor)  
       END

       FETCH NEXT FROM TableCursor INTO @Table   
   END   

   CLOSE TableCursor   
   DEALLOCATE TableCursor  

   FETCH NEXT FROM DatabaseCursor INTO @Database  
END  
CLOSE DatabaseCursor   
DEALLOCATE DatabaseCursor

SELECT 'REBUILD AND UPDATE STATISTICS DONE'

END
GO

-- #############################################################
-- #############################################################
-- #############################################################

-- Stored procedure RebuildsIndexesUpdatesStatistics, END



-- Stored procedure [AlphaSearch_Initialization], BEGIN


USE [AlphaSearch]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AlphaSearch_Initialization]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[AlphaSearch_Initialization]
GO

CREATE PROCEDURE [dbo].[AlphaSearch_Initialization]
AS
BEGIN

SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Params')
BEGIN
EXEC('CREATE SCHEMA Params')
END


IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Data')
BEGIN
EXEC('CREATE SCHEMA Data')
END


IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'TMP')
BEGIN
EXEC('CREATE SCHEMA TMP')
END


IF (NOT EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'Params' 
                 AND  TABLE_NAME = 'DataTableList'))
	BEGIN
			CREATE TABLE [Params].[DataTableList](
			[DataTableListID] [int] IDENTITY(1,1) NOT NULL,
			[DataTableListTableName] [nvarchar](MAX) NOT NULL,
		 CONSTRAINT [PK_Params.DataTableList] PRIMARY KEY CLUSTERED 
		(
			[DataTableListID] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
		) ON [PRIMARY]
	END
ELSE
	BEGIN
		TRUNCATE TABLE [Params].[DataTableList]
	END


IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'Data' 
                 AND  TABLE_NAME = 'Decade1990'))
BEGIN
    DROP TABLE [Data].[Decade1990]
END

IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'Data' 
                 AND  TABLE_NAME = 'Decade2000'))
BEGIN
    DROP TABLE [Data].[Decade2000]
END

IF (EXISTS (SELECT * 
                 FROM INFORMATION_SCHEMA.TABLES 
                 WHERE TABLE_SCHEMA = 'Data' 
                 AND  TABLE_NAME = 'Decade2010'))
BEGIN
    DROP TABLE [Data].[Decade2010]
END

END
GO


-- #############################################################
-- #############################################################
-- #############################################################

-- Stored procedure [AlphaSearch_Initialization], END




-- Stored procedure [AlphaSearch], BEGIN


USE AlphaSearch
GO


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AlphaSearch]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[AlphaSearch]
GO

CREATE PROCEDURE [dbo].[AlphaSearch]
AS
BEGIN

SET NOCOUNT ON;

SET DATEFORMAT dmy;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TMP].[NewData]') AND type in (N'U'))
BEGIN
	DROP TABLE [TMP].[NewData]
END

CREATE TABLE [TMP].[NewData](
	[Date] NVARCHAR (250) NULL,
	[Value] [nvarchar](250) NULL,
) ON [PRIMARY]


BULK INSERT [AlphaSearch].[TMP].[NewData] FROM 'D:\AlphaSearch\Test.csv' WITH (CHECK_CONSTRAINTS, CODEPAGE = ' RAW ', FIRSTROW = 1, FIELDTERMINATOR = ';', ROWTERMINATOR = '\n')


ALTER TABLE [AlphaSearch].[TMP].[NewData]
ADD [ID] [int] IDENTITY(1,1) NOT NULL


ALTER TABLE [AlphaSearch].[TMP].[NewData] ADD  CONSTRAINT [PK_NewData] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];

 IF OBJECT_ID('tempdb..#NewDataToProcess') IS NOT NULL
    DROP TABLE #NewDataToProcess

  CREATE TABLE #NewDataToProcess (
    [Id] int NOT NULL,
    [Code] varchar(32) NOT NULL,
    [MinDate] [date] NULL,
    [MaxDate] [date] NULL,
	[ID_From] INT NULL,
	[ID_To] INT NULL
   )

INSERT INTO #NewDataToProcess ([Id], [Code] ) 

SELECT ND.[ID] , SUBSTRING (CAST(ND.[Value] AS VARCHAR(MAX)) ,1,CHARINDEX('(',CAST(ND.[Value] AS VARCHAR(MAX)))-1) AS Code  
FROM [TMP].[NewData] AS  ND
WHERE (ISNUMERIC(CAST(ND.[Value] AS VARCHAR(MAX))) = 0 OR ISDATE(CAST(ND.[Date] AS VARCHAR(MAX))) = 0) AND ND.[Date] = 'Code'
ORDER BY ND.[ID] ASC


UPDATE #NewDataToProcess
SET 
	ID_From	=  [ID]+2
FROM #NewDataToProcess NDTP


UPDATE #NewDataToProcess
SET 
	ID_To = R2.[Result] 
FROM 
#NewDataToProcess AS RM
INNER JOIN 
(
SELECT NDTP.*, R1.[ID]- 2 AS [Result]
FROM #NewDataToProcess AS NDTP
	CROSS APPLY (SELECT TOP 1 [ID] FROM #NewDataToProcess WHERE [ID]> NDTP.[ID] ORDER BY [ID] ASC ) AS R1
) AS R2 ON RM.[ID] = R2.[ID]


UPDATE #NewDataToProcess
SET 
	ID_To = ( SELECT MAX([ID]) FROM [TMP].[NewData] )
FROM 
#NewDataToProcess AS RM
WHERE RM.[ID_To] IS NULL

DELETE [AlphaSearch].[TMP].[NewData]
WHERE ISNUMERIC(CAST([Value] AS VARCHAR(MAX))) = 0 OR ISDATE(CAST([Date] AS VARCHAR(MAX))) = 0

UPDATE #NewDataToProcess
SET 
	MinDate	= R2.Min_Val,
	MaxDate = R2.Max_Val
FROM 
(SELECT NDTP.* , R1.*
FROM #NewDataToProcess AS NDTP
CROSS APPLY (
		SELECT  MIN([Date]) AS Min_Val, MAX([Date]) AS Max_Val FROM [TMP].[NewData] AS ND
		WHERE ND.[ID] >= NDTP.[ID_From] AND ND.[ID] <= NDTP.ID_To 
		 ) AS R1
) AS R2


ALTER TABLE [AlphaSearch].[TMP].[NewData]
ALTER COLUMN [Date] date NULL

ALTER TABLE [AlphaSearch].[TMP].[NewData]
ALTER COLUMN [Value] money NULL;

CREATE NONCLUSTERED INDEX [INDX_NewData_1] ON [TMP].[NewData]
(
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]


SELECT 'Read Messages tab !!!' AS [Read Messages tab] 

SELECT 'Import data''s info' AS [Recordset Info], * 
FROM #NewDataToProcess

DECLARE @DecadeCounter_Current INT
DECLARE @DecadeCounter_Min INT
DECLARE @DecadeCounter_Max INT


		DECLARE @TableName nvarchar(250)
		DECLARE @Min_Date date
		DECLARE @Max_Date date

		DECLARE @DecadesTable table(  
				[ID] [int] IDENTITY(1,1) NOT NULL,
				Decade CHAR(4) NULL,
				DateFilterFrom CHAR(10) NULL,
				DateFilterTo  CHAR(10) NULL,
				ColumnCount INT NULL
				);  

		

		SELECT @Min_Date = MIN(Date),	@Max_Date = MAX(Date) FROM [TMP].[NewData] 

		DECLARE @DecadeValue INT
		SET @DecadeValue = LEFT(CAST (YEAR(@Min_Date) AS CHAR(4)), 3) + '0'

		WHILE @DecadeValue <= YEAR(@Max_Date) 
		BEGIN
			
			IF NOT EXISTS (SELECT Decade FROM @DecadesTable WHERE Decade = CAST(@DecadeValue AS CHAR(4)))
				BEGIN
					
					INSERT INTO @DecadesTable (Decade, DateFilterFrom, DateFilterTo)
					VALUES (@DecadeValue, '01/01/' + CAST(@DecadeValue AS CHAR(4)), '31/12/' + CAST(@DecadeValue + 9 AS CHAR(4)))

				END

			SET @DecadeValue = @DecadeValue + 10

		END

	UPDATE @DecadesTable		 
		SET ColumnCount = DATEDIFF(dd, DateFilterFrom, DateFilterTo)
	

	SELECT @DecadeCounter_Current = MIN([ID]), @DecadeCounter_Min = MIN([ID]),  @DecadeCounter_Max = MAX([ID]) FROM @DecadesTable

WHILE (@DecadeCounter_Current <= @DecadeCounter_Max)              -- DO
	BEGIN



	DECLARE @Data_TableName nvarchar(250) 

		SET @Data_TableName = '[Data].[Decade' + (SELECT Decade FROM @DecadesTable WHERE [ID] = @DecadeCounter_Current) + ']'
 

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

DECLARE @ColumnsCount INT

SELECT @ColumnsCount = COUNT (DISTINCT [Date])
FROM [TMP].[NewData] AS ND
WHERE ND.Date BETWEEN (SELECT DateFilterFrom FROM @DecadesTable WHERE [ID] = @DecadeCounter_Current) AND (SELECT DateFilterTo FROM @DecadesTable WHERE [ID] = @DecadeCounter_Current)

		IF @ColumnsCount > 1024 
			BEGIN
				SET @ErrorMessage = 'ERROR! I can not create a table ' + @Data_TableName + ', the number of columns will be ' + CAST(@ColumnsCount AS VARCHAR(MAX)) + ', the maximum allowed number of columns in table is 1024.' 
				
				RAISERROR ( @ErrorMessage ,
							16, 
				             1 
							);
				PRINT 'I think there is a solution to the problem, but I need to work on it a little :)'
				GOTO NEXT_Decade
				
			END

		

		IF NOT EXISTS (SELECT TOP 1 DataTableListTableName FROM [Params].[DataTableList] WHERE DataTableListTableName = @Data_TableName ) 
			BEGIN
				INSERT INTO [Params].[DataTableList] (DataTableListTableName)
				VALUES (@Data_TableName)


	DECLARE @Cols AS NVARCHAR(MAX),
    @Query  AS NVARCHAR(MAX)

	SET @Cols = ''

select @cols = STUFF((SELECT ',' + QUOTENAME([Date]) 
                    from (
					SELECT NDTP. Code, CA.[Date], CA.[Value] 
				FROM #NewDataToProcess AS NDTP
				CROSS APPLY (
							SELECT 
							CAST ( DATEPART ( yyyy , [Date] )  AS CHAR(4))
							+
							 CASE WHEN (DATEPART ( mm , [Date] ) )  < 10 THEN '0' + CONVERT( CHAR(1), DATEPART ( mm , [Date] ) )     ELSE RIGHT ( '0' + CONVERT( CHAR(2), DATEPART ( mm , [Date] ) ), 2) END 
							+ CASE WHEN (DATEPART ( dd , [Date] ) )  < 10 THEN '0' + CONVERT( CHAR(1), DATEPART ( dd , [Date] ) )     ELSE RIGHT ( '0' + CONVERT( CHAR(2), DATEPART ( dd , [Date] ) ), 2) END   
							AS [Date]
							, [Value] 
							FROM [TMP].[NewData] AS ND
							WHERE ND.[ID] >= NDTP.ID_From AND ND.[ID] <= NDTP.ID_To
								AND ND.Date BETWEEN (SELECT DateFilterFrom FROM @DecadesTable WHERE [ID] = @DecadeCounter_Current
														) 
														AND 
														(SELECT DateFilterTo FROM @DecadesTable WHERE [ID] = @DecadeCounter_Current
														)

							
							) AS CA
					

					) AS R1

                    group by [Date]
                    order by CAST([Date] AS Date) ASC
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')


		set @query = '
			SET DATEFORMAT dmy ;
			SELECT Code,' + @cols + 
			' INTO ' + @Data_TableName + 
			'
			 from 
             (
                select R1.Code, R1.[Date], R1.[Value]
                from (
					SELECT  NDTP.Code, CA.[Date], CA.[Value] 
				FROM #NewDataToProcess AS NDTP
				CROSS APPLY (
							SELECT 
							CAST ( DATEPART ( yyyy , [Date] )  AS CHAR(4))
							+
							 CASE WHEN (DATEPART ( mm , [Date] ) )  < 10 THEN ''0'' + CONVERT( CHAR(1), DATEPART ( mm , [Date] ) )     ELSE RIGHT ( ''0'' + CONVERT( CHAR(2), DATEPART ( mm , [Date] ) ), 2) END 
							+ CASE WHEN (DATEPART ( dd , [Date] ) )  < 10 THEN ''0'' + CONVERT( CHAR(1), DATEPART ( dd , [Date] ) )     ELSE RIGHT ( ''0'' + CONVERT( CHAR(2), DATEPART ( dd , [Date] ) ), 2) END   
							AS [Date]
							, [Value] 
							FROM [TMP].[NewData] AS ND
							WHERE ND.[ID] >= NDTP.ID_From AND ND.[ID] <= NDTP.ID_To
							AND ND.Date BETWEEN (''' 
													+ (SELECT DateFilterFrom FROM @DecadesTable WHERE [ID] = @DecadeCounter_Current) +
												''') 
													AND 
														('''
													+ (SELECT DateFilterTo FROM @DecadesTable WHERE [ID] = @DecadeCounter_Current) +
												''')
							) AS CA

					) AS R1

            ) x
            pivot 
            (
                sum([Value])
                for [Date] in (' + @cols + ')
            ) p '

	EXECUTE(@query);

			END
		ELSE
			BEGIN
				PRINT ''
				PRINT 'Table ' + @Data_TableName + ' already created!'
				PRINT ''
				SELECT 'Table ' + @Data_TableName + ' already created!' AS [Table already created!]
			END

NEXT_Decade:

		SET @DecadeCounter_Current = (SELECT TOP 1 [ID] FROM @DecadesTable WHERE [ID] > @DecadeCounter_Current ORDER BY [ID] ASC) 

 END

 SELECT 'Decade''s info' AS [Recordset Info] ,* FROM @DecadesTable

PRINT ''
PRINT '===================================='
PRINT '   Take a look at the Results tab'
PRINT '===================================='

END
GO


-- #############################################################
-- #############################################################
-- #############################################################

-- Stored procedure [AlphaSearch], END
