

/*

-- ######################################################################################
-- ##################                                                  ##################
-- ##################   Instructions about installation & run, BEGIN   ##################
-- ##################                                                  ##################
-- ######################################################################################

Before executing the script, create a directory D:\AgileEngineDB\
Grant the access rights to this directory for the current user.
A database AgileEngineDB will be created there.  
Or enter your path in the line
FILENAME = N'D:\AgileEngineDB\AgileEngineDB.mdf'

To change the number of products, the number of stores and the number of cities in the created tables, change the variables
DECLARE @CitiesCount INT = 10
DECLARE @StoresCount INT = 5
DECLARE @ProductsCount INT = 2000


The script was created and tested in the MS SQL Server 2012 R2 x64 version, but should work from version MS SQL Server 2008.

List of stored procedures:

Maintenance of Cities table: 
GetCity
InsertCity
UpdateCity
DeleteCity

Examples of a call:
EXEC GetCity
EXEC GetCity 1
EXEC InsertCity 'NewCity'  -- return new CityID
EXEC UpdateCity 1, 'NewCityName' 
EXEC DeleteCity 1


Maintenance of Products table: 
GetProduct
InsertProduct
UpdateProduct
DeleteProduct

Examples of a call:
EXEC GetProduct
EXEC GetProduct 2
EXEC InsertProduct @ProductName = 'ProductName', @ProductTypeID = 1 -- return new ProductID
EXEC UpdateProduct @ProductID  = 1, @ProductName = 'NewProductName', @ProductTypeID = 1
EXEC DeleteProduct 2001



Maintenance of ProductTypes table: 
GetProductType
InsertProductType
UpdateProductType
DeleteProductType

Examples of a call:
EXEC GetProductType
EXEC GetProductType 1
EXEC InsertProductType @ProductTypeName = 'ProductTypeName'  -- return new ProductTypeID
EXEC UpdateProductType @ProductTypeID = 1, @ProductTypeName = 'NewProductTypeName'
EXEC DeleteProductType @ProductTypeID = 1



Maintenance of Stores table: 
GetStore
InsertStore
UpdateStore
DeleteStore

Examples of a call:
EXEC GetStore
EXEC GetStore 2
EXEC InsertStore @StoreName = 'StoreName', @CityID = 1 -- @CityID from Cities table,  -- return new StoreID  
EXEC UpdateStore @StoreID = 1, @StoreName = 'StoreName', @CityID = 1 --  @CityID from Cities table,
EXEC DeleteStore @StoreID = 1





Update the price for a small amount of products:
UpdatePriceSmallRecordset

/*
-- How to use UpdatePriceSmallRecordset, BEGIN

USE [AgileEngineDB]
GO

SELECT * FROM ProductStorePrice
WHERE ProductID IN (1,2,3) AND StoreID = 1

declare @ProductStorePriceTableType dbo.ProductStorePriceTableType
insert into @ProductStorePriceTableType values(1,1,555.55)	-- [ProductID] [int], [StoreID] [int], [Price] money
insert into @ProductStorePriceTableType values(2,1,12.12)	
insert into @ProductStorePriceTableType values(3,1,33.33)	

EXEC [UpdatePriceSmallRecordset] @ProductStorePriceTableType

SELECT * FROM ProductStorePrice
WHERE ProductID IN (1,2,3) AND StoreID = 1

-- How to use UpdatePriceSmallRecordset, END
*/




Update the price for a huge amount of products:
UpdatePriceBigRecordset

/*
-- How to use UpdatePriceBigRecordset, BEGIN

USE [AgileEngineDB]
GO

SELECT * FROM ProductStorePrice
WHERE ProductID IN (2,3,4) AND StoreID IN (3, 4)

  IF OBJECT_ID('tempdb..#ProductStorePriceTableTemp') IS NOT NULL
    DROP TABLE #ProductStorePriceTableTemp

  CREATE TABLE #ProductStorePriceTableTemp (
    Id int identity(1,1),
    [ProductID] [int] NOT NULL,
    [StoreID] [int] NOT NULL,
    [Price] money NOT NULL
   )

CREATE UNIQUE CLUSTERED INDEX [INDX_ProductStorePriceTableTemp] ON #ProductStorePriceTableTemp
(
	[ProductID] ASC,
	[StoreID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]



   INSERT INTO #ProductStorePriceTableTemp ([ProductID], [StoreID], [Price])
				values	(2,3,11.11),
						(3,3,22.22),
						(4,4,33.33)

	EXEC [UpdatePriceBigRecordset] 

SELECT * FROM ProductStorePrice
WHERE ProductID IN (2,3,4) AND StoreID IN (3, 4)

  IF OBJECT_ID('tempdb..#ProductStorePriceTableTemp') IS NOT NULL
    DROP TABLE #ProductStorePriceTableTemp


-- How to use UpdatePriceBigRecordset, END
*/


Database maintenance:
RebuildsIndexesUpdatesStatistics -- no comments, must have


P.S. I did not use foreign keys in the database, but I provided necessary checks in stored procedures.



-- ####################################################################################
-- ##################                                                ##################
-- ##################   Instructions about installation & run, END   ##################
-- ##################                                                ##################
-- ####################################################################################

*/



