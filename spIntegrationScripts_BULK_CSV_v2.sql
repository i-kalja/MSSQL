USE [1010Tires]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	-- =============================================
	-- Author: Kalchuk Ihor
	-- Task: 1010TIRES BACKEND / TBE-763 Create spIntegrationScripts_BULK_CSV_v2.
	-- Create date: 30 September 2015
	-- Description: New version of spIntegrationScripts_BULK_CSV
	-- Task: TBE-767 Rewrite spIntegrationScripts_BULK_CSV_v2
	-- Create date: 07 October 2015
	-- Description: Correct missing Minus OEM sizes
	-- Task: TBE-773 Update Vehicle_TPMSSensors table
	-- Altered by: Kalchuk Ihor
	-- Date: 15 October 2015
	-- Description: Update information in Vehicle_TPMSSensors table for new vehicles.
	-- Task: TBE-980 Optimize procedures at .../Tires/Reviews/...
	-- by Kalchuk Ihor 
	-- Date: 19 August 2016
	-- Description: Find ways to accelerate the opening of site pages.
	-- Task: TBE-1024 Rewrite spIntegrationScripts_BULK_CSV_v2
	-- by Kalchuk Ihor 
	-- Date: 15 December 2016
	-- Description: Take into account changing of provider's data 
	-- Task: TBE-1055 Rewrite spIntegrationScripts_BULK_CSV_v2
	-- by Kalchuk Ihor 
	-- Date: 16 December 2016
	-- Description: Add log to MessageTransactionLog
	-- Task: TBE-1101 Rewrite spIntegrationScripts_BULK_CSV_v2
	-- by Kalchuk Ihor 
	-- Date: 12 February 2017
	-- Description: ACES format
	-- =============================================
	
ALTER PROCEDURE [dbo].[spIntegrationScripts_BULK_CSV_v2]
	@AddNewDataOnly int = 1
AS

BEGIN
SET NOCOUNT ON;

	-- ==============  REM IT  ===============================

		--DECLARE @AddNewDataOnly int = 0

	-- ==============  REM IT  ===============================


DECLARE @VehicleDailyUpdate_ID NVARCHAR(50)  
SET @VehicleDailyUpdate_ID = CONVERT(varchar(255), NEWID())
DECLARE @VehicleDailyUpdate_Date DATETIME
SET @VehicleDailyUpdate_Date = GETDATE ()
DECLARE @VehicleDailyUpdate_LastVehicleID INT
SELECT @VehicleDailyUpdate_LastVehicleID = MAX(VehicleID) FROM Vehicle
DECLARE @VehicleDailyUpdate_Summary_New INT = 0
DECLARE @VehicleDailyUpdate_Summary_Updated INT = 0
DECLARE @VehicleDailyUpdate_Summary_Error INT = 0

INSERT INTO MessageTransactionLog
([SequenceId], [EventID], [EventDescription], [Message], [ErrorCode], [ErrorMessage], [ProcessName], [RunArguments])
VALUES
(@VehicleDailyUpdate_ID, 10001, 'Start Process', '', '0', '', 'VehicleDailyUpdate', NULL)

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

BEGIN TRY
BEGIN TRANSACTION

SET NOCOUNT ON;

-- CSV processing, START ---
-- ###########################################

-- *******************************************************************************************
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Fitment_Check_TEMP]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Fitment_Check_TEMP](
	[VehicleID] [int] NOT NULL,
	[IsStaggeredFitmentFlag] [bit] NULL,
	[ChassisID] [int] NULL,
	[AftermarketWheelDiameter] [float] NULL,
	[AftermarketWheelWidthMin] [float] NULL,
	[AftermarketWheelWidthMax] [float] NULL,
	[AftermarketWheelOffsetMin] [float] NULL,
	[AftermarketWheelOffsetMax] [float] NULL,
	[RearFitment] [bit] NULL,
	[MinusFitment] [bit] NULL
) ON [PRIMARY]


CREATE UNIQUE NONCLUSTERED INDEX [INDX_Fitment_Check_TEMP] ON [dbo].[Fitment_Check_TEMP]
(
	[VehicleID] ASC,
	[IsStaggeredFitmentFlag] ASC,
	[ChassisID] ASC,
	[AftermarketWheelDiameter] ASC,
	[AftermarketWheelWidthMin] ASC,
	[AftermarketWheelWidthMax] ASC,
	[AftermarketWheelOffsetMin] ASC,
	[AftermarketWheelOffsetMax] ASC,
	[RearFitment] ASC,
	[MinusFitment] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

END
-- *******************************************************************************************

-- CREATE TABLES
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Fitment_Chassis_TEMP]') AND type in (N'U'))
--DROP TABLE [dbo].[Fitment_Chassis_TEMP]
BEGIN
CREATE TABLE [dbo].[Fitment_Chassis_TEMP](
	[ChassisID] [varchar](50) NULL,
	[BoltPattern] [varchar](50) NULL,
	[Hubbore] [varchar](50) NULL,
	[HubboreRear] [varchar](50) NULL,
	[MaxWheelLoad] [varchar](50) NULL,
	[Nutorbolt] [varchar](50) NULL,
	[NutBoltThreadType] [varchar](50) NULL,
	[NutBoltHex] [varchar](50) NULL,
	[BoltLength] [varchar](50) NULL,
	[Minboltlength] [varchar](50) NULL,
	[Maxboltlength] [varchar](50) NULL,
	[NutBoltTorque] [varchar](50) NULL,
	[AxleWeightFront] [varchar](50) NULL,
	[AxleWeightRear] [varchar](50) NULL,
	[TPMS] [varchar](50) NULL
) ON [PRIMARY]
END
-- ***********
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Fitment_ChassisModels_TEMP]') AND type in (N'U'))
--DROP TABLE [dbo].[Fitment_ChassisModels_TEMP]
BEGIN
CREATE TABLE [dbo].[Fitment_ChassisModels_TEMP](
	[ChassisID] [varchar](50) NULL,
	[ModelID] [varchar](50) NULL,
	[PMetric] [varchar](50) NULL,
	[TireSize] [varchar](50) NULL,
	[LoadIndex] [varchar](50) NULL,
	[SpeedRating] [varchar](50) NULL,
	[TireSizeRear] [varchar](50) NULL,
	[LoadIndexRear] [varchar](50) NULL,
	[SpeedRatingRear] [varchar](50) NULL,
	[WheelSize] [varchar](50) NULL,
	[WheelSizeRear] [varchar](50) NULL,
	[RunflatFront] [varchar](50) NULL,
	[RunflatRear] [varchar](50) NULL,
	[ExtraLoadFront] [varchar](50) NULL,
	[ExtraLoadRear] [varchar](50) NULL,
	[TPFrontPSI] [varchar](50) NULL,
	[TPRearPSI] [varchar](50) NULL,
	[OffsetMinF] [varchar](50) NULL,
	[OffsetMaxF] [varchar](50) NULL,
	[OffsetMinR] [varchar](50) NULL,
	[OffsetMaxR] [varchar](50) NULL,
	[RimWidth] [varchar](50) NULL,
	[RimDiameter] [varchar](50) NULL
) ON [PRIMARY]
END
-- ***************
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Fitment_MinusSizes_TEMP]') AND type in (N'U'))
--DROP TABLE [dbo].[Fitment_MinusSizes_TEMP]
BEGIN
CREATE TABLE [dbo].[Fitment_MinusSizes_TEMP](
	[ChassisID] [varchar](50) NULL,
	[WheelSize] [varchar](50) NULL,
	[TireSize] [varchar](50) NULL,
	[FrontRearOrBoth] [varchar](50) NULL,
	[OffsetMin] [varchar](50) NULL,
	[OffsetMax] [varchar](50) NULL
) ON [PRIMARY]
END
-- ************
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Fitment_PlusSizes_TEMP]') AND type in (N'U'))
--DROP TABLE [dbo].[Fitment_PlusSizes_TEMP]
BEGIN
CREATE TABLE [dbo].[Fitment_PlusSizes_TEMP](
[ChassisID] [varchar](50) NULL,
[PlusSizeType] [varchar](50) NULL,
[WheelSize] [varchar](50) NULL,
[Tire1] [varchar](50) NULL,
[Tire2] [varchar](50) NULL,
[Tire3] [varchar](50) NULL,
[Tire4] [varchar](50) NULL,
[Tire5] [varchar](50) NULL,
[Tire6] [varchar](50) NULL,
[Tire7] [varchar](50) NULL,
[Tire8] [varchar](50) NULL,
[OffsetMin] [varchar](50) NULL,
[OffsetMax] [varchar](50) NULL
) ON [PRIMARY]
END
-- *********************
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Fitment_Vehicles_TEMP]') AND type in (N'U'))
--DROP TABLE [dbo].[Fitment_Vehicles_TEMP]
	BEGIN
		CREATE TABLE [dbo].[Fitment_Vehicles_TEMP](
		[VehicleID] [nvarchar](50) NOT NULL,

		[BaseVehicleID] [nvarchar](50) NULL,
		[YearID] [varchar](4) NULL,
		[MakeID] [varchar](50) NULL,
		[MakeName] [nvarchar](100) NULL,
		[ModelID] [varchar](50) NULL,
		[ModelName] [nvarchar](100) NULL,
		[SubmodelID] [varchar](4) NULL,
		[SubmodelName] [nvarchar](100) NULL,
		[DriveTypeID] [varchar](4) NULL,
		[DriveTypeName] [varchar](10) NULL,
		[BodyTypeID] [varchar](50) NULL,
		[BodyTypeName] [nvarchar](100) NULL,
		[BodyNumDoorsID] [varchar](50) NULL,
		[BodyNumDoors] [nvarchar](50) NULL,
		[BedLengthID] [nvarchar](50) NULL,
		[BedLength] [nvarchar](50) NULL,
		[VehicleTypeID] [nvarchar](50) NULL,
		[VehicleTypeName] [nvarchar](100) NULL,
		[RegionID] [nvarchar](50) NULL,
		[RegionName] [nvarchar](100) NULL,
		[FG_CustomNote] [nvarchar](250) NULL,
		[FG_Body] [nvarchar](250) NULL,
		[FG_Option] [nvarchar](250) NULL,
		[FG_ChassisID] [nvarchar](50) NULL,
		[FG_ModelID] [nvarchar](50) NULL,
		[FG_FMK] [nvarchar](50) NOT NULL,
		) ON [PRIMARY]
	END
ELSE
	BEGIN
		TRUNCATE TABLE Fitment_Vehicles_TEMP

		IF EXISTS (	SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='PK_Fitment_Vehicles_TEMP' ) 
			BEGIN
				ALTER TABLE [dbo].[Fitment_Vehicles_TEMP] DROP CONSTRAINT [PK_Fitment_Vehicles_TEMP]
			END

		ALTER TABLE Fitment_Vehicles_TEMP ALTER COLUMN FG_FMK [nvarchar](50) NOT NULL
		ALTER TABLE Fitment_Vehicles_TEMP ALTER COLUMN FG_ModelID [nvarchar](50) NOT NULL
		ALTER TABLE Fitment_Vehicles_TEMP ALTER COLUMN FG_ChassisID [nvarchar](50) NOT NULL
	END


-- ###########################################
TRUNCATE TABLE Fitment_Check_TEMP
TRUNCATE TABLE Fitment_Chassis_TEMP
TRUNCATE TABLE Fitment_ChassisModels_TEMP
TRUNCATE TABLE Fitment_MinusSizes_TEMP
TRUNCATE TABLE Fitment_PlusSizes_TEMP
--TRUNCATE TABLE Fitment_Vehicles_TEMP
BULK INSERT [1010Tires].dbo.Fitment_Chassis_TEMP FROM 'C:\1010Tires\Car_DB_CSV\Chassis.csv' WITH (CHECK_CONSTRAINTS, CODEPAGE = ' RAW ', FIRSTROW = 2, FIELDTERMINATOR = '","', ROWTERMINATOR = '\n')
BULK INSERT [1010Tires].dbo.Fitment_ChassisModels_TEMP FROM 'C:\1010Tires\Car_DB_CSV\ChassisModels.csv' WITH (CHECK_CONSTRAINTS, CODEPAGE = ' RAW ', FIRSTROW = 2, FIELDTERMINATOR = '","', ROWTERMINATOR = '\n')
BULK INSERT [1010Tires].dbo.Fitment_MinusSizes_TEMP FROM 'C:\1010Tires\Car_DB_CSV\MinusSizes.csv' WITH (CHECK_CONSTRAINTS, CODEPAGE = ' RAW ', FIRSTROW = 2, FIELDTERMINATOR = '","', ROWTERMINATOR = '\n')
BULK INSERT [1010Tires].dbo.Fitment_PlusSizes_TEMP FROM 'C:\1010Tires\Car_DB_CSV\PlusSizes.csv' WITH (CHECK_CONSTRAINTS, CODEPAGE = ' RAW ', FIRSTROW = 2, FIELDTERMINATOR = '","', ROWTERMINATOR = '\n')
BULK INSERT [1010Tires].dbo.Fitment_Vehicles_TEMP FROM 'C:\1010Tires\Car_DB_CSV\Vehicles.csv' WITH (CODEPAGE = ' RAW ', FIRSTROW = 2, FIELDTERMINATOR = '","', ROWTERMINATOR = '\n')
TRUNCATE TABLE [1010Tires].dbo.Fitment_Chassis
TRUNCATE TABLE [1010Tires].dbo.Fitment_ChassisModels
TRUNCATE TABLE [1010Tires].dbo.Fitment_MinusSizes
TRUNCATE TABLE [1010Tires].dbo.Fitment_PlusSizes
TRUNCATE TABLE [1010Tires].dbo.Fitment_Vehicles
-- **************************
-- Convert NULL to '' START
-- **************************
UPDATE Fitment_Chassis_TEMP
SET ChassisID = ISNULL(ChassisID, ''), BoltPattern = ISNULL(BoltPattern, ''), Hubbore = ISNULL(Hubbore, ''), HubboreRear = ISNULL(HubboreRear, ''),
MaxWheelLoad = ISNULL(MaxWheelLoad, ''), Nutorbolt = ISNULL(Nutorbolt, ''), NutBoltThreadType = ISNULL(NutBoltThreadType, ''),
NutBoltHex = ISNULL(NutBoltHex, ''), BoltLength = ISNULL(BoltLength, ''), Minboltlength = ISNULL(Minboltlength, ''), Maxboltlength = ISNULL(Maxboltlength, ''),
NutBoltTorque = ISNULL(NutBoltTorque, ''), 

AxleWeightFront = ISNULL(AxleWeightFront, ''),
AxleWeightRear = ISNULL(AxleWeightRear, ''), 
TPMS = ISNULL(TPMS, '')
 
UPDATE Fitment_Chassis_TEMP
SET ChassisID = REPLACE(ChassisID, '"','')
  , TPMS = REPLACE(TPMS, '"','')

UPDATE Fitment_ChassisModels_TEMP
SET ChassisID = ISNULL(ChassisID, ''), ModelID = ISNULL(ModelID, ''), PMetric = ISNULL(PMetric, ''), TireSize = ISNULL(TireSize, ''), LoadIndex = ISNULL(LoadIndex, ''),
SpeedRating = ISNULL(SpeedRating, ''), TireSizeRear = ISNULL(TireSizeRear, ''), LoadIndexRear = ISNULL(LoadIndexRear,
''), SpeedRatingRear = ISNULL(SpeedRatingRear, ''), WheelSize = ISNULL(WheelSize, ''),
WheelSizeRear = ISNULL(WheelSizeRear, ''), RunflatFront = ISNULL(RunflatFront,
''), RunflatRear = ISNULL(RunflatRear, ''), ExtraLoadFront = ISNULL(ExtraLoadFront, ''), ExtraLoadRear = ISNULL(ExtraLoadRear, ''), TPFrontPSI = ISNULL(TPFrontPSI,
''), TPRearPSI = ISNULL(TPRearPSI, ''), OffsetMinF= ISNULL(OffsetMinF, ''), OffsetMaxF= ISNULL(OffsetMaxF, ''), OffsetMinR= ISNULL(OffsetMinR, ''), 
OffsetMaxR= ISNULL(OffsetMaxR, ''), RimWidth= ISNULL(RimWidth, ''), RimDiameter= ISNULL(RimDiameter, '')  
      

UPDATE Fitment_ChassisModels_TEMP
SET ChassisID = REPLACE(ChassisID, '"','')
  , RimDiameter = REPLACE(RimDiameter, '"','')

UPDATE Fitment_MinusSizes_TEMP
SET ChassisID = ISNULL(ChassisID, ''), WheelSize = ISNULL(WheelSize, ''), TireSize = ISNULL(TireSize, ''), FrontRearOrBoth = ISNULL(FrontRearOrBoth, '')
, OffsetMin = ISNULL(OffsetMin, ''), OffsetMax = ISNULL(OffsetMax, '')

UPDATE Fitment_MinusSizes_TEMP
SET ChassisID = REPLACE(ChassisID, '"',''),
OffsetMax = REPLACE(OffsetMax, '"', '')

UPDATE Fitment_PlusSizes_TEMP
SET ChassisID = ISNULL(ChassisID, ''), PlusSizeType = ISNULL(PlusSizeType, ''), WheelSize = ISNULL(WheelSize, ''), Tire1 = ISNULL(Tire1, ''), Tire2 = ISNULL(Tire2, ''),
Tire3 = ISNULL(Tire3, ''), Tire4 = ISNULL(Tire4, ''), Tire5 = ISNULL(Tire5, ''), Tire6 = ISNULL(Tire6, ''), Tire7 = ISNULL(Tire7, ''), Tire8 = ISNULL(Tire8, ''),
OffsetMin = ISNULL(OffsetMin, ''), OffsetMax = ISNULL(OffsetMax, '')

UPDATE Fitment_PlusSizes_TEMP
SET ChassisID = REPLACE(ChassisID, '"',''),
OffsetMax = REPLACE(OffsetMax, '"', '')

UPDATE Fitment_Vehicles_TEMP
SET VehicleID = ISNULL(VehicleID, ''),
	BaseVehicleID = ISNULL(BaseVehicleID, ''), 
	YearID = ISNULL(YearID, ''), 
	MakeID = ISNULL(MakeID, ''), 
	MakeName = ISNULL(MakeName, ''), 
	ModelID = ISNULL(ModelID, ''), 
	ModelName = ISNULL(ModelName, ''), 
	SubmodelID = ISNULL(SubmodelID, ''), 
	SubmodelName = ISNULL(SubmodelName, ''), 
	DriveTypeID = ISNULL(DriveTypeID, ''), 
	DriveTypeName = ISNULL(DriveTypeName, ''), 
	BodyTypeID = ISNULL(BodyTypeID, ''), 
	BodyTypeName = ISNULL(BodyTypeName, ''), 
	BodyNumDoorsID = ISNULL(BodyNumDoorsID, ''), 
	BodyNumDoors = ISNULL(BodyNumDoors, ''), 
	BedLengthID = ISNULL(BedLengthID, ''), 
	BedLength = ISNULL(BedLength, ''), 
	VehicleTypeID = ISNULL(VehicleTypeID, ''), 
	VehicleTypeName = ISNULL(VehicleTypeName, ''), 
	RegionID = ISNULL(RegionID, ''), 
	RegionName = ISNULL(RegionName, ''), 
	FG_CustomNote = ISNULL(FG_CustomNote, ''), 
	FG_Body = ISNULL(FG_Body, ''), 
	FG_Option = ISNULL(FG_Option, ''), 
	FG_ChassisID = ISNULL(FG_ChassisID, ''), 
	FG_ModelID = ISNULL(FG_ModelID, ''), 
	FG_FMK = ISNULL(FG_FMK, '')

