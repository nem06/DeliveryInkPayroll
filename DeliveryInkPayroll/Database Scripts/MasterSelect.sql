USE [D:\GIT REPOS\DELIVERYINKPAYROLL\DELIVERYINKPAYROLL\DAHNAENTERPRISEINC.MDF]
GO
/****** Object:  StoredProcedure [dbo].[GetMasterReport]    Script Date: 2024-05-01 3:37:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[GetMasterReport]
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

Insert into  #T6_1(Route, EmployeeId, Description, Type, Draw, Rate, AMOUNT)
SELECT
	IT1.Route,
	IT1.EmployeeId,
	'ROUTE ADJUSTMENT' AS Description,
	'RTADJ' AS Type,
	1 AS Draw,
	0 AS Rate,
	CASE
		WHEN count(distinct IT1.Date) = IT2.Frequency THEN IT2.Amount
		ELSE (count(distinct IT1.Date)*IT2.Amount)/IT2.Frequency 
	END AS Amount
FROM #T0 AS IT1
JOIN [dbo].[RouteAdjustment] AS IT2
ON IT2.EmployeeId = IT1.EmployeeId AND IT2.Route = IT1.Route
Group By IT1.EmployeeId, IT1.Route, IT2.Frequency, IT2.Amount

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
	#T5.EmployeeId,
	#T5.Route,
	COALESCE(#T5.DrawGrandTotal, 0) AS DrawGrandTotal,
	COALESCE(#T8.AdjustmentGrandTotal, 0) AS AdjustmentGrandTotal,
	(COALESCE(DrawGrandTotal,0) + COALESCE(AdjustmentGrandTotal,0)) AS RouteGrandTotal
INTO #T9
FROM #T5
Left Join #T8
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
LEFT JOIN #T6
ON #T6.EmployeeID = #T5.EmployeeID
AND #T6.Route = #T5.Route
LEFT JOIN #T8
ON #T8.EmployeeID = #T5.EmployeeID
AND #T8.Route = #T5.Route
LEFT JOIN #T9
ON #T9.EmployeeID = #T5.EmployeeID
AND #T9.Route = #T5.Route

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
	E.Name,
	STUFF(
		(SELECT 
			DISTINCT ' | ' + Route 
		FROM  #T10
		WHERE #T10.EmployeeID = IT1.EmployeeId
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
		SELECT Amount
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

Group By IT1.EmployeeID, E.Name, OtherPayments,TotalOtherPay, EmployeeRouteTotal


set @jsonDataOut = (
	Select 
		* 
	from #TF
	Order By Routes
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