-- Create DB, IF NOT EXISTS, BEGIN 

USE [master]
GO

IF NOT EXISTS (select * from sys.databases where name = 'AgileEngineDB')
	BEGIN
		CREATE DATABASE [AgileEngineDB]
		 CONTAINMENT = NONE
		 ON  PRIMARY 
		( NAME = N'AgileEngineDB', FILENAME = N'D:\AgileEngineDB\AgileEngineDB.mdf' , SIZE = 107520KB , MAXSIZE = UNLIMITED, FILEGROWTH = 102400KB )
		 LOG ON 
		( NAME = N'AgileEngineDB_log', FILENAME = N'D:\AgileEngineDB\AgileEngineDB_log.ldf' , SIZE = 3840KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)

	END
GO

USE [AgileEngineDB]
GO

ALTER DATABASE [AgileEngineDB] SET COMPATIBILITY_LEVEL = 100
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
BEGIN
	EXEC [AgileEngineDB].[dbo].[sp_fulltext_database] @action = 'enable'
END
GO

ALTER DATABASE [AgileEngineDB] SET  READ_WRITE 
GO

-- ########################################################################################


USE [AgileEngineDB]
GO

		SET ANSI_NULLS ON

		SET QUOTED_IDENTIFIER ON

		IF OBJECT_ID('Cities', 'U') IS NOT NULL
			DROP TABLE [Cities]

		CREATE TABLE [dbo].[Cities](
			[CityID] [int] IDENTITY(1,1) NOT NULL,
			[CityName] [nvarchar](100) NOT NULL,
		 CONSTRAINT [PK_Cities] PRIMARY KEY CLUSTERED 
		(
			[CityID] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
		) ON [PRIMARY]

		ALTER TABLE [dbo].[Cities]  WITH CHECK ADD  CONSTRAINT [CK_Cities] CHECK  (([CityName] IS NOT NULL AND [CityName]<>''))
		ALTER TABLE [dbo].[Cities] CHECK CONSTRAINT [CK_Cities]
		EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'[CityName] can not be blank.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Cities', @level2type=N'CONSTRAINT',@level2name=N'CK_Cities'

		-- *******************************************************

		IF OBJECT_ID('Products', 'U') IS NOT NULL
			DROP TABLE [Products]

		CREATE TABLE [dbo].[Products](
			[ProductID] [int] IDENTITY(1,1) NOT NULL,
			[ProductName] [nvarchar](250) NOT NULL,
			[ProductTypeID] [int] NOT NULL,
		 CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED 
		(
			[ProductID] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
		) ON [PRIMARY]

		ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [CK_Products] CHECK  (([ProductName] IS NOT NULL AND [ProductName]<>''))
		ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [CK_Products]
		EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'[ProductName] can not be blank.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Products', @level2type=N'CONSTRAINT',@level2name=N'CK_Products'


		-- *******************************************************

		IF OBJECT_ID('ProductStorePrice', 'U') IS NOT NULL
			DROP TABLE [ProductStorePrice]

		CREATE TABLE [dbo].[ProductStorePrice](
			[RowID] [int] IDENTITY(1,1) NOT NULL,
			[ProductID] [int] NOT NULL,
			[StoreID] [int] NOT NULL,
			[Price] [money] NOT NULL,
		 CONSTRAINT [PK_ProductStorePrice] PRIMARY KEY CLUSTERED 
		(
			[RowID] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
		) ON [PRIMARY]

		ALTER TABLE [dbo].[ProductStorePrice]  WITH CHECK ADD  CONSTRAINT [CK_ProductStorePrice] CHECK  (([Price] IS NOT NULL AND [Price]>(0)))
		ALTER TABLE [dbo].[ProductStorePrice] CHECK CONSTRAINT [CK_ProductStorePrice]
		EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'[Price] can not be NULL and value must be greater than 0.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductStorePrice', @level2type=N'CONSTRAINT',@level2name=N'CK_ProductStorePrice'


		-- *******************************************************

		IF OBJECT_ID('ProductTypes', 'U') IS NOT NULL
			DROP TABLE [ProductTypes]

		CREATE TABLE [dbo].[ProductTypes](
			[ProductTypeID] [int] IDENTITY(1,1) NOT NULL,
			[ProductTypeName] [nvarchar](50) NOT NULL,
		 CONSTRAINT [PK_ProductType] PRIMARY KEY CLUSTERED 
		(
			[ProductTypeID] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
		) ON [PRIMARY]

		ALTER TABLE [dbo].[ProductTypes]  WITH CHECK ADD  CONSTRAINT [CK_ProductTypes] CHECK  (([ProductTypeName] IS NOT NULL AND [ProductTypeName]<>''))
		ALTER TABLE [dbo].[ProductTypes] CHECK CONSTRAINT [CK_ProductTypes]
		EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'[ProductTypeName] can not be blank.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ProductTypes', @level2type=N'CONSTRAINT',@level2name=N'CK_ProductTypes'

		-- *******************************************************

		IF OBJECT_ID('Stores', 'U') IS NOT NULL
			DROP TABLE [Stores]

		CREATE TABLE [dbo].[Stores](
			[StoreID] [int] IDENTITY(1,1) NOT NULL,
			[StoreName] [nvarchar](150) NOT NULL,
			[CityID] [int] NOT NULL,
		 CONSTRAINT [PK_Stores] PRIMARY KEY CLUSTERED 
		(
			[StoreID] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
		) ON [PRIMARY]

		ALTER TABLE [dbo].[Stores]  WITH CHECK ADD  CONSTRAINT [CK_Stores] CHECK  (([StoreName] IS NOT NULL AND [StoreName]<>''))
		ALTER TABLE [dbo].[Stores] CHECK CONSTRAINT [CK_Stores]
		EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'[StoreName] can not be blank.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Stores', @level2type=N'CONSTRAINT',@level2name=N'CK_Stores'

		-- *******************************************************


GO

-- #############################################################
-- #############################################################
-- #############################################################

-- Create DB, IF NOT EXISTS, END 


-- Create ProductStorePriceTableType, BEGIN

	USE [AgileEngineDB]
	GO

	IF type_id('[dbo].[ProductStorePriceTableType]') IS NULL
        BEGIN
			CREATE TYPE ProductStorePriceTableType AS TABLE 
				( 
				[ProductID] [int] NOT NULL,
				[StoreID] [int] NOT NULL,
				[Price] money NOT NULL
				 );
		END
	GO

-- #############################################################
-- #############################################################
-- #############################################################

-- Create ProductStorePriceTableType, END 


-- FILL TABLES, BEGIN

USE AgileEngineDB
GO

DECLARE @CitiesCount INT = 10
DECLARE @StoresCount INT = 5
DECLARE @ProductsCount INT = 2000


SET NOCOUNT ON

DECLARE @RowCount INT = 0
DECLARE @Upper INT = 1
DECLARE @Lower INT = 999
DECLARE @RandomStr NVARCHAR(300)

-- ==============================================
	-- Fill ProductTypes, BEGIN
	
	TRUNCATE TABLE ProductTypes;
	INSERT INTO ProductTypes
		([ProductTypeName])
	VALUES
		('Book'),
		('Toy'),
		('Clothes');

	-- Fill ProductTypes, END
-- ==============================================

-- ==============================================
	-- Fill Cities, BEGIN
	
	TRUNCATE TABLE Cities;
	SET @RowCount = 1
	WHILE @RowCount <= @CitiesCount
BEGIN
	
	SELECT @RandomStr = 'City ' + CAST(@RowCount AS NVARCHAR(10)) + '-' +CAST(ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0) AS NVARCHAR(10))
	
	INSERT INTO Cities
		([CityName])
	VALUES (@RandomStr);
	
	SET @RowCount = @RowCount + 1;

END

	-- Fill Cities, END
-- ==============================================

-- ==============================================
	-- Fill Stores, BEGIN
	
	TRUNCATE TABLE Stores;
	SET @RowCount = 1
	WHILE @RowCount <= @StoresCount
BEGIN
	
	SET @Upper = -1
	SET @Lower = -999
	SELECT @RandomStr = 'Store ' + CAST(@RowCount AS NVARCHAR(10)) + CAST(ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0) AS NVARCHAR(10))
	
		-- Get random CityID, BEGIN	
			DECLARE @RandomCityID INT
			SET @Lower = 1 
			SET @Upper = @CitiesCount + 1
			SELECT @RandomCityID = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0)
		-- Get random CityID, BEGIN

	INSERT INTO Stores
		([StoreName], [CityID])
	VALUES (@RandomStr, @RandomCityID);
	
	SET @RowCount = @RowCount + 1;

END

	-- Fill Stores, END
-- ==============================================


-- ==============================================
	-- Fill Products, BEGIN
	
	TRUNCATE TABLE Products;
	SET @RowCount = 1
	WHILE @RowCount <= @ProductsCount
BEGIN
	
	SET @Upper = 1
	SET @Lower = 999
	SELECT @RandomStr = 'Product ' + CAST(@RowCount AS NVARCHAR(10)) + '-' +  CAST(ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0) AS NVARCHAR(10))
	
		-- Get random ProductTypeID, BEGIN	
			DECLARE @RandomProductTypeID INT
			SET @Lower = 1 
			SET @Upper = 3 + 1
			SELECT @RandomProductTypeID = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0)
		-- Get random ProductTypeID, BEGIN

	INSERT INTO Products
		([ProductName], [ProductTypeID])
	VALUES (@RandomStr, @RandomProductTypeID);
	
	SET @RowCount = @RowCount + 1;