UPDATE Fitment_Vehicles_TEMP
SET VehicleID = REPLACE(VehicleID, '"',''),
FG_FMK = REPLACE(FG_FMK, '"', '')

UPDATE Fitment_Chassis
SET ChassisID = ISNULL(ChassisID, ''), BoltPattern = ISNULL(BoltPattern, ''), Hubbore = ISNULL(Hubbore, ''), HubboreRear = ISNULL(HubboreRear, ''),
MaxWheelLoad = ISNULL(MaxWheelLoad, ''), Nutorbolt = ISNULL(Nutorbolt, ''), NutBoltThreadType = ISNULL(NutBoltThreadType, ''),
NutBoltHex = ISNULL(NutBoltHex, ''), BoltLength = ISNULL(BoltLength, ''), Minboltlength = ISNULL(Minboltlength, ''), Maxboltlength = ISNULL(Maxboltlength, ''),
NutBoltTorque = ISNULL(NutBoltTorque, ''), 
AxleWeightFront = ISNULL(AxleWeightFront, ''),
AxleWeightRear = ISNULL(AxleWeightRear, ''), 
TPMS = ISNULL(TPMS, '')

UPDATE Fitment_ChassisModels
SET ChassisID = ISNULL(ChassisID, ''), ModelID = ISNULL(ModelID, ''), PMetric = ISNULL(PMetric, ''), TireSize = ISNULL(TireSize, ''), LoadIndex = ISNULL(LoadIndex, ''),
SpeedRating = ISNULL(SpeedRating, ''), TireSizeRear = ISNULL(TireSizeRear, ''), LoadIndexRear = ISNULL(LoadIndexRear,
''), SpeedRatingRear = ISNULL(SpeedRatingRear, ''),  WheelSize = ISNULL(WheelSize, ''),
WheelSizeRear = ISNULL(WheelSizeRear, ''), RunflatFront = ISNULL(RunflatFront,
''), RunflatRear = ISNULL(RunflatRear, ''), ExtraLoadFront = ISNULL(ExtraLoadFront, ''), ExtraLoadRear = ISNULL(ExtraLoadRear, ''), TPFrontPSI = ISNULL(TPFrontPSI,
''), TPRearPSI = ISNULL(TPRearPSI, '')
 
UPDATE Fitment_MinusSizes
SET ChassisID = ISNULL(ChassisID, ''), WheelSize = ISNULL(WheelSize, ''), TireSize = ISNULL(TireSize, ''), FrontRearOrBoth = ISNULL(FrontRearOrBoth, '')
UPDATE Fitment_PlusSizes
SET ChassisID = ISNULL(ChassisID, ''), PlusSizeType = ISNULL(PlusSizeType, ''), WheelSize = ISNULL(WheelSize, ''), Tire1 = ISNULL(Tire1, ''), Tire2 = ISNULL(Tire2, ''),
Tire3 = ISNULL(Tire3, ''), Tire4 = ISNULL(Tire4, ''), Tire5 = ISNULL(Tire5, ''), Tire6 = ISNULL(Tire6, ''), Tire7 = ISNULL(Tire7, ''), Tire8 = ISNULL(Tire8, ''),
OffsetMin = ISNULL(OffsetMin, ''), OffsetMax = ISNULL(OffsetMax, '')
UPDATE Fitment_Vehicles
SET VehicleID = ISNULL(VehicleID, ''), ChassisID = ISNULL(ChassisID, ''), ModelID = ISNULL(ModelID, ''), Year = ISNULL(Year, ''), Make = ISNULL(Make, ''),
Model = ISNULL(Model, ''), Body = ISNULL(Body, ''), [Option] = ISNULL([Option], ''), RegionName = ISNULL(RegionName, '')

	IF EXISTS (	SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='PK_Fitment_Vehicles_TEMP' ) 
		BEGIN
			ALTER TABLE [dbo].[Fitment_Vehicles_TEMP] DROP CONSTRAINT [PK_Fitment_Vehicles_TEMP]
		END

ALTER TABLE Fitment_Vehicles_TEMP ALTER COLUMN FG_FMK INT NOT NULL
ALTER TABLE Fitment_Vehicles_TEMP ALTER COLUMN FG_ModelID INT NOT NULL
ALTER TABLE Fitment_Vehicles_TEMP ALTER COLUMN FG_ChassisID INT NOT NULL

IF NOT EXISTS (	SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME='PK_Fitment_Vehicles_TEMP' ) 
BEGIN
	ALTER TABLE [dbo].[Fitment_Vehicles_TEMP] ADD  CONSTRAINT [PK_Fitment_Vehicles_TEMP] PRIMARY KEY CLUSTERED 
	(
		[FG_FMK] ASC
	)WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 75) ON [PRIMARY]
END

-- **************************
-- Convert NULL to '' END
-- **************************
-- Index
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Fitment_MinusSizes]') AND name = N'IX_Fitment_MinusSizes')
BEGIN
CREATE UNIQUE NONCLUSTERED INDEX [IX_Fitment_MinusSizes] ON [dbo].[Fitment_MinusSizes]
(
[ChassisID] ASC,
[WheelSize] ASC,
[TireSize] ASC,
[FrontRearOrBoth] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Fitment_PlusSizes]') AND name = N'IX_Fitment_PlusSizes')
BEGIN
CREATE UNIQUE NONCLUSTERED INDEX [IX_Fitment_PlusSizes] ON [dbo].[Fitment_PlusSizes]
(
[ChassisID] ASC,
[PlusSizeType] ASC,
[WheelSize] ASC,
[Tire1] ASC,
[Tire2] ASC,
[Tire3] ASC,
[Tire4] ASC,
[Tire5] ASC,
[Tire6] ASC,
[Tire7] ASC,
[Tire8] ASC,
[OffsetMin] ASC,
[OffsetMax] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END
-- Index

-- Fitment_Chassis
INSERT INTO Fitment_Chassis
(ChassisID, BoltPattern, Hubbore, HubboreRear, MaxWheelLoad, Nutorbolt, NutBoltThreadType, NutBoltHex, BoltLength, Minboltlength, Maxboltlength, NutBoltTorque,
AxleWeightFront, AxleWeightRear, TPMS)
SELECT ChassisID, BoltPattern, Hubbore, HubboreRear, MaxWheelLoad, Nutorbolt, NutBoltThreadType, NutBoltHex, BoltLength, Minboltlength, Maxboltlength, NutBoltTorque,
AxleWeightFront, AxleWeightRear, TPMS
FROM Fitment_Chassis_TEMP
WHERE (NOT (ChassisID IN
(SELECT ChassisID
FROM Fitment_Chassis AS Fitment_Chassis_1)))


-- Fitment_ChassisModels
INSERT INTO Fitment_ChassisModels
(ChassisID, ModelID, PMetric, TireSize, LoadIndex, SpeedRating,  TireSizeRear, LoadIndexRear, SpeedRatingRear, WheelSize,
WheelSizeRear, RunflatFront, RunflatRear, ExtraLoadFront, ExtraLoadRear, TPFrontPSI, TPRearPSI, OffsetMinF, OffsetMaxF, OffsetMinR, OffsetMaxR, RimWidth, RimDiameter)
SELECT ChassisID, ModelID, PMetric, TireSize, LoadIndex, SpeedRating, TireSizeRear, LoadIndexRear, SpeedRatingRear, WheelSize,
WheelSizeRear, RunflatFront, RunflatRear, ExtraLoadFront, ExtraLoadRear, TPFrontPSI, TPRearPSI, OffsetMinF, OffsetMaxF, OffsetMinR, OffsetMaxR, RimWidth, RimDiameter 
FROM Fitment_ChassisModels_TEMP
WHERE (NOT EXISTS
(
SELECT	ChassisID, ModelID, PMetric, TireSize, LoadIndex, SpeedRating, TireSizeRear, LoadIndexRear, SpeedRatingRear, WheelSize,
WheelSizeRear, RunflatFront, RunflatRear, ExtraLoadFront, ExtraLoadRear, TPFrontPSI, TPRearPSI 
FROM Fitment_ChassisModels
WHERE	((ChassisID = Fitment_ChassisModels_TEMP.ChassisID)
AND (ModelID = Fitment_ChassisModels_TEMP.ModelID))
)
)

--Fitment_MinusSizes
INSERT INTO Fitment_MinusSizes
(ChassisID, WheelSize, TireSize, FrontRearOrBoth,OffsetMin, OffsetMax)
SELECT ChassisID, WheelSize, TireSize, FrontRearOrBoth, OffsetMin, OffsetMax
FROM Fitment_MinusSizes_TEMP
WHERE (NOT EXISTS
(
SELECT	ChassisID, WheelSize, TireSize, FrontRearOrBoth
FROM Fitment_MinusSizes
WHERE	(ChassisID = Fitment_MinusSizes_TEMP.ChassisID)
AND (WheelSize = Fitment_MinusSizes_TEMP.WheelSize)
AND (TireSize = Fitment_MinusSizes_TEMP.TireSize)
AND (FrontRearOrBoth = Fitment_MinusSizes_TEMP.FrontRearOrBoth)
)
)
--Fitment_PlusSizes
INSERT INTO Fitment_PlusSizes
(ChassisID, PlusSizeType, WheelSize, Tire1, Tire2, Tire3, Tire4, Tire5, Tire6, Tire7, Tire8, OffsetMin, OffsetMax)
SELECT ChassisID, PlusSizeType, WheelSize, Tire1, Tire2, Tire3, Tire4, Tire5, Tire6, Tire7, Tire8, OffsetMin, OffsetMax
FROM Fitment_PlusSizes_TEMP
WHERE (NOT EXISTS
(
SELECT	ChassisID, PlusSizeType, WheelSize, Tire1, Tire2, Tire3, Tire4, Tire5, Tire6, Tire7, Tire8, OffsetMin, OffsetMax
FROM Fitment_PlusSizes
WHERE	(ChassisID = Fitment_PlusSizes_TEMP.ChassisID)
AND (PlusSizeType = Fitment_PlusSizes_TEMP.PlusSizeType)
AND (WheelSize = Fitment_PlusSizes_TEMP.WheelSize)
AND (Tire1 = Fitment_PlusSizes_TEMP.Tire1)
AND (Tire2 = Fitment_PlusSizes_TEMP.Tire2)
AND (Tire3 = Fitment_PlusSizes_TEMP.Tire3)
AND (Tire4 = Fitment_PlusSizes_TEMP.Tire4)
AND (Tire5 = Fitment_PlusSizes_TEMP.Tire5)
AND (Tire6 = Fitment_PlusSizes_TEMP.Tire6)
AND (Tire7 = Fitment_PlusSizes_TEMP.Tire7)
AND (Tire8 = Fitment_PlusSizes_TEMP.Tire8)
AND (OffsetMin = Fitment_PlusSizes_TEMP.OffsetMin)
AND (OffsetMax = Fitment_PlusSizes_TEMP.OffsetMax)
)
)
-- Fitment_Vehicles
----------UPDATE Fitment_Vehicles_TEMP
----------SET Body = CASE WHEN LEFT(Body, 3) LIKE '"%' THEN replace(LEFT(Body, 3), '"', '') ELSE Body END,
----------[Option] = CASE WHEN [Option] LIKE '%""%' THEN replace(replace(replace([Option], '""', '~~~'), '"', ''), '~~~', '"') ELSE [Option] END, Make = LTRIM(RTRIM(Make)),
----------Model = LTRIM(RTRIM(Model))


INSERT INTO Fitment_Vehicles (VehicleID, ChassisID, ModelID, Year, Make, Model, Body, [Option], RegionName)
SELECT FG_FMK, FG_ChassisID, FG_ModelID, YearID, MakeName, ModelName, FG_Body, FG_Option, RegionName
FROM Fitment_Vehicles_TEMP
WHERE (NOT EXISTS (SELECT VehicleID FROM Fitment_Vehicles WHERE VehicleID = Fitment_Vehicles_TEMP.FG_FMK ) )


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Fitment_Vehicles_ACES]') AND type in (N'U'))
		BEGIN
			CREATE TABLE [dbo].[Fitment_Vehicles_ACES](
				[VehicleIdOrigin] [varchar](50) NULL,
				[BaseVehicleID] [int] NULL,
				[YearID] [int] NOT NULL,
				[MakeID] [int] NULL,
				[MakeName] [varchar](100) NULL,
				[ModelID] [int] NULL,
				[ModelName] [varchar](100) NULL,
				[SubmodelID] [int] NULL,
				[SubmodelName] [varchar](100) NULL,
				[DriveTypeID] [int] NULL,
				[DriveTypeName] [varchar](100) NULL,
				[BodyTypeID] [int] NULL,
				[BodyTypeName] [varchar](100) NULL,
				[BodyNumDoorsID] [int] NULL,
				[BodyNumDoors] [varchar](100) NULL,
				[BedLengthID] [int] NULL,
				[BedLength] [varchar](100) NULL,
				[VehicleTypeID] [int] NULL,
				[VehicleTypeName] [varchar](100) NULL,
				[RegionID] [int] NULL,
				[RegionName] [varchar](100) NULL,
				[CustomNote_1010DB] [varchar](100) NULL,
				[Body_1010DB] [varchar](100) NULL,
				[Option_1010DB] [varchar](100) NULL,
				[ChassisID_1010DB] [int] NOT NULL,
				[ModelID_1010DB] [int] NOT NULL,
				[VehicleId_1010DB] [int] NOT NULL
	
			) ON [PRIMARY]
END

TRUNCATE TABLE [dbo].[Fitment_Vehicles_ACES]
INSERT INTO Fitment_Vehicles_ACES(
				[VehicleIdOrigin],
				[BaseVehicleID],
				[YearID],
				[MakeID],
				[MakeName],
				[ModelID],
				[ModelName],
				[SubmodelID],
				[SubmodelName],
				[DriveTypeID],
				[DriveTypeName],
				[BodyTypeID],
				[BodyTypeName],
				[BodyNumDoorsID],
				[BodyNumDoors],
				[BedLengthID],
				[BedLength],
				[VehicleTypeID],
				[VehicleTypeName],
				[RegionID],
				[RegionName],
				[CustomNote_1010DB],
				[Body_1010DB],
				[Option_1010DB],
				[ChassisID_1010DB],
				[ModelID_1010DB],
				[VehicleId_1010DB] )
SELECT        VehicleID, BaseVehicleID, YearID, MakeID, MakeName, ModelID, ModelName, SubmodelID, SubmodelName, DriveTypeID, DriveTypeName, BodyTypeID, BodyTypeName, BodyNumDoorsID, BodyNumDoors, 
                         BedLengthID, BedLength, VehicleTypeID, VehicleTypeName, RegionID, RegionName, FG_CustomNote, FG_Body, FG_Option, FG_ChassisID, FG_ModelID, FG_FMK
