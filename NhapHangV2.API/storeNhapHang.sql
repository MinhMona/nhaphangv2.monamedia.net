USE [NhapHangV2]
GO
/****** Object:  StoredProcedure [dbo].[AdminSendUserWallet_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 2/11/2021
-- Description:	Lịch sử nạp gần đây
-- =============================================
CREATE PROCEDURE [dbo].[AdminSendUserWallet_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@UID INT = NULL,
	@Status INT = NULL,
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)

    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' ASUW.*,
			COUNT(CASE WHEN ASUW.[Status] = 1 THEN 1 ELSE NULL END) OVER() AS ''TotalStatus1'',
			COUNT(CASE WHEN ASUW.[Status] = 2 THEN 1 ELSE NULL END) OVER() AS ''TotalStatus2'',
			COUNT(CASE WHEN ASUW.[Status] = 3 THEN 1 ELSE NULL END) OVER() AS ''TotalStatus3'',

			SUM(ASUW.Amount) OVER() AS ''TotalAmount'',
			SUM(CASE WHEN ASUW.[Status] = 1 THEN ASUW.Amount ELSE 0 END) OVER() AS ''TotalAmount1'',
			SUM(CASE WHEN ASUW.[Status] = 2 THEN ASUW.Amount ELSE 0 END) OVER() AS ''TotalAmount2'',

			U.UserName,
			U.Wallet,
			SUM(U.Wallet) OVER() AS ''TotalWallet'',
			B.BankName,

			COUNT(ASUW.Id) OVER() AS TotalItem
			FROM AdminSendUserWallet ASUW 
				LEFT JOIN (SELECT ID, UserName, Wallet FROM Users) U ON ASUW.[UID] = U.ID 
				LEFT JOIN (SELECT ID, BankName FROM Bank) B ON ASUW.BankId = B.ID ';

	SET @whereCondition = ' WHERE ASUW.Deleted = 0 ';

	IF (@UID IS NOT NULL AND @UID > 0)
	BEGIN
		SET @whereCondition += ' AND ASUW.[UID] = @UID ';
	END

	IF (@Status IS NOT NULL AND @Status > 0)
	BEGIN
		SET @whereCondition += ' AND ASUW.[Status] = @Status ';
	END

	IF (@FromDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, ASUW.Created) >= CONVERT(DATE, @FromDate) '
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, ASUW.Created) <= CONVERT(DATE, @ToDate) '
	END

	IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	BEGIN
		SET @whereCondition += ' AND (U.UserName LIKE ''%' + @SearchContent + '%''' 
		+ ' )';
	END

	SET @groupBy = ''

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';	
	END

	EXECUTE sp_executesql @sqlResult
		, N'@UID INT, @Status INT, @FromDate DATETIME, @ToDate DATETIME'
		, @UID = @UID, @Status = @Status, @FromDate = @FromDate, @ToDate = @ToDate;
END
GO
/****** Object:  StoredProcedure [dbo].[Bank_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 5/11/2021
-- Description:	Danh sách ngân hàng
-- =============================================
CREATE PROCEDURE [dbo].[Bank_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' B.*, COUNT(B.Id) OVER() AS TotalItem
				FROM Bank B ';

	SET @whereCondition = ' WHERE B.Deleted = 0 '
	SET @groupBy = ''

	--Phân trang + Order By
	SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
	+ ' ORDER BY ' + @OrderBy
	+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	EXECUTE sp_executesql @sqlResult
END
GO
/****** Object:  StoredProcedure [dbo].[BigPackage_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 15/11/2021
-- Description:	Quản lý bao hàng
-- =============================================
CREATE PROCEDURE [dbo].[BigPackage_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' BP.*, SP.Total,
				COUNT(BP.Id) OVER() AS TotalItem
			FROM BigPackage BP
			OUTER APPLY(
				SELECT COUNT(ID) AS Total FROM SmallPackage SP WHERE SP.BigPackageID = BP.ID
			) AS SP ';
	
	SET @whereCondition = ' WHERE BP.Deleted = 0 ';
	  IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
		BEGIN
			SET @whereCondition += ' AND (BP.Code LIKE ''%' + @SearchContent + '%'''
			+ ' )';
		END

	SET @groupBy = ''

	--Phân trang + Order By
	SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
	+ ' ORDER BY ' + @OrderBy
	+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	EXECUTE sp_executesql @sqlResult
	, N'@SearchContent NVARCHAR(1000)'
	, @SearchContent = @SearchContent ;
END
GO
/****** Object:  StoredProcedure [dbo].[Complain_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 3/11/2021
-- Description:	Danh sách khiếu nại
-- =============================================
CREATE PROCEDURE [dbo].[Complain_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@UID INT = NULL,
	@Status INT = NULL,
	@SearchContent NVARCHAR(1000) = NULL,
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' C.*, U.UserName, MO.CurrentCNYVN, COUNT(C.Id) OVER() AS TotalItem
				FROM Complain C 
				LEFT OUTER JOIN (SELECT ID, CurrentCNYVN FROM MainOrder) MO ON MO.Id = C.MainOrderId
				LEFT OUTER JOIN (SELECT ID, UserName FROM Users) U ON U.Id = C.[UID] ';

	SET @whereCondition = ' WHERE C.Deleted = 0';

	IF (@UID IS NOT NULL AND @UID > 0)
	BEGIN
		SET @whereCondition += ' AND C.[UID] = @UID ';
	END

	IF (@Status IS NOT NULL AND @Status >= 0)
	BEGIN
		SET @whereCondition += ' AND C.[Status] = @Status ';
	END

	IF (@FromDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, C.Created) >= CONVERT(DATE, @FromDate) '
	END

	IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	BEGIN
		SET @whereCondition += ' AND (C.CreatedBy LIKE ''%' + @SearchContent + '%''' 
			+ ' )';
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, C.Created) <= CONVERT(DATE, @ToDate) '
	END

	SET @groupBy = '';

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';	
	END

	EXECUTE sp_executesql @sqlResult
	, N'@UID INT, @Status INT, @SearchContent NVARCHAR(1000), @FromDate DATETIME, @ToDate DATETIME'
	, @UID = @UID, @Status = @Status, @SearchContent = @SearchContent, @FromDate = @FromDate, @ToDate = @ToDate;
END
GO
/****** Object:  StoredProcedure [dbo].[Dashboard_GetItemInWeek]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 27/5/2022
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Dashboard_GetItemInWeek]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	DECLARE @Monday DATE = (SELECT DATEADD(wk, DATEDIFF(wk,0,GETDATE()),0))
	DECLARE @Sunday DATE = (SELECT DATEADD(wk, DATEDIFF(wk,0,GETDATE()),6))
	DECLARE @table TABLE(DateOfWeek DATE)
	WHILE @Monday <= @Sunday
	BEGIN
		INSERT INTO @table VALUES (@Monday);
		SET @Monday = DATEADD(DAY, 1, @Monday);
	END

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT T.*, 
		MO1.MainOrder,
		MO3.MainOrderAnother,
		TRO.TransportationOrder,
		PH.PayHelp,
		ASUW.AdminSendUserWallet
	FROM @table T
		OUTER APPLY(
			SELECT COUNT(*) AS MainOrder FROM MainOrder WHERE CAST(Created AS DATE) = T.DateOfWeek AND OrderType = 1
		) AS MO1 --Mua hàng hộ
		OUTER APPLY(
			SELECT COUNT(*) AS MainOrderAnother FROM MainOrder WHERE CAST(Created AS DATE) = T.DateOfWeek AND OrderType = 3
		) AS MO3 --Mua hàng hộ khác
		OUTER APPLY(
			SELECT COUNT(*) AS TransportationOrder FROM TransportationOrder WHERE CAST(Created AS DATE) = T.DateOfWeek
		) AS TRO --Vận chuyển hộ
		OUTER APPLY(
			SELECT COUNT(*) AS PayHelp FROM PayHelp WHERE CAST(Created AS DATE) = T.DateOfWeek
		) AS PH --Thanh toán hộ
		OUTER APPLY(
			SELECT ISNULL(SUM(Amount), 0) AS AdminSendUserWallet FROM AdminSendUserWallet WHERE CAST(Created AS DATE) = T.DateOfWeek AND [Status] = 2
		) AS ASUW --Tổng tiền khách nạp
		GROUP BY T.DateOfWeek, MO1.MainOrder, MO3.MainOrderAnother, TRO.TransportationOrder, PH.PayHelp, ASUW.AdminSendUserWallet
END
GO
/****** Object:  StoredProcedure [dbo].[Dashboard_GetTotalInWeek]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 28/4/2022
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[Dashboard_GetTotalInWeek]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	DECLARE @Monday DATE = (SELECT DATEADD(wk, DATEDIFF(wk,0,GETDATE()),0))
	DECLARE @Sunday DATE = (SELECT DATEADD(wk, DATEDIFF(wk,0,GETDATE()),6))

	DECLARE @MondayPrev DATE = (SELECT DATEADD(wk, DATEDIFF(wk,0,GETDATE()),-7))
	DECLARE @SundayPrev DATE = (SELECT DATEADD(wk, DATEDIFF(wk,0,GETDATE()),-1))

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @table TABLE(MainOrderCount INT, 
		MainOrderAnotherCount INT, 
		TransportationOrderCount INT, 
		PayHelpCount INT,
		TotalAmount DECIMAL,
		TotalAmountPrev DECIMAL
	)
	INSERT INTO @table SELECT 
		-- Mua hàng hộ
		(SELECT COUNT(*) FROM MainOrder WHERE OrderType = 1 AND CONVERT(DATE, Created) >= CONVERT(DATE, @Monday) AND CONVERT(DATE, Created) <= CONVERT(DATE, @Sunday)),
		-- Mua hàng hộ khác
		(SELECT COUNT(*) FROM MainOrder WHERE OrderType = 3 AND CONVERT(DATE, Created) >= CONVERT(DATE, @Monday) AND CONVERT(DATE, Created) <= CONVERT(DATE, @Sunday)),
		-- Vận chuyển hộ
		(SELECT COUNT(*) FROM TransportationOrder WHERE CONVERT(DATE, Created) >= CONVERT(DATE, @Monday) AND CONVERT(DATE, Created) <= CONVERT(DATE, @Sunday)),
		-- Thanh toán hộ
		(SELECT COUNT(*) FROM PayHelp WHERE CONVERT(DATE, Created) >= CONVERT(DATE, @Monday) AND CONVERT(DATE, Created) <= CONVERT(DATE, @Sunday)),
		-- Tổng tiền khách nạp trong tuần
		(SELECT ISNULL(SUM(Amount), 0) FROM AdminSendUserWallet WHERE [Status] = 2 AND CONVERT(DATE, Created) >= CONVERT(DATE, @Monday) AND CONVERT(DATE, Created) <= CONVERT(DATE, @Sunday)),
		-- Tổng tiền khách nạp trong tuần vừa rồi
		(SELECT ISNULL(SUM(Amount), 0) FROM AdminSendUserWallet WHERE [Status] = 2 AND CONVERT(DATE, Created) >= CONVERT(DATE, @MondayPrev) AND CONVERT(DATE, Created) <= CONVERT(DATE, @SundayPrev))
	SELECT T.* FROM @table T
END
GO
/****** Object:  StoredProcedure [dbo].[ExportRequestTurn_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 29/10/2021
-- Description:	Danh sách thống kê cước ký gửi
-- =============================================
CREATE PROCEDURE [dbo].[ExportRequestTurn_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@UID INT = NULL,
	@Status INT = NULL,
	@SearchContent NVARCHAR(1000) = NULL,
	@UserName NVARCHAR(1000) = NULL,
	@OrderTransactionCode NVARCHAR(1000) = NULL,
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' ERT.ID, ERT.Created, ERT.TotalWeight, ERT.TotalPriceVND, ERT.[Status], ERT.[StatusExport], ERT.StaffNote,
				 U.UserName, --Tên tài khoản
				 STRING_AGG(ISNULL(SP.OrderTransactionCode, '''') 
				 + ''_'' + CAST(CASE WHEN SP.DateOutWarehouse IS NULL THEN '' '' ELSE CAST(SP.DateOutWarehouse AS NVARCHAR(MAX)) END AS NVARCHAR(MAX))
				 , '';'') AS BarCodeAndDateOut, --Ngày XK
				 ROS.Total AS TotalPackage, --Tổng số kiện
				 STVN.[Name] AS ShippingTypeVNName, --HTVC
				 COUNT(ERT.Id) OVER() AS TotalItem
			FROM ExportRequestTurn ERT
				OUTER APPLY(
					SELECT COUNT(ExportRequestTurnID) AS Total FROM RequestOutStock ROS WHERE ROS.ExportRequestTurnID = ERT.ID
				) AS ROS
				LEFT JOIN (SELECT ID, [Name] FROM ShippingTypeVN) STVN ON ERT.ShippingTypeInVNID = STVN.ID 
				LEFT JOIN (SELECT ExportRequestTurnID, SmallPackageID FROM RequestOutStock) ROSS ON ROSS.ExportRequestTurnID = ERT.ID
				LEFT JOIN (SELECT ID, OrderTransactionCode, DateOutWarehouse FROM SmallPackage) SP ON ROSS.SmallPackageID = SP.ID 
				LEFT JOIN (SELECT ID, UserName FROM Users) U ON ERT.[UID] = U.Id ';

	SET @whereCondition = ' WHERE ERT.Deleted = 0 ';

	IF (@UID IS NOT NULL AND @UID > 0)
	BEGIN
		SET @whereCondition += ' AND ERT.[UID] = @UID ';
	END

	IF (@Status IS NOT NULL AND @Status >= 0)
	BEGIN
		SET @whereCondition += ' AND ERT.[Status] = @Status ';
	END

	IF (@UserName IS NOT NULL AND LEN(@UserName) > 0)
	BEGIN
		SET @whereCondition += ' AND U.UserName LIKE ''%@UserName%'' ' 
	END

	IF (@OrderTransactionCode IS NOT NULL AND LEN(@OrderTransactionCode) > 0)
	BEGIN
		SET @whereCondition += ' AND SP.OrderTransactionCode LIKE ''%@OrderTransactionCode%'' ' 
	END

	IF (@FromDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, ERT.Created) >= CONVERT(DATE, @FromDate) '
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, ERT.Created) <= CONVERT(DATE, @ToDate) '
	END

	SET @groupBy = ' GROUP BY ERT.ID, ERT.Created, U.UserName, ROS.Total, ERT.TotalWeight, ERT.TotalPriceVND, STVN.[Name], ERT.[Status], ERT.[StatusExport], ERT.StaffNote ';

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';	
	END

	EXECUTE sp_executesql @sqlResult
		, N'@UID INT, @Status INT, @UserName NVARCHAR(1000), @OrderTransactionCode NVARCHAR(1000), @FromDate DATETIME, @ToDate DATETIME'
		, @UID = @UID, @Status = @Status, @UserName = @UserName, @OrderTransactionCode = @OrderTransactionCode, @FromDate = @FromDate, @ToDate = @ToDate;
END
GO
/****** Object:  StoredProcedure [dbo].[FeeBuyPro_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 5/11/2021
-- Description:	Cấu hình phí dịch vụ mua hàng
-- =============================================
CREATE PROCEDURE [dbo].[FeeBuyPro_GetPagingData] 
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' FBP.*, COUNT(FBP.Id) OVER() AS TotalItem
			FROM FeeBuyPro FBP ';

	SET @whereCondition = 'WHERE FBP.Deleted = 0 '
	SET @groupBy = ''

	--Phân trang + Order By
	SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
	+ ' ORDER BY ' + @OrderBy
	+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	EXECUTE sp_executesql @sqlResult
END
GO
/****** Object:  StoredProcedure [dbo].[FeeCheckProduct_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FeeCheckProduct_GetPagingData] 
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(MAX) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' FBP.*, COUNT(FBP.Id) OVER() AS TotalItem
			FROM FeeCheckProduct FBP ';

	SET @whereCondition = 'WHERE FBP.Deleted = 0 '
	SET @groupBy = ''

	--Phân trang + Order By
	SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
	+ ' ORDER BY ' + @OrderBy
	+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	EXECUTE sp_executesql @sqlResult
END
GO
/****** Object:  StoredProcedure [dbo].[FeePackaged_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FeePackaged_GetPagingData] 
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' FP.*, COUNT(FBP.Id) OVER() AS TotalItem
			FROM FeePackaged FP ';

	SET @whereCondition = 'WHERE FP.Deleted = 0 '
	SET @groupBy = ''

	--Phân trang + Order By
	SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
	+ ' ORDER BY ' + @OrderBy
	+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	EXECUTE sp_executesql @sqlResult
END
GO
/****** Object:  StoredProcedure [dbo].[HistoryPayWallet_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 1/11/2021
-- Description:	Load lịch sử giao dịch
-- =============================================
CREATE PROCEDURE [dbo].[HistoryPayWallet_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@UID INT,
	@Status INT = NULL,
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' HPW.*, 

				SUM(CASE WHEN HPW.TradeType = 4 THEN HPW.Amount ELSE 0 END) OVER() AS ''TotalAmount4'',
				U.Wallet,

				COUNT(HPW.Id) OVER() AS TotalItem
				FROM HistoryPayWallet HPW 
					LEFT JOIN (SELECT Id, Wallet FROM Users) U ON HPW.[UID] = U.Id ';

	SET @whereCondition = 'WHERE HPW.Deleted = 0 ';

	IF (@UID IS NOT NULL AND @UID > 0)
	BEGIN
		SET @whereCondition += ' AND HPW.[UID] = @UID ';
	END

	IF (@Status IS NOT NULL AND @Status > 0)
	BEGIN
		IF (@Status = 1)
		BEGIN
			SET @whereCondition += ' AND HPW.TradeType = 1 ';
		END
		ELSE IF (@Status = 2)
		BEGIN
			SET @whereCondition += ' AND HPW.TradeType = 3 ';
		END
		ELSE IF (@Status = 3)
		BEGIN
			SET @whereCondition += ' AND HPW.[Type] = 2 ';
		END
		ELSE
		BEGIN
			SET @whereCondition += ' AND HPW.[Type] = 1 ';
		END
	END

	IF (@FromDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, HPW.Created) >= CONVERT(DATE, @FromDate)'
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, HPW.Created) <= CONVERT(DATE, @ToDate) '
	END

	SET @groupBy = ''

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
	+ ' ORDER BY ' + @OrderBy
	+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';	
	END

	EXECUTE sp_executesql @sqlResult
		, N'@UID INT, @FromDate DATETIME, @ToDate DATETIME'
		, @UID = @UID, @FromDate = @FromDate, @ToDate = @ToDate;
END
GO
/****** Object:  StoredProcedure [dbo].[HistoryPayWalletCNY_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 2/11/2021
-- Description:	Lịch sử giao dịch tệ
-- =============================================
CREATE PROCEDURE [dbo].[HistoryPayWalletCNY_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@UID INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' HPWC.*, COUNT(HPWC.Id) OVER() AS TotalItem
			FROM HistoryPayWalletCNY HPWC ';

	SET @whereCondition = ' WHERE HPWC.Deleted = 0 ';

	IF (@UID IS NOT NULL AND @UID > 0)
	BEGIN
		SET @whereCondition += ' AND HPWC.[UID] = @UID ';
	END

	SET @groupBy = ''

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';	
	END

	EXECUTE sp_executesql @sqlResult
		, N'@UID INT'
		, @UID = @UID;
END
GO
/****** Object:  StoredProcedure [dbo].[MainOrder_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 15/10/2021
-- Description:	Lấy danh sách đơn hàng có phân trang
-- =============================================
CREATE PROCEDURE [dbo].[MainOrder_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@UID INT = NULL,
	@Status INT = NULL,
	@TypeSearch INT = NULL,
	@OrderType INT = NULL,
	@SearchContent NVARCHAR(1000) = NULL,
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL,
	@FromPrice DECIMAL(18, 0) = NULL,
	@ToPrice DECIMAL(18, 0) = NULL,
	@MainOrderCode NVARCHAR(1000) = NULL,
	@OrderTransactionCode NVARCHAR(1000) = NULL,
	@IsNotMainOrderCode BIT = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' MO.Id,
		MO.[Site],
		O.ImageOrigin,
		MO.CurrentCNYVN,
		MO.IsDoneSmallPackage,

		U.UserName,
		MO.DatHangId,
		ORD.UserName AS OrdererUserName,
		MO.SalerId,
		SAL.UserName AS SalerUserName,

		STRING_AGG(ISNULL(MOC.Code,'''') + ''_'' + ISNULL(SP.OrderTransactionCode,''''), '';'') AS MainOrderTransactionCode,

		MO.Created,
		MO.DepositDate,
		MO.DateTQ,
		MO.DateVN,
		MO.PayDate,
		MO.CompleteDate,

		MO.[Status],
		MO.TotalPriceVND,
		MO.Deposit,
		MO.AmountDeposit,
		MO.PriceVND,
		MO.PriceCNY,
		
		U.Wallet,
		U.FullName,
		U.[Address],
		U.Email,
		U.Phone,
		A.TotalLink,

		SUM(MO.TotalPriceVND) OVER() AS TotalAllPrice,
		SUM(MO.TotalPriceReal) OVER() AS TotalAllPriceReal,
		SUM(MO.Deposit) OVER() AS TotalAllDeposit,

		COUNT(CASE WHEN MO.[Status] = 0 THEN 1 ELSE NULL END) OVER() AS ''TotalStatus0'',
		COUNT(CASE WHEN MO.[Status] = 1 THEN 1 ELSE NULL END) OVER() AS ''TotalStatus1'',
		COUNT(CASE WHEN MO.[Status] = 2 THEN 1 ELSE NULL END) OVER() AS ''TotalStatus2'',

		COUNT(CASE WHEN MO.[Status] = 5 THEN 1 ELSE NULL END) OVER() AS ''TotalStatus5'',
		COUNT(CASE WHEN MO.[Status] = 6 THEN 1 ELSE NULL END) OVER() AS ''TotalStatus6'',
		COUNT(CASE WHEN MO.[Status] = 7 THEN 1 ELSE NULL END) OVER() AS ''TotalStatus7'',

		COUNT(CASE WHEN MO.[Status] = 9 THEN 1 ELSE NULL END) OVER() AS ''TotalStatus9'',
		COUNT(CASE WHEN MO.[Status] = 10 THEN 1 ELSE NULL END) OVER() AS ''TotalStatus10'',

		COUNT(MO.Id) OVER() AS TotalItem
		FROM MainOrder AS MO
		LEFT OUTER JOIN (SELECT ImageOrigin, MainOrderID, ROW_NUMBER() OVER (PARTITION BY MainOrderID ORDER BY (SELECT NULL)) AS RowNumber FROM [Order]) O ON O.MainOrderID = MO.ID AND RowNumber = 1
		LEFT OUTER JOIN (SELECT COUNT(*) AS TotalLink, MainOrderID FROM [Order] GROUP BY MainOrderID) AS A ON A.MainOrderID = MO.ID
		LEFT OUTER JOIN (SELECT Id, UserName, FullName, [Address], Phone, Email, Wallet FROM Users) AS U ON U.Id = MO.[UID] 
		LEFT OUTER JOIN (SELECT Id, MainOrderID, Code FROM MainOrderCode WHERE Deleted = 0) MOC ON MO.ID = MOC.MainOrderID
		LEFT OUTER JOIN (SELECT MainOrderCodeId, MainOrderId, OrderTransactionCode FROM SmallPackage WHERE Deleted = 0) SP ON SP.MainOrderID = MO.ID AND SP.MainOrderCodeID = MOC.ID

		LEFT OUTER JOIN (SELECT ID, UserName FROM Users) ORD ON MO.DatHangId = ORD.Id
		LEFT OUTER JOIN (SELECT ID, UserName FROM Users) SAL ON MO.SalerId = SAL.Id ';

	SET @whereCondition = ' WHERE MO.Deleted = 0 ';

	IF (@UID IS NOT NULL AND @UID > 0)
	BEGIN
		SET @whereCondition += ' AND MO.[UID] = @UID ';
	END

	IF (@OrderType IS NOT NULL AND @OrderType > 0)
	BEGIN
		SET @whereCondition += ' AND MO.[OrderType] = @OrderType ';
	END

	IF (@Status IS NOT NULL AND @Status >= 0)
	BEGIN
		SET @whereCondition += ' AND MO.[Status] = @Status ';
	END

	IF (@TypeSearch IS NOT NULL AND @TypeSearch > 0)
	BEGIN
		IF (@TypeSearch = 1)
		BEGIN
			SET @whereCondition += ' AND MO.ID = @SearchContent ';
		END
		IF (@TypeSearch = 2)
		BEGIN
			SET @whereCondition += ' AND MO.BarCode = @SearchContent ';
		END
		ELSE IF (@TypeSearch = 3)
		BEGIN
			SET @whereCondition += ' AND MO.Site LIKE ''%@SearchContent%''' 
		END
		--ELSE IF (@TypeSearch = 4) //Tên sản phẩm
		--BEGIN
		--	SET @whereCondition += ' AND  LIKE ''%@SearchContent%''' 
		--END
		ELSE IF (@TypeSearch = 5)
		BEGIN
			SET @whereCondition += ' AND U.UserName LIKE ''%@SearchContent%''' 
		END
	END

	IF (@FromDate IS NOT NULL)
	BEGIN
	 SET @whereCondition += CASE @Status 
		WHEN 2 THEN ' AND CONVERT(DATE, MO.DepositDate) >= CONVERT(DATE, @FromDate) '
		WHEN 5 THEN ' AND CONVERT(DATE, MO.DateBuy) >= CONVERT(DATE, @FromDate) '
		WHEN 6 THEN ' AND CONVERT(DATE, MO.DateTQ) >= CONVERT(DATE, @FromDate) '
		WHEN 7 THEN ' AND CONVERT(DATE, MO.DateVN) >= CONVERT(DATE, @FromDate) '
		WHEN 9 THEN ' AND CONVERT(DATE, MO.PayDate) >= CONVERT(DATE, @FromDate) '
		WHEN 10 THEN ' AND CONVERT(DATE, MO.CompleteDate) >= CONVERT(DATE, @FromDate) '
		ELSE ' AND CONVERT(DATE, MO.Created) >= CONVERT(DATE, @FromDate) '
		END
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
	 SET @whereCondition += CASE @Status 
		WHEN 2 THEN ' AND CONVERT(DATE, MO.DepositDate) <= CONVERT(DATE, @ToDate) '
		WHEN 5 THEN ' AND CONVERT(DATE, MO.DateBuy) <= CONVERT(DATE, @ToDate) '
		WHEN 6 THEN ' AND CONVERT(DATE, MO.DateTQ) <= CONVERT(DATE, @ToDate) '
		WHEN 7 THEN ' AND CONVERT(DATE, MO.DateVN) <= CONVERT(DATE, @ToDate) '
		WHEN 9 THEN ' AND CONVERT(DATE, MO.PayDate) <= CONVERT(DATE, @ToDate) '
		WHEN 10 THEN ' AND CONVERT(DATE, MO.CompleteDate) <= CONVERT(DATE, @ToDate) '
		ELSE ' AND CONVERT(DATE, MO.Created) <= CONVERT(DATE, @ToDate) '
		END
	END

	IF (@FromPrice IS NOT NULL AND @FromPrice > 0)
	BEGIN
		SET @whereCondition += ' AND MO.TotalPriceVND >= @FromPrice '
	END

	IF (@ToPrice IS NOT NULL AND @ToPrice > 0)
	BEGIN
		SET @whereCondition += ' AND MO.TotalPriceVND <= @ToPrice '
	END

	IF (@IsNotMainOrderCode IS NOT NULL AND @IsNotMainOrderCode = 1)
	BEGIN
		SET @whereCondition += ' AND (MOC.Code IS NULL AND MOC.Code = '''') '
	END

	IF (@MainOrderCode IS NOT NULL AND LEN(@MainOrderCode) > 0)
	BEGIN
		SET @whereCondition += ' AND MOC.Code LIKE ''%' + @MainOrderCode + '%'' '
	END

	IF (@OrderTransactionCode IS NOT NULL AND LEN(@OrderTransactionCode) > 0)
	BEGIN
		SET @whereCondition += ' AND SP.OrderTransactionCode LIKE ''%' + @OrderTransactionCode + '%'' '
	END

	SET @groupBy = ' GROUP BY 
		MO.Id,
		MO.[Site],
		O.ImageOrigin,
		MO.CurrentCNYVN,
		MO.IsDoneSmallPackage,

		U.UserName,
		MO.DatHangId,
		ORD.UserName,
		MO.SalerId,
		SAL.UserName,

		MO.Created,
		MO.DepositDate,
		MO.DateTQ,
		MO.DateVN,
		MO.PayDate,
		MO.CompleteDate,

		MO.[Status],
		MO.TotalPriceVND,
		MO.Deposit,
		MO.AmountDeposit,
		MO.PriceVND,
		MO.PriceCNY,
		
		U.Wallet,
		U.FullName,
		U.[Address],
		U.Email,
		U.Phone,
		A.TotalLink,

		MO.TotalPriceReal '

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	END

	EXECUTE sp_executesql @sqlResult
		, N'@UID INT, @Status INT, @TypeSearch INT, @OrderType INT, @SearchContent NVARCHAR(50), @FromDate DATETIME, @ToDate DATETIME, @FromPrice DECIMAL(18, 0), @ToPrice DECIMAL(18, 0), @IsNotMainOrderCode BIT'
		, @UID = @UID, @Status = @Status, @TypeSearch = @TypeSearch, @OrderType = @OrderType, @SearchContent = @SearchContent, @FromDate = @FromDate, @ToDate = @ToDate, @FromPrice = @FromPrice, @ToPrice = @ToPrice, @IsNotMainOrderCode = @IsNotMainOrderCode;
END
GO
/****** Object:  StoredProcedure [dbo].[MainOrderCode_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 22/2/2022
-- Description:	Load mã đơn hàng
-- =============================================
CREATE PROCEDURE [dbo].[MainOrderCode_GetPagingData] 
	-- Add the parameters for the stored procedure here
	@MainOrderID INT = NULL,
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' MOC.*, COUNT(MOC.Id) OVER() AS TotalItem
				FROM MainOrderCode MOC ';

	SET @whereCondition = ' WHERE MOC.Deleted = 0 '

	IF (@MainOrderID IS NOT NULL AND @MainOrderID > 0)
	BEGIN
		SET @whereCondition += ' AND MOC.MainOrderID = @MainOrderID ';
	END

	SET @groupBy = ''

	--Phân trang + Order By
	SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
	+ ' ORDER BY ' + @OrderBy
	+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	EXECUTE sp_executesql @sqlResult
		, '@MainOrderID INT'
		, @MainOrderID = @MainOrderID
END
GO
/****** Object:  StoredProcedure [dbo].[Notification_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 19/4/2022
-- Description:	Danh sách thông báo
-- =============================================
CREATE PROCEDURE [dbo].[Notification_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL,
	@UID INT = NULL,
	@UserGroupId INT = NULL,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)

    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' NO.*, COUNT(NO.Id) OVER() AS TotalItem
			FROM [Notification] NO ';

	SET @whereCondition = ' WHERE NO.Deleted = 0 ';

	IF (@UID IS NOT NULL AND @UserGroupId IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND (NO.ToUserId = @UID OR NO.UserGroupId = @UserGroupId) ';
	END

	IF (@FromDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, NO.Created) >= CONVERT(DATE, @FromDate) '
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, NO.Created) <= CONVERT(DATE, @ToDate) '
	END

	IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	BEGIN
		SET @whereCondition += ' AND (NO.NotificationContent LIKE ''%' + @SearchContent + '%''' 
		+ ' )';
	END

	SET @groupBy = ''

	--Phân trang + Order By
	SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
	+ ' ORDER BY ' + @OrderBy
	+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	EXECUTE sp_executesql @sqlResult
		, N'@FromDate DATETIME, @ToDate DATETIME, @UID INT, @UserGroupId INT'
		, @FromDate = @FromDate, @ToDate = @ToDate, @UID = @UID, @UserGroupId = @UserGroupId;
END
GO
/****** Object:  StoredProcedure [dbo].[OrderComment_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 27/4/2022
-- Description:	Danh sách nhắn tin đơn hàng
-- =============================================
CREATE PROCEDURE [dbo].[OrderComment_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@MainOrderId INT = NULL,
	@Type INT = NULL,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)

    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' OC.*, U.UserName, COUNT(OC.Id) OVER() AS TotalItem
			FROM OrderComment OC 
			LEFT JOIN Users U ON OC.[UID] = U.ID ';

	SET @whereCondition = ' WHERE OC.Deleted = 0 ';

	IF (@MainOrderId IS NOT NULL AND @MainOrderId > 0)
	BEGIN
		SET @whereCondition += ' AND OC.MainOrderId = @MainOrderId ';
	END

	IF (@Type IS NOT NULL AND @Type > 0)
	BEGIN
		SET @whereCondition += ' AND OC.[Type] = @Type ';
	END

	SET @groupBy = ''

	--Phân trang + Order By
	SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
	+ ' ORDER BY ' + @OrderBy
	+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	EXECUTE sp_executesql @sqlResult
		, N'@MainOrderId INT, @Type INT'
		, @MainOrderId = @MainOrderId, @Type = @Type;
END
GO
/****** Object:  StoredProcedure [dbo].[OrderShopTemp_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 13/10/2021
-- Description:	Lấy danh sách shop của đơn hàng có phân trang
-- =============================================
CREATE PROCEDURE [dbo].[OrderShopTemp_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@UID INT = NULL,
	@SearchContent NVARCHAR(MAX) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' OST.*,
				U.FullName,
				U.Phone,
				U.Email,
				U.[Address],
			COUNT(OST.Id) OVER() AS TotalItem
		FROM OrderShopTemp AS OST
			LEFT OUTER JOIN Users AS U ON OST.[UID] = U.Id';

	SET @whereCondition = ' WHERE OST.Deleted = 0 ';
	IF (@UID IS NOT NULL AND @UID > 0)
	BEGIN
		SET @whereCondition += ' AND OST.UID = @UID ';
	END

	SET @groupBy = ''

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	END
	EXECUTE sp_executesql @sqlResult
		, N'@UID INT'
		, @UID = @UID;
END
GO
/****** Object:  StoredProcedure [dbo].[OrderTemp_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 13/10/2021
-- Description:	Lấy danh sách sản phẩm trong shop của đơn hàng có phân trang
-- =============================================
CREATE PROCEDURE [dbo].[OrderTemp_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@UID INT = NULL,
	@ShopID INT = NULL,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	DECLARE @currentSys DECIMAL(18, 0) = (SELECT TOP 1 Currency FROM [Configurations])
	DECLARE @currentUser DECIMAL(18, 0) = (SELECT Currency FROM Users WHERE ID = @UID)

	DECLARE @current DECIMAL(18, 0)

	IF (@currentUser IS NOT NULL AND @currentUser > 0)
	BEGIN
		SET @current = @currentUser
	END
	ELSE
	BEGIN
		SET @current = @currentSys
	END

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' OT.*, 
	@current AS Currency, 
	CASE WHEN OT.PricePromotion > 0 AND OT.PricePromotion < OT.PriceOrigin 
		THEN SUM(OT.PricePromotion * OT.Quantity * @current) OVER()
	ELSE SUM(OT.PriceOrigin * OT.Quantity * @current) OVER()
		END AS MaxEPriceBuyVN,
	COUNT(OT.Id) OVER() AS TotalItem 
		FROM OrderTemp AS OT';

	SET @whereCondition = ' WHERE OT.Deleted = 0 ';

	IF (@ShopID IS NOT NULL AND @ShopID > 0)
	BEGIN
		SET @whereCondition += ' AND OT.OrderShopTempID = @ShopID';
	END

	SET @groupBy = ''

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	END
	EXECUTE sp_executesql @sqlResult
		, N'@ShopID INT, @current DECIMAL(18, 0)'
		, @ShopID = @ShopID, @current = @current;
END
GO
/****** Object:  StoredProcedure [dbo].[OutStockSession_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 16/3/2022
-- Description:	Thanh toán xuất kho
-- =============================================
CREATE PROCEDURE [dbo].[OutStockSession_GetPagingData] 
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@Status INT = NULL,
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' OSS.Id, OSS.[UID], US.UserName, OSS.Created, OSS.[Status],
		(MO.TotalPriceVND + MO.FeeInWareHouse - MO.Deposit) AS TotalPay, --SUM???
		COUNT(OSS.Id) OVER() AS TotalItem 
	FROM OutStockSession OSS 
		LEFT JOIN OutStockSessionPackage OSSP ON OSSP.OutStockSessionId = OSS.Id
		LEFT JOIN SmallPackage SP ON SP.Id = OSSP.SmallPackageId
		LEFT JOIN MainOrder MO ON MO.Id = SP.MainOrderId 
		LEFT JOIN Users US ON US.Id = OSS.[UID] ';

	SET @whereCondition = ' WHERE OSS.Deleted = 0 ';

	IF (@Status IS NOT NULL AND @Status >= 0)
	BEGIN
		SET @whereCondition += ' AND OSS.[Status] = @Status ';
	END

	IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	BEGIN
		SET @whereCondition += ' AND (US.UserName LIKE ''%' + @SearchContent + '%''' 
		+ ' )';
	END

	IF (@FromDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, OSS.Created) >= CONVERT(DATE, @FromDate) '
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, OSS.Created) <= CONVERT(DATE, @ToDate) '
	END

	SET @groupBy = ' GROUP BY OSS.Id, OSS.[UID], OSS.[Status], OSS.Created, US.UserName, MO.TotalPriceVND, MO.FeeInWareHouse, MO.Deposit ';

	--Phân trang + Order By
	SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
	+ ' ORDER BY ' + @OrderBy
	+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	EXECUTE sp_executesql @sqlResult
	, N'@Status INT, @FromDate DATETIME, @ToDate DATETIME '
	, @Status = @Status, @FromDate = @FromDate, @ToDate = @ToDate;
END
GO
/****** Object:  StoredProcedure [dbo].[Page_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 4/4/2022
-- Description:	Danh sách bài viết
-- =============================================
CREATE PROCEDURE [dbo].[Page_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)

    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' P.*,
				COUNT(P.Id) OVER() AS TotalItem
				FROM [Page] P ';

	SET @whereCondition = ' WHERE P.Deleted = 0 ';

	IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	BEGIN
		SET @whereCondition += ' AND (P.Title LIKE ''%' + @SearchContent + '%''' 
		+ ' )';
	END

	SET @groupBy = ''

	--Phân trang + Order By
	SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
	+ ' ORDER BY ' + @OrderBy
	+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	EXECUTE sp_executesql @sqlResult
END
GO
/****** Object:  StoredProcedure [dbo].[PayHelp_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 29/10/2021
-- Description:	Danh sách yêu cầu thanh toán hộ
-- =============================================
CREATE PROCEDURE [dbo].[PayHelp_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@UID INT = NULL,
	@Status INT = NULL,
	@SearchContent NVARCHAR(1000) = NULL,
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' PH.*, U.UserName, --UserName
				COUNT(PH.Id) OVER() AS TotalItem
			FROM PayHelp PH
			LEFT JOIN (SELECT Id, UserName FROM Users) U ON PH.[UID] = U.Id ';

	SET @whereCondition = ' WHERE PH.Deleted = 0 ';

	IF (@UID IS NOT NULL AND @UID > 0)
	BEGIN
		SET @whereCondition += ' AND PH.[UID] = @UID ';
	END

	IF (@Status IS NOT NULL AND @Status > 0)
	BEGIN
		SET @whereCondition += ' AND PH.[Status] = @Status ';
	END

	IF (@FromDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, PH.Created) >= CONVERT(DATE, @FromDate) '
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, PH.Created) <= CONVERT(DATE, @ToDate) '
	END

	IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	BEGIN
		SET @whereCondition += ' AND (U.UserName LIKE ''%' + @SearchContent + '%''' 
		+ ' )';
	END

	SET @groupBy = '';

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';	
	END

	EXECUTE sp_executesql @sqlResult
		, N'@UID INT, @Status INT, @FromDate DATETIME, @ToDate DATETIME, @SearchContent NVARCHAR(1000)'
		, @UID = @UID, @Status = @Status, @FromDate = @FromDate, @ToDate = @ToDate, @SearchContent = @SearchContent;
END
GO
/****** Object:  StoredProcedure [dbo].[PriceChange_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 5/11/2021
-- Description:	Cấu hình phí thanh toán hộ
-- =============================================
CREATE PROCEDURE [dbo].[PriceChange_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
DECLARE @offset INT
    DECLARE @newsize INT
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @sqlCount NVARCHAR(MAX)
    DECLARE @sqlGroupBy NVARCHAR(MAX)

    DECLARE @whereCondition NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	IF(@PageIndex=1)
      BEGIN
        SET @offset = @PageIndex
        SET @newsize = @PageSize - 1
       END
    ELSE 
      BEGIN
        SET @offset = (@PageIndex -1) * @PageSize + 1
        SET @newsize = @PageSize-1
    END

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' PC.*, COUNT(PC.Id) OVER() AS TotalItem
			FROM PriceChange PC ';
		
	SET @sqlGroupBy = ''
	SET @whereCondition = ' WHERE PC.Deleted = 0 '

	-- Phân trang + Order By
    SET @sqlResult = 'SELECT * FROM ( SELECT ROW_NUMBER() OVER (ORDER BY PC.' + @OrderBy + ') AS RowNumber, ' + @sql + @whereCondition + @sqlGroupBy + ') AS tbl' + ' WHERE RowNumber BETWEEN ' 
	+ CONVERT(NVARCHAR(12), @offset) + ' AND ' 
	+ CONVERT(NVARCHAR(12), (@offset + @newsize));
	  
	EXECUTE sp_executesql @sqlResult
END
GO
/****** Object:  StoredProcedure [dbo].[Refund_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 29/10/2021
-- Description:	Lịch sử yêu cầu rút tệ
-- =============================================
CREATE PROCEDURE [dbo].[Refund_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@Status INT = NULL,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' R.*, U.UserName, --UserName
				COUNT(R.Id) OVER() AS TotalItem
			FROM Refund R
			LEFT JOIN (SELECT Id, UserName FROM Users) U ON R.[UID] = U.Id ';

	SET @whereCondition = ' WHERE R.Deleted = 0 ';

	IF (@Status IS NOT NULL AND @Status > 0)
	BEGIN
		SET @whereCondition += ' AND R.[Status] = @Status ';
	END

	IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	BEGIN
		SET @whereCondition += ' AND (U.UserName LIKE ''%' + @SearchContent + '%''' 
		+ ' )';
	END

	SET @groupBy = '';

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';	
	END

	EXECUTE sp_executesql @sqlResult
		, N'@Status INT'
		, @Status = @Status;
END
GO
/****** Object:  StoredProcedure [dbo].[Report_AdminSendUserWallet]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 17/3/2022
-- Description:	Thống kê danh sách nạp tiền
-- =============================================
CREATE PROCEDURE [dbo].[Report_AdminSendUserWallet]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC',
	@BankId INT = NULL,
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' ASUW.*, U.UserName, B.BankName,
			SUM(ASUW.Amount) OVER() AS TotalAmount,
			COUNT(ASUW.Id) OVER() AS TotalItem
			FROM AdminSendUserWallet ASUW 
				LEFT JOIN (SELECT ID, UserName FROM Users) U ON ASUW.[UID] = U.Id 
				LEFT JOIN (SELECT ID, BankName FROM Bank) B ON ASUW.BankId = B.Id';

	SET @whereCondition = ' WHERE ASUW.Deleted = 0 AND ASUW.[Status] = 2';

	IF (@BankId IS NOT NULL AND @BankId > 0)
	BEGIN
		SET @whereCondition += ' AND B.Id = @BankId ';
	END

	IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	BEGIN
		SET @whereCondition += ' AND (U.UserName LIKE N''%' + @SearchContent + '%'''
		+ ' )';
	END

	IF (@FromDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, ASUW.Created) >= CONVERT(DATE, @FromDate) '
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, ASUW.Created) <= CONVERT(DATE, @ToDate) '
	END

	SET @groupBy = '';

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	END

	EXECUTE sp_executesql @sqlResult
	, N'@BankId INT, @FromDate DATETIME, @ToDate DATETIME'
	, @BankId = @BankId, @FromDate = @FromDate, @ToDate = @ToDate;
END
GO
/****** Object:  StoredProcedure [dbo].[Report_HistoryPayWallet]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 30/3/2022
-- Description:	Thống kê giao dịch
-- =============================================
CREATE PROCEDURE [dbo].[Report_HistoryPayWallet]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC',
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' HPW.*,
			SUM(HPW.Amount) OVER() AS TotalAmount,
			SUM(CASE WHEN HPW.TradeType = 1 THEN Amount ELSE 0 END) OVER() AS ''TotalDeposit'',
			SUM(CASE WHEN HPW.TradeType = 2 THEN Amount ELSE 0 END) OVER() AS ''TotalReciveDeposit'',
			SUM(CASE WHEN HPW.TradeType = 3 THEN Amount ELSE 0 END) OVER() AS ''TotalPaymentBill'',
			SUM(CASE WHEN HPW.TradeType = 4 THEN Amount ELSE 0 END) OVER() AS ''TotalAdminSend'',
			SUM(CASE WHEN HPW.TradeType = 5 THEN Amount ELSE 0 END) OVER() AS ''TotalWithDraw'',
			SUM(CASE WHEN HPW.TradeType = 6 THEN Amount ELSE 0 END) OVER() AS ''TotalCancelWithDraw'',
			SUM(CASE WHEN HPW.TradeType = 7 THEN Amount ELSE 0 END) OVER() AS ''TotalComplain'',
			SUM(CASE WHEN HPW.TradeType = 8 THEN Amount ELSE 0 END) OVER() AS ''TotalPaymentTransport'',
			SUM(CASE WHEN HPW.TradeType = 9 THEN Amount ELSE 0 END) OVER() AS ''TotalPaymentHo'',
			SUM(CASE WHEN HPW.TradeType = 10 THEN Amount ELSE 0 END) OVER() AS ''TotalPaymentSaveWare'',
			SUM(CASE WHEN HPW.TradeType = 11 THEN Amount ELSE 0 END) OVER() AS ''TotalRecivePaymentTransport'',
			COUNT(HPW.Id) OVER() AS TotalItem
			FROM HistoryPayWallet HPW ';

	SET @whereCondition = ' WHERE HPW.Deleted = 0 ';

	--IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	--BEGIN
	--	SET @whereCondition += ' AND (U.UserName LIKE N''%' + @SearchContent + '%'''
	--	+ ' )';
	--END

	IF (@FromDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, HPW.Created) >= CONVERT(DATE, @FromDate) '
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, HPW.Created) <= CONVERT(DATE, @ToDate) '
	END

	SET @groupBy = '';

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	END

	EXECUTE sp_executesql @sqlResult
	, N'@FromDate DATETIME, @ToDate DATETIME'
	, @FromDate = @FromDate, @ToDate = @ToDate;
END
GO
/****** Object:  StoredProcedure [dbo].[Report_MainOrder]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 31/3/2022
-- Description:	Thống kê đơn hàng
-- =============================================
CREATE PROCEDURE [dbo].[Report_MainOrder]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC',
	@Status INT = NULL,
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' MO.Id,
				U.UserName, SAL.UserName AS SalerUserName,
				MO.ShopName,
				MO.FeeShipCN,
				MO.FeeWeight,
				MO.FeeBuyPro,
				MO.TQVNWeight,
				MO.IsFastDeliveryPrice,
				MO.IsCheckProductPrice,
				MO.IsPackedPrice,
				MO.TotalPriceVND,
				MO.Deposit,
				(MO.TotalPriceVND - MO.Deposit) AS MustPay,
				MO.FeeInWareHouse,
				MO.[Status],
				MO.InsuranceMoney,
				(MO.TotalPriceVND - MO.TotalPriceReal - MO.FeeShipCNReal) AS Profit,
				SUM(MO.TotalPriceVND) AS MaxTotalPriceVND,
				SUM(MO.TotalPriceVND - MO.Deposit) AS MaxMustPay,
				SUM(MO.TotalPriceReal) AS MaxTotalPriceReal,
				SUM(MO.TotalPriceVND - MO.TotalPriceReal - MO.FeeShipCNReal) AS MaxProfit,
				SUM(MO.PriceVND) AS MaxPriceVND,
				SUM(MO.FeeShipCN) AS MaxFeeShipCN,
				SUM(MO.FeeWeight) AS MaxFeeWeight,
				SUM(MO.FeeBuyPro) AS MaxFeeBuyPro,
				SUM(MO.IsCheckProductPrice) AS MaxIsCheckProductPrice,
				SUM(MO.IsPackedPrice) AS MaxIsPackedPrice,
				SUM(MO.InsuranceMoney) AS MaxInsuranceMoney,
				SUM(MO.FeeInWareHouse) AS MaxFeeInWareHouse,
				COUNT(MO.Id) OVER() AS TotalItem
			FROM MainOrder MO 
				LEFT JOIN (SELECT ID, UserName FROM Users) U ON MO.[UID] = U.Id 
				LEFT JOIN (SELECT ID, UserName FROM Users) SAL ON MO.SalerId = SAL.Id ';

	SET @whereCondition = ' WHERE MO.Deleted = 0 ';

	--IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	--BEGIN
	--	SET @whereCondition += ' AND (U.UserName LIKE N''%' + @SearchContent + '%'''
	--	+ ' )';
	--END

	IF (@Status IS NOT NULL AND @Status > 0)
	BEGIN
		SET @whereCondition += ' AND MO.[Status] >= @Status '; -- @Status = 5 - Thống kê lợi nhuận mua hộ
	END

	IF (@FromDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, MO.Created) >= CONVERT(DATE, @FromDate) '
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, MO.Created) <= CONVERT(DATE, @ToDate) '
	END

	SET @groupBy = 'GROUP BY U.UserName, 
					SAL.UserName,
					MO.ShopName,
					MO.FeeWeight,
					MO.FeeShipCN,
					MO.FeeBuyPro,
					MO.TQVNWeight,
					MO.IsFastDeliveryPrice,
					MO.IsCheckProductPrice,
					MO.IsPackedPrice,
					MO.TotalPriceVND,
					MO.TotalPriceReal,
					MO.FeeShipCNReal,
					MO.Deposit,
					MO.[Status],
					MO.FeeInWareHouse,
					MO.InsuranceMoney,
					MO.Id ';

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	END

	EXECUTE sp_executesql @sqlResult
	, N'@Status INT, @FromDate DATETIME, @ToDate DATETIME'
	, @Status = @Status, @FromDate = @FromDate, @ToDate = @ToDate;
END
GO
/****** Object:  StoredProcedure [dbo].[Report_MainOrderReal]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 16/5/2022
-- Description:	Thống kê tiền mua thật
-- =============================================
CREATE PROCEDURE [dbo].[Report_MainOrderReal]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC',
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' SUM(MO.TotalPriceRealCNY) AS MaxTotalPriceRealCNY,
				COUNT(MO.Id) AS TotalItem
			FROM MainOrder MO ';

	SET @whereCondition = ' WHERE MO.Deleted = 0 AND MO.DateBuy IS NOT NULL ';

	--IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	--BEGIN
	--	SET @whereCondition += ' AND (U.UserName LIKE N''%' + @SearchContent + '%'''
	--	+ ' )';
	--END

	IF (@FromDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, MO.Created) >= CONVERT(DATE, @FromDate) '
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, MO.Created) <= CONVERT(DATE, @ToDate) '
	END

	SET @groupBy = ' ';
	
	--Order By
	SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
	--+ ' ORDER BY ' + @OrderBy

	EXECUTE sp_executesql @sqlResult
	, N'@FromDate DATETIME, @ToDate DATETIME'
	, @FromDate = @FromDate, @ToDate = @ToDate;
END
GO
/****** Object:  StoredProcedure [dbo].[Report_MainOrderRevenue]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 30/3/2022
-- Description:	Thống kê doanh thu cho saler, đặt hàng
-- =============================================
CREATE PROCEDURE [dbo].[Report_MainOrderRevenue]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC',
	@Type INT = NULL,
	@Status INT = NULL,
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)
	DECLARE @declareSql NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SET @declareSql = 'DECLARE @table TABLE(
				UserName NVARCHAR(MAX), 
				Id INT, 
				TotalPriceVND DECIMAL(18, 0),
				PriceVND DECIMAL(18, 0),
				FeeBuyPro DECIMAL(18, 0),
				FeeShipCN DECIMAL(18, 0),
				TQVNWeight DECIMAL(18, 0),
				FeeWeight DECIMAL(18, 0),
				OrderFee DECIMAL(18, 0),
				BargainMoney DECIMAL(18, 0),
				TotalOrder INT,
				TotalCus INT)
		INSERT INTO @table 
		SELECT U.UserName, U.Id,
			SUM(MO.TotalPriceVND) AS TotalPriceVND,
			SUM(MO.PriceVND) AS PriceVND,
			SUM(MO.FeeBuyPro) AS FeeBuyPro,
			SUM(MO.FeeShipCN) AS FeeShipCN,
			SUM(MO.TQVNWeight) AS TQVNWeight,
			SUM(MO.FeeWeight) AS FeeWeight,
			SUM(MO.FeeBuyPro + MO.FeeShipCN + MO.FeeWeight) AS OrderFee,
			SUM((MO.PriceVND + MO.FeeShipCN) - (MO.TotalPriceReal - MO.FeeShipCNReal)) AS BargainMoney,
			COUNT(MO.ID) AS TotalOrder,
			COUNT(TC.ID) AS TotalCus
				FROM MainOrder MO '

	SET @whereCondition = ' WHERE MO.Deleted = 0 AND U.UserName IS NOT NULL';

	SET @declareSql += CASE @Type 
		WHEN 1 THEN ' LEFT JOIN (SELECT ID, UserName FROM Users) U ON MO.SalerId = U.Id
			OUTER APPLY(
				SELECT ID FROM Users WHERE SaleId = U.Id
			) TC ' --Saler
		WHEN 2 THEN ' LEFT JOIN (SELECT ID, UserName FROM Users) U ON MO.DatHangId = U.Id
			OUTER APPLY(
				SELECT ID FROM Users WHERE DatHangId = U.Id
			) TC ' --Đặt hàng
		ELSE ' LEFT JOIN (SELECT ID, UserName FROM Users) U ON MO.[UID] = U.Id
			OUTER APPLY(
				SELECT ID FROM Users WHERE Id = U.Id
			) TC '
		END

	IF (@Status IS NOT NULL AND @Status >= 0)
	BEGIN
		SET @whereCondition += ' AND MO.[Status] = @Status ';
		--SET @whereCondition += ' AND MO.[Status] IN (SELECT CAST(VALUE AS INT) FROM STRING_SPLIT(@Status, '',''))';
	END

	IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	BEGIN
		SET @whereCondition += ' AND (U.UserName LIKE N''%' + @SearchContent + '%'''
		+ ' )';
	END

	IF (@FromDate IS NOT NULL)
	BEGIN
	 SET @whereCondition += CASE @Status 
		WHEN 2 THEN ' AND CONVERT(DATE, MO.DepositDate) >= CONVERT(DATE, @FromDate) '
		WHEN 5 THEN ' AND CONVERT(DATE, MO.DateBuy) >= CONVERT(DATE, @FromDate) '
		WHEN 6 THEN ' AND CONVERT(DATE, MO.DateTQ) >= CONVERT(DATE, @FromDate) '
		WHEN 7 THEN ' AND CONVERT(DATE, MO.DateVN) >= CONVERT(DATE, @FromDate) '
		WHEN 9 THEN ' AND CONVERT(DATE, MO.PayDate) >= CONVERT(DATE, @FromDate) '
		WHEN 10 THEN ' AND CONVERT(DATE, MO.CompleteDate) >= CONVERT(DATE, @FromDate) '
		ELSE ' AND CONVERT(DATE, MO.Created) >= CONVERT(DATE, @FromDate) '
		END
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
	 SET @whereCondition += CASE @Status 
		WHEN 2 THEN ' AND CONVERT(DATE, MO.DepositDate) <= CONVERT(DATE, @ToDate) '
		WHEN 5 THEN ' AND CONVERT(DATE, MO.DateBuy) <= CONVERT(DATE, @ToDate) '
		WHEN 6 THEN ' AND CONVERT(DATE, MO.DateTQ) <= CONVERT(DATE, @ToDate) '
		WHEN 7 THEN ' AND CONVERT(DATE, MO.DateVN) <= CONVERT(DATE, @ToDate) '
		WHEN 9 THEN ' AND CONVERT(DATE, MO.PayDate) <= CONVERT(DATE, @ToDate) '
		WHEN 10 THEN ' AND CONVERT(DATE, MO.CompleteDate) <= CONVERT(DATE, @ToDate) '
		ELSE ' AND CONVERT(DATE, MO.Created) <= CONVERT(DATE, @ToDate) '
		END
	END

	SET @groupBy = ' GROUP BY U.UserName, U.Id ';

	SET @sql = ' T.*,
				SUM(T.TotalPriceVND) OVER() AS MaxTotalPriceVND,
				SUM(T.PriceVND) OVER() AS MaxPriceVND,
				SUM(T.FeeBuyPro) OVER() AS MaxFeeBuyPro,
				SUM(T.FeeShipCN) OVER() AS MaxFeeShipCN,
				SUM(T.TQVNWeight) OVER() AS MaxTQVNWeight,
				SUM(T.FeeWeight) OVER() AS MaxFeeWeight,
				SUM(T.OrderFee) OVER() AS MaxOrderFee,
				SUM(T.BargainMoney) OVER() AS MaxBargainMoney,
				SUM(T.TotalOrder) OVER() AS MaxTotalOrder
				FROM @table T ';

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult =  @declareSql +  @whereCondition + @groupBy + ' SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql +
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = @declareSql +  @whereCondition + @groupBy + ' SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql +
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	END

	EXECUTE sp_executesql @sqlResult
	, N'@Status INT, @FromDate DATETIME, @ToDate DATETIME'
	, @Status = @Status, @FromDate = @FromDate, @ToDate = @ToDate;
END
GO
/****** Object:  StoredProcedure [dbo].[Report_OutStockSession]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 15/3/2022
-- Description:	Thống kê đơn mua hộ đã xuất kho
-- =============================================
CREATE PROCEDURE [dbo].[Report_OutStockSession]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC',
	@UID INT = NULL,
	@Status INT = NULL,
	@MainOrderId INT = NULL,
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' OSS.* FROM OutStockSession OSS 
		LEFT JOIN OutStockSessionPackage OSSP ON OSSP.OutStockSessionId = OSS.Id
		LEFT JOIN SmallPackage SP ON SP.Id = OSSP.SmallPackageId
		LEFT JOIN MainOrder MO ON MO.Id = SP.MainOrderId 
		LEFT JOIN Users US ON US.Id = OSS.[UID] ';

	SET @whereCondition = ' WHERE OSS.Deleted = 0 AND MO.[Status] = 10 AND OSS.[Status] = 2 ';

	IF (@UID IS NOT NULL AND @UID > 0)
	BEGIN
		SET @whereCondition += ' AND OSS.[UID] = @UID ';
	END

	IF (@Status IS NOT NULL AND @Status >= 0)
	BEGIN
		SET @whereCondition += ' AND OSS.[Status] = @Status ';
	END

	IF (@MainOrderId IS NOT NULL AND @MainOrderId > 0)
	BEGIN
		SET @whereCondition += ' AND MO.Id = @MainOrderId ';
	END

	IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	BEGIN
		SET @whereCondition += ' AND (US.UserName LIKE N''%' + @SearchContent + '%'''
		+ ' )';
	END

	IF (@FromDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, OSS.Created) >= CONVERT(DATE, @FromDate) '
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, OSS.Created) <= CONVERT(DATE, @ToDate) '
	END

	SET @groupBy = '';

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';	
	END

	EXECUTE sp_executesql @sqlResult
	, N'@UID INT, @Status INT, @FromDate DATETIME, @ToDate DATETIME, @MainOrderId INT'
	, @UID = @UID, @Status = @Status, @FromDate = @FromDate, @ToDate = @ToDate, @MainOrderId = @MainOrderId;
END
GO
/****** Object:  StoredProcedure [dbo].[Report_PayHelp]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 31/3/2022
-- Description:	Thống kê lợi nhuận thanh toán hộ
-- =============================================
CREATE PROCEDURE [dbo].[Report_PayHelp]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC',
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' PH.Id, 
				U.UserName, 
				PH.TotalPrice, 
				PH.TotalPriceVNDGiaGoc, 
				PH.TotalPriceVND, 
				(PH.TotalPriceVND - PH.TotalPriceVNDGiaGoc) AS Profit,
				PH.Created,
				SUM(TotalPrice) AS MaxTotalPrice,
				SUM(PH.TotalPriceVND) AS MaxTotalPriceVND,
				SUM(PH.TotalPriceVNDGiaGoc) AS MaxTotalPriceVNDGiaGoc,
				SUM((PH.TotalPriceVND - PH.TotalPriceVNDGiaGoc)) AS MaxProfit,
				COUNT(PH.Id) OVER() AS TotalItem 
			FROM PayHelp PH 
					LEFT OUTER JOIN Users U ON U.Id = PH.[UID] ';

	SET @whereCondition = ' WHERE PH.Deleted = 0 AND PH.[Status] >= 3';

	--IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	--BEGIN
	--	SET @whereCondition += ' AND (U.UserName LIKE N''%' + @SearchContent + '%'''
	--	+ ' )';
	--END

	IF (@FromDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, PH.Created) >= CONVERT(DATE, @FromDate) '
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, PH.Created) <= CONVERT(DATE, @ToDate) '
	END

	SET @groupBy = ' GROUP BY PH.Id, U.UserName, PH.TotalPrice, PH.TotalPriceVND, PH.TotalPriceVNDGiaGoc, PH.Created ';

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';	
	END

	EXECUTE sp_executesql @sqlResult
	, N'@FromDate DATETIME, @ToDate DATETIME'
	, @FromDate = @FromDate, @ToDate = @ToDate;
END
GO
/****** Object:  StoredProcedure [dbo].[Report_PayOrderHistory]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 31/3/2022
-- Description: Thống kê thanh toán
-- =============================================
CREATE PROCEDURE [dbo].[Report_PayOrderHistory]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC',
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' POH.*, U.UserName,
			COUNT(POH.Id) OVER() AS TotalItem
			FROM PayOrderHistory POH 
				LEFT JOIN (SELECT ID, UserName FROM Users) U ON POH.[UID] = U.Id ';

	SET @whereCondition = ' WHERE POH.Deleted = 0 ';

	--IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	--BEGIN
	--	SET @whereCondition += ' AND (U.UserName LIKE N''%' + @SearchContent + '%'''
	--	+ ' )';
	--END

	IF (@FromDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, POH.Created) >= CONVERT(DATE, @FromDate) '
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, POH.Created) <= CONVERT(DATE, @ToDate) '
	END

	SET @groupBy = '';

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';	
	END

	EXECUTE sp_executesql @sqlResult
	, N'@FromDate DATETIME, @ToDate DATETIME'
	, @FromDate = @FromDate, @ToDate = @ToDate;
END
GO
/****** Object:  StoredProcedure [dbo].[Report_TransportationOrder]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 31/3/2022
-- Description:	Thống kê doanh thu ký gửi
-- =============================================
CREATE PROCEDURE [dbo].[Report_TransportationOrder]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC',
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' TON.*, U.UserName,
				SP.OrderTransactionCode,
				WF.[Name] AS WareHouseFrom,
				 W.[Name] AS WareHouseTo,
				 STTW.[Name] AS ShippingTypeName,
				 SP.DateInTQWarehouse,
				 SP.DateInLasteWareHouse,
				 SUM(SP.[Weight]) OVER() AS MaxWeight,
				SUM(TON.TotalPriceVND) OVER() AS MaxTotalPriceVND,
				COUNT(TON.Id) OVER() AS TotalItem
			FROM TransportationOrder TON 
				LEFT JOIN (SELECT ID, UserName FROM Users) U ON TON.[UID] = U.Id
				LEFT JOIN (SELECT ID, OrderTransactionCode, DateInTQWarehouse, DateInLasteWareHouse, [Weight] FROM SmallPackage) SP ON TON.SmallPackageId = SP.Id
				LEFT JOIN (SELECT ID, [Name] FROM WarehouseFrom) WF ON TON.WareHouseFromID = WF.ID
				LEFT JOIN (SELECT ID, [Name] FROM Warehouse) W ON TON.WareHouseID = W.ID
				LEFT JOIN (SELECT ID, [Name] FROM ShippingTypeToWareHouse) STTW ON TON.ShippingTypeID = STTW.ID ';

	SET @whereCondition = ' WHERE TON.Deleted = 0 ';

	--IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	--BEGIN
	--	SET @whereCondition += ' AND (U.UserName LIKE N''%' + @SearchContent + '%'''
	--	+ ' )';
	--END

	IF (@FromDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, TON.Created) >= CONVERT(DATE, @FromDate) '
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, TON.Created) <= CONVERT(DATE, @ToDate) '
	END

	SET @groupBy = ' ';

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';	
	END

	EXECUTE sp_executesql @sqlResult
	, N'@FromDate DATETIME, @ToDate DATETIME'
	, @FromDate = @FromDate, @ToDate = @ToDate;
END
GO
/****** Object:  StoredProcedure [dbo].[Report_User]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 30/3/2022
-- Description:	Thống kê số dư
-- =============================================
CREATE PROCEDURE [dbo].[Report_User] 
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC',
	@type INT = NULL
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' U.*, 
			   UG.[Description] AS UserGroupName,
			   S.UserName AS SaleUserName,
			   O.UserName AS OrdererUserName,
			   SUM(U.Wallet) OVER() AS TotalWallet,
			   SUM(C1.GreaterThan0) OVER() AS GreaterThan0,
			   SUM(C2.Equals0) OVER() AS Equals0,
			   SUM(C3.From1MTo5M) OVER() AS From1MTo5M,
			   SUM(C4.From5MTo10M) OVER() AS From5MTo10M,
			   SUM(C5.GreaterThan10M) OVER() AS GreaterThan10M,
			   COUNT(U.Id) OVER() AS TotalItem 
		FROM Users AS U
				OUTER APPLY(
					SELECT COUNT(Id) AS GreaterThan0 FROM Users WHERE Id = U.Id AND Wallet > 0
				) AS C1
				OUTER APPLY(
					SELECT COUNT(Id) AS Equals0 FROM Users WHERE Id = U.Id AND Wallet = 0
				) AS C2
				OUTER APPLY(
					SELECT COUNT(Id) AS From1MTo5M FROM Users WHERE Id = U.Id AND Wallet >= 1000000 AND Wallet <= 5000000
				) AS C3
				OUTER APPLY(
					SELECT COUNT(Id) AS From5MTo10M FROM Users WHERE Id = U.Id AND Wallet >= 5000000 AND Wallet <= 10000000
				) AS C4
				OUTER APPLY(
					SELECT COUNT(Id) AS GreaterThan10M FROM Users WHERE Id = U.Id AND Wallet > 10000000
				) AS C5
				LEFT OUTER JOIN UserInGroups AS UIG ON UIG.UserId = U.Id
				LEFT OUTER JOIN UserGroups AS UG ON UG.Id = UIG.UserGroupId
				LEFT OUTER JOIN Users AS S ON S.Id = U.SaleId
				LEFT OUTER JOIN Users AS O ON O.Id = U.DatHangId ';

	SET @whereCondition = ' WHERE U.Deleted = 0 ';

	IF (@type IS NOT NULL AND @type > 0)
	BEGIN
	 SET @whereCondition += CASE @type 
		WHEN 1 THEN ' AND U.Wallet > 0 ' --User có số dư tài khoản
		WHEN 2 THEN ' AND U.Wallet = 0 ' --User không có số dư tài khoản
		ELSE ' '
		END
	END

	--IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	--BEGIN
	--	SET @whereCondition += ' AND (U.UserName LIKE N''%' + @SearchContent + '%'''
	--	+ ' )';
	--END

	SET @groupBy = '';

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';	
	END

	EXECUTE sp_executesql @sqlResult
	, N'@type INT'
	, @type = @type;
END
GO
/****** Object:  StoredProcedure [dbo].[Report_Withdraw]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 17/3/2022
-- Description:	Thống kê danh sách rút tiền
-- =============================================
CREATE PROCEDURE [dbo].[Report_Withdraw]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC',
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' WD.*, U.UserName,
				SUM(WD.Amount) OVER() AS TotalAmount,
				COUNT(WD.Id) OVER() AS TotalItem
				FROM Withdraw WD
				LEFT JOIN (SELECT Id, UserName FROM Users) U ON WD.[UID] = U.Id';

	SET @whereCondition = ' WHERE WD.Deleted = 0 AND WD.[Type] = 2 AND WD.[Status] = 2 ';

	IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	BEGIN
		SET @whereCondition += ' AND (U.UserName LIKE N''%' + @SearchContent + '%'''
		+ ' )';
	END

	IF (@FromDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, WD.Created) >= CONVERT(DATE, @FromDate) '
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, WD.Created) <= CONVERT(DATE, @ToDate) '
	END

	SET @groupBy = '';

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';	
	END

	EXECUTE sp_executesql @sqlResult
	, N'@FromDate DATETIME, @ToDate DATETIME'
	, @FromDate = @FromDate, @ToDate = @ToDate;
END
GO
/****** Object:  StoredProcedure [dbo].[SmallPackage_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 3/11/2021
-- Description:	Danh sách kiện trôi nổi
-- =============================================
CREATE PROCEDURE [dbo].[SmallPackage_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@UID INT = NULL,
	@MainOrderId INT = NULL,
	@SearchContent NVARCHAR(1000) = NULL,
	@Status INT = NULL,
	@BigPackageId INT = NULL,
	@SearchType INT = NULL,
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL,
	@Menu INT = 0,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' SP.*, COUNT(SP.Id) OVER() AS TotalItem,
				A.UserName,
				BP.Code,
				SP.[Weight],
				COUNT(SP.Id) OVER() AS TotalItem,
				COUNT(CASE WHEN SP.[Status] = 1 THEN 1 ELSE NULL END) OVER() AS ''TotalStatus1'',
				COUNT(CASE WHEN SP.[Status] = 2 THEN 1 ELSE NULL END) OVER() AS ''TotalStatus2'',
				COUNT(CASE WHEN SP.[Status] = 3 THEN 1 ELSE NULL END) OVER() AS ''TotalStatus3'',
				COUNT(CASE WHEN SP.[Status] = 4 THEN 1 ELSE NULL END) OVER() AS ''TotalStatus4'',
				COUNT(CASE WHEN SP.[Status] = 0 THEN 1 ELSE NULL END) OVER() AS ''TotalStatus0''
			FROM SmallPackage SP 
				LEFT JOIN (SELECT ID, UserName FROM Users) A ON SP.[UID] = A.ID
				LEFT JOIN (SELECT ID, Code FROM BigPackage) BP ON SP.BigPackageID = BP.ID ';

	SET @whereCondition = ' WHERE SP.Deleted = 0 ';

	IF (@Menu IS NOT NULL AND @Menu >= 0)
	BEGIN
	 SET @whereCondition += CASE @menu 
		WHEN 0 THEN ' AND SP.MainOrderId = 0 AND SP.TransportationOrderId = 0 AND SP.[Status] != 0 ' --Danh sách kiện trôi nổi
		WHEN 1 THEN ' ' --Các kiện dựa vào kiện lớn
		WHEN 2 THEN ' ' --Quản lý mã vận đơn
		WHEN 3 THEN ' AND SP.IsLost = 1 ' --Danh sách kiện thất lạc
		ELSE ' '
		END
	END

	IF (@Status IS NOT NULL AND @Status > 1)
	BEGIN
		SET @whereCondition += ' AND SP.StatusConfirm = @Status';
	END

	IF (@BigPackageId IS NOT NULL AND @BigPackageId > 0)
	BEGIN
		SET @whereCondition += ' AND SP.BigPackageId = @BigPackageId';
	END

	IF (@BigPackageId IS NOT NULL AND @BigPackageId > 0)
	BEGIN
		SET @whereCondition += ' AND SP.BigPackageId = @BigPackageId';
	END

	IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	BEGIN
		IF (@SearchType = 1)
		BEGIN
			SET @whereCondition += ' AND (SP.MainOrderId LIKE ''%' + @SearchContent + '%''' 
				+ ' )';
		END
		ELSE IF (@SearchType = 2)
		BEGIN
			SET @whereCondition += ' AND (SP.Id LIKE ''%' + @SearchContent + '%''' 
				+ ' )';
		END
		ELSE IF (@SearchType = 3)
		BEGIN
			SET @whereCondition += ' AND (A.UserName LIKE ''%' + @SearchContent + '%''' 
				+ ' )';
		END
		ELSE
		BEGIN
			SET @whereCondition += ' AND (SP.OrderTransactionCode LIKE ''%' + @SearchContent + '%''' 
				+ ' )';
		END
	END

	IF (@FromDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, SP.Created) >= CONVERT(DATE, @FromDate) '
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, SP.Created) <= CONVERT(DATE, @ToDate) '
	END

	SET @groupBy = '';

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';	
	END

	EXECUTE sp_executesql @sqlResult
		, N'@UID INT, @Status INT, @SearchContent NVARCHAR(1000), @BigPackageId INT, @SearchType INT, @FromDate DATETIME, @ToDate DATETIME, @Menu INT'
		, @UID = @UID, @Status = @Status, @SearchContent = @SearchContent, @BigPackageId = @BigPackageId, @SearchType = @SearchType, @FromDate = @FromDate, @ToDate = @ToDate, @Menu = @Menu;
END
GO
/****** Object:  StoredProcedure [dbo].[StaffInCome_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 29/3/2022
-- Description:	Quản lý hoa hồng
-- =============================================
CREATE PROCEDURE [dbo].[StaffInCome_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@Status INT = NULL,
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)

    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' SI.*,
			UG.Description AS RoleName,
			U.UserName,

			SUM(CASE WHEN SI.[Status] = 1 THEN SI.TotalPriceReceive ELSE 0 END) OVER() AS ''MaxTotalPriceReceiveNotPayment'',
			SUM(CASE WHEN SI.[Status] = 2 THEN SI.TotalPriceReceive ELSE 0 END) OVER() AS ''MaxTotalPriceReceivePayment'',

			COUNT(SI.Id) OVER() AS TotalItem
			FROM StaffIncome SI 
				LEFT JOIN (SELECT ID, UserName FROM Users) U ON SI.[UID] = U.ID 
				LEFT OUTER JOIN UserInGroups AS UIG ON UIG.UserId = U.Id
				LEFT OUTER JOIN UserGroups AS UG ON UG.Id = UIG.UserGroupId ';

	SET @whereCondition = ' WHERE SI.Deleted = 0 ';

	IF (@Status IS NOT NULL AND @Status > 0)
	BEGIN
		SET @whereCondition += ' AND SI.[Status] = @Status ';
	END

	IF (@FromDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, SI.Created) >= CONVERT(DATE, @FromDate) '
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, SI.Created) <= CONVERT(DATE, @ToDate) '
	END

	IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	BEGIN
		SET @whereCondition += ' AND (U.UserName LIKE ''%' + @SearchContent + '%''' 
		+ ' )';
	END

	SET @groupBy = ''

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	END

	EXECUTE sp_executesql @sqlResult
		, N'@Status INT, @FromDate DATETIME, @ToDate DATETIME'
		, @Status = @Status, @FromDate = @FromDate, @ToDate = @ToDate;
END
GO
/****** Object:  StoredProcedure [dbo].[TransportationOrder_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 28/10/2021
-- Description:	Danh sách kiện yêu cầu ký gửi
-- =============================================
CREATE PROCEDURE [dbo].[TransportationOrder_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@UID INT = NULL,
	@Status INT = NULL,
	@TypeSearch INT = NULL,
	@SearchContent NVARCHAR(1000) = NULL,
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' TON.*,
				 U.UserName, --UserName từ UID (SmallPackage = MainOrder = TransportationOrder)
				 SP.OrderTransactionCode, --Mã vận đơn
				 --Cân nặng làm trong code á
				 SP.SensorFeeVND, --Cước vật tư (VNĐ)
				 SP.AdditionFeeVND, --PP hàng đặt biệt (VNĐ)
				 WF.[Name] AS WareHouseFrom, --Kho TQ
				 W.[Name] AS WareHouseTo, --Kho VN
				 STTW.[Name] AS ShippingTypeName, --PTVC
				 SP.DateInTQWarehouse, --Ngày về kho TQ
				 SP.DateInLasteWareHouse, --Ngày về kho VN
				 STVN.[Name] AS ShippingTypeVNName, --HTVC
				 COUNT(TON.Id) OVER() AS TotalItem
		FROM TransportationOrder TON
		LEFT JOIN (SELECT ID, [UID], OrderTransactionCode, DateInTQWarehouse, DateInLasteWareHouse, SensorFeeVND, AdditionFeeVND FROM SmallPackage) SP ON TON.SmallPackageID = SP.ID
		LEFT JOIN (SELECT ID, UserName FROM Users) U ON SP.[UID] = U.Id
		LEFT JOIN (SELECT ID, [Name] FROM WarehouseFrom) WF ON TON.WareHouseFromID = WF.ID
		LEFT JOIN (SELECT ID, [Name] FROM Warehouse) W ON TON.WareHouseID = W.ID
		LEFT JOIN (SELECT ID, [Name] FROM ShippingTypeToWareHouse) STTW ON TON.ShippingTypeID = STTW.ID
		LEFT JOIN (SELECT ID, [Name] FROM ShippingTypeVN) STVN ON TON.ShippingTypeVN = STVN.ID ';

	SET @whereCondition = ' WHERE TON.Deleted = 0 ';

	IF (@UID IS NOT NULL AND @UID > 0)
	BEGIN
		SET @whereCondition += ' AND TON.[UID] = @UID ';
	END

	IF (@TypeSearch IS NOT NULL AND @TypeSearch > 0)
	BEGIN
		IF (@TypeSearch = 1)
		BEGIN
			SET @whereCondition += ' AND TON.ID = ' + @SearchContent + '';
		END
		ELSE IF (@TypeSearch = 2)
		BEGIN
			SET @whereCondition += ' AND SP.OrderTransactionCode LIKE ''%' + @SearchContent + '%''' 
		END
	END

	IF (@FromDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, TON.Created) >= CONVERT(DATE, @FromDate)'
	END

	IF (@ToDate IS NOT NULL)
	BEGIN
		SET @whereCondition += ' AND CONVERT(DATE, TON.Created) <= CONVERT(DATE, @ToDate) '
	END

	IF (@Status IS NOT NULL AND @Status > 0)
	BEGIN
		SET @whereCondition += ' AND TON.[Status] = @Status ';
	END

	SET @groupBy = '';

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';	
	END

	EXECUTE sp_executesql @sqlResult
		, N'@UID INT, @Status INT, @TypeSearch INT, @FromDate DATETIME, @ToDate DATETIME'
		, @UID = @UID, @Status = @Status, @TypeSearch = @TypeSearch, @FromDate = @FromDate, @ToDate = @ToDate;
END
GO
/****** Object:  StoredProcedure [dbo].[User_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 13/10/2021
-- Description:	Lấy danh sách User
-- =============================================
CREATE PROCEDURE [dbo].[User_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@Id INT = NULL,
	@UserName NVARCHAR(20)= NULL,
	@SalerID INT = NULL,
	@OrdererID INT = NULL,
	@Phone NVARCHAR(20)= NULL,
	@UserGroupId INT = NULL,
	@Status INT = NULL,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
    DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = 'US.*, 
	UG.Id AS UserGroupId,
	UG.Description AS UserGroupName,
	ASUW.SumAmount,
	MO.TotalMainOrder, 
	[TO].TotalTransportationOrder, 
	[PH].TotalPayHelp,
	COUNT(US.Id) OVER() AS TotalItem 
	  FROM Users AS US
	  LEFT OUTER JOIN UserInGroups AS UIG ON UIG.UserId = US.Id
	  LEFT OUTER JOIN UserGroups AS UG ON UG.Id = UIG.UserGroupId 
	  OUTER APPLY(
			SELECT ISNULL(SUM(ASUW.Amount), 0) AS SumAmount FROM AdminSendUserWallet ASUW WHERE ASUW.UID = US.ID AND ASUW.Status = 2
		) AS ASUW
		OUTER APPLY(
			SELECT COUNT(MO.ID) AS TotalMainOrder FROM MainOrder MO WHERE MO.UID = US.ID AND MO.Status >= 2
		) AS MO
		OUTER APPLY(
			SELECT COUNT([TO].ID) AS TotalTransportationOrder FROM TransportationOrder [TO] WHERE [TO].UID = US.ID AND [TO].Status >= 2
		) AS [TO]
		OUTER APPLY(
			SELECT COUNT(PH.ID) AS TotalPayHelp FROM PayHelp PH WHERE PH.UID = US.ID AND PH.Status != 2 AND PH.Status >= 1
		) AS PH';

	  SET @whereCondition = ' WHERE US.Deleted = 0 ';
	  IF (@Phone IS NOT NULL AND LEN(@Phone) > 0)
		BEGIN
			SET @whereCondition += ' AND US.Phone LIKE ''%' + @Phone + '%''';
		END

	IF (@UserName IS NOT NULL AND LEN(@UserName) > 0)
		BEGIN
			SET @whereCondition += ' AND US.UserName LIKE ''%' + @UserName + '%''';
		END

	  IF (@UserGroupId IS NOT NULL AND @UserGroupId > 0)
		BEGIN
			SET @whereCondition += ' AND UIG.UserGroupId = @UserGroupId';
		END
	  ELSE
		BEGIN
			SET @whereCondition += ' AND UIG.UserGroupId != 2';
		END

	
	IF (@SalerID IS NOT NULL AND @SalerID > 0)
		BEGIN
			SET @whereCondition += ' AND US.SaleID = @SalerID';
		END

	IF (@OrdererID IS NOT NULL AND @OrdererID > 0)
		BEGIN
			SET @whereCondition += ' AND US.DatHangId = @OrdererID';
		END

	IF (@Status IS NOT NULL AND @Status > 0)
		BEGIN
			SET @whereCondition += ' AND US.Status = @Status';
		END

	IF (@Id IS NOT NULL AND @Id > 0)
		BEGIN
			SET @whereCondition += ' AND US.Id = @Id';
		END

	  IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
		BEGIN
			SET @whereCondition += ' AND (US.FirstName LIKE ''%' + @SearchContent + '%''' 
			+ ' OR US.LastName LIKE ''%' + @SearchContent + '%''' 
			+ ' OR US.UserName LIKE ''%' + @SearchContent + '%'''
			+ ' OR US.Address LIKE ''%' + @SearchContent + '%''' 
			+ ' OR US.CreatedBy LIKE ''%' + @SearchContent + '%''' 
			+ ' )';
		END

	SET @groupBy = '';

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	END

	EXECUTE sp_executesql @sqlResult
	  , N'@Id INT, @UserName NVARCHAR(MAX), @Phone NVARCHAR(20), @UserGroupId INT, @SearchContent NVARCHAR(1000), @Status INT, @SalerID INT, @OrdererID INT'
	  , @Id = @Id, @UserName = @UserName, @Phone = @Phone, @UserGroupId = @UserGroupId, @SearchContent = @SearchContent, @Status = @Status, @SalerID = @SalerID, @OrdererID = @OrdererID;
END
GO
/****** Object:  StoredProcedure [dbo].[UserInGroup_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 10/11/2021
-- Description:	Nhóm người dùng
-- =============================================
CREATE PROCEDURE [dbo].[UserInGroup_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@UserId INT = NULL,
	@UserGroupId INT = NULL,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' UIG.*, COUNT(UIG.Id) OVER() AS TotalItem
		  FROM UserInGroups UIG 
		  LEFT JOIN (SELECT Id, Deleted FROM Users) US ON US.Id = UIG.UserId
		  LEFT JOIN (SELECT Id, Deleted FROM UserGroups) UG ON UG.Id = UIG.UserGroupId ';

	  SET @whereCondition = ' WHERE UIG.Deleted = 0 AND US.Deleted = 0 AND UG.Deleted = 0 ';
	  IF (@UserId IS NOT NULL AND @UserId > 0)
		BEGIN
			SET @whereCondition += ' AND UIG.UserId = @UserId';
		END
	  IF (@UserGroupId IS NOT NULL AND @UserGroupId > 0)
		BEGIN
			SET @whereCondition += ' AND UIG.UserGroupId = @UserGroupId';
		END

	SET @groupBy = '';

	--Phân trang + Order By
	SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
	+ ' ORDER BY ' + @OrderBy
	+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	EXECUTE sp_executesql @sqlResult
	  , N'@UserId int, @UserGroupId int'
	  , @UserId = @UserId, @UserGroupId = @UserGroupId;

END
GO
/****** Object:  StoredProcedure [dbo].[UserLevel_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 5/11/2021
-- Description:	Cấu hình phí người dùng
-- =============================================
CREATE PROCEDURE [dbo].[UserLevel_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' UL.*, COUNT(UL.Id) OVER() AS TotalItem
				FROM UserLevel UL ';

	SET @whereCondition = ' WHERE UL.Deleted = 0 '
	SET @groupBy = '';

	--Phân trang + Order By
	SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
	+ ' ORDER BY ' + @OrderBy
	+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	EXECUTE sp_executesql @sqlResult
END
GO
/****** Object:  StoredProcedure [dbo].[WarehouseFee_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee	
-- Create date: 5/11/2021
-- Description:	Cấu hình phí vận chuyển TQ - VN
-- =============================================
CREATE PROCEDURE [dbo].[WarehouseFee_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' WF.*,
				WFr.[Name] AS WareHouseFromName,--Từ kho
				W.[Name] AS WareHouseToName,--Đến kho
				STTH.[Name] AS ShippingTypeToWareHouseName, --Hình thức VC
				COUNT(WF.Id) OVER() AS TotalItem
			FROM WarehouseFee WF
				LEFT JOIN (SELECT ID, [Name] FROM WarehouseFrom) WFr ON WF.WarehouseFromID = WFr.ID
				LEFT JOIN (SELECT ID, [Name] FROM Warehouse) W ON WF.WarehouseID = W.ID
				LEFT JOIN (SELECT ID, [Name] FROM ShippingTypeToWareHouse) STTH ON WF.ShippingTypeToWareHouseID = STTH.ID ';
		
	SET @whereCondition = ' WHERE WF.Deleted = 0 '

	IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	BEGIN
		SET @whereCondition += ' AND (WFr.[Name] LIKE ''%' + @SearchContent + '%''' 
								+ ' OR W.[Name] LIKE ''%' + @SearchContent + '%''' 
								+ ' )';
	END

	SET @groupBy = '';

	--Phân trang + Order By
	SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
	+ ' ORDER BY ' + @OrderBy
	+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';
	EXECUTE sp_executesql @sqlResult
	, N'@SearchContent NVARCHAR(1000)'
	, @SearchContent = @SearchContent ;
END
GO
/****** Object:  StoredProcedure [dbo].[Withdraw_GetPagingData]    Script Date: 6/27/2022 10:08:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		hoangflee
-- Create date: 3/11/2021
-- Description:	Lịch sử nạp tệ (Lịch sử thì Type = 3)
-- =============================================
CREATE PROCEDURE [dbo].[Withdraw_GetPagingData]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@Type INT = NULL,
	@Status INT = NULL,
	@UID INT = NULL,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC'
AS
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    DECLARE @whereCondition NVARCHAR(MAX)
	DECLARE @groupBy NVARCHAR(MAX)
    DECLARE @sqlResult NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @sql = ' WD.*, U.UserName, U.FullName,
				COUNT(WD.Id) OVER() AS TotalItem
				FROM Withdraw WD
				LEFT JOIN (SELECT Id, UserName, FullName FROM Users) U ON WD.[UID] = U.Id';

	SET @whereCondition = ' WHERE WD.Deleted = 0';

	IF (@UID IS NOT NULL AND @UID > 0)
	BEGIN
		SET @whereCondition += ' AND WD.[UID] = @UID ';
	END

	IF (@Type IS NOT NULL AND @Type > 0)
	BEGIN
		SET @whereCondition += ' AND WD.[Type] = @Type ';
	END

	IF (@Status IS NOT NULL AND @Status > 0)
	BEGIN
		SET @whereCondition += ' AND WD.[Status] = @Status ';
	END

	IF (@SearchContent IS NOT NULL AND LEN(@SearchContent) > 0)
	BEGIN
		SET @whereCondition += ' AND (U.UserName LIKE ''%' + @SearchContent + '%''' 
		+ ' )';
	END

	SET @groupBy = '';

	IF (@PageIndex = 0 AND @PageSize = 0)
	BEGIN
		--Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
	END
	ELSE
	BEGIN
		--Phân trang + Order By
		SET @sqlResult = 'SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS RowNumber, ' + @sql + @whereCondition + @groupBy
		+ ' ORDER BY ' + @OrderBy
		+ ' OFFSET ' + CAST(@PageSize * (@PageIndex - 1) AS NVARCHAR(MAX)) + ' ROWS FETCH NEXT ' + CAST(@PageSize AS NVARCHAR(MAX)) + ' ROWS ONLY ';	
	END

	EXECUTE sp_executesql @sqlResult
		, N'@UID INT, @Type INT, @Status INT'
		, @UID = @UID, @Type = @Type, @Status = @Status;
END
GO



-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE Dashboard_GetPerCentOrder
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	DECLARE @Monday DATE = (SELECT DATEADD(wk, DATEDIFF(wk,0,GETDATE()),0))
	DECLARE @Sunday DATE = (SELECT DATEADD(wk, DATEDIFF(wk,0,GETDATE()),6))

	DECLARE @Stt int = 0

	DECLARE @table TABLE(Status int,Name nvarchar(100) )

	DECLARE @Name nvarchar(100) = N'Chưa đặt cọc'

	WHILE @Stt <= 10
	BEGIN
	
		INSERT INTO @table VALUES (@Stt,@Name);
		SET @Stt = @Stt +1;

		if(@Stt = 4 or @Stt = 3 or @Stt = 8) begin
		SET @Stt = @Stt +1;
		end
		
		if(@Stt = 1) begin
		SET @Name = N'Huỷ đơn hàng';
		end
		if(@Stt = 2) begin
		SET @Name = N'Đã đặt cọc';
		end
		if(@Stt = 5) begin
		SET @Name = N'Đã mua hàng';
		end
		
		if(@Stt = 6) begin
		SET @Name = N'Đã về kho TQ';
		end
		if(@Stt = 7) begin
		SET @Name = N'Đã về kho VN';
		end		
		if(@Stt = 9) begin
		SET @Name = N'Khách đã thanh toán';
		end
		if(@Stt = 10) begin
		SET @Name = N'Đã hoàn thành';
		end
		
	END

	--select * from @table
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT T.*, 
		MO.Amount
		
	FROM @table T
		-- Mua hàng hộ
		OUTER APPLY(
		SELECT COUNT(*) Amount FROM MainOrder WHERE CONVERT(DATE, Created) >= CONVERT(DATE, @Monday) AND CONVERT(DATE, Created) <= CONVERT(DATE, @Sunday) and Status= T.Status

		)MO 

	group by Mo.Amount, T.Status, t.Name
END
GO


USE [NhapHangV2]
GO

/****** Object:  StoredProcedure [dbo].[Report_MainOrder]    Script Date: 7/14/2022 4:59:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		connguyen
-- Create date: 14/7/2022
-- Description:	thong ke tong quat 
-- =============================================
Create PROCEDURE [dbo].[Report_MainOrderOverView]
	-- Add the parameters for the stored procedure here
	@PageIndex INT,
	@PageSize INT,
	@SearchContent NVARCHAR(1000) = NULL,
	@OrderBy NVARCHAR(20) = 'ID DESC',
	@Status INT = NULL,
	@FromDate DATETIME = NULL,
	@ToDate DATETIME = NULL
AS
BEGIN

select N'Phí ship TQ'as Name, sum(main.FeeShipCN)Total,feeShipTQNotPay.NotPay,feeShipTQPay.Pay from MainOrder as main

outer apply ( select sum(FeeShipCN)NotPay from MainOrder where Status >=2 and Status < 9  AND ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate))) feeShipTQNotPay

outer apply ( select sum(FeeShipCN)Pay from MainOrder where Status >=9  AND ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate)))feeShipTQPay

where 1 = 1  AND ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate))

group by feeShipTQNotPay.NotPay, feeShipTQPay.Pay

union all

select N'Phí mua hàng'as Name, sum(main.FeeBuyPro)Total,feeShipTQNotPay.NotPay,feeShipTQPay.Pay from MainOrder as main

outer apply ( select sum(FeeBuyPro)NotPay from MainOrder where Status >=2 and Status < 9 AND ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate)))feeShipTQNotPay

outer apply ( select sum(FeeBuyPro)Pay from MainOrder where Status >=9 AND ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate)))feeShipTQPay

where 1 = 1 AND ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate))

group by feeShipTQNotPay.NotPay, feeShipTQPay.Pay

union all

select N'Phí cân nặng'as Name, sum(main.FeeWeight)Total,feeShipTQNotPay.NotPay,feeShipTQPay.Pay from MainOrder as main

outer apply ( select sum(FeeWeight)NotPay from MainOrder where Status >=2 and Status < 9 AND ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate)))feeShipTQNotPay

outer apply ( select sum(FeeWeight)Pay from MainOrder where Status >=9 AND ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate)))feeShipTQPay

where ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate))

group by feeShipTQNotPay.NotPay, feeShipTQPay.Pay


union all 

select N'Phí kiểm đếm'as Name, sum(main.IsCheckProductPrice)Total,feeShipTQNotPay.NotPay,feeShipTQPay.Pay from MainOrder as main

outer apply ( select sum(IsCheckProductPrice)NotPay from MainOrder where Status >=2 and Status < 9 and ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate)))feeShipTQNotPay

outer apply ( select sum(IsCheckProductPrice)Pay from MainOrder where Status >=9 and ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate)))feeShipTQPay

where ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate))

group by feeShipTQNotPay.NotPay, feeShipTQPay.Pay

union all 

select N'Phí đóng gỗ'as Name, sum(main.IsPackedPrice)Total,feeShipTQNotPay.NotPay,feeShipTQPay.Pay from MainOrder as main

outer apply ( select sum(IsPackedPrice)NotPay from MainOrder where Status >=2 and Status < 9 and ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate)))feeShipTQNotPay

outer apply ( select sum(IsPackedPrice)Pay from MainOrder where Status >=9 and ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate)))feeShipTQPay

where ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate))

group by feeShipTQNotPay.NotPay, feeShipTQPay.Pay

union all 

select N'Phí bảo hiểm'as Name, sum(main.InsuranceMoney)Total,feeShipTQNotPay.NotPay,feeShipTQPay.Pay from MainOrder as main

outer apply ( select sum(InsuranceMoney)NotPay from MainOrder where Status >=2 and Status < 9 and ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate)))feeShipTQNotPay

outer apply ( select sum(InsuranceMoney)Pay from MainOrder where Status >=9 and ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate)))feeShipTQPay

where ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate))

group by feeShipTQNotPay.NotPay, feeShipTQPay.Pay


union all 

select N'Những đơn đã mua hàng'as Name, isnull(sum(main.TotalPriceVND),0)Total,null as NotPay,null as Pay from MainOrder as main where Status = 3 

and ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate))

union all 

select N'Những đơn hoàn thành'as Name, isnull(sum(main.TotalPriceVND),0)Total,null as NotPay,null as Pay from MainOrder as main where Status = 10

and ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate))

--union all 

--select 'Nhung don hoan thanh'as Name, isnull(sum(main.TotalPriceVND),0)Total,null as NotPay,null as Pay from MainOrder as main where Status <= 10 and Status >= 2

--and ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate))

union all 

select N'Những đơn đã cọc đến hoàn thành'as Name, isnull(sum(main.TotalPriceVND),0)Total,null as NotPay,null as Pay from MainOrder as main where Status <= 10 and Status >= 2

and ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate))

union all 

select N'Tổng tiền đã cọc'as Name, isnull(sum(main.Deposit),0)Total,null as NotPay,null as Pay from MainOrder as main where Status <= 10 and Status >= 2

and ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate))

union all 

select N'Tổng tiền chưa thanh toán'as Name, (sum(main.TotalPriceVND) - sum(main.Deposit))Total,null as NotPay,null as Pay from MainOrder as main 

where ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate))

union all 

select N'Tổng phí ship tận nhà'as Name, sum(main.IsFastDeliveryPrice)Total,null as NotPay,null as Pay from MainOrder as main 

where ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate))

union all 

select N'Tổng tiền tất cả'as Name, sum(main.TotalPriceVND)Total,null as NotPay,null as Pay from MainOrder as main 

where ((@FromDate IS NULL And  @ToDate IS NULL)  OR CONVERT(DATE, Created) >= CONVERT(DATE, @FromDate)  AND CONVERT(DATE, Created) <= CONVERT(DATE, @ToDate))

END