END

	-- Fill Products, END
-- ==============================================


-- ==============================================
	-- Fill ProductStorePrice, BEGIN
	
	TRUNCATE TABLE ProductStorePrice;
	SET @RowCount = 1
	WHILE @RowCount <= @ProductsCount
BEGIN
	
	DECLARE @Price_Part1 INT
	DECLARE @Price_Part2 INT
	DECLARE @ProductPrice MONEY
	DECLARE @StoreID INT

	SET @StoreID = 1

		WHILE @StoreID <= @StoresCount
	BEGIN
		-- Get @Price_Part1, BEGIN
			SET @Lower = 1 
			SET @Upper = 999 + 1
			SELECT @Price_Part1 = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0)
		-- Get @Price_Part1, BEGIN

		-- Get @Price_Part2, BEGIN
			SET @Lower = 1 
			SET @Upper = 99 + 1
			SELECT @Price_Part2 = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0)
		-- Get @Price_Part2, BEGIN

		SET @ProductPrice = CAST(@Price_Part1 AS NVARCHAR(10)) + '.' + CAST(@Price_Part2 AS NVARCHAR(2))
	
		--PRINT @RowCount
		--PRINT @StoreID
		--PRINT @ProductPrice
		--PRINT '********************'

		INSERT INTO ProductStorePrice
			([ProductID], [StoreID], [Price])
		VALUES (@RowCount, @StoreID, @ProductPrice);
	
		SET @StoreID = @StoreID + 1
	
	END

	SET @RowCount = @RowCount + 1;

