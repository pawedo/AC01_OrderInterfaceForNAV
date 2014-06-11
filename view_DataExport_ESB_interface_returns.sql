USE [AC01]
GO

--returns header

SELECT DER.DataExportReturnId AS salesOrderId
	 , 'Return' AS salesOrderType
	 , rr.OrderNumber+'/R'+convert(varchar(2),rr.Rank) AS returnOrderNo
	 , 'Quantiv' AS salesOrderSource
	 , DER.OrderNumber AS originalSalesOrderNo
	 , DER.CustomerId AS billToNetCustomerUrn
	 , DE.DataExportCreatedDateTime AS returnCreatedDate
	 , CASE
		   WHEN DER.Channel = 'CallCentre' THEN
			   'Call Centre'
		   ELSE
			   DER.Channel
	   END AS channelType
	 , DER.TransactionCurrencyISO AS currencyCode
	 , convert(MONEY, DER.GrossTotal) AS salesOrderAmount
	 , convert(MONEY, DER.GrossTotalMaster) AS salesOrderAmountMaster
	 , convert(MONEY, der.GrossTax) AS GrossTax
	 , convert(MONEY, DER.GrossTaxMaster) AS GrossTaxMaster
	 , convert(MONEY, isnull(DER.TaxRate,0)) AS PostageVATBusPostingGroup
	 , convert(MONEY, 0) AS dutyPaid
	 , convert(MONEY, 0) AS dutyPaidMaster
	 , convert(MONEY, 0) AS importTax
	 , convert(MONEY, 0) AS importTaxMaster
FROM
	AC01.dbo.AC01_DataExportReturn AS DER
	INNER JOIN AC01.dbo.AC01_CustomerOrder AS CO
		ON CO.CustomerOrderRef = DER.OrderNumber
	INNER JOIN AC01.dbo.AC01_DataExport AS DE
		ON DE.DataExportId = DER.DataExportReturnId
	LEFT OUTER JOIN AC01.dbo.AC01_DataExportOrder AS DEO
		ON DEO.OrderNumber = DER.OrderNumber
	LEFT OUTER JOIN AC01.dbo.AC01_DataExportAddress AS DEAD
		ON DEAD.DataExportAddressId = DEO.DeliveryAddressId
	LEFT OUTER JOIN AC01.dbo.AC01_DataExportAddress AS DEAB
		ON DEAB.DataExportAddressId = DEO.BillingAddressId
	LEFT JOIN (SELECT DataExportReturnId
					, OrderNumber
					, rank() OVER (PARTITION BY OrderNumber ORDER BY de.DataExportCreatedDateTime) AS Rank
			   FROM
				   AC01..AC01_DataExportReturn DER
				   JOIN Ac01..AC01_DataExport DE
					   ON DE.DataExportId = DER.DataExportReturnId) rr
		ON rr.DataExportReturnId = DER.DataExportReturnId
go




--return lines stock

SELECT DER.DataExportReturnId AS salesOrderId
	 , DEO.OrderNumber AS salesOrderNo	 
	 , convert(money,0) as dutyAmount	 
	 , 'Blended' as dutyType 
	 , DERL.[SKU] AS salesOrderItemNo
	 , sum(convert(money,DERL.[LineValue])) AS amount	 
	 , count(DERL.[SKU]) AS Qty	 
	 , Reason as returnReason
	 , sum(convert(money,DERL.[TaxValue])) AS taxAmount
	 , convert(money,DERL.[AgreedPrice]) AS unitPrice	 	 	 
	 , convert(money,isnull(DEO.TaxRate,0)) as VATBusPostingGroup
	 , sum(convert(money,DERL.[TaxValue])) as VATAmout	 
	 , convert(money,0) as dutyPaid
	 , convert(money,0) as importTax	 
FROM
	AC01.[dbo].[AC01_DataExportReturn] DER
	INNER JOIN AC01.dbo.AC01_DataExportReturnLine DERL
		ON DERL.DataExportReturnId = DER.DataExportReturnId
	INNER JOIN AC01.[dbo].[AC01_DataExportOrder] DEO
		ON DEO.CustomerOrderId = DER.CustomerOrderId
GROUP BY
	DER.DataExportReturnId
  , DEO.OrderNumber
  , DERL.[SKU]
  , convert(money,isnull(DEO.TaxRate,0))
  , convert(money,DERL.[AgreedPrice])
  , Reason
go





--returns adjustemnt lines 
SELECT DER.DataExportReturnId as salesOrderId
	 , DEO.OrderNumber as salesOrderNumber
	 , convert(money,DEAD.[SignedAgreedValue]) as amount
	 , CASE WHEN DEAD.[AdjustmentReason]='None' then chargeType ELSE DEAD.[AdjustmentReason] END as NonStockSKU
	 , convert(MONEY, isnull(DER.TaxRate,0)) as VATBusPostingGroup	 
	 , isnull(convert(money,DEAD.[SignedAgreedValue]*DER.TaxRate/100),0) as VATAmount
FROM
	AC01..[AC01_DataExportReturn] DER
	INNER JOIN (AC01.dbo.[AC01_DataExportReturnAdjustmentLine] DERAL
	INNER JOIN AC01.dbo.[AC01_DataExportAdjustmentDetail] DEAD
		ON DEAD.DataExportOrderAdjustmentId = DERAL.DataExportReturnAdjustmentLineId
		)
		ON DERAL.DataExportReturnId = DER.DataExportReturnId
	INNER JOIN AC01.[dbo].[AC01_DataExportOrder] DEO
		ON DEO.CustomerOrderId = DER.CustomerOrderId

go



--returns payments


SELECT DER.DataExportReturnId as salesOrderId	 
	 , 'Card' AS paymentType
	 , DERTL.CardType AS CardType	 
	 , DERTL.TransactionGUID AS tranasctionId	 
	 , convert(money,DERTL.AmountRefunded) as AmountRefunded
	  ,TransactionCurrencyISO
FROM
	AC01..[AC01_DataExportReturn] DER
	INNER JOIN AC01.dbo.AC01_DataExportRefundTenderLine DERTL
		ON DERTL.DataExportReturnId = DER.DataExportReturnId	
UNION
SELECT DER.DataExportReturnId	 
	 , 'Credit' AS PaymentType
	 , NULL as CardType
	 , convert(UNIQUEIDENTIFIER, '00000000-0000-0000-0000-000000000000') AS TranasctionId	 
	 , convert(money,DERCRL.AmountCredited) as AmountCredited
	  ,TransactionCurrencyISO
FROM
	AC01..[AC01_DataExportReturn] DER
	INNER JOIN AC01.dbo.AC01_DataExportRefundCreditsLine DERCRL
		ON DERCRL.DataExportReturnId = DER.DataExportReturnId
go