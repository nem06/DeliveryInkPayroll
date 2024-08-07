USE [master]
GO
/****** Object:  Database [DAHNAENTERPRISEINC.MDF]    Script Date: 2024-06-18 4:27:44 PM ******/
CREATE DATABASE [DAHNAENTERPRISEINC.MDF]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Database1', FILENAME = N'D:\Dahna\Container\Databases\DahnaEnterpriseInc.mdf' , SIZE = 51968KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Database1_log', FILENAME = N'D:\Dahna\Container\Databases\DahnaEnterpriseInc_log.ldf' , SIZE = 1536KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [DAHNAENTERPRISEINC.MDF].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET ARITHABORT OFF 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET AUTO_SHRINK ON 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET  DISABLE_BROKER 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET  MULTI_USER 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET DB_CHAINING OFF 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET QUERY_STORE = OFF
GO
USE [DAHNAENTERPRISEINC.MDF]
GO
/****** Object:  UserDefinedFunction [dbo].[ShortRouteString]    Script Date: 2024-06-18 4:27:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[ShortRouteString] 
(
	@input NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @output NVARCHAR(MAX)

	;WITH SplitValues AS
	(
		SELECT TRIM(value) AS value
		FROM STRING_SPLIT(@input, '|')
	),
	ProcessedValues AS
	(
		SELECT
			value,
			SUBSTRING(value, CHARINDEX('M', value) + 2, 1) AS prefix,
			TRY_CAST(RIGHT(SUBSTRING(value, CHARINDEX('M', value), LEN(value)), 2) AS INT) AS suffix
		FROM SplitValues
	),
	GroupedValues AS
	(
		SELECT 
			prefix,
			STRING_AGG(CONVERT(NVARCHAR(10), suffix), '/') WITHIN GROUP (ORDER BY suffix) AS numbers
		FROM ProcessedValues
		GROUP BY prefix
	)
	SELECT @output = STRING_AGG(prefix + numbers, ', ')
	FROM GroupedValues

	RETURN @output

END
GO
/****** Object:  Table [dbo].[DeliveryMapping]    Script Date: 2024-06-18 4:27:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeliveryMapping](
	[Id] [int] IDENTITY(1000,1) NOT NULL,
	[Date] [date] NULL,
	[Route] [varchar](10) NOT NULL,
	[EmployeeId] [varchar](8) NULL,
	[InsertedOn] [date] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RawDraw]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RawDraw](
	[Id] [int] IDENTITY(100,1) NOT NULL,
	[Date] [date] NOT NULL,
	[Day] [varchar](15) NOT NULL,
	[DayClass] [varchar](5) NOT NULL,
	[WeekEnding] [date] NOT NULL,
	[Plant] [int] NOT NULL,
	[Route] [varchar](10) NOT NULL,
	[Product] [varchar](10) NOT NULL,
	[CustomerClassification] [varchar](3) NOT NULL,
	[Draw] [int] NULL,
	[CATAddressID] [int] NOT NULL,
	[ZipCode] [varchar](3) NOT NULL,
	[ZipPlus4] [varchar](3) NOT NULL,
	[Count] [int] NULL,
	[InsertedOn] [date] NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[DrawCountAndCarrier]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DrawCountAndCarrier] AS

Select 
	DL.WeekEnding, 
	DL.Date, 
	DL.Day, 
	DL.DayClass, 
	DL.Route, 
	Product, 
	Draw, 
	CASE 
		WHEN DM.EmployeeId is not null then DM.EmployeeId
		ELSE 'D0001'
	END AS EmployeeId
FROM (
	SELECT WeekEnding, Date, Day, DayClass, Route, Product, SUM(Draw) AS Draw
	FROM (
		SELECT WeekEnding, Date, Route, Product, Day, DayClass, SUM(Draw) AS Draw
		FROM RawDraw
		WHERE CustomerClassification IN ('Z1', 'ZW')
		--AND Product NOT IN ('GAM', 'STAR', 'TSUN', 'NNP', 'NYT')
		GROUP BY WeekEnding, Route, Product, Day, Date, DayClass
		UNION
		--SELECT WeekEnding, Date, Route, Product + '(SMP)' AS Product, Day, DayClass, SUM(Draw) AS Draw
		SELECT WeekEnding, Date, Route, 'GAM(SMP)' AS Product, Day, DayClass, SUM(Draw) AS Draw
		FROM RawDraw
		WHERE CustomerClassification = 'Z6'
		--AND Product = 'GAM'
		GROUP BY WeekEnding, Route, Product, Day, Date, DayClass
		UNION
		SELECT WeekEnding, Date, Route, Product + '_DROP' AS Product, Day, DayClass, SUM(Count) AS Draw
		--SELECT WeekEnding, Date, Route, 'DROP*' AS Product, Day, DayClass, SUM(Count) AS Draw
		FROM RawDraw
		WHERE CustomerClassification IN ('Z4', 'ZZ')
		--AND Product IN ('STAR', 'TSUN')
		GROUP BY WeekEnding, Route, Product, Day, Date, DayClass
	) AS T
	-- WHERE T.Route = '5971M4G009' AND
	-- WeekEnding in ('2024-02-18', '2024-02-25')
	-- WeekEnding in ('2024-02-04','2024-02-11')
	GROUP BY WeekEnding, Date, Day, DayClass, Route,Product
)AS DL 
Left Join [dbo].[DeliveryMapping] AS DM 
on DL.Date = DM.Date and DL.Route = DM.Route
--Where DM.EmployeeId = 'D0029'
--ORDER BY Route, Date, Product
GO
/****** Object:  Table [dbo].[DeliveryRate]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeliveryRate](
	[EmployeeId] [varchar](5) NOT NULL,
	[STAR_MF] [decimal](2, 2) NOT NULL,
	[STAR_SAT] [decimal](2, 2) NOT NULL,
	[STAR_SUN] [decimal](2, 2) NOT NULL,
	[GAM_MF] [decimal](2, 2) NOT NULL,
	[GAM_SAT] [decimal](2, 2) NOT NULL,
	[GAM_SUN] [decimal](2, 2) NOT NULL,
	[GAM(SMP)_MF] [decimal](2, 2) NOT NULL,
	[GAM(SMP)_SAT] [decimal](2, 2) NOT NULL,
	[GAM(SMP)_SUN] [decimal](2, 2) NOT NULL,
	[NNP_MF] [decimal](2, 2) NOT NULL,
	[NNP_SAT] [decimal](2, 2) NOT NULL,
	[NNP_SUN] [decimal](2, 2) NOT NULL,
	[TSUN_MF] [decimal](2, 2) NOT NULL,
	[TSUN_SAT] [decimal](2, 2) NOT NULL,
	[TSUN_SUN] [decimal](2, 2) NOT NULL,
	[NYT_MF] [decimal](2, 2) NOT NULL,
	[NYT_SAT] [decimal](2, 2) NOT NULL,
	[NYT_SUN] [decimal](2, 2) NOT NULL,
	[STWK] [decimal](2, 2) NOT NULL,
	[NYBR] [decimal](2, 2) NOT NULL,
	[TVBK] [decimal](2, 2) NOT NULL,
	[OTHER] [decimal](2, 2) NOT NULL,
	[DROP] [decimal](2, 2) NULL,
	[ROUTE] [varchar](15) NULL,
	[TIPS] [bit] NULL,
	[INS] [decimal](2, 2) NULL,
	[Active] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ViewDeliveryRate]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[ViewDeliveryRate] AS
SELECT 
	EmployeeID,
	Route,
	CASE
		WHEN CHARINDEX('_', Product) > 0 THEN SUBSTRING(Product, 1, CHARINDEX('_', Product) - 1)
		ELSE Product
	 END AS Product,
	 CASE
		WHEN CHARINDEX('_', Product) > 0 THEN 	SUBSTRING(Product, CHARINDEX('_', Product) + 1, LEN(Product) - CHARINDEX(' ', Product)) 
		ELSE NULL
	END AS DayClass,
	Rate
FROM(
	SELECT 
		EmployeeId, 
		Route,
		STAR_MF, STAR_SAT, STAR_SUN, 
		[GAM_MF], [GAM_SAT], [GAM_SUN], 
		[GAM(SMP)_MF], [GAM(SMP)_SAT], [GAM(SMP)_SUN], 
		[NNP_MF], [NNP_SAT], [NNP_SUN], 
		[TSUN_MF], [TSUN_SAT], [TSUN_SUN], 
		[NYT_MF], [NYT_SAT], [NYT_SUN],
		[STWK], [NYBR], [TVBK], [OTHER], [DROP], [INS]
	FROM [dbo].[DeliveryRate]
	WHERE Active = 1
	--WHERE EmployeeId = 'D0031'
) AS SourceTable
UNPIVOT
(
	Rate FOR Product IN (
		STAR_MF, STAR_SAT, STAR_SUN, 
		[GAM_MF], [GAM_SAT], [GAM_SUN], 
		[GAM(SMP)_MF], [GAM(SMP)_SAT], [GAM(SMP)_SUN], 
		[NNP_MF], [NNP_SAT], [NNP_SUN], 
		[TSUN_MF], [TSUN_SAT], [TSUN_SUN], 
		[NYT_MF], [NYT_SAT], [NYT_SUN],
		[STWK], [NYBR], [TVBK], [OTHER], [DROP], [INS]
	)
) AS UnpivotTable;
GO
/****** Object:  Table [dbo].[InsertList]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InsertList](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[InsName] [varchar](50) NULL,
	[Plant] [int] NOT NULL,
	[Product] [varchar](5) NOT NULL,
	[DistributionDate] [date] NOT NULL,
	[ZipCodes] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[ViewInsertCounts]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[ViewInsertCounts] AS
SELECT 
	I.DistributionDate, 
	I.Product, 
	I.InsName, 
	R.Route, 
	D.EmployeeId,
	SUM(R.draw) AS TotalDraw,
	MAX(DR.Rate) AS Rate,
	SUM(R.draw)*MAX(DR.Rate) AS Amount
FROM RawDraw R
JOIN [dbo].[InsertList] I ON 
    R.Plant = I.Plant 
    AND R.Product = I.Product 
    AND R.Date = I.DistributionDate
    AND EXISTS (
        SELECT 1
        FROM STRING_SPLIT(I.ZipCodes, ',') AS S
        WHERE S.value = R.ZipCode
    )
JOIN [dbo].[DeliveryMapping] D ON
	D.Date = R.Date And D.Route = R.Route
JOIN  [dbo].[ViewDeliveryRate] DR ON
	D.EmployeeId = DR.EmployeeId AND DR.Product = 'INS'
--WHERE I.DistributionDate Between '2024-03-25' AND '2024-04-07'
GROUP BY I.DistributionDate, I.Product, I.InsName, R.Route, D.EmployeeId
GO
/****** Object:  View [dbo].[GetDrawsWithAmount]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[GetDrawsWithAmount] AS
SELECT FT.Date, FT.Route, FT.EmployeeId,FT.DayClass, FT.Product,FT.TotalDraw,FT.Rate, sum(AMOUNT) AS Amount
FROM
(
	SELECT 
			T1.Date,
			T1.DayClass,
			T1.Route,
			T1.product,
			SUM(T1.Draw) AS TotalDraw,
			COALESCE(MAX(T0.Rate), MAX(T2.Rate), MAX(T3.Rate), MAX(T33.Rate), MAX(T4.Rate), MAX(T44.Rate), MAX(T5.Rate), MAX(T55.Rate)) AS Rate,
			(SUM(T1.Draw) * COALESCE(MAX(T0.Rate), MAX(T2.Rate), MAX(T3.Rate), MAX(T33.Rate), MAX(T4.Rate), MAX(T44.Rate), MAX(T5.Rate), MAX(T55.Rate))) AS AMOUNT,
			T1.EmployeeId
	FROM 
		[dbo].[DrawCountAndCarrier] T1
	LEFT JOIN 
		ViewDeliveryRate T0 
	ON 
		T1.Product = T0.Product 
		AND T0.Route = T1.Route
		AND T0.DayClass = T1.DayClass 
		AND T0.EmployeeId = T1.EmployeeId
	LEFT JOIN 
		ViewDeliveryRate T2 
	ON 
		T1.Product = T2.Product 
		AND T2.Route IS NULL
		AND T2.DayClass = T1.DayClass 
		AND T2.EmployeeId = T1.EmployeeId
	LEFT JOIN 
		ViewDeliveryRate T3 
	ON 
		T1.Product LIKE '%_DROP'
		AND T3.Route = T1.Route
		AND T3.Product = 'DROP'
		AND T3.EmployeeId = T1.EmployeeId
	LEFT JOIN 
		ViewDeliveryRate T33 
	ON 
		T1.Product LIKE '%_DROP'
		AND T33.Route is null
		AND T33.Product = 'DROP'
		AND T33.EmployeeId = T1.EmployeeId
	LEFT JOIN 
		ViewDeliveryRate T4 
	ON 
		T1.Product NOT IN (SELECT Product FROM ViewDeliveryRate) 
		AND T4.Route = T1.Route
		AND T4.Product = 'OTHER'
		AND T4.EmployeeId = T1.EmployeeId
	LEFT JOIN 
		ViewDeliveryRate T44 
	ON 
		T1.Product NOT IN (SELECT Product FROM ViewDeliveryRate) 
		AND T44.Route is null
		AND T44.Product = 'OTHER'
		AND T44.EmployeeId = T1.EmployeeId
	LEFT JOIN
		ViewDeliveryRate T5
	ON
		T1.Product = T5.Product 
		AND T5.Route = T1.Route
		AND T5.DayClass is NULL
		AND T5.EmployeeId = T1.EmployeeId
	LEFT JOIN
		ViewDeliveryRate T55
	ON
		T1.Product = T55.Product 
		AND T55.Route is null
		AND T55.DayClass is NULL
		AND T55.EmployeeId = T1.EmployeeId
	GROUP BY  T1.Date,T1.DayClass, T1.Product, T1.Route, T1.EmployeeId
) AS FT
GROUP BY  FT.Date, FT.Route,FT.DayClass,FT.TotalDraw,FT.Rate, FT.EmployeeId,  Ft.Product

GO
/****** Object:  View [dbo].[GetAdjustments]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[GetAdjustments] AS
SELECT
	T.EmployeeID,
	T.Date,
	T.BiWeekEnd,
	T.Route,
	T.Description,
	T.Type,
	SUM(T.Draw) AS Draw,
	MAX(T.Rate) AS Rate,
	SUM(T.Amount) AS Amount
FROM
(
	(
		SELECT 
			EmployeeID,
			Date,
			CASE 
                WHEN DATEDIFF(DAY, '2024-01-14', T.Date) % 14 = 0 THEN T.Date 
                ELSE DATEADD(DAY, ((DATEDIFF(DAY, '2024-01-14', T.Date) / 14) + 1) * 14, '2024-01-14')
            END 
			AS BiWeekEnd,
			ROUTE,
			Description,
			Type,
			Draw,
			CASE WHEN Description LIKE '%_DROP' AND RowNUM != 1 THEN NULL ELSE Rate END AS RATE,
			CASE WHEN Description LIKE '%_DROP' AND RowNUM != 1 THEN NULL ELSE AMOUNT END AS AMOUNT
		FROM
		(
			SELECT
				EmployeeID,
				Date,
				ROUTE,
				Product AS Description,
				CASE WHEN PRODUCT LIKE '%_DROP' THEN 'DRAW_DROP' ELSE 'DRAW' END AS Type,
				SUM(TotalDraw) AS Draw,
				Rate,
				Sum(Amount) AS AMOUNT,
				ROW_NUMBER() OVER (PARTITION BY Date,Route,
                                     CASE WHEN PRODUCT LIKE '%_DROP' THEN NULL ELSE PRODUCT END
                           ORDER BY SUM(TotalDraw) DESC, Product DESC) AS RowNum
			FROM [dbo].[GetDrawsWithAmount] AS T5
			WHERE Product NOT IN ('STAR', 'GAM', 'GAM(SMP)','NNP','NYT','TSUN', 'TVBK_DROP', 'CREG')
			GROUP BY EmployeeID,Date, ROUTE, Product,Rate
		) AS T
		
	)
	UNION
	(
		SELECT 
			EmployeeID,
			DistributionDate AS Date,
			CASE 
                WHEN DATEDIFF(DAY, '2024-01-14', DistributionDate) % 14 = 0 THEN DistributionDate 
                ELSE DATEADD(DAY, ((DATEDIFF(DAY, '2024-01-14', DistributionDate) / 14) + 1) * 14, '2024-01-14') 
            END
			AS BiWeekEnd,
			ROUTE,
			Product + ':' + INSName AS Description,
			'INS' AS Type,
			SUM(TotalDraw) AS Draw,
			Rate,
			Sum(Amount) AS AMOUNT
		FROM [dbo].[ViewInsertCounts]
		GROUP BY EmployeeID,DistributionDate, ROUTE, Product, INSName, Rate
	)
) T
--WHERE T.Date BETWEEN '2024-03-25' AND '2024-04-07'
--AND Route = '5961M4W002'
Group By T.EmployeeID,T.Date,T.BiWeekEnd,T.Route, T.Description, T.Type
GO
/****** Object:  View [dbo].[GetAdjustmentDescriptionAmount]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[GetAdjustmentDescriptionAmount] AS
SELECT 
	EmployeeId,
	BiWeekEnd,
	Route,
	CONVERT(VARCHAR,SUM(Draw)) + ' x ' + Description  AS Description,
	--Description + 
	--	'('+ CONVERT(VARCHAR,SUM(Draw)) + 
	--	CASE WHEN (SUM(Amount) is not null And SUM(Amount)/MAX(Rate) != SUM(Draw) ) 
	--		THEN (')(Payable '+ CONVERT(VARCHAR,CONVERT(int,(SUM(Amount)/MAX(Rate)))) + ' x '+ CONVERT(VARCHAR,MAX(Rate)) +' = '+ CONVERT(VARCHAR,SUM(Amount)) + ')') 
	--		ELSE CASE WHEN (SUM(Amount) is not null) THEN' x '+ CONVERT(VARCHAR,MAX(Rate)) +' = '+ CONVERT(VARCHAR,SUM(Amount)) ELSE ')(Payable 0' END +')'   
	--	END
	--AS Description,
	Type,
	SUM(Draw) AS Draw,
	MAX(Rate) AS Rate,
	SUM(Amount) AS AMOUNT
FROM [dbo].[GetAdjustments]
--WHERE route = '5961M4W002'
Group By EmployeeId,BiWeekEnd,Route,Description,Type
GO
/****** Object:  Table [dbo].[Collections]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Collections](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SubscriptionID] [varchar](20) NULL,
	[Amount] [decimal](18, 2) NULL,
	[Name] [varchar](50) NULL,
	[Address] [varchar](100) NULL,
	[Route] [varchar](15) NULL,
	[EmployeeID] [varchar](10) NULL,
	[BiWeekEnd] [date] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Employee]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employee](
	[EmployeeId] [varchar](5) NOT NULL,
	[Old_Id] [varchar](8) NULL,
	[Name] [varchar](50) NOT NULL,
	[PayeeName] [varchar](50) NOT NULL,
	[Status] [varchar](10) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FLATPAY]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FLATPAY](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeID] [varchar](10) NULL,
	[Route] [varchar](15) NULL,
	[Amount] [decimal](18, 2) NULL,
	[Status] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OtherTaskMapping]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OtherTaskMapping](
	[Id] [int] IDENTITY(1000,1) NOT NULL,
	[Date] [date] NULL,
	[Role] [varchar](50) NULL,
	[EmployeeId] [varchar](8) NULL,
	[InsertedOn] [date] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OtherTaskRate]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OtherTaskRate](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Role] [nvarchar](25) NOT NULL,
	[Description] [varchar](200) NULL,
	[EmployeeID] [varchar](10) NULL,
	[Rate] [decimal](18, 2) NULL,
	[Frequency] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductTypes]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductTypes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Product] [varchar](10) NOT NULL,
	[Type] [varchar](10) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RouteAdjustment]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RouteAdjustment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeID] [varchar](10) NULL,
	[Route] [varchar](15) NULL,
	[Amount] [decimal](18, 2) NULL,
	[Frequency] [int] NULL,
	[Status] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Tips]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tips](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Product] [varchar](10) NULL,
	[BiWeekEnd] [date] NULL,
	[TipDate] [date] NULL,
	[Route] [varchar](15) NULL,
	[Address] [varchar](100) NULL,
	[Amount] [decimal](18, 2) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UnusualPayments]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UnusualPayments](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeId] [varchar](10) NULL,
	[Description] [varchar](50) NULL,
	[Amount] [decimal](10, 2) NULL,
	[BiWeekEnd] [date] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DeliveryMapping] ADD  DEFAULT (getdate()) FOR [InsertedOn]
GO
ALTER TABLE [dbo].[OtherTaskMapping] ADD  DEFAULT (getdate()) FOR [InsertedOn]
GO
ALTER TABLE [dbo].[RawDraw] ADD  DEFAULT (getdate()) FOR [InsertedOn]
GO
/****** Object:  StoredProcedure [dbo].[CheckDrawData]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CheckDrawData]
	@jsonData NVARCHAR(MAX),
	@jsonDataOut NVARCHAR(MAX) out
AS
BEGIN
	declare @startDate Date = JSON_VALUE(@jsonData, '$.startDate')
	declare @endDate Date = JSON_VALUE(@jsonData, '$.endDate')

	SELECT
		@jsonDataOut = count(distinct Date)
	FROM [dbo].[RawDraw]
	WHERE DATE BETWEEN @startDate AND @endDate
END
GO
/****** Object:  StoredProcedure [dbo].[GetCurrentEmployee]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetCurrentEmployee]
	-- Add the parameters for the stored procedure here
	@jsonDataOut NVARCHAR(MAX) out
AS
BEGIN
	set @jsonDataOut = (SELECT * FROM [dbo].[Employee]
	FOR JSON PATH)
END
GO
/****** Object:  StoredProcedure [dbo].[GetMasterReport]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetMasterReport]
	@jsonData NVARCHAR(MAX),
	@jsonDataOut NVARCHAR(MAX) out
AS
BEGIN

declare @startDate Date = JSON_VALUE(@jsonData, '$.startDate')
declare @endDate Date = JSON_VALUE(@jsonData, '$.endDate')

--declare @startDate Date = '2024-03-25'
--declare @endDate Date = '2024-04-07'

IF OBJECT_ID('tempdb..#T0') IS NOT NULL
BEGIN
    DROP TABLE #T0;
END;
IF OBJECT_ID('tempdb..#T1') IS NOT NULL
BEGIN
    DROP TABLE #T1;
END;
IF OBJECT_ID('tempdb..#T2') IS NOT NULL
BEGIN
    DROP TABLE #T2;
END;
IF OBJECT_ID('tempdb..#T3') IS NOT NULL
BEGIN
    DROP TABLE #T3;
END;
IF OBJECT_ID('tempdb..#T4') IS NOT NULL
BEGIN
    DROP TABLE #T4;
END;
IF OBJECT_ID('tempdb..#T5') IS NOT NULL
BEGIN
    DROP TABLE #T5;
END;
IF OBJECT_ID('tempdb..#T6_1') IS NOT NULL
BEGIN
    DROP TABLE #T6_1;
END;
IF OBJECT_ID('tempdb..#T6') IS NOT NULL
BEGIN
    DROP TABLE #T6;
END;
IF OBJECT_ID('tempdb..#T7') IS NOT NULL
BEGIN
    DROP TABLE #T7;
END;
IF OBJECT_ID('tempdb..#T8') IS NOT NULL
BEGIN
    DROP TABLE #T8;
END;
IF OBJECT_ID('tempdb..#T9') IS NOT NULL
BEGIN
    DROP TABLE #T9;
END;
IF OBJECT_ID('tempdb..#T10') IS NOT NULL
BEGIN
    DROP TABLE #T10;
END;
IF OBJECT_ID('tempdb..#T11') IS NOT NULL
BEGIN
    DROP TABLE #T11;
END;
IF OBJECT_ID('tempdb..#T12') IS NOT NULL
BEGIN
    DROP TABLE #T12;
END;
IF OBJECT_ID('tempdb..#T13') IS NOT NULL
BEGIN
    DROP TABLE #T13;
END;
IF OBJECT_ID('tempdb..#T14') IS NOT NULL
BEGIN
    DROP TABLE #T14;
END;
IF OBJECT_ID('tempdb..#TF') IS NOT NULL
BEGIN
    DROP TABLE #TF;
END;

SELECT
	EmployeeId,
	Date,
	Route,
	Role
INTO #T0
FROM(
	SELECT 
		ID,Date,EmployeeId,NULL AS Route,Role  
	From [dbo].[OtherTaskMapping]
	Where Date BETWEEN @startDate AND @endDate
	UNION
	SELECT 
		ID,Date,EmployeeId,Route, NULL AS Role 
	From [dbo].[DeliveryMapping]
	Where Date BETWEEN @startDate AND @endDate
) AS DM
Group By EmployeeId,Date,Route,Role;

SELECT 
		IT1.EmployeeId,
		IT1.DATE,
		DATEDIFF(day, @startDate, IT1.Date) AS DayIndex,
		IT1.ROUTE,
		DayClass,
		PRODUCT,
		TotalDraw AS Draw,
		Rate,
		Amount
	INTO #T1
FROM [dbo].[GetDrawsWithAmount] AS IT1
--LEFT JOIN [dbo].[GetDrawsWithAmount] IT2
--ON IT2.EmployeeId = IT1.EmployeeId
--AND IT2.Route = IT1.Route
--AND IT2.Date = IT1.Date
WHERE Product IN ('STAR', 'GAM', 'GAM(SMP)','NNP','NYT','TSUN')
AND IT1.Date BETWEEN @startDate AND @endDate;

INSERT INTO #T0
SELECT
	distinct EmployeeId,
	DATE,
	ROUTE,
	NULL AS Role
FROM #T1
WHERE EmployeeId = 'D0001'

SELECT
	EmployeeId,
	Route,
	Product,
	DayClass,
	Sum(Draw) AS TotalDraw,
	Max(Rate) AS Rate,
	Sum(Amount) AS Amount
INTO #T2
FROM #T1
GROUP BY Route,EmployeeId,Product,DayClass;

SELECT
	EmployeeId,
	Route,
	DayClass,
	Sum(Amount) AS Amount
INTO #T3
FROM #T1
GROUP BY Route,EmployeeId,DayClass;

SELECT
	EmployeeId,
	Route,
	Sum(Amount) AS DrawGrandTotal
INTO #T4
FROM #T1
GROUP BY Route,EmployeeId;

Select 
	IT1.EmployeeId,
	IT1.Route,
	(
		Select 
			distinct Product,
			(
				Select 
					Date,
					DayIndex,
					Draw
				FROM #T1
				WHERE Route = IT1.Route
				AND Product = IT2.Product
				AND EmployeeId = IT1.EmployeeId
				Order By Date
				FOR JSON PATH
			) AS Draws
		FROM #T1 AS IT2
		WHERE Route = IT1.Route
		AND EmployeeId = IT1.EmployeeId
		FOR JSON PATH
	) AS Products,
	(
		Select
			Product,
			DayClass,
			TotalDraw,
			Rate,
			Amount
		FROM #T2
		WHERE Route = IT1.Route
		AND EmployeeId = IT1.EmployeeId
		FOR JSON PATH
	) AS RouteDrawAmounts,
	(
		Select
			DayClass,
			Amount
		FROM #T3
		WHERE Route = IT1.Route
		AND EmployeeId = IT1.EmployeeId
		FOR JSON PATH
	) AS DayClassTotal,
	#T4.DrawGrandTotal
INTO #T5
FROM #T1 AS IT1
left JOIN #T4
ON #T4.Route = IT1.Route
AND #T4.EmployeeId = IT1.EmployeeId
--WHERE route = '5961M4W002'
GROUP BY IT1.EmployeeId, IT1.Route, #T4.DrawGrandTotal;

Select 
	Route,
	EmployeeID,
	Description,
	Type,
	Draw,
	Rate,
	Amount
INTO #T6_1
From GetAdjustmentDescriptionAmount IT2
WHERE BiWeekEnd = @endDate;

--Insert into  #T6_1(Route, EmployeeId, Description, Type, Draw, Rate, AMOUNT)
--SELECT
--	IT1.Route,
--	IT1.EmployeeId,
--	'ROUTE ADJUSTMENT' AS Description,
--	'RTADJ' AS Type,
--	1 AS Draw,
--	0 AS Rate,
--	CASE
--		WHEN count(distinct IT1.Date) = IT2.Frequency THEN IT2.Amount
--		ELSE (count(distinct IT1.Date)*IT2.Amount)/IT2.Frequency 
--	END AS Amount
--FROM #T0 AS IT1
--JOIN [dbo].[RouteAdjustment] AS IT2
--ON IT2.EmployeeId = IT1.EmployeeId AND IT2.Route = IT1.Route
--Group By IT1.EmployeeId, IT1.Route, IT2.Frequency, IT2.Amount

Insert into  #T6_1(Route, EmployeeId, Description, Type, Draw, Rate, AMOUNT)
Select 
	T.[Route],
	IT1.EmployeeId,
	(Product + ' TIP FROM ' + [Address] + ' ($' + CONVERT(varchar,[Amount]) + ') (' + CONVERT(varchar, [TipDate]) +')') AS Description,
	'TIPS' AS Type,
	1 AS Draw,
	0 AS Rate,
	[Amount]
FROM TIPS T
LEFT JOIN [dbo].[DeliveryMapping] IT1
ON IT1.Date = T.TipDate AND T.Route = IT1.Route
LEFT JOIN  DeliveryRate R
ON IT1.EmployeeId = R.EmployeeId 
WHERE BiWeekEnd = @endDate
AND TIPS= 1 AND R.ROUTE IS NULL

SELECT 
	Route,
	EmployeeID,
	(
		Select 
			Description,
			Type,
			Draw,
			Rate,
			Amount
		From #T6_1 IT2
		Where IT2.EmployeeID = IT1.EmployeeID 
		AND IT2.Route = IT1.Route
		FOR JSON PATH 
	) AS Adjustments
INTO #T6
FROM #T6_1 AS IT1
Group By Route,EmployeeID;

Select 
	EmployeeId,
	Route,
	Type,
	Sum(Amount) As Amount
INTO #T7
FROM
(
	Select
		EmployeeId,
		Route,
		CASE
			WHEN Type like 'DRA%'
			Then 'DRAW'
			ELSE Type
		End AS Type,
		Sum(Amount) AS Amount
	FROM #T6_1 --GetAdjustmentDescriptionAmount
	--Where BiWeekEnd = @endDate
	Group By EmployeeId,Route,Type
) AS IT
Group By EmployeeId,Route,Type;

SELECT
	EmployeeId,
	Route,
	Sum(Amount) AS AdjustmentGrandTotal
INTO #T8
FROM #T7
GROUP BY Route,EmployeeId;

Select
	CASE
		WHEN #T5.EmployeeId is null
		THEN #T8.EmployeeId
		ELSE #T5.EmployeeId 
	END AS EmployeeId,
	CASE
		WHEN #T5.Route is null
		THEN #T8.Route
		ELSE #T5.Route 
	END AS Route,
	COALESCE(#T5.DrawGrandTotal, 0) AS DrawGrandTotal,
	COALESCE(#T8.AdjustmentGrandTotal, 0) AS AdjustmentGrandTotal,
	(COALESCE(DrawGrandTotal,0) + COALESCE(AdjustmentGrandTotal,0)) AS RouteGrandTotal
INTO #T9
FROM #T5
Full Join #T8
ON #T5.EmployeeId = #T8.EmployeeID
AND #T5.Route = #T8.Route;

SELECT 
	CASE
		WHEN #T5.EmployeeId is null
		THEN #T8.EmployeeId
		ELSE #T5.EmployeeId 
	END AS EmployeeId,
	CASE
		WHEN #T5.Route is null
		THEN #T8.Route
		ELSE #T5.Route 
	END AS Route,
	#T5.Products,
	#T5.RouteDrawAmounts,
	#T5.DayClassTotal,
	#T5.DrawGrandTotal,
	#T6.Adjustments,
	(
		Select 
			Type,
			Amount
		FROM #T7
		Where (#T5.EmployeeID = #T7.EmployeeID OR #T6.EmployeeID = #T7.EmployeeID)
		AND (#T5.Route = #T7.Route OR #T6.Route = #T7.Route)
		FOR JSON PATH
	) AS AdjustmentTypeTotal,
	#T8.AdjustmentGrandTotal,
	#T9.RouteGrandTotal
INTO #T10
FROM #T5	
FULL JOIN #T6
ON #T6.EmployeeID = #T5.EmployeeID
AND #T6.Route = #T5.Route
LEFT JOIN #T8
ON (#T8.EmployeeID = #T5.EmployeeID OR #T8.EmployeeID = #T6.EmployeeID)
AND (#T8.Route = #T5.Route OR #T8.Route = #T6.Route)
LEFT JOIN #T9
ON (#T9.EmployeeID = #T5.EmployeeID OR #T9.EmployeeID = #T6.EmployeeID)
AND (#T9.Route = #T5.Route OR #T9.Route = #T6.Route)

Select 
	EmployeeId,
	Sum(RouteGrandTotal) AS EmployeeRouteTotal
INTO #T13
From #T10
Group by EmployeeId

SELECT 
	IT1.EmployeeID,
	IT1.Role,
	CASE
		WHEN Frequency = 1
		THEN Description + ' (' + Convert(nvarchar,Count(distinct IT1.Date)) + ' Days)'
		ELSE Description
	END AS Description,
	--Count(distinct IT1.Date) DaysWorked,
	--Rate,
	CASE
		WHEN Frequency = 1
		THEN Rate*Count(distinct IT1.Date)
		ELSE Rate
	END AS Amount
INTO #T11 
FROM #T0 AS IT1
LEFT JOIN [dbo].[OtherTaskRate] AS IT2
ON IT1.EmployeeID = IT2.EmployeeID
AND IT1.Role = IT2.Role
GROUP BY IT1.EmployeeID,Description, Frequency, Rate, IT1.Role

Insert into #T11(EmployeeId, Role, Description,Amount)
Select 
	IT1.EmployeeId,
	'DRIVER' AS Role,
	'Subsidy (' + Convert(VARCHAR(5),Count(distinct date)) + ' days)' AS Description,
	((Count(distinct date)*IT3.Amount/14) - IT2.EmployeeRouteTotal) AS Amount
FROM #T0 IT1
LEFT JOIN #T13 AS IT2
ON IT1.EmployeeId = IT2.EmployeeId
LEFT JOIN [dbo].[FLATPAY] AS IT3
ON IT1.EmployeeId = IT3.EmployeeID
WHERE IT3.Route is NULL 
GROUP By IT1.EmployeeId, IT2.EmployeeRouteTotal, IT3.Amount
Having Amount is not null

Insert into #T11(EmployeeId, Role, Description,Amount)
Select 
	IT1.EmployeeId,
	'DRIVER' AS Role,
	'Subsidy (' + IT3.Route + ') ('+ Convert(VARCHAR(5),Count(distinct date)) + ' days)' AS Description,
	((Count(distinct date)*IT3.Amount/14) - IT2.RouteGrandTotal) AS Amount
FROM #T0 IT1
LEFT JOIN #T9 AS IT2
ON IT1.EmployeeId = IT2.EmployeeId
LEFT JOIN [dbo].[FLATPAY] AS IT3
ON IT1.EmployeeId = IT3.EmployeeID
AND IT1.Route = IT3.Route AND IT2.Route = IT3.Route
WHERE IT3.Route is not NULL 
GROUP By IT1.EmployeeId, IT2.RouteGrandTotal, IT3.Amount, IT3.Route

--Route adjustment
Insert into  #T11(EmployeeId, Role, Description, Amount)
SELECT
	IT1.EmployeeId,
	'DRIVER' AS Role,
	'Subsidy (' + IT1.Route + ') ('+ Convert(VARCHAR(5),Count(distinct IT1.date)) + ' days)' AS Description,
	CASE
		WHEN count(distinct IT1.Date) = IT2.Frequency THEN IT2.Amount
		ELSE (count(distinct IT1.Date)*IT2.Amount)/IT2.Frequency 
	END AS Amount
FROM #T0 AS IT1
JOIN [dbo].[RouteAdjustment] AS IT2
ON IT2.EmployeeId = IT1.EmployeeId AND IT2.Route = IT1.Route
Group By IT1.EmployeeId, IT1.Route, IT2.Frequency, IT2.Amount

SELECT
	IT1.EmployeeId,
	IT1.Route,
	Address,
	Amount
INTO #T14
FROM #T0 IT1
LEFT JOIN [dbo].[Collections] IT2
ON IT1.EmployeeId = IT2.EmployeeID AND IT1.Route = It2.Route
WHERE BiWeekEnd = @endDate
AND IT2.Amount is not null
Group By IT1.EmployeeId, IT1.Route, Amount, Address

Insert into #T11(EmployeeId, Role, Description,Amount)
SELECT
	EmployeeId,
	'CLCTN' AS Role,
	'Collection' AS Description,
	--'Collection (' + STUFF(
	--	(SELECT 
	--		DISTINCT ', ' + Route 
	--	FROM  #T14
	--	WHERE #T14.EmployeeID = IT1.EmployeeId
	--	Group By EmployeeID,Route
	--	FOR XML PATH('')), 1, 2, ''
	--) + ')' AS Description,
	SUM(Amount) - (2*SUM(Amount)) AS Amount
FROM #T14 IT1
Group By EmployeeId

Insert into #T11(EmployeeId, Role, Description,Amount)
SELECT
	EmployeeId,
	'OTHR' AS Role,
	Description,
	Amount
FROM [UnusualPayments]
WHERE BiWeekEnd is null
OR BiWeekEnd = @endDate

Select 
	distinct EmployeeId,
	(
		Select
			Description,
			Amount
		FROM #T11
		WHERE EmployeeId = IT1.EmployeeId
		AND #T11.Role IS NOT NULL
		FOR JSON PATH
	) AS OtherPayments,
	SUM(Amount) AS TotalOtherPay
INTO #T12
from #T11 AS IT1
GROUP By EmployeeId

Select
	IT1.EmployeeID,
	E.PayeeName AS Name,
	STUFF(
		(SELECT 
			DISTINCT ' | ' + Route 
		FROM  #T10
		WHERE #T10.EmployeeID = IT1.EmployeeId
		Group By EmployeeID,Route
		FOR XML PATH('')), 1, 3, ''
	) AS Routes,
	STUFF(
		(SELECT 
			DISTINCT ' | ' + Description 
		FROM  #T11
		WHERE #T11.EmployeeID = IT1.EmployeeId
		AND Role <> 'DRIVER'
		Group By EmployeeID, Description
		FOR XML PATH('')), 1, 3, ''
	) AS OtherTasks,
	(
		SELECT 
			Route,
			Products,
			RouteDrawAmounts,
			DayClassTotal,
			DrawGrandTotal,
			Adjustments,
			(
				SELECT 
					'<b>COLLECTION: </b>' + Address AS Description,
					Amount
				FROM #T14
				WHERE #T14.EmployeeID = IT1.EmployeeID
				AND #T14.Route = #T10.Route
				FOR JSON PATH
			) AS Collections,
			AdjustmentTypeTotal,
			AdjustmentGrandTotal,
			RouteGrandTotal
		FROM #T10
		WHERE #T10.EmployeeID = IT1.EmployeeID
		FOR JSON PATH
	) AS RouteList,
	OtherPayments,
	COALESCE(EmployeeRouteTotal,0) AS EmployeeRouteTotal,
	(
		SELECT SUM(Amount)
		FROM #T11
		WHERE #T11.EmployeeID = IT1.EmployeeID
		AND Role = 'DRIVER'
	) AS Subsidy,
	COALESCE(TotalOtherPay,0) AS TotalOtherPay,
	COALESCE(EmployeeRouteTotal,0) + COALESCE(TotalOtherPay,0) AS FinalPay 
INTO #TF
FROM #T0 AS IT1
Left Join Employee E
ON E.EmployeeId = IT1.EmployeeID
LEFT JOIN #T10
ON #T10.EmployeeID = IT1.EmployeeID
LEFT JOIN #T13
ON #T13.EmployeeID = IT1.EmployeeID
LEFT JOIN #T12
ON #T12.EmployeeID = IT1.EmployeeID

Group By IT1.EmployeeID, E.PayeeName, OtherPayments,TotalOtherPay, EmployeeRouteTotal


set @jsonDataOut = (
	Select 
		* 
	from #TF
	Order By Name
	FOR JSON PATH
)

END
GO
/****** Object:  StoredProcedure [dbo].[GetMasterReport1]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetMasterReport1]
	@jsonData NVARCHAR(MAX),
	@jsonDataOut NVARCHAR(MAX) out
AS
BEGIN

declare @startDate Date = JSON_VALUE(@jsonData, '$.startDate')
declare @endDate Date = JSON_VALUE(@jsonData, '$.endDate')

--declare @startDate Date = '2024-05-20'
--declare @endDate Date = '2024-06-02'

IF OBJECT_ID('tempdb..#T0') IS NOT NULL
BEGIN
    DROP TABLE #T0;
END;
IF OBJECT_ID('tempdb..#T1') IS NOT NULL
BEGIN
    DROP TABLE #T1;
END;
IF OBJECT_ID('tempdb..#T2') IS NOT NULL
BEGIN
    DROP TABLE #T2;
END;
IF OBJECT_ID('tempdb..#T3') IS NOT NULL
BEGIN
    DROP TABLE #T3;
END;
IF OBJECT_ID('tempdb..#T4') IS NOT NULL
BEGIN
    DROP TABLE #T4;
END;
IF OBJECT_ID('tempdb..#T5') IS NOT NULL
BEGIN
    DROP TABLE #T5;
END;
IF OBJECT_ID('tempdb..#T6_1') IS NOT NULL
BEGIN
    DROP TABLE #T6_1;
END;
IF OBJECT_ID('tempdb..#T6') IS NOT NULL
BEGIN
    DROP TABLE #T6;
END;
IF OBJECT_ID('tempdb..#T7') IS NOT NULL
BEGIN
    DROP TABLE #T7;
END;
IF OBJECT_ID('tempdb..#T8') IS NOT NULL
BEGIN
    DROP TABLE #T8;
END;
IF OBJECT_ID('tempdb..#T9') IS NOT NULL
BEGIN
    DROP TABLE #T9;
END;
IF OBJECT_ID('tempdb..#T10') IS NOT NULL
BEGIN
    DROP TABLE #T10;
END;
IF OBJECT_ID('tempdb..#T11') IS NOT NULL
BEGIN
    DROP TABLE #T11;
END;
IF OBJECT_ID('tempdb..#T12') IS NOT NULL
BEGIN
    DROP TABLE #T12;
END;
IF OBJECT_ID('tempdb..#T13') IS NOT NULL
BEGIN
    DROP TABLE #T13;
END;
IF OBJECT_ID('tempdb..#T14') IS NOT NULL
BEGIN
    DROP TABLE #T14;
END;
IF OBJECT_ID('tempdb..#TF') IS NOT NULL
BEGIN
    DROP TABLE #TF;
END;

SELECT
	EmployeeId,
	Date,
	Route,
	Role
INTO #T0
FROM(
	SELECT 
		ID,Date,EmployeeId,NULL AS Route,Role  
	From [dbo].[OtherTaskMapping]
	Where Date BETWEEN @startDate AND @endDate
	UNION
	SELECT 
		ID,Date,EmployeeId,Route, NULL AS Role 
	From [dbo].[DeliveryMapping]
	Where Date BETWEEN @startDate AND @endDate
) AS DM
Group By EmployeeId,Date,Route,Role;

SELECT 
		IT1.EmployeeId,
		IT1.DATE,
		DATEDIFF(day, @startDate, IT1.Date) AS DayIndex,
		IT1.ROUTE,
		DayClass,
		PRODUCT,
		TotalDraw AS Draw,
		Rate,
		Amount
	INTO #T1
FROM [dbo].[GetDrawsWithAmount] AS IT1
--LEFT JOIN [dbo].[GetDrawsWithAmount] IT2
--ON IT2.EmployeeId = IT1.EmployeeId
--AND IT2.Route = IT1.Route
--AND IT2.Date = IT1.Date
WHERE Product IN ('STAR', 'GAM', 'GAM(SMP)','NNP','NYT','TSUN')
AND IT1.Date BETWEEN @startDate AND @endDate;

INSERT INTO #T0
SELECT
	distinct EmployeeId,
	DATE,
	ROUTE,
	NULL AS Role
FROM #T1
WHERE EmployeeId = 'D0001'

SELECT
	EmployeeId,
	Route,
	Product,
	DayClass,
	Sum(Draw) AS TotalDraw,
	Max(Rate) AS Rate,
	Sum(Amount) AS Amount
INTO #T2
FROM #T1
GROUP BY Route,EmployeeId,Product,DayClass;

SELECT
	EmployeeId,
	Route,
	DayClass,
	Sum(Amount) AS Amount
INTO #T3
FROM #T1
GROUP BY Route,EmployeeId,DayClass;

SELECT
	EmployeeId,
	Route,
	Sum(Amount) AS DrawGrandTotal
INTO #T4
FROM #T1
GROUP BY Route,EmployeeId;

Select 
	IT1.EmployeeId,
	IT1.Route,
	(
		Select 
			distinct Product,
			(
				Select 
					Date,
					DayIndex,
					Draw
				FROM #T1
				WHERE Route = IT1.Route
				AND Product = IT2.Product
				AND EmployeeId = IT1.EmployeeId
				Order By Date
				FOR JSON PATH
			) AS Draws
		FROM #T1 AS IT2
		WHERE Route = IT1.Route
		AND EmployeeId = IT1.EmployeeId
		FOR JSON PATH
	) AS Products,
	(
		Select
			Product,
			DayClass,
			TotalDraw,
			Rate,
			Amount
		FROM #T2
		WHERE Route = IT1.Route
		AND EmployeeId = IT1.EmployeeId
		FOR JSON PATH
	) AS RouteDrawAmounts,
	(
		Select
			DayClass,
			Amount
		FROM #T3
		WHERE Route = IT1.Route
		AND EmployeeId = IT1.EmployeeId
		FOR JSON PATH
	) AS DayClassTotal,
	#T4.DrawGrandTotal
INTO #T5
FROM #T1 AS IT1
left JOIN #T4
ON #T4.Route = IT1.Route
AND #T4.EmployeeId = IT1.EmployeeId
--WHERE route = '5961M4W002'
GROUP BY IT1.EmployeeId, IT1.Route, #T4.DrawGrandTotal;

Select 
	Route,
	EmployeeID,
	Description,
	Type,
	Draw,
	Rate,
	Amount
INTO #T6_1
From GetAdjustmentDescriptionAmount IT2
WHERE BiWeekEnd = @endDate;

--Insert into  #T6_1(Route, EmployeeId, Description, Type, Draw, Rate, AMOUNT)
--SELECT
--	IT1.Route,
--	IT1.EmployeeId,
--	'ROUTE ADJUSTMENT' AS Description,
--	'RTADJ' AS Type,
--	1 AS Draw,
--	0 AS Rate,
--	CASE
--		WHEN count(distinct IT1.Date) = IT2.Frequency THEN IT2.Amount
--		ELSE (count(distinct IT1.Date)*IT2.Amount)/IT2.Frequency 
--	END AS Amount
--FROM #T0 AS IT1
--JOIN [dbo].[RouteAdjustment] AS IT2
--ON IT2.EmployeeId = IT1.EmployeeId AND IT2.Route = IT1.Route
--Group By IT1.EmployeeId, IT1.Route, IT2.Frequency, IT2.Amount

Insert into  #T6_1(Route, EmployeeId, Description, Type, Draw, Rate, AMOUNT)
Select 
	T.[Route],
	IT1.EmployeeId,
	(Product + ' TIP FROM ' + [Address] + ' ($' + CONVERT(varchar,[Amount]) + ') (' + CONVERT(varchar, [TipDate]) +')') AS Description,
	'TIPS' AS Type,
	1 AS Draw,
	0 AS Rate,
	[Amount]
FROM TIPS T
LEFT JOIN [dbo].[DeliveryMapping] IT1
ON IT1.Date = T.TipDate AND T.Route = IT1.Route
LEFT JOIN  DeliveryRate R
ON IT1.EmployeeId = R.EmployeeId 
WHERE BiWeekEnd = @endDate
AND TIPS= 1 AND R.ROUTE IS NULL

SELECT 
	Route,
	EmployeeID,
	(
		Select 
			Description,
			Type,
			Draw,
			Rate,
			Amount
		From #T6_1 IT2
		Where IT2.EmployeeID = IT1.EmployeeID 
		AND IT2.Route = IT1.Route
		FOR JSON PATH 
	) AS Adjustments
INTO #T6
FROM #T6_1 AS IT1
Group By Route,EmployeeID;

Select 
	EmployeeId,
	Route,
	Type,
	Sum(Amount) As Amount
INTO #T7
FROM
(
	Select
		EmployeeId,
		Route,
		CASE
			WHEN Type like 'DRA%'
			Then 'DRAW'
			ELSE Type
		End AS Type,
		Sum(Amount) AS Amount
	FROM #T6_1 --GetAdjustmentDescriptionAmount
	--Where BiWeekEnd = @endDate
	Group By EmployeeId,Route,Type
) AS IT
Group By EmployeeId,Route,Type;

SELECT
	EmployeeId,
	Route,
	Sum(Amount) AS AdjustmentGrandTotal
INTO #T8
FROM #T7
GROUP BY Route,EmployeeId;

Select
	case
	when #T5.EmployeeId is null
	then #T8.EmployeeId
	else #T5.EmployeeId 
	End AS EmployeeId,
	case
	when #T5.Route is null
	then #T8.Route
	else #T5.Route 
	End AS Route,
	COALESCE(#T5.DrawGrandTotal, 0) AS DrawGrandTotal,
	COALESCE(#T8.AdjustmentGrandTotal, 0) AS AdjustmentGrandTotal,
	(COALESCE(DrawGrandTotal,0) + COALESCE(AdjustmentGrandTotal,0)) AS RouteGrandTotal
INTO #T9
FROM #T5
full Join #T8   --- Change
ON #T5.EmployeeId = #T8.EmployeeID
AND #T5.Route = #T8.Route;

SELECT 
	case
	when #T5.EmployeeId is null
	then #T6.EmployeeId
	else #T5.EmployeeId 
	End AS EmployeeId,
	case
	when #T5.Route is null
	then #T6.Route
	else #T5.Route 
	End AS Route,
	#T5.Products,
	#T5.RouteDrawAmounts,
	#T5.DayClassTotal,
	#T5.DrawGrandTotal,
	#T6.Adjustments,
	(
		Select 
			Type,
			Amount
		FROM #T7
		Where (#T5.EmployeeID = #T7.EmployeeID OR #T6.EmployeeID = #T7.EmployeeID)
		AND (#T5.Route = #T7.Route OR #T6.Route = #T7.Route)
		FOR JSON PATH
	) AS AdjustmentTypeTotal,
	#T8.AdjustmentGrandTotal,
	#T9.RouteGrandTotal
INTO #T10
FROM #T5	
FULL JOIN #T6
ON #T6.EmployeeID = #T5.EmployeeID
AND #T6.Route = #T5.Route
LEFT JOIN #T8
ON (#T8.EmployeeID = #T5.EmployeeID OR #T8.EmployeeID = #T6.EmployeeID)
AND (#T8.Route = #T5.Route OR #T8.Route = #T6.Route)
LEFT JOIN #T9
ON (#T9.EmployeeID = #T5.EmployeeID OR #T9.EmployeeID = #T6.EmployeeID)
AND (#T9.Route = #T5.Route OR #T9.Route = #T6.Route)

Select 
	EmployeeId,
	Sum(RouteGrandTotal) AS EmployeeRouteTotal
INTO #T13
From #T10
Group by EmployeeId

SELECT 
	IT1.EmployeeID,
	IT1.Role,
	CASE
		WHEN Frequency = 1
		THEN Description + ' (' + Convert(nvarchar,Count(distinct IT1.Date)) + ' Days)'
		ELSE Description
	END AS Description,
	--Count(distinct IT1.Date) DaysWorked,
	--Rate,
	CASE
		WHEN Frequency = 1
		THEN Rate*Count(distinct IT1.Date)
		ELSE Rate
	END AS Amount
INTO #T11 
FROM #T0 AS IT1
LEFT JOIN [dbo].[OtherTaskRate] AS IT2
ON IT1.EmployeeID = IT2.EmployeeID
AND IT1.Role = IT2.Role
GROUP BY IT1.EmployeeID,Description, Frequency, Rate, IT1.Role

Insert into #T11(EmployeeId, Role, Description,Amount)
Select 
	IT1.EmployeeId,
	'DRIVER' AS Role,
	'Subsidy (' + Convert(VARCHAR(5),Count(distinct date)) + ' days)' AS Description,
	((Count(distinct date)*IT3.Amount/14) - IT2.EmployeeRouteTotal) AS Amount
FROM #T0 IT1
LEFT JOIN #T13 AS IT2
ON IT1.EmployeeId = IT2.EmployeeId
LEFT JOIN [dbo].[FLATPAY] AS IT3
ON IT1.EmployeeId = IT3.EmployeeID
WHERE IT3.Route is NULL 
GROUP By IT1.EmployeeId, IT2.EmployeeRouteTotal, IT3.Amount
Having Amount is not null

Insert into #T11(EmployeeId, Role, Description,Amount)
Select 
	IT1.EmployeeId,
	'DRIVER' AS Role,
	'Subsidy (' + IT3.Route + ') ('+ Convert(VARCHAR(5),Count(distinct date)) + ' days)' AS Description,
	((Count(distinct date)*IT3.Amount/14) - IT2.RouteGrandTotal) AS Amount
FROM #T0 IT1
LEFT JOIN #T9 AS IT2
ON IT1.EmployeeId = IT2.EmployeeId
LEFT JOIN [dbo].[FLATPAY] AS IT3
ON IT1.EmployeeId = IT3.EmployeeID
AND IT1.Route = IT3.Route AND IT2.Route = IT3.Route
WHERE IT3.Route is not NULL 
GROUP By IT1.EmployeeId, IT2.RouteGrandTotal, IT3.Amount, IT3.Route

--Route adjustment
Insert into  #T11(EmployeeId, Role, Description, Amount)
SELECT
	IT1.EmployeeId,
	'DRIVER' AS Role,
	'Subsidy (' + IT1.Route + ') ('+ Convert(VARCHAR(5),Count(distinct IT1.date)) + ' days)' AS Description,
	CASE
		WHEN count(distinct IT1.Date) = IT2.Frequency THEN IT2.Amount
		ELSE (count(distinct IT1.Date)*IT2.Amount)/IT2.Frequency 
	END AS Amount
FROM #T0 AS IT1
JOIN [dbo].[RouteAdjustment] AS IT2
ON IT2.EmployeeId = IT1.EmployeeId AND IT2.Route = IT1.Route
Group By IT1.EmployeeId, IT1.Route, IT2.Frequency, IT2.Amount

SELECT
	IT1.EmployeeId,
	IT1.Route,
	Address,
	Amount
INTO #T14
FROM #T0 IT1
LEFT JOIN [dbo].[Collections] IT2
ON IT1.EmployeeId = IT2.EmployeeID AND IT1.Route = It2.Route
WHERE BiWeekEnd = @endDate
AND IT2.Amount is not null
Group By IT1.EmployeeId, IT1.Route, Amount, Address

Insert into #T11(EmployeeId, Role, Description,Amount)
SELECT
	EmployeeId,
	'CLCTN' AS Role,
	'Collection' AS Description,
	--'Collection (' + STUFF(
	--	(SELECT 
	--		DISTINCT ', ' + Route 
	--	FROM  #T14
	--	WHERE #T14.EmployeeID = IT1.EmployeeId
	--	Group By EmployeeID,Route
	--	FOR XML PATH('')), 1, 2, ''
	--) + ')' AS Description,
	SUM(Amount) - (2*SUM(Amount)) AS Amount
FROM #T14 IT1
Group By EmployeeId

Insert into #T11(EmployeeId, Role, Description,Amount)
SELECT
	EmployeeId,
	'OTHR' AS Role,
	Description,
	Amount
FROM [UnusualPayments]
WHERE BiWeekEnd is null
OR BiWeekEnd = @endDate

Select 
	distinct EmployeeId,
	(
		Select
			Description,
			Amount
		FROM #T11
		WHERE EmployeeId = IT1.EmployeeId
		AND #T11.Role IS NOT NULL
		FOR JSON PATH
	) AS OtherPayments,
	SUM(Amount) AS TotalOtherPay
INTO #T12
from #T11 AS IT1
GROUP By EmployeeId

Select
	IT1.EmployeeID,
	E.PayeeName AS Name,
	STUFF(
		(SELECT 
			DISTINCT ' | ' + Route 
		FROM  #T10
		WHERE #T10.EmployeeID = IT1.EmployeeId
		Group By EmployeeID,Route
		FOR XML PATH('')), 1, 3, ''
	) AS Routes,
	STUFF(
		(SELECT 
			DISTINCT ' | ' + Description 
		FROM  #T11
		WHERE #T11.EmployeeID = IT1.EmployeeId
		AND Role <> 'DRIVER'
		Group By EmployeeID, Description
		FOR XML PATH('')), 1, 3, ''
	) AS OtherTasks,
	(
		SELECT 
			Route,
			Products,
			RouteDrawAmounts,
			DayClassTotal,
			DrawGrandTotal,
			Adjustments,
			(
				SELECT 
					'<b>COLLECTION: </b>' + Address AS Description,
					Amount
				FROM #T14
				WHERE #T14.EmployeeID = IT1.EmployeeID
				AND #T14.Route = #T10.Route
				FOR JSON PATH
			) AS Collections,
			AdjustmentTypeTotal,
			AdjustmentGrandTotal,
			RouteGrandTotal
		FROM #T10
		WHERE #T10.EmployeeID = IT1.EmployeeID
		FOR JSON PATH
	) AS RouteList,
	OtherPayments,
	COALESCE(EmployeeRouteTotal,0) AS EmployeeRouteTotal,
	(
		SELECT SUM(Amount)
		FROM #T11
		WHERE #T11.EmployeeID = IT1.EmployeeID
		AND Role = 'DRIVER'
	) AS Subsidy,
	COALESCE(TotalOtherPay,0) AS TotalOtherPay,
	COALESCE(EmployeeRouteTotal,0) + COALESCE(TotalOtherPay,0) AS FinalPay 
INTO #TF
FROM #T0 AS IT1
Left Join Employee E
ON E.EmployeeId = IT1.EmployeeID
LEFT JOIN #T10
ON #T10.EmployeeID = IT1.EmployeeID
LEFT JOIN #T13
ON #T13.EmployeeID = IT1.EmployeeID
LEFT JOIN #T12
ON #T12.EmployeeID = IT1.EmployeeID

Group By IT1.EmployeeID, E.PayeeName, OtherPayments,TotalOtherPay, EmployeeRouteTotal


set @jsonDataOut = (
	Select 
		* 
	from #TF
	Order By Name
	FOR JSON PATH
)

END

--Select * from #TF
--Order by routes
--where EmployeeId = 'D0056'

--Select 
--EmployeeId,
--	Name,
--	Routes,
--	EmployeeRouteTotal,
--	(TotalOtherPay-COALESCE(Subsidy,0)) AS OtherPay,
--	COALESCE(Subsidy,0) AS Subsidy,
--	FinalPay 
--from #TF
--order by Name

--select * from #T10
--Where Route like '%G012'
GO
/****** Object:  StoredProcedure [dbo].[GetTestMasterReport]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetTestMasterReport]
	@jsonDataOut NVARCHAR(MAX) out
AS
BEGIN
DECLARE @startDate DATE = '2024-03-25';
DECLARE @endDate DATE = '2024-04-07';

IF OBJECT_ID('tempdb..#T1') IS NOT NULL
BEGIN
    DROP TABLE #T1;
END;
IF OBJECT_ID('tempdb..#T2') IS NOT NULL
BEGIN
    DROP TABLE #T2;
END;
IF OBJECT_ID('tempdb..#T3') IS NOT NULL
BEGIN
    DROP TABLE #T3;
END;
IF OBJECT_ID('tempdb..#T4') IS NOT NULL
BEGIN
    DROP TABLE #T4;
END;
IF OBJECT_ID('tempdb..#T5') IS NOT NULL
BEGIN
    DROP TABLE #T5;
END;
IF OBJECT_ID('tempdb..#T6') IS NOT NULL
BEGIN
    DROP TABLE #T6;
END;
IF OBJECT_ID('tempdb..#T7') IS NOT NULL
BEGIN
    DROP TABLE #T7;
END;
IF OBJECT_ID('tempdb..#T8') IS NOT NULL
BEGIN
    DROP TABLE #T8;
END;
IF OBJECT_ID('tempdb..#T9') IS NOT NULL
BEGIN
    DROP TABLE #T9;
END;
IF OBJECT_ID('tempdb..#T10') IS NOT NULL
BEGIN
    DROP TABLE #T10;
END;


SELECT 
		DATE,
		DATEDIFF(day, @startDate, Date) AS DayIndex,
		ROUTE,
		EmployeeId,
		DayClass,
		PRODUCT,
		TotalDraw AS Draw,
		Rate,
		Amount
	INTO #T1
FROM [dbo].[GetDrawsWithAmount]
WHERE Product IN ('STAR', 'GAM', 'GAM(SMP)','NNP','NYT','TSUN')
AND Date BETWEEN @startDate AND @endDate;

SELECT
	EmployeeId,
	Route,
	Product,
	DayClass,
	Sum(Draw) AS TotalDraw,
	Max(Rate) AS Rate,
	Sum(Amount) AS Amount
INTO #T2
FROM #T1
GROUP BY Route,EmployeeId,Product,DayClass;

SELECT
	EmployeeId,
	Route,
	DayClass,
	Sum(Amount) AS Amount
INTO #T3
FROM #T1
GROUP BY Route,EmployeeId,DayClass;

SELECT
	EmployeeId,
	Route,
	Sum(Amount) AS DrawGrandTotal
INTO #T4
FROM #T1
GROUP BY Route,EmployeeId;

Select 
	IT1.EmployeeId,
	IT1.Route,
	(
		Select 
			distinct Product,
			(
				Select 
					Date,
					DayIndex,
					Draw
				FROM #T1
				WHERE Route = IT1.Route
				AND Product = IT2.Product
				Order By Date
				FOR JSON PATH
			) AS Draws
		FROM #T1 AS IT2
		WHERE Route = IT1.Route
		AND EmployeeId = IT1.EmployeeId
		FOR JSON PATH
	) AS Products,
	(
		Select
			Product,
			DayClass,
			TotalDraw,
			Rate,
			Amount
		FROM #T2
		WHERE Route = IT1.Route
		AND EmployeeId = IT1.EmployeeId
		FOR JSON PATH
	) AS RouteDrawAmounts,
	(
		Select
			DayClass,
			Amount
		FROM #T3
		WHERE Route = IT1.Route
		AND EmployeeId = IT1.EmployeeId
		FOR JSON PATH
	) AS DayClassTotal,
	#T4.DrawGrandTotal
INTO #T5
FROM #T1 AS IT1
JOIN #T4
ON #T4.Route = IT1.Route
AND #T4.EmployeeId = IT1.EmployeeId
--WHERE route = '5961M4W002'
GROUP BY IT1.EmployeeId, IT1.Route, #T4.DrawGrandTotal;

SELECT 
	Route,
	EmployeeID,
	(
		Select 
			Description,
			Type,
			Draw,
			Rate,
			Amount
		From GetAdjustmentDescriptionAmount IT2
		Where IT2.EmployeeID = IT1.EmployeeID 
		AND IT2.Route = IT1.Route
		AND BiWeekEnd = @endDate
		FOR JSON PATH 
	) AS Adjustments
INTO #T6
FROM GetAdjustmentDescriptionAmount AS IT1
Where BiWeekEnd = @endDate	
Group By Route,EmployeeID;

Select 
	EmployeeId,
	Route,
	Type,
	Sum(Amount) As Amount
INTO #T7
FROM
(
	Select
		EmployeeId,
		Route,
		CASE
			WHEN Type like 'DRA%'
			Then 'DRAW'
			ELSE Type
		End AS Type,
		Sum(Amount) AS Amount
	FROM GetAdjustmentDescriptionAmount
	Where BiWeekEnd = @endDate
	Group By EmployeeId,Route,Type
) AS IT
Group By EmployeeId,Route,Type;

SELECT
	EmployeeId,
	Route,
	Sum(Amount) AS AdjustmentGrandTotal
INTO #T8
FROM #T7
GROUP BY Route,EmployeeId;

Select
	#T5.EmployeeId,
	#T5.Route,
	(DrawGrandTotal + AdjustmentGrandTotal) AS RouteGrandTotal
INTO #T9
FROM #T5
Join #T8
ON #T5.EmployeeId = #T8.EmployeeID
AND #T5.Route = #T8.Route;

SELECT 
	#T5.EmployeeId,
	#T5.Route,
	#T5.Products,
	#T5.RouteDrawAmounts,
	#T5.DayClassTotal,
	#T5.DrawGrandTotal,
	#T6.Adjustments,
	(
		Select 
			Type,
			Amount
		FROM #T7
		Where #T5.EmployeeID = #T7.EmployeeID
		AND #T5.Route = #T7.Route
		FOR JSON PATH
	) AS AdjustmentTypeTotal,
	#T8.AdjustmentGrandTotal,
	#T9.RouteGrandTotal
INTO #T10
FROM #T5	
JOIN #T6
ON #T6.EmployeeID = #T5.EmployeeID
AND #T6.Route = #T5.Route
JOIN #T8
ON #T8.EmployeeID = #T5.EmployeeID
AND #T8.Route = #T5.Route
JOIN #T9
ON #T9.EmployeeID = #T5.EmployeeID
AND #T9.Route = #T5.Route


IF OBJECT_ID('tempdb..#TF') IS NOT NULL
BEGIN
    DROP TABLE #TF;
END;
Select
	IT1.EmployeeID,
	E.Name,
	STUFF(
		(SELECT 
			DISTINCT ' | ' + Route 
		FROM  #T1
		WHERE #T1.EmployeeID = IT1.EmployeeId
		Group By EmployeeID,Route
		FOR XML PATH('')), 1, 3, ''
	) AS Routes,
	(
		SELECT 
			Route,
			Products,
			RouteDrawAmounts,
			DayClassTotal,
			DrawGrandTotal,
			Adjustments,
			AdjustmentTypeTotal,
			AdjustmentGrandTotal,
			RouteGrandTotal
		FROM #T10
		WHERE #T10.EmployeeID = IT1.EmployeeID
		FOR JSON PATH
	) AS RouteList,
	(
		Select
			SUM(RouteGrandTotal)
		FROM #T10
		WHERE #T10.EmployeeID = IT1.EmployeeID
	)AS EmployeeRouteTotal
INTO #TF
FROM #T1 AS IT1
LEFT JOIN #T10
ON #T10.EmployeeID = IT1.EmployeeID
Left Join Employee E
ON E.EmployeeId = IT1.EmployeeID
Group By IT1.EmployeeID, E.Name

set @jsonDataOut =(Select * from #TF
FOR JSON PATH)

END



GO
/****** Object:  StoredProcedure [dbo].[InsertCollections]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertCollections]
	@jsonData NVARCHAR(MAX)
AS
BEGIN
	DELETE FROM Collections
	WHERE BiWeekEnd IN (
		SELECT distinct BiWeekEnd
		FROM OPENJSON(@jsonData)
		WITH
		(
			BiWeekEnd DATE
		)
	)
	
	INSERT INTO Collections(SubscriptionID, Amount, Name, Address, Route, BiWeekEnd, EmployeeID)
	SELECT
			*
		FROM OPENJSON(@jsonData)
		WITH
		(
			SubscriptionID varchar(20),
			Amount decimal(18,2),
			Name varchar(50),
			Address varchar(100),
			Route varchar(15),
			BiWeekEnd Date,
			EmployeeID varchar(10)
		)
END
GO
/****** Object:  StoredProcedure [dbo].[InsertDrawData]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertDrawData]
	@jsonData NVARCHAR(MAX)
AS
BEGIN
	Delete From  RawDraw
	Where WeekEnding IN (
		SELECT distinct WeekEnding
		FROM OPENJSON(@jsonData)
		WITH
		(
			WeekEnding DATE
		)
	)

	INSERT INTO RawDraw(Date, Day, DayClass, WeekEnding, Plant, Route, Product, CustomerClassification, Draw, Count)
		SELECT
			*
		FROM OPENJSON(@jsonData)
		WITH
		(
			Date Date,
			Day VARCHAR(15),
			DayClass VARCHAR(5),
			WeekEnding DATE,
			Plant INT, 
			Route VARCHAR(10),
			Product VARCHAR(10),
			CustomerClassification VARCHAR(3),
			Draw INT,
			Count INT
		)
END
GO
/****** Object:  StoredProcedure [dbo].[InsertDrawDataTest]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertDrawDataTest]
	@jsonData NVARCHAR(MAX)
AS
BEGIN
	INSERT INTO DrawDataTest(Date, Day, DayClass, WeekEnding, Plant, Route, Product, CustomerClassification, Draw, Count)
		SELECT
			*
		FROM OPENJSON(@jsonData)
		WITH
		(
			Date Date,
			Day VARCHAR(15),
			DayClass VARCHAR(5),
			WeekEnding DATE,
			Plant INT, 
			Route VARCHAR(10),
			Product VARCHAR(10),
			CustomerClassification VARCHAR(3),
			Draw INT,
			Count INT
		)
END
GO
/****** Object:  StoredProcedure [dbo].[InsertRawDrawData]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertRawDrawData]
	@jsonData NVARCHAR(MAX)
AS
BEGIN
	Delete From  RawDraw
	Where WeekEnding IN (
		SELECT 
			distinct Date
		FROM OPENJSON(@jsonData)
		WITH
		(
			Date DATE
		)
	)
	AND PLANT IN ( 
		SELECT 
			distinct PLANT
		FROM OPENJSON(@jsonData)
		WITH
		(
			Plant INT
		)
	)
	
	INSERT INTO RawDraw(Date, Day, DayClass, WeekEnding, Plant, Route, Product, CustomerClassification, Draw, CATAddressID, ZipCode, ZipPlus4, Count)
		SELECT
			*
		FROM OPENJSON(@jsonData)
		WITH
		(
			Date Date,
			Day VARCHAR (15),
			DayClass VARCHAR (5),
			WeekEnding DATE,
			Plant INT, 
			Route VARCHAR(10),
			Product VARCHAR(10),
			CustomerClassification VARCHAR(3),
			Draw INT,
			CATAddressID INT ,
			ZipCode VARCHAR(3) ,
			ZipPlus4 VARCHAR(3) ,
			Count INT
		)
END
GO
/****** Object:  StoredProcedure [dbo].[InsertSiteReport]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertSiteReport]
	@jsonData NVARCHAR(MAX)
AS
BEGIN
	Delete From  DeliveryMapping
	Where Date IN (
		SELECT distinct Date
		FROM OPENJSON(@jsonData,'$.route')
		WITH
		(
			Date Date '$.Date'
		)
	)
	Delete From  OtherTaskMapping
	Where Date IN (
		SELECT distinct Date
		FROM OPENJSON(@jsonData,'$.other')
		WITH
		(
			Date Date '$.Date'
		)
	)

	INSERT INTO DeliveryMapping(Date,Route,EmployeeID)
		SELECT *
		FROM OPENJSON(@jsonData, '$.route')
		WITH
		(
			Date Date '$.Date',
			Route varchar(50) '$.TaskName',
			EmployeeId varchar(50) '$.EmployeeId'
		)
	INSERT INTO OtherTaskMapping(Date,Role,EmployeeID)
		SELECT *
		FROM OPENJSON(@jsonData, '$.other')
		WITH
		(
			Date Date '$.Date',
			Role varchar(50) '$.TaskName',
			EmployeeId varchar(50) '$.EmployeeId'
		)
END
GO
/****** Object:  StoredProcedure [dbo].[InsertTips]    Script Date: 2024-06-18 4:27:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertTips]
	@jsonData NVARCHAR(MAX)
AS
BEGIN
	DELETE FROM Tips
	WHERE BiWeekEnd IN (
		SELECT distinct BiWeekEnd
		FROM OPENJSON(@jsonData)
		WITH
		(
			BiWeekEnd DATE
		)
	)
	
	INSERT INTO Tips(Product, BiWeekEnd, TipDate, Route, Address, Amount)
	SELECT
			*
		FROM OPENJSON(@jsonData)
		WITH
		(
			Product varchar(10),
			BiWeekEnd Date,
			TipDate Date,
			Route varchar(15),
			Address varchar(100),
			Amount decimal(18,2)
		)
END
GO
USE [master]
GO
ALTER DATABASE [DAHNAENTERPRISEINC.MDF] SET  READ_WRITE 
GO