END

	-- Fill ProductStorePrice, END
-- ==============================================

GO

-- #############################################################
-- #############################################################
-- #############################################################

-- FILL TABLES, END


-- STORED PROCEDURES, BEGIN

-- Stored procedures for Cities, BEGIN


USE AgileEngineDB 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetCity]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[GetCity]
GO

-- =============================================
-- Author:		Ihor Kalchuk
-- Create date: 12 October 2017
-- Description:	Test task
-- =============================================

CREATE PROCEDURE [dbo].[GetCity]
	@CityID int = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CityID, CityName
	FROM Cities WITH (READPAST)
	WHERE CityID = @CityID OR @CityID IS NULL

END
GO

-- ###############################################################
-- ###############################################################
-- ###############################################################

USE AgileEngineDB 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertCity]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[InsertCity]
GO

-- =============================================
-- Author:		Ihor Kalchuk
-- Create date: 12 October 2017
-- Description:	Test task
-- =============================================

CREATE PROCEDURE [dbo].[InsertCity]
	@CityName NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @ReturnCityID INT = NULL

BEGIN TRY
BEGIN TRANSACTION

	SELECT @ReturnCityID = CityID
	FROM Cities WITH (READPAST)
	WHERE CityName = @CityName
	
	IF @ReturnCityID IS NULL
		BEGIN
			
			INSERT INTO Cities
				([CityName])
			VALUES (@CityName);			

			SET @ReturnCityID = IDENT_CURRENT('Cities') -- variant 1
			-- SET @ReturnCityID = @@IDENTITY -- variant 2 
			-- SET @ReturnCityID = SCOPE_IDENTITY() -- variant 3

		END
	
	SELECT @ReturnCityID

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			COMMIT TRANSACTION
		END

END TRY

BEGIN CATCH

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			ROLLBACK TRANSACTION
		END
	
-- Variant 1
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

	RAISERROR (@ErrorMessage,
               @ErrorSeverity,
               @ErrorState
               )
			   WITH LOG;


-- Variant 2
	--SELECT
	--		 ERROR_NUMBER() AS ErrorNumber
	--		,ERROR_LINE() AS ErrorLine
	--		,ERROR_MESSAGE() AS ErrorMessage;

END CATCH

END
GO

-- ###############################################################
-- ###############################################################
-- ###############################################################

USE AgileEngineDB 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateCity]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[UpdateCity]
GO

-- =============================================
-- Author:		Ihor Kalchuk
-- Create date: 12 October 2017
-- Description:	Test task
-- =============================================

CREATE PROCEDURE [dbo].[UpdateCity]
	@CityID INT,
	@CityName NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

BEGIN TRY
BEGIN TRANSACTION

	UPDATE Cities
	SET CityName = @CityName
	WHERE CityID = @CityID 

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			COMMIT TRANSACTION
		END

END TRY

BEGIN CATCH

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			ROLLBACK TRANSACTION
		END
	
-- Variant 1
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

	RAISERROR (@ErrorMessage,
               @ErrorSeverity,
               @ErrorState
               )
			   WITH LOG;


-- Variant 2
	--SELECT
	--		 ERROR_NUMBER() AS ErrorNumber
	--		,ERROR_LINE() AS ErrorLine
	--		,ERROR_MESSAGE() AS ErrorMessage;

END CATCH

END
GO

-- ###############################################################
-- ###############################################################
-- ###############################################################

USE AgileEngineDB 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeleteCity]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[DeleteCity]
GO

-- =============================================
-- Author:		Ihor Kalchuk
-- Create date: 12 October 2017
-- Description:	Test task
-- =============================================

CREATE PROCEDURE [dbo].[DeleteCity]
	@CityID INT
AS
BEGIN
	SET NOCOUNT ON;

BEGIN TRY
BEGIN TRANSACTION



	-- Check Stores table for @CityID, BEGIN	

		-- I don't use FK in this DB, so I check it by myself 

		IF EXISTS (SELECT TOP 1 CityID FROM Stores WHERE CityID = @CityID)
			BEGIN
				RAISERROR ('I can not delete this city, it is used in the Stores table',
							16, 
				             1 
							);
			END
	-- Check Stores table for @CityID, END

	DELETE Cities
	WHERE CityID = @CityID 

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			COMMIT TRANSACTION
		END

END TRY

BEGIN CATCH

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			ROLLBACK TRANSACTION
		END
	
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

			RAISERROR (@ErrorMessage,
					   @ErrorSeverity,
					   @ErrorState
					   )
					   WITH LOG;