FROM            Fitment_Vehicles_TEMP

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Fitment_Vehicles_ACES]') AND name = N'PK_Fitment_Vehicles_ACES')
	BEGIN
		ALTER TABLE [dbo].[Fitment_Vehicles_ACES] ADD  CONSTRAINT [PK_Fitment_Vehicles_ACES] PRIMARY KEY CLUSTERED 
		(
			[VehicleId_1010DB] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Fitment_Vehicles_ACES]') AND name = N'INDX_BaseVehicleID_Fitment_Vehicles_ACES')
	BEGIN
		CREATE NONCLUSTERED INDEX [INDX_BaseVehicleID_Fitment_Vehicles_ACES] ON [dbo].[Fitment_Vehicles_ACES]
		(
			[BaseVehicleID] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Fitment_Vehicles_ACES]') AND name = N'INDX_BodyTypeID_Fitment_Vehicles_ACES')
	BEGIN
		CREATE NONCLUSTERED INDEX [INDX_BodyTypeID_Fitment_Vehicles_ACES] ON [dbo].[Fitment_Vehicles_ACES]
		(
			[BodyTypeID] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Fitment_Vehicles_ACES]') AND name = N'INDX_MakeID_Fitment_Vehicles_ACES')
	BEGIN
		CREATE NONCLUSTERED INDEX [INDX_MakeID_Fitment_Vehicles_ACES] ON [dbo].[Fitment_Vehicles_ACES]
		(
			[MakeID] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	END


IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Fitment_Vehicles_ACES]') AND name = N'INDX_ModelID_Fitment_Vehicles_ACES')
	BEGIN
		CREATE NONCLUSTERED INDEX [INDX_ModelID_Fitment_Vehicles_ACES] ON [dbo].[Fitment_Vehicles_ACES]
		(
			[ModelID] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Fitment_Vehicles_ACES]') AND name = N'INDX_ModelID_Fitment_Vehicles_ACES')
	BEGIN
		CREATE NONCLUSTERED INDEX [INDX_SubmodelID_Fitment_Vehicles_ACES] ON [dbo].[Fitment_Vehicles_ACES]
		(
			[SubmodelID] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END


-- Remove old formats TireSize and clean data in Fitment_* tables, BEGIN

DELETE FROM [1010Tires].dbo.Fitment_Vehicles
WHERE     (Year < '1990')

DELETE FROM Fitment_ChassisModels
WHERE     (TireSize NOT LIKE '%/%R%') AND (TireSize NOT LIKE '%x%R%')

DELETE FROM Fitment_MinusSizes
WHERE     (TireSize NOT LIKE '%/%R%') AND (TireSize NOT LIKE '%x%R%')


DELETE FROM [1010Tires].dbo.Fitment_Chassis
WHERE     (BoltPattern NOT LIKE '%x%')

DELETE FROM [1010Tires].dbo.Fitment_Chassis
WHERE     (isnumeric(Hubbore) = 0)

DELETE FROM Fitment_MinusSizes
WHERE     (WheelSize = '6x115')

UPDATE    Fitment_ChassisModels
SET              TireSizeRear = ''
FROM         Fitment_ChassisModels INNER JOIN
                      Fitment_Chassis AS c ON Fitment_ChassisModels.ChassisID = c.ChassisID
WHERE     (Fitment_ChassisModels.TireSizeRear <> '') AND (Fitment_ChassisModels.WheelSizeRear = '') AND 
                      (Fitment_ChassisModels.TireSize = Fitment_ChassisModels.TireSizeRear)

DELETE FROM Fitment_ChassisModels
FROM         Fitment_ChassisModels INNER JOIN
                      Fitment_Chassis AS c ON Fitment_ChassisModels.ChassisID = c.ChassisID
WHERE     (Fitment_ChassisModels.TireSizeRear <> '') AND (Fitment_ChassisModels.WheelSizeRear = '')
                      

DELETE FROM Fitment_Vehicles
FROM         Fitment_Vehicles LEFT OUTER JOIN
                      Fitment_ChassisModels ON Fitment_Vehicles.ChassisID = Fitment_ChassisModels.ChassisID AND 
                      Fitment_Vehicles.ModelID = Fitment_ChassisModels.ModelID
WHERE     (Fitment_ChassisModels.ChassisID IS NULL) AND (Fitment_ChassisModels.ModelID IS NULL)

DELETE FROM Fitment_Chassis
FROM         Fitment_Chassis LEFT OUTER JOIN
                      Fitment_Vehicles ON Fitment_Chassis.ChassisID = Fitment_Vehicles.ChassisID
WHERE     (Fitment_Vehicles.ChassisID IS NULL)

DELETE FROM Fitment_Vehicles
FROM         Fitment_Vehicles LEFT OUTER JOIN
                      Fitment_Chassis ON Fitment_Vehicles.ChassisID = Fitment_Chassis.ChassisID
WHERE     (Fitment_Chassis.ChassisID IS NULL)


DELETE FROM Fitment_ChassisModels
FROM         Fitment_ChassisModels LEFT OUTER JOIN
                      Fitment_Chassis ON Fitment_ChassisModels.ChassisID = Fitment_Chassis.ChassisID
WHERE     (Fitment_Chassis.ChassisID IS NULL) 


-- Remove old formats TireSize and clean data in Fitment_* tables, END

TRUNCATE TABLE Fitment_Actual_VehiclesID

INSERT INTO Fitment_Actual_VehiclesID
(VehicleID)
SELECT DISTINCT [FG_FMK]
FROM Fitment_Vehicles_TEMP
ORDER BY [FG_FMK]




-- CSV processing, END ---
-- ##################################################################################################################
-- ##################################################################################################################
-- II. Update TrimName in [1010Tires] DB. Synchronizing it with MASTER DB (csv files).
UPDATE [1010Tires].dbo.Vehicle
SET TrimName = [1010Tires].dbo.Fitment_Vehicles.Body + N' ' + [1010Tires].dbo.Fitment_Vehicles.[Option]
FROM [1010Tires].dbo.Fitment_Vehicles INNER JOIN
[1010Tires].dbo.Vehicle ON [1010Tires].dbo.Fitment_Vehicles.VehicleID = [1010Tires].dbo.Vehicle.VehicleID
UPDATE [1010Tires].dbo.Vehicle
SET TrimName = N'4 Dr Sport Utility LS 16" option'
WHERE (VehicleID = 52261)
-- Fix issue with BoltPattern field in Fitment_Chassis table
UPDATE [1010Tires].[dbo].Fitment_Chassis
SET BoltPattern = SUBSTRING (BoltPattern ,1,CHARINDEX('/',BoltPattern)-1)
WHERE (BoltPattern LIKE '%x%/%x%')
UPDATE [1010Tires].[dbo].Fitment_Chassis
SET BoltPattern = REPLACE(BoltPattern,'/' ,'x')
WHERE (BoltPattern LIKE '%/%')
-- Fix issue with BoltPattern field in Fitment_Chassis table

-- ##################################################################################################################
-- Make data correction 12.08.2015, BEGIN

	UPDATE    Fitment_ChassisModels
	SET              TireSize = SUBSTRING(TireSize, 1, LEN(TireSize) - 1)
	WHERE     (TireSize LIKE '%/%R%C')

	UPDATE    Fitment_MinusSizes
	SET              TireSize = SUBSTRING(TireSize, 1, LEN(TireSize) - 1)
	WHERE     (TireSize LIKE '%/%R%C')
	
	UPDATE    Fitment_ChassisModels
	SET              SpeedRatingRear = 'W'
	WHERE     (SpeedRatingRear = 'WE')

-- Make data correction 12.08.2015, END
-- ##################################################################################################################

-- ##################################################################################################################
-- Make data correction 24.11.2016, BEGIN

--PRINT 'UPDATE Fitment_ChassisModels SET LoadIndex = CASE '

UPDATE Fitment_ChassisModels
SET LoadIndex = 
CASE Fitment_ChassisModels.LoadIndex
         WHEN 'D' THEN 65
         WHEN 'E' THEN 80
         WHEN 'B' THEN 60
		 WHEN 'C' THEN 63
		 WHEN 'A' THEN 60
         ELSE Fitment_ChassisModels.LoadIndex END, 
	LoadIndexRear = 
CASE Fitment_ChassisModels.LoadIndexRear
			 WHEN 'D' THEN 65
			 WHEN 'E' THEN 80
			 WHEN 'B' THEN 60
			 WHEN 'C' THEN 63
			 WHEN 'A' THEN 60
			 ELSE Fitment_ChassisModels.LoadIndexRear END

UPDATE Fitment_ChassisModels
SET Fitment_ChassisModels.LoadIndexRear =
	CASE WHEN  [TireSizeRear] = '' OR [TireSizeRear] IS NULL OR [TireSizeRear] = [TireSize] THEN Fitment_ChassisModels.LoadIndex ELSE Fitment_ChassisModels.LoadIndexRear END

-- Make data correction 24.11.2016, END
-- ##################################################################################################################


-------- TESTING VehicleID =135138, BEGIN

------		DELETE FROM Fitment_Vehicles
------		WHERE     (VehicleID <> 135138)

-------- TESTING VehicleID =135138, END

-- ##################################################################################################################
-- ##################################################################################################################


IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
	BEGIN
		COMMIT TRANSACTION
		--PRINT 0
	END


DECLARE @Vehicles_ID TABLE (VehicleID INT PRIMARY KEY);
DECLARE @VerifyComplianceLocalVendorData BIT = 1

VerifyComplianceLocalVendorData_Label:

---- III. Add new data into 1010Tires
---- AddVehicles.sql
-- spIntegrationScripts_AddVehiclesNewData
-- 1. AddVehicles.sql +++
declare
@Year int
, @MakeID int = null
, @Model nvarchar(75)
, @Make nvarchar(75)
, @ModelID int-- = null
, @TrimName nvarchar(MAX)
, @ChassisID int
, @VehicleID INT
, @TireSize varchar(max)
, @TireSizeRear varchar(max)
, @Treadwidth int
, @Profile int
, @TireWheelDiam int
, @WheelDiam int
, @WheelWidth float

, @WheelSizeRear float

, @HubBore float
, @FrontConfigID int
, @RearConfigID int
, @MXVehicleID INT

DECLARE @cursor_AddVehicles CURSOR


IF @VerifyComplianceLocalVendorData = 1
	BEGIN
		IF @AddNewDataOnly = 0
			BEGIN
				SET @cursor_AddVehicles = CURSOR FOR
				SELECT DISTINCT 
				VehicleID
				, [Year]
				, Make
				, Model
				--,[Option]
				, case when left(Body, 3) like '"%' then replace(left(Body, 3), '"', '') else Body end
				+ ' '
				+ case when [Option] like '%""%' then replace(replace(replace([Option], '""', '~~~'), '"', ''), '~~~', '"') else [Option] end
				, ModelID
				, ChassisID
				FROM Fitment_Vehicles fv
				where 
				-- Vehicleid not in (select Vehicleid from Vehicle) AND 
				(Year >= '1990')
				AND Vehicleid in (select Vehicleid from Fitment_Actual_VehiclesID)
				--AND Vehicleid  IN (17777)
			END
		ELSE
			BEGIN
				SET @cursor_AddVehicles = CURSOR FOR
				SELECT DISTINCT 
				VehicleID
				, [Year]
				, Make
				, Model
				--,[Option]
				, case when left(Body, 3) like '"%' then replace(left(Body, 3), '"', '') else Body end
				+ ' '
				+ case when [Option] like '%""%' then replace(replace(replace([Option], '""', '~~~'), '"', ''), '~~~', '"') else [Option] end
				, ModelID
				, ChassisID
				FROM Fitment_Vehicles fv
				where 
				-- Vehicleid not in (select Vehicleid from Vehicle) AND 
				(Year >= '1990')
				AND Vehicleid IN (select Fitment_Actual_VehiclesID.Vehicleid from Fitment_Actual_VehiclesID LEFT JOIN Vehicle ON Fitment_Actual_VehiclesID.VehicleID = Vehicle.VehicleID WHERE Vehicle.VehicleID IS NULL)
				--AND Vehicleid  IN (17777)
			END
	END
ELSE
	BEGIN -- @VerifyComplianceLocalVendorData = 0
		SET @cursor_AddVehicles = CURSOR FOR
		SELECT DISTINCT 
		VehicleID
		, [Year]
		, Make
		, Model
		--,[Option]
		, case when left(Body, 3) like '"%' then replace(left(Body, 3), '"', '') else Body end
		+ ' '
		+ case when [Option] like '%""%' then replace(replace(replace([Option], '""', '~~~'), '"', ''), '~~~', '"') else [Option] end
		, ModelID
		, ChassisID
		FROM Fitment_Vehicles fv
		where 
		-- Vehicleid not in (select Vehicleid from Vehicle) AND 
		(Year >= '1990')
		AND Vehicleid in (select Vehicleid from @Vehicles_ID)

	END


OPEN @cursor_AddVehicles


WHILE 1 = 1
BEGIN
FETCH NEXT FROM @cursor_AddVehicles INTO
@VehicleID
, @Year
, @Make
, @Model
, @TrimName
, @ModelID
, @ChassisID
IF @@FETCH_STATUS <> 0 BREAK


IF NOT EXISTS (SELECT Vehicleid FROM Vehicle WHERE Vehicleid = @VehicleID)
	BEGIN
		insert into dbo.[Vehicle] (VehicleID, FitmentDataDBYearID, FitmentDataDBModelID, MakeName, ModelName, TrimName, Published, Status, DateCreatedUTC, DateModifiedUTC)
		values	(@VehicleID, @Year, @ModelID, ltrim(rtrim(@Make)), ltrim(rtrim(@Model)), @TrimName, 1, 1, getutcdate(), getutcdate())
	END


DECLARE @TireSize_Metric_Inch_Sign char

select
  @TireSize = TireSize
, @TireSizeRear = TireSizeRear
, @WheelSizeRear = CASE WHEN LEN(WheelSizeRear)>0 THEN CAST(LTRIM(RTRIM(LEFT(WheelSizeRear, CHARINDEX('x', WheelSizeRear, 1) - 1))) AS float) ELSE CAST(LTRIM(RTRIM(LEFT(WheelSize, CHARINDEX('x', WheelSize, 1) - 1))) AS float) END
from Fitment_ChassisModels
where ModelID = @ModelID AND ChassisID = @ChassisID

DECLARE @Search_IsStaggeredFitmentFlag BIT -- 1 - different, 0 - same, RearOEMTireAndWheelConfigID IS NULL

IF @TireSizeRear = '' OR @TireSize = @TireSizeRear
	BEGIN
		SET @Search_IsStaggeredFitmentFlag = 0
	END
ELSE
	BEGIN
		SET @Search_IsStaggeredFitmentFlag = 1
	END

if @TireSize like '%x%' 
	BEGIN
		SET @TireSize_Metric_Inch_Sign= 'x'
	END
ELSE
	BEGIN
		SET @TireSize_Metric_Inch_Sign= '/'
	END
	
-- Check records in [VehicleOEMTireAndWheelConfig] for front axle, find out @FrontConfigID


DECLARE @Search_Treadwidth float
DECLARE @Search_Profile float
DECLARE @Search_TireRimDiameter float
DECLARE @Search_LoadIndex float
DECLARE @Search_SpeedRating nvarchar(MAX)
DECLARE @Search_WheelDiameter float
DECLARE @Search_WheelWidth float
DECLARE @Search_HubBore float

DECLARE @Search_TreadwidthRear float
DECLARE @Search_ProfileRear float
DECLARE @Search_TireRimDiameterRear float
DECLARE @Search_LoadIndexRear float
DECLARE @Search_SpeedRatingRear nvarchar(MAX)
DECLARE @Search_WheelDiameterRear float
DECLARE @Search_WheelWidthRear float
DECLARE @Search_HubBoreRear float



SET @FrontConfigID = NULL
SET @RearConfigID = NULL

-- Set all variables to search
SELECT     
		@Search_Treadwidth = CAST(LTRIM(RTRIM(LEFT(CM.TireSize, CHARINDEX(@TireSize_Metric_Inch_Sign, CM.TireSize, 1) - 1))) AS float) -- AS Treadwidth
		, @Search_Profile = CAST(LTRIM(RTRIM(SUBSTRING(CM.TireSize, CHARINDEX(@TireSize_Metric_Inch_Sign, CM.TireSize, 1) + 1, CHARINDEX('R', CM.TireSize, CHARINDEX(@TireSize_Metric_Inch_Sign, CM.TireSize, 1) + 1) - CHARINDEX(@TireSize_Metric_Inch_Sign, CM.TireSize, 1) - 1))) AS float) -- AS Profile
		, @Search_TireRimDiameter = CAST(LTRIM(RTRIM(RIGHT(CM.TireSize, LEN(CM.TireSize) - CHARINDEX('R', CM.TireSize, CHARINDEX(@TireSize_Metric_Inch_Sign, CM.TireSize, 1) + 1)))) AS float) -- AS TireRimDiameter
		, @Search_LoadIndex = CASE WHEN isnumeric(Loadindex) <> 1 THEN 0 ELSE CAST(LoadIndex AS float) END -- AS LoadIndex
		, @Search_SpeedRating = CM.SpeedRating -- AS SpeedRating
		, @Search_SpeedRatingRear = CASE WHEN LEN(CM.SpeedRatingRear)>0 THEN CM.SpeedRatingRear ELSE CM.SpeedRating END -- AS SpeedRating
		, @Search_WheelDiameter = CAST(LTRIM(RTRIM(RIGHT(CM.WheelSize, LEN(CM.WheelSize) - CHARINDEX('x', CM.WheelSize, 1)))) AS float) -- AS WheelDiameter
		, @Search_WheelWidth = CAST(LTRIM(RTRIM(LEFT(CM.WheelSize, CHARINDEX('x', CM.WheelSize, 1) - 1))) AS float) -- AS WheelWidth
		, @Search_WheelWidthRear = CASE WHEN LEN(CM.WheelSizeRear)= 0 THEN CAST(LTRIM(RTRIM(LEFT(CM.WheelSize, CHARINDEX('x', CM.WheelSize, 1) - 1))) AS float) ELSE CAST(LTRIM(RTRIM(LEFT(CM.WheelSizeRear, CHARINDEX('x', CM.WheelSizeRear, 1) - 1))) AS float) END -- AS WheelWidthRear
		, @Search_HubBore = CAST(ltrim(rtrim(C.Hubbore)) AS float) -- AS Hubbore 
		, @Search_HubBoreRear  = CASE WHEN CAST(ltrim(rtrim(C.HubboreRear)) AS float) = 0 THEN CAST(ltrim(rtrim(C.Hubbore)) AS float) ELSE CAST(ltrim(rtrim(C.HubboreRear)) AS float) END -- AS Hubbore 
FROM	Fitment_ChassisModels AS CM INNER JOIN Fitment_Chassis AS C ON CM.ChassisID = C.ChassisID
where CM.ModelID = @ModelID AND CM.ChassisID = @ChassisID


IF @TireSizeRear = '' --AND @WheelSizeRear = ''
	BEGIN
		 
		IF @WheelSizeRear = ''
			BEGIN
				IF EXISTS (
							SELECT     OEMTireAndWheelConfigID 
							FROM         VehicleOEMTireAndWheelConfig
							WHERE     (IsFrontFlag = 1) AND (IsRearFlag = 1) AND  (Treadwidth = @Search_Treadwidth) AND (Profile = @Search_Profile) AND (TireRimDiameter = @Search_TireRimDiameter) AND (LoadIndex = @Search_LoadIndex) AND (SpeedRating = @Search_SpeedRating) AND (WheelDiameter = @Search_WheelDiameter) AND (WheelWidth = @Search_WheelWidth) AND (HubBore = @Search_HubBore)
							)	
					BEGIN
						-- there is a record, take @FrontConfigID
						SELECT     @FrontConfigID = OEMTireAndWheelConfigID 
						FROM         VehicleOEMTireAndWheelConfig
						WHERE     (IsFrontFlag = 1) AND (IsRearFlag = 1) AND (Treadwidth = @Search_Treadwidth) AND (Profile = @Search_Profile) AND (TireRimDiameter = @Search_TireRimDiameter) AND (LoadIndex = @Search_LoadIndex) AND (SpeedRating = @Search_SpeedRating) AND (WheelDiameter = @Search_WheelDiameter) AND (WheelWidth = @Search_WheelWidth) AND (HubBore = @Search_HubBore)

						SET @RearConfigID = @FrontConfigID
				
						--IF @FrontConfigID IS NULL
						--	BEGIN
						--		PRINT '@FrontConfigID IS NULL'
						--	END
				

					END
				ELSE
					BEGIN
			
						--IF @Search_HubBore IS NULL
						--	BEGIN
						--		PRINT '@Search_HubBore IS NULL'
						--	END
			
						-- no record, write a new, take @FrontConfigID = @@IDENTITY
						insert into dbo.[VehicleOEMTireAndWheelConfig] (IsFrontFlag, IsRearFlag, Treadwidth, Profile, TireRimDiameter, LoadIndex, SpeedRating, WheelDiameter, WheelWidth, HubBore, DateCreatedUTC, DateModifiedUTC)
						select 
							  1
							, 1
							, @Search_Treadwidth
							, @Search_Profile
							, @Search_TireRimDiameter
							, @Search_LoadIndex
							, @Search_SpeedRating
							, @Search_WheelDiameter
							, @Search_WheelWidth
							, @Search_HubBore
							, getutcdate()
							, getutcdate()
							from Fitment_ChassisModels cm inner join dbo.Fitment_Chassis c on cm.ChassisID = c.ChassisID
							WHERE	(cm.ModelID = @ModelID)
			
							SET @FrontConfigID = @@IDENTITY
							SET @RearConfigID = @FrontConfigID


						--IF @FrontConfigID IS NULL
						--	BEGIN
						--		PRINT '@FrontConfigID IS NULL'
						--	END
				


					END
				END
			ELSE
				BEGIN
					-- FrontConfigID processing, BEGIN
					----------------------------------------------------------------------
						IF EXISTS (
									SELECT     OEMTireAndWheelConfigID 
									FROM         VehicleOEMTireAndWheelConfig
									WHERE     (IsFrontFlag = 1) AND (IsRearFlag = 1) AND  (Treadwidth = @Search_Treadwidth) AND (Profile = @Search_Profile) AND (TireRimDiameter = @Search_TireRimDiameter) AND (LoadIndex = @Search_LoadIndex) AND (SpeedRating = @Search_SpeedRating) AND (WheelDiameter = @Search_WheelDiameter) AND (WheelWidth = @Search_WheelWidth) AND (HubBore = @Search_HubBore)
									)	
							BEGIN
								-- there is a record, take @FrontConfigID
								SELECT     @FrontConfigID = OEMTireAndWheelConfigID 
								FROM         VehicleOEMTireAndWheelConfig
								WHERE     (IsFrontFlag = 1) AND (IsRearFlag = 1) AND (Treadwidth = @Search_Treadwidth) AND (Profile = @Search_Profile) AND (TireRimDiameter = @Search_TireRimDiameter) AND (LoadIndex = @Search_LoadIndex) AND (SpeedRating = @Search_SpeedRating) AND (WheelDiameter = @Search_WheelDiameter) AND (WheelWidth = @Search_WheelWidth) AND (HubBore = @Search_HubBore)

								--SET @RearConfigID = @FrontConfigID
				
								--IF @FrontConfigID IS NULL
								--	BEGIN
								--		PRINT '@FrontConfigID IS NULL'
								--	END
				

							END
						ELSE
							BEGIN
			
								--IF @Search_HubBore IS NULL
								--	BEGIN
								--		PRINT '@Search_HubBore IS NULL'
								--	END
			
								-- no record, write a new, take @FrontConfigID = @@IDENTITY
								insert into dbo.[VehicleOEMTireAndWheelConfig] (IsFrontFlag, IsRearFlag, Treadwidth, Profile, TireRimDiameter, LoadIndex, SpeedRating, WheelDiameter, WheelWidth, HubBore, DateCreatedUTC, DateModifiedUTC)
								select 
									  1
									, 1
									, @Search_Treadwidth
									, @Search_Profile
									, @Search_TireRimDiameter
									, @Search_LoadIndex
									, @Search_SpeedRating
									, @Search_WheelDiameter
									, @Search_WheelWidth
									, @Search_HubBore
									, getutcdate()
									, getutcdate()
									from Fitment_ChassisModels cm inner join dbo.Fitment_Chassis c on cm.ChassisID = c.ChassisID
									WHERE	(cm.ModelID = @ModelID)
			
									SET @FrontConfigID = @@IDENTITY
									--SET @RearConfigID = @FrontConfigID


								--IF @FrontConfigID IS NULL
								--	BEGIN
								--		PRINT '@FrontConfigID IS NULL'
								--	END
				


							END


					----------------------------------------------------------------------
					-- FrontConfigID processing, END



					-- @RearConfigID processing, BEGIN
					----------------------------------------------------------------------

						IF EXISTS (
									SELECT     OEMTireAndWheelConfigID 
									FROM         VehicleOEMTireAndWheelConfig
									WHERE     (IsFrontFlag = 1) AND (IsRearFlag = 1) AND  (Treadwidth = @Search_Treadwidth) AND (Profile = @Search_Profile) AND (TireRimDiameter = @Search_TireRimDiameter) AND (LoadIndex = @Search_LoadIndex) AND (SpeedRating = @Search_SpeedRatingRear) AND (WheelDiameter = @Search_WheelDiameter) AND (WheelWidth = @Search_WheelWidthRear) AND (HubBore = @Search_HubBoreRear)
									)	
							BEGIN
								-- there is a record, take @FrontConfigID
								SELECT     @RearConfigID = OEMTireAndWheelConfigID 
								FROM         VehicleOEMTireAndWheelConfig
								WHERE     (IsFrontFlag = 1) AND (IsRearFlag = 1) AND (Treadwidth = @Search_Treadwidth) AND (Profile = @Search_Profile) AND (TireRimDiameter = @Search_TireRimDiameter) AND (LoadIndex = @Search_LoadIndex) AND (SpeedRating = @Search_SpeedRatingRear) AND (WheelDiameter = @Search_WheelDiameter) AND (WheelWidth = @Search_WheelWidthRear) AND (HubBore = @Search_HubBoreRear)

							END
						ELSE
							BEGIN
			
								-- no record, write a new, take @FrontConfigID = @@IDENTITY
								insert into dbo.[VehicleOEMTireAndWheelConfig] (IsFrontFlag, IsRearFlag, Treadwidth, Profile, TireRimDiameter, LoadIndex, SpeedRating, WheelDiameter, WheelWidth, HubBore, DateCreatedUTC, DateModifiedUTC)
								select 
									  1
									, 1
									, @Search_Treadwidth
									, @Search_Profile
									, @Search_TireRimDiameter
									, @Search_LoadIndex
									, @Search_SpeedRatingRear
									, @Search_WheelDiameter
									, @Search_WheelWidthRear 
									, @Search_HubBoreRear
									, getutcdate()
									, getutcdate()
									from Fitment_ChassisModels cm inner join dbo.Fitment_Chassis c on cm.ChassisID = c.ChassisID
									WHERE	(cm.ModelID = @ModelID)
			
									SET @RearConfigID = @@IDENTITY
									--SET @RearConfigID = @FrontConfigID


							END

					----------------------------------------------------------------------
					-- @RearConfigID processing, END



				END


	END 

		
ELSE -- IF @TireSizeRear = '' AND @WheelSizeRear = ''


	BEGIN
-- Front axle, BEGIN

		IF EXISTS (
					SELECT     OEMTireAndWheelConfigID 
					FROM         VehicleOEMTireAndWheelConfig
					WHERE     (IsFrontFlag = 1) AND (IsRearFlag = 0) AND  (Treadwidth = @Search_Treadwidth) AND (Profile = @Search_Profile) AND (TireRimDiameter = @Search_TireRimDiameter) AND (LoadIndex = @Search_LoadIndex) AND (SpeedRating = @Search_SpeedRating) AND (WheelDiameter = @Search_WheelDiameter) AND (WheelWidth = @Search_WheelWidth) AND (HubBore = @Search_HubBore)
					)	
			BEGIN
				-- there is a line, take @FrontConfigID
				SELECT     @FrontConfigID = OEMTireAndWheelConfigID 
				FROM         VehicleOEMTireAndWheelConfig
				WHERE     (IsFrontFlag = 1) AND (IsRearFlag = 0) AND (Treadwidth = @Search_Treadwidth) AND (Profile = @Search_Profile) AND (TireRimDiameter = @Search_TireRimDiameter) AND (LoadIndex = @Search_LoadIndex) AND (SpeedRating = @Search_SpeedRating) AND (WheelDiameter = @Search_WheelDiameter) AND (WheelWidth = @Search_WheelWidth) AND (HubBore = @Search_HubBore)


			END
		ELSE
			BEGIN


				-- no record, write a new record, take @FrontConfigID = @@IDENTITY
				insert into dbo.[VehicleOEMTireAndWheelConfig] (IsFrontFlag, IsRearFlag, Treadwidth, Profile, TireRimDiameter, LoadIndex, SpeedRating, WheelDiameter, WheelWidth, HubBore, DateCreatedUTC, DateModifiedUTC)
				select 
					  1
					, 0
					, @Search_Treadwidth
					, @Search_Profile
					, @Search_TireRimDiameter
					, @Search_LoadIndex
					, @Search_SpeedRating
					, @Search_WheelDiameter
					, @Search_WheelWidth
					, @Search_HubBore
					, getutcdate()
					, getutcdate()
			
					SET @FrontConfigID = @@IDENTITY
					

			END
	--END

-- Front axle, END

-- Rear axle, BEGIN

-- Set variables to search, Rear axle
SELECT     
		@Search_Treadwidth = CAST(LTRIM(RTRIM(LEFT(CASE WHEN CM.TireSizeRear='' THEN CM.TireSize  ELSE CM.TireSizeRear END, CHARINDEX(@TireSize_Metric_Inch_Sign, CASE WHEN CM.TireSizeRear='' THEN CM.TireSize  ELSE CM.TireSizeRear END, 1) - 1))) AS float) -- AS Treadwidth
		, @Search_Profile = CAST(LTRIM(RTRIM(SUBSTRING(CASE WHEN CM.TireSizeRear='' THEN CM.TireSize  ELSE CM.TireSizeRear END, CHARINDEX(@TireSize_Metric_Inch_Sign, CASE WHEN CM.TireSizeRear='' THEN CM.TireSize  ELSE CM.TireSizeRear END, 1) + 1, CHARINDEX('R', CASE WHEN CM.TireSizeRear='' THEN CM.TireSize  ELSE CM.TireSizeRear END, CHARINDEX(@TireSize_Metric_Inch_Sign, CASE WHEN CM.TireSizeRear='' THEN CM.TireSize  ELSE CM.TireSizeRear END, 1) + 1) - CHARINDEX(@TireSize_Metric_Inch_Sign, CASE WHEN CM.TireSizeRear='' THEN CM.TireSize  ELSE CM.TireSizeRear END, 1) - 1))) AS float) -- AS Profile
		, @Search_TireRimDiameter = CAST(LTRIM(RTRIM(RIGHT(CASE WHEN CM.TireSizeRear='' THEN CM.TireSize  ELSE CM.TireSizeRear END, LEN(CASE WHEN CM.TireSizeRear='' THEN CM.TireSize  ELSE CM.TireSizeRear END) - CHARINDEX('R', CASE WHEN CM.TireSizeRear='' THEN CM.TireSize  ELSE CM.TireSizeRear END, CHARINDEX(@TireSize_Metric_Inch_Sign, CASE WHEN CM.TireSizeRear='' THEN CM.TireSize  ELSE CM.TireSizeRear END, 1) + 1)))) AS float) -- AS TireRimDiameter
		, @Search_LoadIndex = CASE WHEN isnumeric(LoadIndexRear) <> 1 THEN 0 ELSE CAST(LoadIndexRear AS float) END -- AS LoadIndex
		, @Search_SpeedRating = CASE WHEN CM.SpeedRatingRear = '' THEN CM.SpeedRating ELSE CM.SpeedRatingRear END --  CM.SpeedRatingRear -- AS SpeedRating
		, @Search_WheelDiameter = CASE WHEN LEN(CM.WheelSizeRear) > 0 THEN CAST(LTRIM(RTRIM(RIGHT(CM.WheelSizeRear, LEN(CM.WheelSizeRear) - CHARINDEX('x', CM.WheelSizeRear, 1)))) AS float) ELSE CAST(LTRIM(RTRIM(RIGHT(CM.WheelSize, LEN(CM.WheelSize) - CHARINDEX('x', CM.WheelSize, 1)))) AS float) END -- AS WheelDiameter
		--, @Search_WheelWidth = CAST(LTRIM(RTRIM(LEFT(CM.WheelSizeRear, CHARINDEX('x', CM.WheelSizeRear, 1) - 1))) AS float) -- AS WheelWidth
		, @Search_WheelWidthRear  = CASE WHEN LEN(WheelSizeRear) = 0 THEN CAST(LTRIM(RTRIM(LEFT(CM.WheelSize, CHARINDEX('x', CM.WheelSize, 1) - 1))) AS float) ELSE CAST(LTRIM(RTRIM(LEFT(CM.WheelSizeRear, CHARINDEX('x', CM.WheelSizeRear, 1) - 1))) AS float) END --  -- AS WheelWidthRear
		, @Search_HubBore =  CASE WHEN CAST(ltrim(rtrim(C.HubboreRear)) AS float) = 0 THEN CAST(ltrim(rtrim(C.Hubbore)) AS float) ELSE CAST(ltrim(rtrim(C.HubboreRear)) AS float) END -- AS Hubbore 
FROM	Fitment_ChassisModels AS CM INNER JOIN Fitment_Chassis AS C ON CM.ChassisID = C.ChassisID
where CM.ModelID = @ModelID AND CM.ChassisID = @ChassisID

		SET @Search_TreadwidthRear = @Search_Treadwidth
		SET @Search_ProfileRear = @Search_Profile
		SET @Search_TireRimDiameterRear = @Search_TireRimDiameter
		SET @Search_LoadIndexRear = @Search_LoadIndex
		SET @Search_SpeedRatingRear = @Search_SpeedRating
		SET @Search_WheelDiameterRear = @Search_WheelDiameter
		SET @Search_HubBoreRear = @Search_HubBore
		

		IF EXISTS (
					SELECT     OEMTireAndWheelConfigID 
					FROM         VehicleOEMTireAndWheelConfig
					WHERE     (IsFrontFlag = 0) AND (IsRearFlag = 1) AND  (Treadwidth = @Search_Treadwidth) AND (Profile = @Search_Profile) AND (TireRimDiameter = @Search_TireRimDiameter) AND (LoadIndex = @Search_LoadIndex) AND (SpeedRating = @Search_SpeedRating) AND (WheelDiameter = @Search_WheelDiameter) AND (WheelWidth = @Search_WheelWidthRear) AND (HubBore = @Search_HubBore)
					)	
			BEGIN
				-- there is a record, take @RearConfigID
				SELECT     @RearConfigID = OEMTireAndWheelConfigID 
				FROM         VehicleOEMTireAndWheelConfig
				WHERE     (IsFrontFlag = 0) AND (IsRearFlag = 1) AND (Treadwidth = @Search_Treadwidth) AND (Profile = @Search_Profile) AND (TireRimDiameter = @Search_TireRimDiameter) AND (LoadIndex = @Search_LoadIndex) AND (SpeedRating = @Search_SpeedRating) AND (WheelDiameter = @Search_WheelDiameter) AND (WheelWidth = @Search_WheelWidthRear) AND (HubBore = @Search_HubBore)

			END
		ELSE
			BEGIN
				-- no record, write a new record, take @RearConfigID = @@IDENTITY

				insert into dbo.[VehicleOEMTireAndWheelConfig] (IsFrontFlag, IsRearFlag, Treadwidth, Profile, TireRimDiameter, LoadIndex, SpeedRating, WheelDiameter, WheelWidth, HubBore, DateCreatedUTC, DateModifiedUTC)
				select 
					  0
					, 1
					, @Search_Treadwidth
					, @Search_Profile
					, @Search_TireRimDiameter
					, @Search_LoadIndex
					, @Search_SpeedRating
					, @Search_WheelDiameter
					, @Search_WheelWidthRear
					, @Search_HubBore
					, getutcdate()
					, getutcdate()
					--from Fitment_ChassisModels cm inner join dbo.Fitment_Chassis c on cm.ChassisID = c.ChassisID
					--WHERE	(cm.ModelID = @ModelID)
			
					SET @RearConfigID = @@IDENTITY
 
			END  -- IF EXISTS ELSE

-- Rear axle, END

	END  -- ELSE -- IF @TireSizeRear = ''
	

-- Check entries in [VehicleOEMPackage], BEGIN

-- Create variables for search, BEGIN
DECLARE @Search_VehicleOEMPackageID INT
DECLARE @Search_VehicleOEMPackageName nvarchar(50)
DECLARE @Search_BoltPattern nvarchar(50)
DECLARE @Search_BoltPatternNumber TINYINT
DECLARE @Search_BoltPatternDiameter FLOAT
DECLARE @Search_FrontOEMTireAndWheelConfigID INT
DECLARE @Search_RearOEMTireAndWheelConfigID INT
-- Create variables for search, END

-- Fill variables, BEGIN
	
	SET @Search_FrontOEMTireAndWheelConfigID = @FrontConfigID
	SET @Search_RearOEMTireAndWheelConfigID = @RearConfigID
	
	IF @TireSizeRear = ''
		BEGIN

			SET @Search_IsStaggeredFitmentFlag = 0

			SELECT 
			@Search_VehicleOEMPackageName =
			TireSize + ' (' + LoadIndex + SpeedRating + ')'
			from Fitment_ChassisModels cm inner join Fitment_Chassis c on cm.ChassisID = c.ChassisID
			WHERE	(cm.ModelID = @ModelID)
			
		END
	ELSE
		BEGIN
			SET @Search_IsStaggeredFitmentFlag = 1
			
			SELECT 
			@Search_VehicleOEMPackageName =
			'F:' + TireSize + ' (' + LoadIndex + SpeedRating + ')' + '/R:' + TireSizeRear + ' (' + LoadIndexRear + SpeedRatingRear + ')'
			from Fitment_ChassisModels cm inner join Fitment_Chassis c on cm.ChassisID = c.ChassisID
			WHERE	(cm.ModelID = @ModelID)
			
		END

		SELECT     
				@Search_BoltPattern = replace(C.BoltPattern, 'x', '/')
			  ,	@Search_BoltPatternNumber = SUBSTRING(C.BoltPattern, 1, CHARINDEX('x', C.BoltPattern,0)-1) 
			  , @Search_BoltPatternDiameter = SUBSTRING(C.BoltPattern, CHARINDEX('x', C.BoltPattern,0) + 1, LEN(C.BoltPattern))
		FROM         Fitment_ChassisModels AS CM INNER JOIN
							  Fitment_Chassis AS C ON CM.ChassisID = C.ChassisID
		WHERE     (CM.ModelID = @ModelID) AND (CM.ChassisID = @ChassisID)

-- Fill variables, END

IF EXISTS (
	SELECT	  VehicleOEMPackageID
	FROM	  VehicleOEMPackage
	WHERE	  VehicleID = @VehicleID  
		AND   VehicleOEMPackageName = @Search_VehicleOEMPackageName
		AND   BoltPattern = @Search_BoltPattern
		AND   BoltPatternNumber = @Search_BoltPatternNumber 
		AND   BoltPatternDiameter = @Search_BoltPatternDiameter
		AND   IsStaggeredFitmentFlag = @Search_IsStaggeredFitmentFlag 
		AND   FrontOEMTireAndWheelConfigID = @FrontConfigID
		AND   RearOEMTireAndWheelConfigID = @RearConfigID
			)
	BEGIN
			
			SELECT	  @Search_VehicleOEMPackageID = VehicleOEMPackageID
			FROM	  VehicleOEMPackage
			WHERE	  VehicleID = @VehicleID  
				AND   VehicleOEMPackageName = @Search_VehicleOEMPackageName
				AND   BoltPattern = @Search_BoltPattern
				AND   BoltPatternNumber = @Search_BoltPatternNumber 
				AND   BoltPatternDiameter = @Search_BoltPatternDiameter
				AND   IsStaggeredFitmentFlag = @Search_IsStaggeredFitmentFlag 
				AND   FrontOEMTireAndWheelConfigID = @FrontConfigID
				AND   RearOEMTireAndWheelConfigID = @RearConfigID
			
	END
ELSE -- IF EXISTS , VehicleOEMPackageID
	BEGIN
	-- If exist vehicle with @VehicleID, edit - if not, add row
		IF EXISTS (
			SELECT	  VehicleOEMPackageID
			FROM	  VehicleOEMPackage
			WHERE	  VehicleID = @VehicleID  
					)
			BEGIN -- edit
                    
				UPDATE VehicleOEMPackage
				SET		  VehicleOEMPackageName = @Search_VehicleOEMPackageName
						, BoltPattern = @Search_BoltPattern
						, BoltPatternNumber = @Search_BoltPatternNumber
						, BoltPatternDiameter = @Search_BoltPatternDiameter
						, IsStaggeredFitmentFlag = @Search_IsStaggeredFitmentFlag
						, FrontOEMTireAndWheelConfigID = @FrontConfigID
						, RearOEMTireAndWheelConfigID = @RearConfigID
						, DateModifiedUTC = getutcdate()
				WHERE  VehicleID = @VehicleID
					
				SELECT	  @Search_VehicleOEMPackageID = VehicleOEMPackageID
				FROM	  VehicleOEMPackage
				WHERE	  VehicleID = @VehicleID  
				
                      
			END
		ELSE -- IF EXISTS 
			BEGIN -- new record
			
				insert into dbo.[VehicleOEMPackage] 
					( VehicleID, 
					  VehicleOEMPackageName
					, BoltPattern
					, BoltPatternNumber
					, BoltPatternDiameter
					, IsStaggeredFitmentFlag
					, FrontOEMTireAndWheelConfigID
					, RearOEMTireAndWheelConfigID
					, DateCreatedUTC
					, DateModifiedUTC )
				select	
				  @VehicleID
				, @Search_VehicleOEMPackageName
				, @Search_BoltPattern
				, @Search_BoltPatternNumber
				, @Search_BoltPatternDiameter
				, @Search_IsStaggeredFitmentFlag
				, @FrontConfigID
				, @RearConfigID
				, getutcdate()
				, getutcdate()
				
				SET @Search_VehicleOEMPackageID = @@IDENTITY
			
			END
	
	END
			
      

-- Check entries in [VehicleOEMPackage], END



-- Check entries in [VehicleAftermarketFitment], BEGIN


-- Create variables for search, BEGIN
DECLARE @Search_OEMTireAndWheelConfigID INT
DECLARE @Search_OEMTireAndWheelConfigID_Rear INT

DECLARE @Search_AftermarketWheelDiameter FLOAT
DECLARE @Search_AftermarketWheelWidthMin FLOAT
DECLARE @Search_AftermarketWheelWidthMax FLOAT
DECLARE @Search_AftermarketWheelOffsetMax FLOAT 
DECLARE @Search_AftermarketWheelOffsetMin FLOAT
DECLARE @Search_RearFitment BIT = 0
DECLARE @Search_MinusFitment BIT = 0
DECLARE @Search_TSQLComputed BIT = 0
DECLARE @Search_FitmentNote nvarchar(1) = NULL
DECLARE @Search_ INT

DECLARE @Search_AftermarketWheelDiameter_Front FLOAT
DECLARE @Search_AftermarketWheelDiameter_Rear FLOAT

DECLARE @Search_AftermarketWheelOffsetMin_Front FLOAT
DECLARE @Search_AftermarketWheelOffsetMin_Rear FLOAT

DECLARE @Search_AftermarketWheelOffsetMax_Front FLOAT
DECLARE @Search_AftermarketWheelOffsetMax_Rear FLOAT

DECLARE @Search_AftermarketWheelWidthMin_Front FLOAT
DECLARE @Search_AftermarketWheelWidthMin_Rear FLOAT

DECLARE @Search_AftermarketWheelWidthMax_Front FLOAT
DECLARE @Search_AftermarketWheelWidthMax_Rear FLOAT

-- Create variables for search, END


-- -- /*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/


-- OEM processing, BEGIN

	-- Front axle, BEGIN
	SET @Search_OEMTireAndWheelConfigID = @FrontConfigID
	SET @Search_OEMTireAndWheelConfigID_Rear = @RearConfigID 

SELECT     
		@Search_AftermarketWheelDiameter_Front =  CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) -- RimDiameter -- CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) AS Diameter
		, @Search_AftermarketWheelOffsetMin_Front = OffsetMinF 
		, @Search_AftermarketWheelOffsetMax_Front = OffsetMaxF 
FROM	Fitment_ChassisModels AS CM INNER JOIN Fitment_Chassis AS C ON CM.ChassisID = C.ChassisID
where CM.ModelID = @ModelID AND CM.ChassisID = @ChassisID

SELECT    --CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) AS Diameter
		--, 
			@Search_AftermarketWheelWidthMin_Front = MIN(CAST(LTRIM(RTRIM(LEFT(WheelSize, CHARINDEX('x', WheelSize, 1) - 1))) AS float)) -- AS WheelWith_Min
		,	@Search_AftermarketWheelWidthMax_Front = MAX(CAST(LTRIM(RTRIM(LEFT(WheelSize, CHARINDEX('x', WheelSize, 1) - 1))) AS float)) -- AS WheelWith_Max
FROM         Fitment_MinusSizes
WHERE   (ChassisID = @ChassisID) 
		AND (FrontRearOrBoth = 'Both' OR FrontRearOrBoth = 'Front') 
		AND (CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) = @Search_AftermarketWheelDiameter_Front)

	IF @Search_AftermarketWheelWidthMin_Front IS NULL
		BEGIN
			--PRINT '@Search_AftermarketWheelWidthMin_Front IS NULL'
			--GOTO Skip_Front_axle
			-- search in Fitment_PlusSizes, then - in Fitment_ChassisModels
			 
				SELECT    
					@Search_AftermarketWheelWidthMin_Front = MIN(CAST(LTRIM(RTRIM(WheelWith)) AS float)) -- AS WheelWith_Min
				,	@Search_AftermarketWheelWidthMax_Front = MAX(CAST(LTRIM(RTRIM(WheelWith)) AS float)) -- AS WheelWith_Max
				FROM         v_Fitment_PlusSizes
				WHERE   (ChassisID = @ChassisID) 
				AND (PlusSizeType = 'Upstep' OR PlusSizeType = 'FrontUpstep') 
				AND Diameter = @Search_AftermarketWheelDiameter_Front
			
			
			IF @Search_AftermarketWheelWidthMin_Front IS NULL
				BEGIN
					
					SELECT 
						@Search_AftermarketWheelWidthMin_Front = MIN(CAST(LTRIM(RTRIM(LEFT(WheelSize, CHARINDEX('x', WheelSize, 1) - 1))) AS float))
						, @Search_AftermarketWheelWidthMax_Front = MAX(CAST(LTRIM(RTRIM(LEFT(WheelSize, CHARINDEX('x', WheelSize, 1) - 1))) AS float))
					FROM  Fitment_ChassisModels
					WHERE ChassisID = @ChassisID AND ModelID = @ModelID 
				
				END
			

		END

	SET @Search_RearFitment = 0
	SET @Search_MinusFitment = 0
	SET @Search_TSQLComputed = 0
	SET @Search_FitmentNote = NULL

 -- INSERT INTO VehicleAftermarketFitment #1

 --IF @ChassisID = 1353 AND @FrontConfigID = 32544 --AND @VehicleID = 19459
	--BEGIN
	--	PRINT 'STOP @ChassisID = 1353 AND @FrontConfigID = 32544 -- AND @VehicleID = 19459'
	--END

IF @AddNewDataOnly = 0 
	BEGIN
		INSERT INTO Fitment_Check_TEMP ([VehicleID], [IsStaggeredFitmentFlag], [ChassisID], [AftermarketWheelDiameter], [AftermarketWheelWidthMin], [AftermarketWheelWidthMax], [AftermarketWheelOffsetMin], [AftermarketWheelOffsetMax], [RearFitment], [MinusFitment])
		SELECT	@VehicleID
				, @Search_IsStaggeredFitmentFlag
				, @ChassisID
				, @Search_AftermarketWheelDiameter_Front
				, @Search_AftermarketWheelWidthMin_Front
				, @Search_AftermarketWheelWidthMax_Front
				, @Search_AftermarketWheelOffsetMin_Front
				, @Search_AftermarketWheelOffsetMax_Front
				, @Search_RearFitment
				, @Search_MinusFitment
	END

	IF NOT EXISTS (
					SELECT OEMTireAndWheelConfigID, *
					FROM   VehicleAftermarketFitment
					WHERE		(ChassisID = @ChassisID)
							AND	(OEMTireAndWheelConfigID = @Search_OEMTireAndWheelConfigID) 
							AND (AftermarketWheelDiameter = @Search_AftermarketWheelDiameter_Front) 
							AND (AftermarketWheelWidthMin = @Search_AftermarketWheelWidthMin_Front) 
							AND (AftermarketWheelWidthMax = @Search_AftermarketWheelWidthMax_Front) 
							AND (AftermarketWheelOffsetMin = @Search_AftermarketWheelOffsetMin_Front) 
							AND (AftermarketWheelOffsetMax = @Search_AftermarketWheelOffsetMax_Front) 
							AND (RearFitment = @Search_RearFitment) 
							AND (MinusFitment = @Search_MinusFitment) 
							AND (TSQLComputed = @Search_TSQLComputed)
							AND (VehicleID = @VehicleID)
					)
		BEGIN
			-- Add new record
			

			
	--IF @ChassisID = 1353 AND @FrontConfigID = 32544 --AND @VehicleID = 19459
	--BEGIN
	--	PRINT 'STOP @ChassisID = 1353 AND @FrontConfigID = 32544 -- AND @VehicleID = 19459'
	--END
			
				INSERT INTO VehicleAftermarketFitment -- INSERT INTO VehicleAftermarketFitment #1
                      ( ChassisID 
                      , OEMTireAndWheelConfigID
                      , AftermarketWheelDiameter
                      , AftermarketWheelWidthMin
                      , AftermarketWheelWidthMax
                      , AftermarketWheelOffsetMin
                      , AftermarketWheelOffsetMax
                      , RearFitment
                      , MinusFitment
                      , TSQLComputed
                      , FitmentNote
                      , DateCreatedUTC
                      , DateModifiedUTC
					  , VehicleID)
				SELECT
					   @ChassisID
				     , @Search_OEMTireAndWheelConfigID
				     , @Search_AftermarketWheelDiameter_Front
				     , @Search_AftermarketWheelWidthMin_Front
				     , @Search_AftermarketWheelWidthMax_Front
				     , @Search_AftermarketWheelOffsetMin_Front
				     , @Search_AftermarketWheelOffsetMax_Front
				     , @Search_RearFitment
				     , @Search_MinusFitment
				     , @Search_TSQLComputed
				     , @Search_FitmentNote
				     , getutcdate()
				     , getutcdate()
					 , @VehicleID
						
		END

	-- Front axle, END

Skip_Front_axle:
	
	-- Rear axle, BEGIN
	IF @FrontConfigID <> @RearConfigID
		BEGIN

SELECT     
		@Search_AftermarketWheelDiameter_Rear =  CASE WHEN LEN(CM.WheelSizeRear) > 0 THEN CAST(LTRIM(RTRIM(RIGHT(CM.WheelSizeRear , LEN(CM.WheelSizeRear ) - CHARINDEX('x', CM.WheelSizeRear , 1)))) AS float) ELSE CAST(LTRIM(RTRIM(RIGHT(CM.WheelSize , LEN(CM.WheelSize ) - CHARINDEX('x', CM.WheelSize , 1)))) AS float) END -- RimDiameter -- CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) AS Diameter
		, @Search_AftermarketWheelOffsetMin_Rear  = OffsetMinR  
		, @Search_AftermarketWheelOffsetMax_Rear  = OffsetMaxR  
FROM	Fitment_ChassisModels AS CM INNER JOIN Fitment_Chassis AS C ON CM.ChassisID = C.ChassisID
where CM.ModelID = @ModelID AND CM.ChassisID = @ChassisID

			SELECT    --CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) AS Diameter
					--, 
						@Search_AftermarketWheelWidthMin_Rear  = MIN(CAST(LTRIM(RTRIM(LEFT(WheelSize, CHARINDEX('x', WheelSize, 1) - 1))) AS float)) -- AS WheelWith_Min
					,	@Search_AftermarketWheelWidthMax_Rear  = MAX(CAST(LTRIM(RTRIM(LEFT(WheelSize, CHARINDEX('x', WheelSize, 1) - 1))) AS float)) -- AS WheelWith_Max
			FROM         Fitment_MinusSizes
			WHERE   (ChassisID = @ChassisID) 
					AND (FrontRearOrBoth = 'Both' OR FrontRearOrBoth = 'Rear') 
					AND (CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) = @Search_AftermarketWheelDiameter_Rear)

	
		IF @Search_AftermarketWheelWidthMin_Rear IS NULL
		BEGIN
			--PRINT '@Search_AftermarketWheelWidthMin_Front IS NULL'
			--GOTO Skip_Rear_axle
			-- search in Fitment_PlusSizes, then - in Fitment_ChassisModels
			 
				SELECT    
					@Search_AftermarketWheelWidthMin_Rear = MIN(CAST(LTRIM(RTRIM(WheelWith)) AS float)) -- AS WheelWith_Min
				,	@Search_AftermarketWheelWidthMax_Rear = MAX(CAST(LTRIM(RTRIM(WheelWith)) AS float)) -- AS WheelWith_Max
				FROM         v_Fitment_PlusSizes
				WHERE   (ChassisID = @ChassisID) 
				AND (PlusSizeType = 'RearUpstep') 
				AND Diameter = @Search_AftermarketWheelDiameter_Rear
			
			
			IF @Search_AftermarketWheelWidthMin_Rear IS NULL
				BEGIN

					DECLARE @WheelSizeRear_Value nvarchar(max)
					
					SELECT @WheelSizeRear_Value = WheelSizeRear
					FROM  Fitment_ChassisModels
					WHERE ChassisID = @ChassisID AND ModelID = @ModelID 
					
					IF @WheelSizeRear_Value = '' 
						BEGIN
							SELECT 
								  @Search_AftermarketWheelWidthMin_Rear = MIN(CAST(LTRIM(RTRIM(LEFT(WheelSize, CHARINDEX('x', WheelSize, 1) - 1))) AS float))
								, @Search_AftermarketWheelWidthMax_Rear = MAX(CAST(LTRIM(RTRIM(LEFT(WheelSize, CHARINDEX('x', WheelSize, 1) - 1))) AS float)) 
							FROM  Fitment_ChassisModels
							WHERE ChassisID = @ChassisID AND ModelID = @ModelID 
						END
						
					ELSE
						BEGIN
							SELECT 
								--  @Search_AftermarketWheelWidthMin_Rear = MIN(CAST(LTRIM(RTRIM(LEFT(WheelSizeRear, CHARINDEX('x', WheelSizeRear, 1) - 1))) AS float))
								--, @Search_AftermarketWheelWidthMax_Rear = MAX(CAST(LTRIM(RTRIM(LEFT(WheelSizeRear, CHARINDEX('x', WheelSizeRear, 1) - 1))) AS float))
								  @Search_AftermarketWheelWidthMin_Rear = MIN(CAST(LTRIM(RTRIM(LEFT(CASE WHEN LEN(WheelSizeRear) = 0 THEN WheelSize ELSE WheelSizeRear END, CHARINDEX('x', CASE WHEN LEN(WheelSizeRear) = 0 THEN WheelSize ELSE WheelSizeRear END, 1) - 1))) AS float))
								, @Search_AftermarketWheelWidthMax_Rear = MAX(CAST(LTRIM(RTRIM(LEFT(CASE WHEN LEN(WheelSizeRear) = 0 THEN WheelSize ELSE WheelSizeRear END, CHARINDEX('x', CASE WHEN LEN(WheelSizeRear) = 0 THEN WheelSize ELSE WheelSizeRear END, 1) - 1))) AS float))
							FROM  Fitment_ChassisModels
							WHERE ChassisID = @ChassisID AND ModelID = @ModelID 
						END
				
				END			
			
		END
	

--SELECT DISTINCT FrontRearOrBoth FROM Fitment_MinusSizes


				SET @Search_RearFitment = 1
				SET @Search_MinusFitment = 0
				SET @Search_TSQLComputed = 0
				SET @Search_FitmentNote = NULL

 -- INSERT INTO VehicleAftermarketFitment #2

 IF @AddNewDataOnly = 0 
	BEGIN
		INSERT INTO Fitment_Check_TEMP ([VehicleID], [IsStaggeredFitmentFlag], [ChassisID], [AftermarketWheelDiameter], [AftermarketWheelWidthMin], [AftermarketWheelWidthMax], [AftermarketWheelOffsetMin], [AftermarketWheelOffsetMax], [RearFitment], [MinusFitment])
		SELECT	@VehicleID
				, @Search_IsStaggeredFitmentFlag
				, @ChassisID
				, @Search_AftermarketWheelDiameter_Rear 
				, @Search_AftermarketWheelWidthMin_Rear 
				, @Search_AftermarketWheelWidthMax_Rear 
				, @Search_AftermarketWheelOffsetMin_Rear 
				, @Search_AftermarketWheelOffsetMax_Rear 
				, @Search_RearFitment
				, @Search_MinusFitment
	END

				IF NOT EXISTS (
								SELECT OEMTireAndWheelConfigID
								FROM   VehicleAftermarketFitment
								WHERE		(ChassisID = @ChassisID)
										AND (OEMTireAndWheelConfigID = @Search_OEMTireAndWheelConfigID_Rear) 
										AND (AftermarketWheelDiameter = @Search_AftermarketWheelDiameter_Rear) 
										AND (AftermarketWheelWidthMin = @Search_AftermarketWheelWidthMin_Rear) 
										AND (AftermarketWheelWidthMax = @Search_AftermarketWheelWidthMax_Rear) 
										AND (AftermarketWheelOffsetMin = @Search_AftermarketWheelOffsetMin_Rear) 
										AND (AftermarketWheelOffsetMax = @Search_AftermarketWheelOffsetMax_Rear) 
										AND (RearFitment = @Search_RearFitment) 
										AND (MinusFitment = @Search_MinusFitment) 
										AND (TSQLComputed = @Search_TSQLComputed)
										AND (VehicleID = @VehicleID)
								)
					BEGIN
						-- Add new record
						

 --IF @ChassisID = 1353 AND @FrontConfigID = 32544 --AND @VehicleID = 19459
	--BEGIN
	--	PRINT 'STOP @ChassisID = 1353 AND @FrontConfigID = 32544 -- AND @VehicleID = 19459'
	--END						
						
							INSERT INTO VehicleAftermarketFitment -- INSERT INTO VehicleAftermarketFitment #2
								  (ChassisID
								  , OEMTireAndWheelConfigID
								  , AftermarketWheelDiameter
								  , AftermarketWheelWidthMin
								  , AftermarketWheelWidthMax
								  , AftermarketWheelOffsetMin
								  , AftermarketWheelOffsetMax
								  , RearFitment
								  , MinusFitment
								  , TSQLComputed
								  , FitmentNote
								  , DateCreatedUTC
								  , DateModifiedUTC
								  , VehicleID)
							SELECT
								   @ChassisID 
								 , @Search_OEMTireAndWheelConfigID_Rear 
								 , @Search_AftermarketWheelDiameter_Rear 
								 , @Search_AftermarketWheelWidthMin_Rear 
								 , @Search_AftermarketWheelWidthMax_Rear 
								 , @Search_AftermarketWheelOffsetMin_Rear 
								 , @Search_AftermarketWheelOffsetMax_Rear 
								 , @Search_RearFitment
								 , @Search_MinusFitment
								 , @Search_TSQLComputed
								 , @Search_FitmentNote
								 , getutcdate()
								 , getutcdate()
								 , @VehicleID
					END
					
		
		END -- IF @FrontConfigID <> @RearConfigID
	-- Rear axle, END


Skip_Rear_axle:
-- OEM processing, BEGIN
-- Processing OEM-Minus, BEGIN

-- Create a list of front axle, BEGIN
DECLARE @Search_AftermarketWheelDiameter_Current FLOAT
SET @Search_AftermarketWheelDiameter_Current = 0

Circle_1:

IF EXISTS(
		SELECT TOP 1  CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) AS Diameter
				--, MIN(CAST(LTRIM(RTRIM(LEFT(WheelSize, CHARINDEX('x', WheelSize, 1) - 1))) AS float)) AS WheelWith_Min
				--, MAX(CAST(LTRIM(RTRIM(LEFT(WheelSize, CHARINDEX('x', WheelSize, 1) - 1))) AS float)) AS WheelWith_Max
		FROM         Fitment_MinusSizes
		WHERE      (ChassisID = @ChassisID) -- 7406 --@ChassisID
				AND (CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) < @Search_AftermarketWheelDiameter_Front)  -- @Search_AftermarketWheelDiameter_Front
				AND (CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) >=  @Search_AftermarketWheelDiameter_Current) -- @Search_AftermarketWheelDiameter_Current
				AND (FrontRearOrBoth = 'Both' OR FrontRearOrBoth = 'Front')
		ORDER BY Diameter
		)
		
	BEGIN
	
		SELECT  TOP 1  
					@Search_AftermarketWheelDiameter_Current =CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) --AS Diameter -- @Search_AftermarketWheelDiameter_Current =
				,	@Search_AftermarketWheelWidthMin_Front = MIN(CAST(LTRIM(RTRIM(LEFT(WheelSize, CHARINDEX('x', WheelSize, 1) - 1))) AS float)) -- AS WheelWith_Min -- @Search_AftermarketWheelWidthMin_Front = 
				,	@Search_AftermarketWheelWidthMax_Front = MAX(CAST(LTRIM(RTRIM(LEFT(WheelSize, CHARINDEX('x', WheelSize, 1) - 1))) AS float)) -- AS WheelWith_Max -- @Search_AftermarketWheelWidthMax_Front = 
		FROM        Fitment_MinusSizes
		WHERE (ChassisID = @ChassisID) -- 7406 -- @ChassisID
				AND (CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) < @Search_AftermarketWheelDiameter_Front) -- @Search_AftermarketWheelDiameter_Front
				AND (CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) >= @Search_AftermarketWheelDiameter_Current) -- @Search_AftermarketWheelDiameter_Current		-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				AND (FrontRearOrBoth = 'Both' OR FrontRearOrBoth = 'Front')
		GROUP BY	CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float)
		ORDER BY CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float)


		SELECT     --CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) AS Diam, 
					@Search_AftermarketWheelOffsetMin_Front = MIN(OffsetMin) -- AS @Search_AftermarketWheelOffsetMin_Front
				,	@Search_AftermarketWheelOffsetMax_Front = MAX(OffsetMax) -- AS @Search_AftermarketWheelOffsetMax_Front
		FROM         Fitment_MinusSizes
		WHERE     (ChassisID = @ChassisID)  -- 7406
		AND (FrontRearOrBoth = 'Both' OR FrontRearOrBoth = 'Front')
		AND (CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) = @Search_AftermarketWheelDiameter_Current)


			SET @Search_RearFitment = 0
			SET @Search_MinusFitment = 1
			SET @Search_TSQLComputed = 0
			SET @Search_FitmentNote = NULL

 -- INSERT INTO VehicleAftermarketFitment #3

  IF @AddNewDataOnly = 0 
	BEGIN
		INSERT INTO Fitment_Check_TEMP ([VehicleID], [IsStaggeredFitmentFlag], [ChassisID], [AftermarketWheelDiameter], [AftermarketWheelWidthMin], [AftermarketWheelWidthMax], [AftermarketWheelOffsetMin], [AftermarketWheelOffsetMax], [RearFitment], [MinusFitment])
		SELECT	@VehicleID
				, @Search_IsStaggeredFitmentFlag
				, @ChassisID
				, @Search_AftermarketWheelDiameter_Current 
				, @Search_AftermarketWheelWidthMin_Front 
				, @Search_AftermarketWheelWidthMax_Front 
				, @Search_AftermarketWheelOffsetMin_Front 
				, @Search_AftermarketWheelOffsetMax_Front 
				, @Search_RearFitment
				, @Search_MinusFitment
	END


			IF NOT EXISTS (
							SELECT OEMTireAndWheelConfigID
							FROM   VehicleAftermarketFitment
							WHERE		ChassisID = @ChassisID
									AND (OEMTireAndWheelConfigID = @Search_OEMTireAndWheelConfigID) 
									AND (AftermarketWheelDiameter = @Search_AftermarketWheelDiameter_Current) 
									AND (AftermarketWheelWidthMin = @Search_AftermarketWheelWidthMin_Front) 
									AND (AftermarketWheelWidthMax = @Search_AftermarketWheelWidthMax_Front) 
									AND (AftermarketWheelOffsetMin = @Search_AftermarketWheelOffsetMin_Front) 
									AND (AftermarketWheelOffsetMax = @Search_AftermarketWheelOffsetMax_Front) 
									AND (RearFitment = @Search_RearFitment) 
									AND (MinusFitment = @Search_MinusFitment) 
									AND (TSQLComputed = @Search_TSQLComputed)
									AND (VehicleID = @VehicleID)
							)
				BEGIN
					-- Add new record
					
 --IF @ChassisID = 1353 AND @FrontConfigID = 32544 --AND @VehicleID = 19459
	--BEGIN
	--	PRINT 'STOP @ChassisID = 1353 AND @FrontConfigID = 32544 -- AND @VehicleID = 19459'
	--END
					
						INSERT INTO VehicleAftermarketFitment -- INSERT INTO VehicleAftermarketFitment #3
							  ( ChassisID
							  , OEMTireAndWheelConfigID
							  , AftermarketWheelDiameter
							  , AftermarketWheelWidthMin
							  , AftermarketWheelWidthMax
							  , AftermarketWheelOffsetMin
							  , AftermarketWheelOffsetMax
							  , RearFitment
							  , MinusFitment
							  , TSQLComputed
							  , FitmentNote
							  , DateCreatedUTC
							  , DateModifiedUTC
							  , VehicleID)
						SELECT
							   @ChassisID
							 , @Search_OEMTireAndWheelConfigID
							 , @Search_AftermarketWheelDiameter_Current
							 , @Search_AftermarketWheelWidthMin_Front
							 , @Search_AftermarketWheelWidthMax_Front
							 , @Search_AftermarketWheelOffsetMin_Front
							 , @Search_AftermarketWheelOffsetMax_Front
							 , @Search_RearFitment
							 , @Search_MinusFitment
							 , @Search_TSQLComputed
							 , @Search_FitmentNote
							 , getutcdate()
							 , getutcdate()
							 , @VehicleID
								
				END

	
	--IF @Search_AftermarketWheelDiameter_Current < @Search_AftermarketWheelDiameter_Front
	--	BEGIN
	--		GOTO Circle_1
	--	END
	


	END

	SET @Search_AftermarketWheelDiameter_Current = @Search_AftermarketWheelDiameter_Current + 1
	
	IF @Search_AftermarketWheelDiameter_Current < @Search_AftermarketWheelDiameter_Front
		BEGIN
			GOTO Circle_1
		END
	


-- Create a list of front axle, END

	
-- Rear axle, BEGIN	
	IF @FrontConfigID <> @RearConfigID
		BEGIN

		
			SET @Search_AftermarketWheelDiameter_Current = 0
			

			Circle_2:

			IF EXISTS(
					SELECT TOP 1  CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) AS Diameter
							--, MIN(CAST(LTRIM(RTRIM(LEFT(WheelSize, CHARINDEX('x', WheelSize, 1) - 1))) AS float)) AS WheelWith_Min
							--, MAX(CAST(LTRIM(RTRIM(LEFT(WheelSize, CHARINDEX('x', WheelSize, 1) - 1))) AS float)) AS WheelWith_Max
					FROM         Fitment_MinusSizes
					WHERE      (ChassisID = @ChassisID) -- 7406 --@ChassisID -- 3389
							AND (CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) < @Search_AftermarketWheelDiameter_Front)  -- @Search_AftermarketWheelDiameter_Front			-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!
							AND (CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) >  @Search_AftermarketWheelDiameter_Current) -- @Search_AftermarketWheelDiameter_Current
							AND (FrontRearOrBoth = 'Rear')
					GROUP BY	CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float)
					ORDER BY CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float)
					)
					
				BEGIN
				
					SELECT  TOP 1  
								@Search_AftermarketWheelDiameter_Current =CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) --AS Diameter -- @Search_AftermarketWheelDiameter_Current =
							,	@Search_AftermarketWheelWidthMin_Rear = MIN(CAST(LTRIM(RTRIM(LEFT(WheelSize, CHARINDEX('x', WheelSize, 1) - 1))) AS float)) -- AS WheelWith_Min -- @Search_AftermarketWheelWidthMin_Front = 
							,	@Search_AftermarketWheelWidthMax_Rear = MAX(CAST(LTRIM(RTRIM(LEFT(WheelSize, CHARINDEX('x', WheelSize, 1) - 1))) AS float)) -- AS WheelWith_Max -- @Search_AftermarketWheelWidthMax_Front = 
					FROM        Fitment_MinusSizes
					WHERE      (ChassisID = @ChassisID) -- 7406 -- @ChassisID
							AND (CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) < @Search_AftermarketWheelDiameter_Front) -- @Search_AftermarketWheelDiameter_Front
							AND (CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) > @Search_AftermarketWheelDiameter_Current) -- @Search_AftermarketWheelDiameter_Current
							AND (FrontRearOrBoth = 'Rear')
					GROUP BY	CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float)
					ORDER BY CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float)


					SELECT     --CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) AS Diam, 
								@Search_AftermarketWheelOffsetMin_Rear = MIN(OffsetMin) -- AS @Search_AftermarketWheelOffsetMin_Front
							,	@Search_AftermarketWheelOffsetMax_Rear = MAX(OffsetMax) -- AS @Search_AftermarketWheelOffsetMax_Front
					FROM         Fitment_MinusSizes
					WHERE     (ChassisID = @ChassisID)  -- 7406
					AND (FrontRearOrBoth = 'Rear')
					AND (CAST(LTRIM(RTRIM(RIGHT(WheelSize, LEN(WheelSize) - CHARINDEX('x', WheelSize, 1)))) AS float) = @Search_AftermarketWheelDiameter_Current)


		IF @Search_AftermarketWheelOffsetMin_Rear IS NULL
		BEGIN
			--PRINT '@Search_AftermarketWheelWidthMin_Front IS NULL'
			GOTO Skip_OEM_Minus_Rear_axle
		END

						SET @Search_RearFitment = 1
						SET @Search_MinusFitment = 1
						SET @Search_TSQLComputed = 0
						SET @Search_FitmentNote = NULL

 -- INSERT INTO VehicleAftermarketFitment #4

  IF @AddNewDataOnly = 0 
	BEGIN
		INSERT INTO Fitment_Check_TEMP ([VehicleID], [IsStaggeredFitmentFlag], [ChassisID], [AftermarketWheelDiameter], [AftermarketWheelWidthMin], [AftermarketWheelWidthMax], [AftermarketWheelOffsetMin], [AftermarketWheelOffsetMax], [RearFitment], [MinusFitment])
		SELECT	@VehicleID
				, @Search_IsStaggeredFitmentFlag
				, @ChassisID
				, @Search_AftermarketWheelDiameter_Current 
				, @Search_AftermarketWheelWidthMin_Rear 
				, @Search_AftermarketWheelWidthMax_Rear  
				, @Search_AftermarketWheelOffsetMin_Rear  
				, @Search_AftermarketWheelOffsetMax_Rear  
				, @Search_RearFitment
				, @Search_MinusFitment
	END

						IF NOT EXISTS (
										SELECT OEMTireAndWheelConfigID
										FROM   VehicleAftermarketFitment
										WHERE		ChassisID = @ChassisID
												AND (OEMTireAndWheelConfigID = @Search_OEMTireAndWheelConfigID_Rear) 
												AND (AftermarketWheelDiameter = @Search_AftermarketWheelDiameter_Current) 
												AND (AftermarketWheelWidthMin = @Search_AftermarketWheelWidthMin_Front) 
												AND (AftermarketWheelWidthMax = @Search_AftermarketWheelWidthMax_Front) 
												AND (AftermarketWheelOffsetMin = @Search_AftermarketWheelOffsetMin_Front) 
												AND (AftermarketWheelOffsetMax = @Search_AftermarketWheelOffsetMax_Front) 
												AND (RearFitment = @Search_RearFitment) 
												AND (MinusFitment = @Search_MinusFitment) 
												AND (TSQLComputed = @Search_TSQLComputed)
												AND (VehicleID = @VehicleID)
												AND (VehicleID = @VehicleID)
										)
							BEGIN
								-- Add new record
								
 --IF @ChassisID = 1353 AND @FrontConfigID = 32544 --AND @VehicleID = 19459
	--BEGIN
	--	PRINT 'STOP @ChassisID = 1353 AND @FrontConfigID = 32544 -- AND @VehicleID = 19459'
	--END
	--1								
									INSERT INTO VehicleAftermarketFitment -- INSERT INTO VehicleAftermarketFitment #4
										  ( ChassisID 
										  , OEMTireAndWheelConfigID
										  , AftermarketWheelDiameter
										  , AftermarketWheelWidthMin
										  , AftermarketWheelWidthMax
										  , AftermarketWheelOffsetMin
										  , AftermarketWheelOffsetMax
										  , RearFitment
										  , MinusFitment
										  , TSQLComputed
										  , FitmentNote
										  , DateCreatedUTC
										  , DateModifiedUTC
										  , VehicleID)
									SELECT
										   @ChassisID
										 , @Search_OEMTireAndWheelConfigID_Rear
										 , @Search_AftermarketWheelDiameter_Current
										 , @Search_AftermarketWheelWidthMin_Rear
										 , @Search_AftermarketWheelWidthMax_Rear
										 , @Search_AftermarketWheelOffsetMin_Rear
										 , @Search_AftermarketWheelOffsetMax_Rear
										 , @Search_RearFitment
										 , @Search_MinusFitment
										 , @Search_TSQLComputed
										 , @Search_FitmentNote
										 , getutcdate()
										 , getutcdate()
										 , @VehicleID
							END

--Skip_OEM_Minus_Rear_axle:
				
--				IF @Search_AftermarketWheelDiameter_Current < @Search_AftermarketWheelDiameter_Rear
--					BEGIN
--						GOTO Circle_2
--					END
				




				END
		
Skip_OEM_Minus_Rear_axle:
				
				SET @Search_AftermarketWheelDiameter_Current = @Search_AftermarketWheelDiameter_Current + 1
				
				IF @Search_AftermarketWheelDiameter_Current < @Search_AftermarketWheelDiameter_Rear
					BEGIN
						GOTO Circle_2
					END
				
		
		
		
		
		
		END -- IF @FrontConfigID <> @RearConfigID
-- Rear axle, END
	
-- Processing OEM-Minus, END


-- Processing OEM-Plus, BEGIN


-- Create a list of front axle, OEM-Plus, BEGIN
--DECLARE @Search_AftermarketWheelDiameter_Current FLOAT
SET @Search_AftermarketWheelDiameter_Current = 40

Circle_3:

IF EXISTS(
		
			SELECT Diameter 
			FROM v_Fitment_PlusSizes
			WHERE	ChassisID = @ChassisID
					
					AND Diameter > @Search_AftermarketWheelDiameter_Front
					AND Diameter <= @Search_AftermarketWheelDiameter_Current	  -- !!!!!!!!!!!!!!!!!!!!!!!
					
					AND (PlusSizeType = 'FrontUpstep' OR PlusSizeType = 'Upstep')
		)
		
	BEGIN
	
			-- Find the largest diameter
			SELECT	TOP 1 @Search_AftermarketWheelDiameter_Current = Diameter
			FROM v_Fitment_PlusSizes
			WHERE	ChassisID = @ChassisID
					AND Diameter > @Search_AftermarketWheelDiameter_Front
					AND Diameter <= @Search_AftermarketWheelDiameter_Current				-- !!!!!!!!!!!!!!!!!!!!!!
					AND (PlusSizeType = 'FrontUpstep' OR PlusSizeType = 'Upstep')
			ORDER BY Diameter DESC


			SELECT		@Search_AftermarketWheelDiameter_Current = Diameter
					,	@Search_AftermarketWheelWidthMin_Front = MIN(WheelWith)
					,	@Search_AftermarketWheelWidthMax_Front = MAX(WheelWith)
					,	@Search_AftermarketWheelOffsetMin_Front = MIN(OffsetMin)
					,	@Search_AftermarketWheelOffsetMax_Front = MAX(OffsetMax)
			FROM         v_Fitment_PlusSizes
			WHERE     (ChassisID = @ChassisID) 
						AND (PlusSizeType = 'FrontUpstep' OR PlusSizeType = 'Upstep')
						AND (Diameter = @Search_AftermarketWheelDiameter_Current)
			GROUP BY Diameter

			SET @Search_RearFitment = 0
			SET @Search_MinusFitment = 0
			SET @Search_TSQLComputed = 0
			SET @Search_FitmentNote = NULL

 -- INSERT INTO VehicleAftermarketFitment #5

  IF @AddNewDataOnly = 0 
	BEGIN
		INSERT INTO Fitment_Check_TEMP ([VehicleID], [IsStaggeredFitmentFlag], [ChassisID], [AftermarketWheelDiameter], [AftermarketWheelWidthMin], [AftermarketWheelWidthMax], [AftermarketWheelOffsetMin], [AftermarketWheelOffsetMax], [RearFitment], [MinusFitment])
		SELECT	@VehicleID
				, @Search_IsStaggeredFitmentFlag
				, @ChassisID
				, @Search_AftermarketWheelDiameter_Current 
				, @Search_AftermarketWheelWidthMin_Front 
				, @Search_AftermarketWheelWidthMax_Front 
				, @Search_AftermarketWheelOffsetMin_Front  
				, @Search_AftermarketWheelOffsetMax_Front 
				, @Search_RearFitment
				, @Search_MinusFitment
	END
			IF NOT EXISTS (
							SELECT OEMTireAndWheelConfigID
							FROM   VehicleAftermarketFitment
							WHERE		ChassisID = @ChassisID
									AND (OEMTireAndWheelConfigID = @Search_OEMTireAndWheelConfigID) 
									AND (AftermarketWheelDiameter = @Search_AftermarketWheelDiameter_Current) 
									AND (AftermarketWheelWidthMin = @Search_AftermarketWheelWidthMin_Front) 
									AND (AftermarketWheelWidthMax = @Search_AftermarketWheelWidthMax_Front) 
									AND (AftermarketWheelOffsetMin = @Search_AftermarketWheelOffsetMin_Front) 
									AND (AftermarketWheelOffsetMax = @Search_AftermarketWheelOffsetMax_Front) 
									AND (RearFitment = @Search_RearFitment) 
									AND (MinusFitment = @Search_MinusFitment) 
									AND (TSQLComputed = @Search_TSQLComputed)
									AND (VehicleID = @VehicleID)
							)
				BEGIN
					-- Add new record
					
 --IF @ChassisID = 1353 AND @FrontConfigID = 32544 --AND @VehicleID = 19459
	--BEGIN
	--	PRINT 'STOP @ChassisID = 1353 AND @FrontConfigID = 32544 -- AND @VehicleID = 19459'
	--END					

						INSERT INTO VehicleAftermarketFitment -- INSERT INTO VehicleAftermarketFitment #5
							  ( ChassisID
							  , OEMTireAndWheelConfigID
							  , AftermarketWheelDiameter
							  , AftermarketWheelWidthMin
							  , AftermarketWheelWidthMax
							  , AftermarketWheelOffsetMin
							  , AftermarketWheelOffsetMax
							  , RearFitment
							  , MinusFitment
							  , TSQLComputed
							  , FitmentNote
							  , DateCreatedUTC
							  , DateModifiedUTC
							  , VehicleID)
						SELECT
							   @ChassisID
							 , @Search_OEMTireAndWheelConfigID
							 , @Search_AftermarketWheelDiameter_Current
							 , @Search_AftermarketWheelWidthMin_Front
							 , @Search_AftermarketWheelWidthMax_Front
							 , @Search_AftermarketWheelOffsetMin_Front
							 , @Search_AftermarketWheelOffsetMax_Front
							 , @Search_RearFitment
							 , @Search_MinusFitment
							 , @Search_TSQLComputed
							 , @Search_FitmentNote
							 , getutcdate()
							 , getutcdate()
							 , @VehicleID
								
				END

	END
	
	SET @Search_AftermarketWheelDiameter_Current = @Search_AftermarketWheelDiameter_Current - 1
	
	IF @Search_AftermarketWheelDiameter_Current > @Search_AftermarketWheelDiameter_Front
		BEGIN
			GOTO Circle_3
		END

	--END

-- check end of list
-- Create a list of front axle, OEM-Plus, END


-- Rear axle,  OEM-Plus, BEGIN

IF @FrontConfigID <> @RearConfigID
	BEGIN
	SET @Search_AftermarketWheelDiameter_Current = 40

	Circle_4:
	
IF EXISTS(
		
			SELECT Diameter 
			FROM v_Fitment_PlusSizes
			WHERE	ChassisID = @ChassisID

					AND Diameter > @Search_AftermarketWheelDiameter_Rear
					AND Diameter <= @Search_AftermarketWheelDiameter_Current		-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					
					AND (PlusSizeType = 'RearUpstep')
		)
		
	BEGIN
	
			-- Find the largest diameter
			SELECT	TOP 1 @Search_AftermarketWheelDiameter_Current = Diameter
			FROM v_Fitment_PlusSizes
			WHERE	ChassisID = @ChassisID
			
					AND Diameter > @Search_AftermarketWheelDiameter_Rear
					AND Diameter <= @Search_AftermarketWheelDiameter_Current		-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					
					AND PlusSizeType = 'RearUpstep'
					
			ORDER BY Diameter DESC


			SELECT		@Search_AftermarketWheelDiameter_Current = Diameter
					,	@Search_AftermarketWheelWidthMin_Rear = MIN(WheelWith)
					,	@Search_AftermarketWheelWidthMax_Rear = MAX(WheelWith)
					,	@Search_AftermarketWheelOffsetMin_Rear = MIN(OffsetMin)
					,	@Search_AftermarketWheelOffsetMax_Rear = MAX(OffsetMax)
			FROM         v_Fitment_PlusSizes
			WHERE		(ChassisID = @ChassisID) 
						AND PlusSizeType = 'RearUpstep'
						AND (Diameter = @Search_AftermarketWheelDiameter_Current)
			GROUP BY Diameter


			SET @Search_RearFitment = 1
			SET @Search_MinusFitment = 0
			SET @Search_TSQLComputed = 0
			SET @Search_FitmentNote = NULL


		--IF @Search_AftermarketWheelOffsetMin_Rear IS NULL
		--BEGIN
		--	--PRINT '@Search_AftermarketWheelWidthMin_Rear IS NULL'
		--	GOTO Skip_OEM_Plus_Rear_axle
		--END

		IF @Search_AftermarketWheelOffsetMin_Rear IS NULL
		BEGIN
			--PRINT '@Search_AftermarketWheelOffsetMin_Rear IS NULL'
			GOTO Skip_Circle_4
		END



		 IF @Search_AftermarketWheelWidthMin_Rear IS NULL 
			BEGIN                     
			
				SET @Search_AftermarketWheelDiameter_Current = @Search_AftermarketWheelDiameter_Current - 1
					
					IF @Search_AftermarketWheelDiameter_Current > @Search_AftermarketWheelDiameter_Rear 
						BEGIN
							GOTO Circle_4
						END
					ELSE 
						BEGIN
							GOTO Exit_Circle_4
						END
			END
			
 -- INSERT INTO VehicleAftermarketFitment #6

 IF @AddNewDataOnly = 0 
	BEGIN
		INSERT INTO Fitment_Check_TEMP ([VehicleID], [IsStaggeredFitmentFlag], [ChassisID], [AftermarketWheelDiameter], [AftermarketWheelWidthMin], [AftermarketWheelWidthMax], [AftermarketWheelOffsetMin], [AftermarketWheelOffsetMax], [RearFitment], [MinusFitment])
		SELECT	@VehicleID
				, @Search_IsStaggeredFitmentFlag
				, @ChassisID
				, @Search_AftermarketWheelDiameter_Current 
				, @Search_AftermarketWheelWidthMin_Rear 
				, @Search_AftermarketWheelWidthMax_Rear  
				, @Search_AftermarketWheelOffsetMin_Rear   
				, @Search_AftermarketWheelOffsetMax_Rear  
				, @Search_RearFitment
				, @Search_MinusFitment
	END
			IF NOT EXISTS (
							SELECT OEMTireAndWheelConfigID
							FROM   VehicleAftermarketFitment
							WHERE		ChassisID = @ChassisID
									AND (OEMTireAndWheelConfigID = @Search_OEMTireAndWheelConfigID_Rear) 
									AND (AftermarketWheelDiameter = @Search_AftermarketWheelDiameter_Current) 
									AND (AftermarketWheelWidthMin = @Search_AftermarketWheelWidthMin_Rear) 
									AND (AftermarketWheelWidthMax = @Search_AftermarketWheelWidthMax_Rear) 
									AND (AftermarketWheelOffsetMin = @Search_AftermarketWheelOffsetMin_Rear) 
									AND (AftermarketWheelOffsetMax = @Search_AftermarketWheelOffsetMax_Rear) 
									AND (RearFitment = @Search_RearFitment) 
									AND (MinusFitment = @Search_MinusFitment) 
									AND (TSQLComputed = @Search_TSQLComputed)
									AND (VehicleID = @VehicleID)
							)
				BEGIN
					-- Add new record
					
					
 --IF @ChassisID = 1353 AND @FrontConfigID = 32544 --AND @VehicleID = 19459
	--BEGIN
	--	PRINT 'STOP @ChassisID = 1353 AND @FrontConfigID = 32544 -- AND @VehicleID = 19459'
	--END
						
						INSERT INTO VehicleAftermarketFitment -- INSERT INTO VehicleAftermarketFitment #6
							  ( ChassisID 
							  , OEMTireAndWheelConfigID
							  , AftermarketWheelDiameter
							  , AftermarketWheelWidthMin
							  , AftermarketWheelWidthMax
							  , AftermarketWheelOffsetMin
							  , AftermarketWheelOffsetMax
							  , RearFitment
							  , MinusFitment
							  , TSQLComputed
							  , FitmentNote
							  , DateCreatedUTC
							  , DateModifiedUTC
							  , VehicleID)
						SELECT
							   @ChassisID
							 , @Search_OEMTireAndWheelConfigID_Rear
							 , @Search_AftermarketWheelDiameter_Current
							 , @Search_AftermarketWheelWidthMin_Rear
							 , @Search_AftermarketWheelWidthMax_Rear
							 , @Search_AftermarketWheelOffsetMin_Rear
							 , @Search_AftermarketWheelOffsetMax_Rear
							 , @Search_RearFitment
							 , @Search_MinusFitment
							 , @Search_TSQLComputed
							 , @Search_FitmentNote
							 , getutcdate()
							 , getutcdate()
							 , @VehicleID
				END

--Skip_Circle_4:	

--	SET @Search_AftermarketWheelDiameter_Current = @Search_AftermarketWheelDiameter_Current - 1
	
--	IF @Search_AftermarketWheelDiameter_Current > @Search_AftermarketWheelDiameter_Rear 
--		BEGIN
--			GOTO Circle_4
--		END
		


	END	
		
Skip_Circle_4:	

	SET @Search_AftermarketWheelDiameter_Current = @Search_AftermarketWheelDiameter_Current - 1
	
	IF @Search_AftermarketWheelDiameter_Current > @Search_AftermarketWheelDiameter_Rear 
		BEGIN
			GOTO Circle_4
		END

Exit_Circle_4:		
		
		
	END -- IF @FrontConfigID <> @RearConfigID



-- Rear axle,  OEM-Plus, END

-- Processing OEM-Plus, END

-- Check entries in [VehicleAftermarketFitment], END

END

CLOSE @cursor_AddVehicles


insert into [1010Tires].[dbo].Vehicle_TPMSSensors (VehicleID, TPMSSensorProductCode, DateCreated, DateModified)
select 
	VehicleID
	, case	when v.Make in ('Acura', 'Daihatsu', 'Honda', 'Infiniti', 'Isuzu', 'Lexus', 'Mazda', 'Mitsubishi', 'Nissan', 'Scion', 'Subaru', 'Suzuki' , 'Toyota')
			then 'UNI-S-JP'
			when v.Make in ('Buick', 'Cadillac', 'Chevrolet', 'Chrysler', 'Dodge', 'Ford', 'Geo', 'GMC', 'Hummer', 'Jeep', 'Lincoln'
							, 'Oldsmobile', 'Plymouth', 'Pontiac', 'Ram', 'Saturn', 'Tesla', 'Mercury', 'Panoz')
			then 'UNI-S-DOM'
			when v.Make in ('Daewoo', 'Hyundai', 'Kia')
			then 'UNI-S-KO'
			when v.Make in ('Aston Martin', 'Audi', 'Bentley', 'BMW', 'Bugatti', 'Fiat', 'Jaguar', 'Lamborghini', 'Lotus', 'Maserati'
							, 'Maybach', 'McLaren', 'Mercedes-Benz', 'Mini', 'Opel', 'Peugeot', 'Porsche', 'Renault', 'Rolls Royce'
							, 'Saab', 'Smart', 'Volkswagen', 'Volvo', 'Land Rover')
			then 'UNI-S-EU'
	else 'kuku'		
	end as TPMSSensorProductCode
	, GETDATE()
	, GETDATE()
from [1010Tires].[dbo].Fitment_Vehicles v inner join [1010Tires].[dbo].[Fitment_Chassis] c on v.ChassisID = c.ChassisID and c.TPMS = 'on' and v.Year >= 1990



-- Update Vehicle_OEM_Data table, BEGIN

-- ========================================================================
-- Task: TBE-980 Optimize procedures at .../Tires/Reviews/...
-- by Kalchuk Ihor 
-- Date: 13 August 2016
-- Description: Find ways to accelerate the opening of site pages.
-- ========================================================================

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Vehicle_OEM_Data]') AND type in (N'U'))
	BEGIN
		TRUNCATE TABLE Vehicle_OEM_Data
	END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Vehicle_OEM_Data]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Vehicle_OEM_Data](
	[VehicleID] [int] NOT NULL,
	[F_BoltPatternNumber] [tinyint] NULL,
	[F_BoltPatternDiameter] [float] NULL,
	[F_Treadwidth] [float] NULL,
	[F_Profile] [float] NULL,
	[F_TireRimDiameter] [float] NULL,
	[F_LoadIndex] [float] NULL,
	[F_SpeedRating] [float] NULL,
	[F_WheelDiameter] [float] NULL,
	[F_WheelWidth] [float] NULL,
	[F_HubBore] [float] NULL,
	[R_BoltPatternNumber] [tinyint] NULL,
	[R_BoltPatternDiameter] [float] NULL,
	[R_Treadwidth] [float] NULL,
	[R_Profile] [float] NULL,
	[R_TireRimDiameter] [float] NULL,
	[R_LoadIndex] [float] NULL,
	[R_SpeedRating] [float] NULL,
	[R_WheelDiameter] [float] NULL,
	[R_WheelWidth] [float] NULL,
	[R_HubBore] [float] NULL,
	[F_OffserMin] [float] NULL,
	[F_OffserMax] [float] NULL,
	[R_OffserMin] [float] NULL,
	[R_OffserMax] [float] NULL,
 CONSTRAINT [PK_Vehicle_OEM_Data] PRIMARY KEY CLUSTERED 
(
	[VehicleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END


-- ########################################################

INSERT INTO Vehicle_OEM_Data
                      (VehicleID, F_WheelDiameter, R_WheelDiameter, F_WheelWidth, R_WheelWidth, F_Treadwidth, R_Treadwidth, F_Profile, F_TireRimDiameter, R_Profile, R_TireRimDiameter, F_LoadIndex, R_LoadIndex, 
                      F_SpeedRating, R_SpeedRating, F_OffserMin, F_OffserMax, R_OffserMin, R_OffserMax, F_BoltPatternNumber, R_BoltPatternNumber, F_BoltPatternDiameter, 
                      R_BoltPatternDiameter, F_HubBore, R_HubBore)
SELECT  Fitment_Vehicles.VehicleID, 
		CAST( CASE WHEN TireSize LIKE '%/%' THEN LTRIM(RTRIM(RIGHT(TireSize, LEN(TireSize) - CHARINDEX('R', TireSize, CHARINDEX('/', TireSize, 1) + 1))))  ELSE LTRIM(RTRIM(RIGHT(TireSize, LEN(TireSize) - CHARINDEX('R', TireSize, CHARINDEX('x', TireSize, 1) + 1))))  END AS float) AS Diameter,
		CAST( CASE WHEN TireSizeRear IS NULL OR TireSizeRear = '' THEN CASE WHEN TireSize LIKE '%/%' THEN LTRIM(RTRIM(RIGHT(TireSize, LEN(TireSize) - CHARINDEX('R', TireSize, CHARINDEX('/', TireSize, 1) + 1))))  ELSE LTRIM(RTRIM(RIGHT(TireSize, LEN(TireSize) - CHARINDEX('R', TireSize, CHARINDEX('x', TireSize, 1) + 1))))  END ELSE CASE WHEN TireSizeRear LIKE '%/%' THEN LTRIM(RTRIM(RIGHT(TireSizeRear, LEN(TireSizeRear) - CHARINDEX('R', TireSizeRear, CHARINDEX('/', TireSizeRear, 1) + 1))))  ELSE LTRIM(RTRIM(RIGHT(TireSizeRear, LEN(TireSizeRear) - CHARINDEX('R', TireSizeRear, CHARINDEX('x', TireSizeRear, 1)  + 1))))  END END AS float) AS DiameterRear, 
		CAST(LTRIM(RTRIM(LEFT(Fitment_ChassisModels.WheelSize, CHARINDEX('x', Fitment_ChassisModels.WheelSize, 1) - 1))) AS float) AS RimWidth, 

		CAST(CASE WHEN WheelSizeRear IS NULL OR WheelSizeRear = '' THEN LTRIM(RTRIM(LEFT(WheelSize, CHARINDEX('x', WheelSize, 1) - 1)))  ELSE LTRIM(RTRIM(LEFT(WheelSizeRear, CHARINDEX('x', WheelSizeRear, 1) - 1)))  END AS float) AS RimWidthRear, 
		CAST(CASE WHEN TireSize LIKE '%/%' THEN LTRIM(RTRIM(LEFT(TireSize, CHARINDEX('/', TireSize, 1) - 1)))  ELSE LTRIM(RTRIM(LEFT(TireSize, CHARINDEX('x', TireSize, 1) - 1)))  END AS float) AS Treadwidth,
		CAST(CASE WHEN TireSizeRear IS NULL OR TireSizeRear = '' THEN CASE WHEN TireSize LIKE '%/%' THEN LTRIM(RTRIM(LEFT(TireSize, CHARINDEX('/', TireSize, 1) - 1))) ELSE LTRIM(RTRIM(LEFT(TireSize, CHARINDEX('x', TireSize, 1) - 1))) END ELSE CASE WHEN TireSizeRear LIKE '%/%' THEN LTRIM(RTRIM(LEFT(TireSizeRear, CHARINDEX('/', TireSizeRear, 1) - 1))) ELSE LTRIM(RTRIM(LEFT(TireSizeRear, CHARINDEX('x', TireSizeRear, 1) - 1))) END END AS float) AS TreadwidthRear,
		CAST(CASE WHEN TireSize LIKE '%/%' THEN LTRIM(RTRIM(SUBSTRING(TireSize, CHARINDEX('/', TireSize, 1) + 1, CHARINDEX('R', TireSize, CHARINDEX('/', TireSize, 1) + 1) - CHARINDEX('/', TireSize, 1) - 1))) ELSE LTRIM(RTRIM(SUBSTRING(TireSize, CHARINDEX('x', TireSize, 1) + 1, CHARINDEX('R', TireSize, CHARINDEX('x', TireSize, 1) + 1) - CHARINDEX('x', TireSize, 1) - 1))) END AS float) AS Profile,
		CAST( CASE WHEN TireSize LIKE '%/%' THEN LTRIM(RTRIM(RIGHT(TireSize, LEN(TireSize) - CHARINDEX('R', TireSize, CHARINDEX('/', TireSize, 1) + 1))))  ELSE LTRIM(RTRIM(RIGHT(TireSize, LEN(TireSize) - CHARINDEX('R', TireSize, CHARINDEX('x', TireSize, 1) + 1))))  END AS float) AS TireRimDiameter,
		CAST(CASE WHEN TireSizeRear IS NULL OR TireSizeRear = '' THEN CASE WHEN TireSize LIKE '%/%' THEN LTRIM(RTRIM(SUBSTRING(TireSize, CHARINDEX('/', TireSize, 1) + 1, CHARINDEX('R', TireSize, CHARINDEX('/', TireSize, 1) + 1) - CHARINDEX('/', TireSize, 1) - 1))) ELSE LTRIM(RTRIM(SUBSTRING(TireSize, CHARINDEX('x', TireSize, 1) + 1, CHARINDEX('R', TireSize, CHARINDEX('x', TireSize, 1) + 1) - CHARINDEX('x', TireSize, 1) - 1))) END ELSE CASE WHEN TireSizeRear LIKE '%/%' THEN LTRIM(RTRIM(SUBSTRING(TireSizeRear, CHARINDEX('/', TireSizeRear, 1) + 1, CHARINDEX('R', TireSizeRear, CHARINDEX('/', TireSizeRear, 1) + 1) - CHARINDEX('/', TireSizeRear, 1) - 1))) ELSE LTRIM(RTRIM(SUBSTRING(TireSizeRear, CHARINDEX('x', TireSizeRear, 1) + 1, CHARINDEX('R', TireSizeRear, CHARINDEX('x', TireSizeRear, 1) + 1) - CHARINDEX('x', TireSizeRear, 1) - 1))) END END AS float) AS ProfileRear, 
		CAST(CASE WHEN TireSizeRear IS NULL OR TireSizeRear = '' THEN CASE WHEN TireSize LIKE '%/%' THEN LTRIM(RTRIM(RIGHT(TireSize, LEN(TireSize) - CHARINDEX('R', TireSize, CHARINDEX('/', TireSize, 1) + 1))))  ELSE LTRIM(RTRIM(RIGHT(TireSize, LEN(TireSize) - CHARINDEX('R', TireSize, CHARINDEX('x', TireSize, 1) + 1))))  END ELSE CASE WHEN TireSizeRear LIKE '%/%' THEN LTRIM(RTRIM(RIGHT(TireSizeRear, LEN(TireSizeRear) - CHARINDEX('R', TireSizeRear, CHARINDEX('/', TireSizeRear, 1) + 1))))  ELSE LTRIM(RTRIM(RIGHT(TireSizeRear, LEN(TireSizeRear) - CHARINDEX('R', TireSizeRear, CHARINDEX('x', TireSizeRear, 1)  + 1))))  END END AS float) AS TireRimDiameterRear, 

		CASE Fitment_ChassisModels.LoadIndex
         WHEN 'D' THEN 65
         WHEN 'E' THEN 80
         WHEN 'B' THEN 60
		 WHEN 'C' THEN 63
		 WHEN 'A' THEN 60
         ELSE Fitment_ChassisModels.LoadIndex END AS LoadIndex, 

		CASE WHEN LoadIndexRear IS NULL OR LoadIndexRear = '' THEN 
			CASE Fitment_ChassisModels.LoadIndex
			 WHEN 'D' THEN 65
			 WHEN 'E' THEN 80
			 WHEN 'B' THEN 60
			 WHEN 'C' THEN 63
			 WHEN 'A' THEN 60
			 ELSE Fitment_ChassisModels.LoadIndex END 
		ELSE 
			CASE Fitment_ChassisModels.LoadIndexRear
			 WHEN 'D' THEN 65
			 WHEN 'E' THEN 80
			 WHEN 'B' THEN 60
			 WHEN 'C' THEN 63
			 WHEN 'A' THEN 60
			 ELSE Fitment_ChassisModels.LoadIndexRear END
		END  AS LoadIndexRear, 

		CAST([1010Tires.com].dbo.fnConvertToSpeedRatingNewNumeric(Fitment_ChassisModels.SpeedRating) AS float) AS SpeedRating, 
		CAST(CASE WHEN SpeedRatingRear IS NULL OR SpeedRatingRear = '' THEN [1010Tires.com].dbo.fnConvertToSpeedRatingNewNumeric(SpeedRating) ELSE [1010Tires.com].dbo.fnConvertToSpeedRatingNewNumeric(SpeedRatingRear) END AS float) AS SpeedRatingRear, 
		CAST(Fitment_ChassisModels.OffsetMinF AS float) AS OffsetMinF, 
		CAST(Fitment_ChassisModels.OffsetMaxF AS float) AS OffsetMaxF, 
		CAST(Fitment_ChassisModels.OffsetMinR AS float) AS OffsetMinR, 
		CAST(Fitment_ChassisModels.OffsetMaxR AS float) AS OffsetMaxR, 
		CAST(LTRIM(RTRIM(LEFT(Fitment_Chassis.BoltPattern, CHARINDEX('x', Fitment_Chassis.BoltPattern, 1) - 1))) AS float) AS BoltNumber, 
		CAST(LTRIM(RTRIM(LEFT(Fitment_Chassis.BoltPattern, CHARINDEX('x', Fitment_Chassis.BoltPattern, 1) - 1))) AS float) AS BoltNumberRear, 
		CAST(LTRIM(RTRIM(RIGHT(Fitment_Chassis.BoltPattern, LEN(Fitment_Chassis.BoltPattern) - CHARINDEX('x', Fitment_Chassis.BoltPattern, 1)))) AS float) AS BoltDiameter, 
		CAST(LTRIM(RTRIM(RIGHT(Fitment_Chassis.BoltPattern, LEN(Fitment_Chassis.BoltPattern) - CHARINDEX('x', Fitment_Chassis.BoltPattern, 1)))) AS float) AS BoltDiameterRear, 
		CAST(Fitment_Chassis.Hubbore AS float) AS Hubbore, 
		CASE WHEN CAST(Fitment_Chassis.HubboreRear AS float) = 0 THEN CAST(Fitment_Chassis.Hubbore AS float) ELSE CAST(Fitment_Chassis.HubboreRear AS float) END AS HubboreRear
FROM         Fitment_ChassisModels INNER JOIN
                      Fitment_Vehicles ON Fitment_ChassisModels.ChassisID = Fitment_Vehicles.ChassisID AND Fitment_ChassisModels.ModelID = Fitment_Vehicles.ModelID INNER JOIN
                      Fitment_Chassis ON Fitment_Chassis.ChassisID = Fitment_Vehicles.ChassisID

-- Update Vehicle_OEM_Data table, END



-- VehicleDailyUpdate, report new vehicles, BEGIN
IF EXISTS (SELECT TOP 1 MAX(VehicleID) FROM Vehicle WHERE VehicleID > @VehicleDailyUpdate_LastVehicleID) AND @VerifyComplianceLocalVendorData = 1
	BEGIN
		INSERT INTO MessageTransactionLog
		([SequenceId], [EventID], [EventDescription], [Message], [ErrorCode], [ErrorMessage], [ProcessName], [RunArguments])
		SELECT  @VehicleDailyUpdate_ID, 1100, 'New', LTRIM(STR(VehicleID)) + '   ' + LTRIM(STR(FitmentDataDBYearID))  + ' ' + MakeName + ' ' + ModelName + ' ' + TrimName, '0', '', '', NULL
		FROM    Vehicle
		WHERE VehicleID > @VehicleDailyUpdate_LastVehicleID
		ORDER BY Vehicle.VehicleID

		SET @VehicleDailyUpdate_Summary_New = @@ROWCOUNT 

	END
-- VehicleDailyUpdate, report new vehicles, END

-- ===============================================================================================

-- Verify compliance of local records and vendor data, BEGIN

IF @AddNewDataOnly = 0 
	BEGIN

		DELETE FROM  @Vehicles_ID

		;
		WITH CTE_1 as (
		SELECT DISTINCT 
					Fitment_Vehicles.VehicleID
					, VehicleOEMPackage.IsStaggeredFitmentFlag
					, VehicleAftermarketFitment.ChassisID
					, VehicleAftermarketFitment.AftermarketWheelDiameter 
					, VehicleAftermarketFitment.AftermarketWheelWidthMin 
					, VehicleAftermarketFitment.AftermarketWheelWidthMax
					, VehicleAftermarketFitment.AftermarketWheelOffsetMin
					, VehicleAftermarketFitment.AftermarketWheelOffsetMax
					, VehicleAftermarketFitment.RearFitment
					, VehicleAftermarketFitment.MinusFitment
		FROM            VehicleAftermarketFitment INNER JOIN
								 Fitment_Vehicles ON VehicleAftermarketFitment.ChassisID = Fitment_Vehicles.ChassisID  AND VehicleAftermarketFitment.VehicleID = Fitment_Vehicles.VehicleID 
					INNER JOIN   VehicleOEMPackage ON Fitment_Vehicles.VehicleID = VehicleOEMPackage.VehicleID AND VehicleAftermarketFitment.OEMTireAndWheelConfigID = VehicleOEMPackage.FrontOEMTireAndWheelConfigID

		UNION

		SELECT DISTINCT 
					Fitment_Vehicles.VehicleID
					, VehicleOEMPackage.IsStaggeredFitmentFlag
					, VehicleAftermarketFitment.ChassisID
					, VehicleAftermarketFitment.AftermarketWheelDiameter 
					, VehicleAftermarketFitment.AftermarketWheelWidthMin 
					, VehicleAftermarketFitment.AftermarketWheelWidthMax
					, VehicleAftermarketFitment.AftermarketWheelOffsetMin
					, VehicleAftermarketFitment.AftermarketWheelOffsetMax
					, VehicleAftermarketFitment.RearFitment
					, VehicleAftermarketFitment.MinusFitment
		FROM            VehicleAftermarketFitment INNER JOIN
								 Fitment_Vehicles ON VehicleAftermarketFitment.ChassisID = Fitment_Vehicles.ChassisID  AND VehicleAftermarketFitment.VehicleID = Fitment_Vehicles.VehicleID 
					INNER JOIN   VehicleOEMPackage ON Fitment_Vehicles.VehicleID = VehicleOEMPackage.VehicleID AND VehicleAftermarketFitment.OEMTireAndWheelConfigID = VehicleOEMPackage.RearOEMTireAndWheelConfigID


		EXCEPT

		SELECT DISTINCT [VehicleID]
			  ,[IsStaggeredFitmentFlag]
			  ,[ChassisID]
			  ,[AftermarketWheelDiameter]
			  ,[AftermarketWheelWidthMin]
			  ,[AftermarketWheelWidthMax]
			  ,[AftermarketWheelOffsetMin]
			  ,[AftermarketWheelOffsetMax]
			  ,[RearFitment]
			  ,[MinusFitment]
		FROM [1010Tires].[dbo].[Fitment_Check_TEMP]
		),
		----------------------------------------------------------------------------------
		CTE_2 AS (

		-- Collected record 
		SELECT DISTINCT
					Vehicle.VehicleID,
					BoltPatternNumber AS [F_BoltPatternNumber],
					BoltPatternDiameter AS  [F_BoltPatternDiameter],
					FrontConfig.Treadwidth AS [F_Treadwidth],
					FrontConfig.Profile AS [F_Profile],
					FrontConfig.TireRimDiameter AS [F_TireRimDiameter],
					FrontConfig.LoadIndex AS [F_LoadIndex],
					[1010Tires.com].dbo.fnConvertToSpeedRatingNewNumeric(FrontConfig.SpeedRating) AS [F_SpeedRating],
					FrontConfig.WheelDiameter AS [F_WheelDiameter],
					FrontConfig.WheelWidth AS [F_WheelWidth],
					FrontConfig.HubBore AS [F_HubBore],
					BoltPatternNumber AS [R_BoltPatternNumber],
					BoltPatternDiameter AS  [R_BoltPatternDiameter],
					RearConfig.Treadwidth AS [R_Treadwidth],
					RearConfig.Profile AS [R_Profile],
					RearConfig.TireRimDiameter AS [R_TireRimDiameter],
					RearConfig.LoadIndex AS [R_LoadIndex],
					[1010Tires.com].dbo.fnConvertToSpeedRatingNewNumeric(RearConfig.SpeedRating) AS [R_SpeedRating],
					RearConfig.WheelDiameter AS [R_WheelDiameter],
					RearConfig.WheelWidth AS [R_WheelWidth],
					RearConfig.HubBore AS [R_HubBore],
					[1010Tires].dbo.[Fitment_Vehicles].ChassisID  ,
					FitmentDataDBModelID AS [ModelID], FitmentDataDBYearID AS [Year], MakeName AS [Make], ModelName AS [Model], TrimName
		FROM            [1010Tires].dbo.Vehicle
						INNER JOIN [1010Tires].dbo.[VehicleOEMPackage] ON [1010Tires].dbo.[VehicleOEMPackage].VehicleID = [1010Tires].dbo.Vehicle.VehicleID 
						INNER JOIN [1010Tires].dbo.[VehicleOEMTireAndWheelConfig] AS FrontConfig ON [1010Tires].dbo.[VehicleOEMPackage].FrontOEMTireAndWheelConfigID = FrontConfig.OEMTireAndWheelConfigID 
						INNER JOIN [1010Tires].dbo.[VehicleOEMTireAndWheelConfig] AS RearConfig ON [1010Tires].dbo.[VehicleOEMPackage].RearOEMTireAndWheelConfigID = RearConfig.OEMTireAndWheelConfigID 
						INNER JOIN [1010Tires].dbo.[Fitment_Vehicles] ON [1010Tires].dbo.[Fitment_Vehicles].VehicleID = [1010Tires].dbo.Vehicle.VehicleID  

		EXCEPT

		SELECT  DISTINCT
				Vehicle_OEM_Data.VehicleID, 
				Vehicle_OEM_Data.F_BoltPatternNumber, 
				Vehicle_OEM_Data.F_BoltPatternDiameter, 
				Vehicle_OEM_Data.F_Treadwidth, 
				Vehicle_OEM_Data.F_Profile, 
				Vehicle_OEM_Data.F_TireRimDiameter, 
				Vehicle_OEM_Data.F_LoadIndex, 
				Vehicle_OEM_Data.F_SpeedRating, 
				Vehicle_OEM_Data.F_WheelDiameter, 
				Vehicle_OEM_Data.F_WheelWidth, 
				Vehicle_OEM_Data.F_HubBore, 
				Vehicle_OEM_Data.R_BoltPatternNumber, 
				Vehicle_OEM_Data.R_BoltPatternDiameter, 
				Vehicle_OEM_Data.R_Treadwidth, 
				Vehicle_OEM_Data.R_Profile, 
				Vehicle_OEM_Data.R_TireRimDiameter, 
				Vehicle_OEM_Data.R_LoadIndex, 
				Vehicle_OEM_Data.R_SpeedRating, 
				Vehicle_OEM_Data.R_WheelDiameter, 
				Vehicle_OEM_Data.R_WheelWidth, 
				Vehicle_OEM_Data.R_HubBore, 
				Fitment_Vehicles.ChassisID, 
				Fitment_Vehicles.ModelID, 
				Fitment_Vehicles.Year, 
				Fitment_Vehicles.Make, 
				Fitment_Vehicles.Model, 
				Fitment_Vehicles.Body + ' ' + Fitment_Vehicles.[Option] AS [TrimName]
		FROM            [1010Tires].dbo.Vehicle_OEM_Data INNER JOIN
								 [1010Tires].dbo.Fitment_Vehicles ON [1010Tires].dbo.Fitment_Vehicles.VehicleID = [1010Tires].dbo.Vehicle_OEM_Data.VehicleID

		)

		INSERT INTO @Vehicles_ID

		SELECT CTE_1.VehicleID FROM CTE_1 
		UNION
		SELECT CTE_2.VehicleID FROM CTE_2 


		-- VehicleDailyUpdate, report updated vehicles, BEGIN
		IF EXISTS (SELECT TOP 1 Vehicle.VehicleID FROM @Vehicles_ID AS [V_ID] INNER JOIN Vehicle ON Vehicle.VehicleID = [V_ID].VehicleID ) AND @VerifyComplianceLocalVendorData = 1
			BEGIN
				INSERT INTO MessageTransactionLog
				([SequenceId], [EventID], [EventDescription], [Message], [ErrorCode], [ErrorMessage], [ProcessName], [RunArguments])
				SELECT  @VehicleDailyUpdate_ID, 1101, 'Updated', LTRIM(STR(Vehicle.VehicleID)) + '   ' + LTRIM(STR(FitmentDataDBYearID))  + ' ' + MakeName + ' ' + ModelName + ' ' + TrimName, '0', '', '', NULL
				FROM            @Vehicles_ID AS [V_ID] INNER JOIN
								 Vehicle ON Vehicle.VehicleID = [V_ID].VehicleID
				ORDER BY Vehicle.VehicleID

				SET @VehicleDailyUpdate_Summary_Updated = @@ROWCOUNT 

			END
		-- VehicleDailyUpdate, report updated vehicles, END

		-- VehicleDailyUpdate, report err vehicles, BEGIN
		IF EXISTS (SELECT TOP 1 Vehicle.VehicleID FROM @Vehicles_ID AS [V_ID] INNER JOIN Vehicle ON Vehicle.VehicleID = [V_ID].VehicleID ) AND @VerifyComplianceLocalVendorData = 0
			BEGIN
				INSERT INTO MessageTransactionLog
				([SequenceId], [EventID], [EventDescription], [Message], [ErrorCode], [ErrorMessage], [ProcessName], [RunArguments])
				SELECT  @VehicleDailyUpdate_ID, 1102, 'Error', LTRIM(STR(Vehicle.VehicleID)) + '   ' + LTRIM(STR(FitmentDataDBYearID))  + ' ' + MakeName + ' ' + ModelName + ' ' + TrimName, '0', '', '', NULL
				FROM            @Vehicles_ID AS [V_ID] INNER JOIN
								 Vehicle ON Vehicle.VehicleID = [V_ID].VehicleID
				ORDER BY Vehicle.VehicleID

				SET @VehicleDailyUpdate_Summary_Error = @@ROWCOUNT 

			END
		-- VehicleDailyUpdate, report err vehicles, END

				IF EXISTS (SELECT TOP 1 Vehicleid FROM @Vehicles_ID)
					BEGIN
						DELETE FROM [1010Tires].dbo.[VehicleOEMTireAndWheelConfig]
						FROM [1010Tires].dbo.[VehicleOEMTireAndWheelConfig]
							  INNER JOIN VehicleOEMPackage ON VehicleOEMTireAndWheelConfig.OEMTireAndWheelConfigID = VehicleOEMPackage.FrontOEMTireAndWheelConfigID  
						WHERE (VehicleOEMPackage.VehicleID IN (SELECT * FROM @Vehicles_ID))

						DELETE FROM [1010Tires].dbo.[VehicleOEMTireAndWheelConfig]
						FROM [1010Tires].dbo.[VehicleOEMTireAndWheelConfig]
							  INNER JOIN VehicleOEMPackage ON VehicleOEMTireAndWheelConfig.OEMTireAndWheelConfigID = VehicleOEMPackage.RearOEMTireAndWheelConfigID 
						WHERE (VehicleOEMPackage.VehicleID IN (SELECT * FROM @Vehicles_ID))

						DELETE FROM VehicleAftermarketFitment
						FROM            VehicleAftermarketFitment INNER JOIN
												 VehicleOEMPackage ON VehicleAftermarketFitment.OEMTireAndWheelConfigID = VehicleOEMPackage.RearOEMTireAndWheelConfigID INNER JOIN
												 Fitment_Vehicles ON VehicleOEMPackage.VehicleID = Fitment_Vehicles.VehicleID AND VehicleAftermarketFitment.ChassisID = Fitment_Vehicles.ChassisID
						WHERE        (VehicleOEMPackage.VehicleID IN (SELECT * FROM @Vehicles_ID))

						DELETE FROM VehicleAftermarketFitment
						FROM            VehicleAftermarketFitment INNER JOIN
												 VehicleOEMPackage ON VehicleAftermarketFitment.OEMTireAndWheelConfigID = VehicleOEMPackage.FrontOEMTireAndWheelConfigID INNER JOIN
												 Fitment_Vehicles ON VehicleOEMPackage.VehicleID = Fitment_Vehicles.VehicleID AND VehicleAftermarketFitment.ChassisID = Fitment_Vehicles.ChassisID
						WHERE        (VehicleOEMPackage.VehicleID IN (SELECT * FROM @Vehicles_ID))

						DELETE FROM VehicleOEMPackage
						WHERE        (VehicleID IN (SELECT * FROM @Vehicles_ID))

						DELETE FROM Vehicle
						WHERE        (VehicleID IN (SELECT * FROM @Vehicles_ID))
					END

		

		IF @VerifyComplianceLocalVendorData = 1
			BEGIN
				SET @VerifyComplianceLocalVendorData = 0
				--COMMIT TRANSACTION;
				IF EXISTS (SELECT TOP 1 Vehicleid FROM @Vehicles_ID)
					BEGIN
						--BEGIN TRANSACTION;
						GOTO VerifyComplianceLocalVendorData_Label
					END
			END

	END
-- Verify compliance of local records and vendor data, END

DELETE FROM  @Vehicles_ID;
DEALLOCATE @cursor_AddVehicles;

IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
	BEGIN
		COMMIT TRANSACTION
		--PRINT 0
	END

	--SELECT
	--0 AS ErrorNumber
	--,0 AS ErrorLine
	--,'Script executed without errors' AS ErrorMessage;

	INSERT INTO MessageTransactionLog
	([SequenceId], [EventID], [EventDescription], [Message], [ErrorCode], [ErrorMessage], [ProcessName], [RunArguments])
	VALUES
	(@VehicleDailyUpdate_ID, 1103, 'Vehicle daily update summary. New: ' + LTRIM(STR(@VehicleDailyUpdate_Summary_New)) + '; Updated: ' + LTRIM(STR(@VehicleDailyUpdate_Summary_Updated)) + '; Error: ' + LTRIM(STR(@VehicleDailyUpdate_Summary_Error)), '', '0', '', 'VehicleDailyUpdate', NULL)

	INSERT INTO MessageTransactionLog
	([SequenceId], [EventID], [EventDescription], [Message], [ErrorCode], [ErrorMessage], [ProcessName], [RunArguments])
	VALUES
	(@VehicleDailyUpdate_ID, 10002, 'End Process Successfully', '', '0', '', 'VehicleDailyUpdate', NULL)

	
END TRY

BEGIN CATCH

IF EXISTS (SELECT transaction_id FROM sys.dm_tran_session_transactions WHERE session_id = @@SPID)
	BEGIN
		ROLLBACK TRANSACTION
	END
	
	--SELECT
	--ERROR_NUMBER() AS ErrorNumber
	--,ERROR_LINE() AS ErrorLine
	--,ERROR_MESSAGE() AS ErrorMessage;

	INSERT INTO MessageTransactionLog
		([SequenceId], [EventID], [EventDescription], [Message], [ErrorCode], [ErrorMessage], [ProcessName], [RunArguments])
	VALUES
		(@VehicleDailyUpdate_ID, 10003, 'End Process with errors', '', '100', SUBSTRING ('ErrNumber: ' + LTRIM(STR(ERROR_NUMBER())) + ', ErrLine: ' + LTRIM(STR(ERROR_LINE())) + ', ErrMessage: ' + ERROR_MESSAGE(),1,499), 'VehicleDailyUpdate', NULL)


END CATCH


END 

GO

-- ######################################################################################################################################
-- ######################################################################################################################################
-- ######################################################################################################################################
