# AgileEngineDB
Test task

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