END CATCH

END
GO

-- ###############################################################
-- ###############################################################
-- ###############################################################

-- Stored procedures for Cities, END



-- Stored procedures for Products, BEGIN


USE AgileEngineDB 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetProduct]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[GetProduct]
GO

-- =============================================
-- Author:		Ihor Kalchuk
-- Create date: 12 October 2017
-- Description:	Test task
-- =============================================

CREATE PROCEDURE [dbo].[GetProduct]
	@ProductID int = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT P.ProductID, P.ProductName, PT.ProductTypeName
	FROM Products AS P WITH (READPAST)
	INNER JOIN ProductTypes AS PT ON p.ProductTypeID = PT.ProductTypeID
	WHERE P.ProductID = @ProductID OR @ProductID IS NULL

END
GO

-- ###############################################################
-- ###############################################################
-- ###############################################################

USE AgileEngineDB 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertProduct]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[InsertProduct]
GO

-- =============================================
-- Author:		Ihor Kalchuk
-- Create date: 12 October 2017
-- Description:	Test task
-- =============================================

CREATE PROCEDURE [dbo].[InsertProduct]
	@ProductName NVARCHAR(250),
	@ProductTypeID INT
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @ReturnProductID INT = NULL

BEGIN TRY
BEGIN TRANSACTION

	SELECT @ReturnProductID = ProductID
	FROM Products WITH (READPAST)
	WHERE ProductName = @ProductName
	
	IF @ReturnProductID IS NULL
		BEGIN
			
			INSERT INTO Products
				([ProductName], [ProductTypeID])
			VALUES (@ProductName, @ProductTypeID);			

			SET @ReturnProductID = IDENT_CURRENT('Products') -- variant 1
			-- SET @ReturnCityID = @@IDENTITY -- variant 2 
			-- SET @ReturnCityID = SCOPE_IDENTITY() -- variant 3

		END
	ELSE
		BEGIN
			RAISERROR ('A product with this name already exists!',
							16, 
				             1 
							);
		END

	
	SELECT @ReturnProductID

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			COMMIT TRANSACTION
		END

END TRY

BEGIN CATCH

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			ROLLBACK TRANSACTION
		END
	
-- Variant 1
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

	RAISERROR (@ErrorMessage,
               @ErrorSeverity,
               @ErrorState
               )
			   WITH LOG;


-- Variant 2
	--SELECT
	--		 ERROR_NUMBER() AS ErrorNumber
	--		,ERROR_LINE() AS ErrorLine
	--		,ERROR_MESSAGE() AS ErrorMessage;

END CATCH

END
GO

-- ###############################################################
-- ###############################################################
-- ###############################################################

USE AgileEngineDB 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateProduct]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[UpdateProduct]
GO

-- =============================================
-- Author:		Ihor Kalchuk
-- Create date: 12 October 2017
-- Description:	Test task
-- =============================================

CREATE PROCEDURE [dbo].[UpdateProduct]
	@ProductID int,
	@ProductName NVARCHAR(250),
	@ProductTypeID INT
AS
BEGIN
	SET NOCOUNT ON;

BEGIN TRY
BEGIN TRANSACTION

	UPDATE Products
	SET ProductName = @ProductName,
		ProductTypeID = @ProductTypeID
	WHERE ProductID = @ProductID 

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			COMMIT TRANSACTION
		END

END TRY

BEGIN CATCH

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			ROLLBACK TRANSACTION
		END
	
-- Variant 1
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

	RAISERROR (@ErrorMessage,
               @ErrorSeverity,
               @ErrorState
               )
			   WITH LOG;


-- Variant 2
	--SELECT
	--		 ERROR_NUMBER() AS ErrorNumber
	--		,ERROR_LINE() AS ErrorLine
	--		,ERROR_MESSAGE() AS ErrorMessage;

END CATCH

END
GO

-- ###############################################################
-- ###############################################################
-- ###############################################################

USE AgileEngineDB 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeleteProduct]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[DeleteProduct]
GO

-- =============================================
-- Author:		Ihor Kalchuk
-- Create date: 12 October 2017
-- Description:	Test task
-- =============================================

CREATE PROCEDURE [dbo].[DeleteProduct]
	@ProductID INT
AS
BEGIN
	SET NOCOUNT ON;

BEGIN TRY
BEGIN TRANSACTION



	-- Delete from ProductStorePrice table for @ProductID, BEGIN	

		-- I don't use FK in this DB, so I do it by myself 

		DELETE ProductStorePrice
		WHERE ProductID = @ProductID
		
	-- Delete from ProductStorePrice table for @ProductID, END

	DELETE Products
	WHERE ProductID = @ProductID 

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			COMMIT TRANSACTION
		END

END TRY

BEGIN CATCH

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			ROLLBACK TRANSACTION
		END
	
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

			RAISERROR (@ErrorMessage,
					   @ErrorSeverity,
					   @ErrorState
					   )
					   WITH LOG;

END CATCH

END
GO

-- ###############################################################
-- ###############################################################
-- ###############################################################

-- Stored procedures for Products, END


-- Stored procedures for ProductTypes, BEGIN


USE AgileEngineDB 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetProductType]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[GetProductType]
GO

