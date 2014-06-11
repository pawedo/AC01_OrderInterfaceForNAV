USE [AC01]
GO

--Misc Adjustment, header

SELECT DEA.DataExportOrderAdjustmentId AS salesOrderId
	 , 'Adjustment' AS salesOrderType
	 , rr.OrderNumber+'/A'+convert(VARCHAR(2),rr.Rank) AS adjustmentOrderNo
	 , 'Quantiv' AS salesOrderSource
	 , DEA.OrderNumber AS originalSalesOrderNo
	 , DEA.CustomerId AS billToNetCustomerUrn
	 , DE.DataExportCreatedDateTime AS adjustementCreatedDate
	 , case when DEA.Channel='CallCentre' then 'Call Centre' 
			when DEA.Channel ='Mobile' then 'Web' else DEA.Channel end  AS channelType
	 , DEO.TransactionCurrencyISO AS CurrencyCode
	 , isnull(convert(money,a.salesOrderAmount), 0) AS SalesOrderAmount	 
	 , isnull(convert(money,a.salesOrderAmountMaster), 0) AS SalesOrderAmountMaster
	 , convert(MONEY, isnull(DEO.TaxRate,0)) AS PostageVATBusPostingGroup
	 , isnull(convert(money,a.salesOrderAmount*DEO.TaxRate/100), 0) AS VATAmount 
	 , convert(money,0) as GrossTax --to be added by quantiv
	 , convert(money,0) as GrossTaxMaster --to be added by quantiv	 
FROM
	AC01.dbo.AC01_DataExportAdjustment AS DEA
	INNER JOIN AC01.dbo.AC01_DataExportOrder AS DEO
		ON DEO.CustomerOrderId = DEA.CustomerOrderId
	INNER JOIN AC01.dbo.AC01_DataExport AS DE
		ON DE.DataExportId = DEA.DataExportOrderAdjustmentId
	LEFT JOIN (SELECT DEA.[DataExportOrderAdjustmentId] AS AdjustmentID
					, sum(DEAD.[SignedAgreedValue]) AS salesOrderAmount
					, sum(DEAD.[SignedAgreedValueMaster]) AS salesOrderAmountMaster
			   FROM
				   AC01.[dbo].[AC01_DataExportAdjustment] DEA
				   INNER JOIN (AC01..[AC01_DataExportAdjustmentLine] DEAL
				   INNER JOIN AC01..[AC01_DataExportAdjustmentDetail] DEAD
					   ON DEAD.DataExportOrderAdjustmentId = DEAL.DataExportAdjustmentLineId
					   )
					   ON DEAL.DataExportAdjustmentId = DEA.DataExportOrderAdjustmentId
			   GROUP BY
				   DEA.[DataExportOrderAdjustmentId]) a
		ON a.AdjustmentID = DEA.DataExportOrderAdjustmentId	 
	LEFT JOIN (SELECT dea1.DataExportOrderAdjustmentId
					, dea1.OrderNumber
					, rank() OVER (PARTITION BY dea1.OrderNumber ORDER BY de1.DataExportCreatedDateTime) AS Rank
			   FROM
				   AC01..AC01_DataExportAdjustment DEA1
				   JOIN Ac01..AC01_DataExport DE1
					   ON DE1.DataExportId = DEA1.DataExportOrderAdjustmentId) rr
		ON rr.DataExportOrderAdjustmentId=DEA.DataExportOrderAdjustmentId
go




--lines
SELECT DEA.DataExportOrderAdjustmentId AS salesOrderID
	 , convert(money,DEAD.[SignedAgreedValue]) AS amount
, CASE WHEN DEAD.[AdjustmentReason]='None' then chargeType ELSE DEAD.[AdjustmentReason] END as NonStockSKU	 
	 , convert(money,isnull(DEO.TaxRate,0)) as VATBusPostingGroup
	 , isnull(convert(money,DEAD.[SignedAgreedValue]*DEO.TaxRate/100),0) AS VATAmount

FROM
	AC01.[dbo].[AC01_DataExportAdjustment] DEA
	INNER JOIN (AC01..[AC01_DataExportAdjustmentLine] DEAL
	INNER JOIN AC01..[AC01_DataExportAdjustmentDetail] DEAD
		ON DEAD.DataExportOrderAdjustmentId = DEAL.DataExportAdjustmentLineId
		)
		ON DEAL.DataExportAdjustmentId = DEA.DataExportOrderAdjustmentId
	INNER JOIN AC01.[dbo].[AC01_DataExportOrder] DEO
		ON DEO.CustomerOrderId = DEA.CustomerOrderId
go




--payments
SELECT DEA.[DataExportOrderAdjustmentId] AS salesorderId
	   , 'Card' as paymentType
	   , CardType AS CardType
	 , DEATL.TransactionGUID AS tranasctionId	 
	 , convert(money,DEATL.AmountRefunded) AS transactionAmount	
	  , DEA.TransactionCurrencyISO as Currency	  
FROM
	AC01.[dbo].[AC01_DataExportAdjustment] DEA
	INNER JOIN AC01.dbo.AC01_DataExportAdjustmentTenderLine DEATL
		ON DEATL.DataExportAdjustmentId = DEA.DataExportOrderAdjustmentId
	INNER JOIN AC01.[dbo].[AC01_DataExportOrder] DEO
		ON DEO.CustomerOrderId = DEA.CustomerOrderId
UNION
SELECT DEA.[DataExportOrderAdjustmentId] AS salesOrderId
	 , 'Credit' AS paymentType
	 , null AS cardType
	 , convert(UNIQUEIDENTIFIER, '00000000-0000-0000-0000-000000000000') AS tranasctionId
	 , convert(money,DEACRL.AmountCredited) AS transactionAmount	
	  ,DEA.TransactionCurrencyISO as Currency	  
FROM
	AC01.[dbo].[AC01_DataExportAdjustment] DEA
	INNER JOIN AC01.dbo.AC01_DataExportAdjustmentCreditsLine DEACRL
		ON DEACRL.DataExportAdjustmentId = DEA.DataExportOrderAdjustmentId
	INNER JOIN AC01.[dbo].[AC01_DataExportOrder] DEO
		ON DEO.CustomerOrderId = DEA.CustomerOrderId
go