-- =============================================
-- Author:		Ihor Kalchuk
-- Create date: 12 October 2017
-- Description:	Test task
-- =============================================

CREATE PROCEDURE [dbo].[GetProductType]
	@ProductTypeID int = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT PT.ProductTypeID, PT.ProductTypeName 
	FROM ProductTypes AS PT WITH (READPAST) 
	WHERE PT.ProductTypeID = @ProductTypeID OR @ProductTypeID IS NULL

END
GO

-- ###############################################################
-- ###############################################################
-- ###############################################################

USE AgileEngineDB 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertProductType]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[InsertProductType]
GO

-- =============================================
-- Author:		Ihor Kalchuk
-- Create date: 12 October 2017
-- Description:	Test task
-- =============================================

CREATE PROCEDURE [dbo].[InsertProductType]
	@ProductTypeName NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @ReturnProductTypeID INT = NULL

BEGIN TRY
BEGIN TRANSACTION

	SELECT @ReturnProductTypeID = ProductTypeID
	FROM ProductTypes WITH (READPAST)
	WHERE ProductTypeName = @ProductTypeName
	
	IF @ReturnProductTypeID IS NULL
		BEGIN
			
			INSERT INTO ProductTypes
				([ProductTypeName])
			VALUES (@ProductTypeName);			

			SET @ReturnProductTypeID = IDENT_CURRENT('ProductTypes') -- variant 1
			-- SET @ReturnCityID = @@IDENTITY -- variant 2 
			-- SET @ReturnCityID = SCOPE_IDENTITY() -- variant 3

		END
	ELSE
		BEGIN
			RAISERROR ('A product types with this name already exists!',
							16, 
				             1 
							);
		END

	
	SELECT @ReturnProductTypeID

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			COMMIT TRANSACTION
		END

END TRY

BEGIN CATCH

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			ROLLBACK TRANSACTION
		END
	
-- Variant 1
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

	RAISERROR (@ErrorMessage,
               @ErrorSeverity,
               @ErrorState
               )
			   WITH LOG;


-- Variant 2
	--SELECT
	--		 ERROR_NUMBER() AS ErrorNumber
	--		,ERROR_LINE() AS ErrorLine
	--		,ERROR_MESSAGE() AS ErrorMessage;

END CATCH

END
GO

-- ###############################################################
-- ###############################################################
-- ###############################################################

USE AgileEngineDB 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateProductType]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[UpdateProductType]
GO

-- =============================================
-- Author:		Ihor Kalchuk
-- Create date: 12 October 2017
-- Description:	Test task
-- =============================================

CREATE PROCEDURE [dbo].[UpdateProductType]
	@ProductTypeID int,
	@ProductTypeName NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

BEGIN TRY
BEGIN TRANSACTION

	UPDATE ProductTypes
	SET ProductTypeName = @ProductTypeName
	WHERE ProductTypeID = @ProductTypeID 

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			COMMIT TRANSACTION
		END

END TRY

BEGIN CATCH

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			ROLLBACK TRANSACTION
		END
	
-- Variant 1
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

	RAISERROR (@ErrorMessage,
               @ErrorSeverity,
               @ErrorState
               )
			   WITH LOG;


-- Variant 2
	--SELECT
	--		 ERROR_NUMBER() AS ErrorNumber
	--		,ERROR_LINE() AS ErrorLine
	--		,ERROR_MESSAGE() AS ErrorMessage;

END CATCH

END
GO

-- ###############################################################
-- ###############################################################
-- ###############################################################

USE AgileEngineDB 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeleteProductType]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[DeleteProductType]
GO

-- =============================================
-- Author:		Ihor Kalchuk
-- Create date: 12 October 2017
-- Description:	Test task
-- =============================================

CREATE PROCEDURE [dbo].[DeleteProductType]
	@ProductTypeID INT
AS
BEGIN
	SET NOCOUNT ON;

BEGIN TRY
BEGIN TRANSACTION



	-- Check Products table for @@ProductTypeID, BEGIN	

		-- I don't use FK in this DB, so I check it by myself 

		IF EXISTS (SELECT TOP 1 ProductTypeID FROM Products WHERE ProductTypeID = @ProductTypeID)
			BEGIN
				RAISERROR ('I can not delete this product type, it is used in the Products table',
							16, 
				             1 
							);
			END
	-- -- Check Products table for @@ProductTypeID, END


	DELETE ProductTypes
	WHERE ProductTypeID = @ProductTypeID 

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			COMMIT TRANSACTION
		END

END TRY

BEGIN CATCH

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			ROLLBACK TRANSACTION
		END
	
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

			RAISERROR (@ErrorMessage,
					   @ErrorSeverity,
					   @ErrorState
					   )
					   WITH LOG;

END CATCH

END
GO

-- ###############################################################
-- ###############################################################
-- ###############################################################

-- Stored procedures for ProductTypes, END



-- Stored procedures for Stores, BEGIN


USE AgileEngineDB 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetStore]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[GetStore]
GO

-- =============================================
-- Author:		Ihor Kalchuk
-- Create date: 12 October 2017
-- Description:	Test task
-- =============================================

CREATE PROCEDURE [dbo].[GetStore]
	@StoreID int = NULL,
	@CityID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT S.StoreID, S.StoreName, C.CityName 
	FROM Stores AS S WITH (READPAST) 
	INNER JOIN Cities AS C WITH (READPAST) ON S.CityID = C.CityID
	WHERE (S.StoreID = @StoreID OR @StoreID IS NULL) 
		AND (C.CityID = @CityID OR @CityID IS NULL)

END
GO

-- ###############################################################
-- ###############################################################
-- ###############################################################

USE AgileEngineDB 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[InsertStore]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[InsertStore]
GO

-- =============================================
-- Author:		Ihor Kalchuk
-- Create date: 12 October 2017
-- Description:	Test task
-- =============================================

CREATE PROCEDURE [dbo].[InsertStore]
	@StoreName NVARCHAR(150),
	@CityID INT
AS
BEGIN
	SET NOCOUNT ON;

DECLARE @ReturnStoreID INT = NULL

BEGIN TRY
BEGIN TRANSACTION

	SELECT @ReturnStoreID = StoreID
	FROM Stores WITH (READPAST)
	WHERE StoreName = @StoreName

	-- Check Cities table for @CityID, BEGIN	

		-- I don't use FK in this DB, so I check it by myself 

		IF NOT EXISTS (SELECT TOP 1 CityID FROM Cities WHERE CityID = @CityID)
			BEGIN
				RAISERROR ('Unknown city identifier!',
							16, 
				             1 
							);
			END
	-- -- Check Cities table for @CityID, END

	
	IF @ReturnStoreID IS NULL
		BEGIN
			
			INSERT INTO Stores
				([StoreName], [CityID])
			VALUES (@StoreName, @CityID);			

			SET @ReturnStoreID = IDENT_CURRENT('Stores') -- variant 1
			-- SET @ReturnCityID = @@IDENTITY -- variant 2 
			-- SET @ReturnCityID = SCOPE_IDENTITY() -- variant 3

		END
	ELSE
		BEGIN
			RAISERROR ('A store with this name already exists!',
							16, 
				             1 
							);
		END

	
	SELECT @ReturnStoreID

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			COMMIT TRANSACTION
		END

END TRY

BEGIN CATCH

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			ROLLBACK TRANSACTION
		END
	
-- Variant 1
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

	RAISERROR (@ErrorMessage,
               @ErrorSeverity,
               @ErrorState
               )
			   WITH LOG;


-- Variant 2
	--SELECT
	--		 ERROR_NUMBER() AS ErrorNumber
	--		,ERROR_LINE() AS ErrorLine
	--		,ERROR_MESSAGE() AS ErrorMessage;

END CATCH

END
GO

-- ###############################################################
-- ###############################################################
-- ###############################################################

USE AgileEngineDB 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdateStore]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[UpdateStore]
GO

-- =============================================
-- Author:		Ihor Kalchuk
-- Create date: 12 October 2017
-- Description:	Test task
-- =============================================

CREATE PROCEDURE [dbo].[UpdateStore]
	@StoreID int,
	@StoreName NVARCHAR(150),
	@CityID INT
AS
BEGIN
	SET NOCOUNT ON;

BEGIN TRY
BEGIN TRANSACTION

	-- Check Cities table for @CityID, BEGIN	

		-- I don't use FK in this DB, so I check it by myself 

		IF NOT EXISTS (SELECT TOP 1 CityID FROM Cities WHERE CityID = @CityID)
			BEGIN
				RAISERROR ('Unknown city identifier!',
							16, 
				             1 
							);
			END
	-- -- Check Cities table for @CityID, END


	UPDATE Stores
	SET StoreName = @StoreName,
		CityID = @CityID
	WHERE StoreID = @StoreID 

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			COMMIT TRANSACTION
		END

END TRY

BEGIN CATCH

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			ROLLBACK TRANSACTION
		END
	
-- Variant 1
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

	RAISERROR (@ErrorMessage,
               @ErrorSeverity,
               @ErrorState
               )
			   WITH LOG;


-- Variant 2
	--SELECT
	--		 ERROR_NUMBER() AS ErrorNumber
	--		,ERROR_LINE() AS ErrorLine
	--		,ERROR_MESSAGE() AS ErrorMessage;

END CATCH

END
GO

-- ###############################################################
-- ###############################################################
-- ###############################################################

USE AgileEngineDB 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DeleteStore]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[DeleteStore]
GO

-- =============================================
-- Author:		Ihor Kalchuk
-- Create date: 12 October 2017
-- Description:	Test task
-- =============================================

CREATE PROCEDURE [dbo].[DeleteStore]
	@StoreID INT
AS
BEGIN
	SET NOCOUNT ON;

BEGIN TRY
BEGIN TRANSACTION



	-- Delete from ProductStorePrice table for @StoreID, BEGIN	

		-- I don't use FK in this DB, so I do it by myself 

		DELETE ProductStorePrice
		WHERE StoreID = @StoreID
		
	-- Delete from ProductStorePrice table for @StoreID, END


	DELETE Stores
	WHERE StoreID = @StoreID

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			COMMIT TRANSACTION
		END

END TRY

BEGIN CATCH

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			ROLLBACK TRANSACTION
		END
	
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

			RAISERROR (@ErrorMessage,
					   @ErrorSeverity,
					   @ErrorState
					   )
					   WITH LOG;

END CATCH

END
GO

-- ###############################################################
-- ###############################################################
-- ###############################################################

-- Stored procedures for Stores, END


-- Stored procedure UpdatePriceSmallRecordset, BEGIN

USE AgileEngineDB 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdatePriceSmallRecordset]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[UpdatePriceSmallRecordset]
GO

-- =============================================
-- Author:		Ihor Kalchuk
-- Create date: 12 October 2017
-- Description:	Test task
-- =============================================

/*
-- How to use UpdatePriceSmallRecordset, BEGIN

USE [AgileEngineDB]
GO

SELECT * FROM ProductStorePrice
WHERE ProductID IN (1,2,3) AND StoreID = 1

declare @ProductStorePriceTableType dbo.ProductStorePriceTableType
insert into @ProductStorePriceTableType values(1,1,555.55)	-- [ProductID] [int], [StoreID] [int], [Price] money
insert into @ProductStorePriceTableType values(2,1,12.12)	
insert into @ProductStorePriceTableType values(3,1,33.33)	

EXEC [UpdatePriceSmallRecordset] @ProductStorePriceTableType

SELECT * FROM ProductStorePrice
WHERE ProductID IN (1,2,3) AND StoreID = 1

-- How to use UpdatePriceSmallRecordset, END
*/

CREATE PROCEDURE [dbo].[UpdatePriceSmallRecordset]
	@ProductStorePriceTableType AS [dbo].ProductStorePriceTableType Readonly
AS
BEGIN
	SET NOCOUNT ON;

BEGIN TRY
BEGIN TRANSACTION

	UPDATE ProductStorePrice
	SET	Price = TT.Price 
	FROM ProductStorePrice AS PST
		INNER JOIN @ProductStorePriceTableType AS TT ON PST.ProductID = TT.ProductID 
														AND PST.StoreID = TT.StoreID

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			COMMIT TRANSACTION
		END

END TRY

BEGIN CATCH

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			ROLLBACK TRANSACTION
		END
	
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

			RAISERROR (@ErrorMessage,
					   @ErrorSeverity,
					   @ErrorState
					   )
					   WITH LOG;

END CATCH

END
GO

-- #############################################################
-- #############################################################
-- #############################################################


-- Stored procedure UpdatePriceSmallRecordset, END


-- Stored procedure UpdatePriceBigRecordset, BEGIN

USE AgileEngineDB 
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UpdatePriceBigRecordset]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[UpdatePriceBigRecordset]
GO

-- =============================================
-- Author:		Ihor Kalchuk
-- Create date: 12 October 2017
-- Description:	Test task
-- =============================================

/*
-- How to use UpdatePriceBigRecordset, BEGIN

USE [AgileEngineDB]
GO

SELECT * FROM ProductStorePrice
WHERE ProductID IN (2,3,4) AND StoreID IN (3, 4)

  IF OBJECT_ID('tempdb..#ProductStorePriceTableTemp') IS NOT NULL
    DROP TABLE #ProductStorePriceTableTemp

  CREATE TABLE #ProductStorePriceTableTemp (
    Id int identity(1,1),
    [ProductID] [int] NOT NULL,
    [StoreID] [int] NOT NULL,
    [Price] money NOT NULL
   )

CREATE UNIQUE CLUSTERED INDEX [INDX_ProductStorePriceTableTemp] ON #ProductStorePriceTableTemp
(
	[ProductID] ASC,
	[StoreID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]



   INSERT INTO #ProductStorePriceTableTemp ([ProductID], [StoreID], [Price])
				values	(2,3,11.11),
						(3,3,22.22),
						(4,4,33.33)

	EXEC [UpdatePriceBigRecordset] 

SELECT * FROM ProductStorePrice
WHERE ProductID IN (2,3,4) AND StoreID IN (3, 4)

  IF OBJECT_ID('tempdb..#ProductStorePriceTableTemp') IS NOT NULL
    DROP TABLE #ProductStorePriceTableTemp


-- How to use UpdatePriceBigRecordset, END
*/

CREATE PROCEDURE [dbo].[UpdatePriceBigRecordset]
AS
BEGIN
	SET NOCOUNT ON;

BEGIN TRY
BEGIN TRANSACTION

	UPDATE ProductStorePrice
	SET	Price = TT.Price 
	FROM ProductStorePrice AS PST
		INNER JOIN #ProductStorePriceTableTemp AS TT ON PST.ProductID = TT.ProductID 
														AND PST.StoreID = TT.StoreID

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			COMMIT TRANSACTION
		END

END TRY

BEGIN CATCH

	IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
		BEGIN
			ROLLBACK TRANSACTION
		END
	
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

			RAISERROR (@ErrorMessage,
					   @ErrorSeverity,
					   @ErrorState
					   )
					   WITH LOG;

END CATCH

END
GO

-- #############################################################
-- #############################################################
-- #############################################################

-- Stored procedure UpdatePriceBigRecordset, END

-- Stored procedure RebuildsIndexesUpdatesStatistics, BEGIN

USE AgileEngineDB 
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
WHERE name = 'AgileEngineDB' 


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

-- #############################################################
-- #############################################################
-- #############################################################

-- STORED PROCEDURES, END





