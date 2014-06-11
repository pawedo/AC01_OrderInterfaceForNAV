USE [AC01]
GO

--orders goods header

SELECT DEO.DataExportOrderId AS salesOrderId
	 , 'Order' AS salesOrderType
	 , DEO.OrderNumber AS salesOrderNo
	 , 'Quantiv' AS salesOrderSource
	 , DEO.OrderNumber AS originalSalesOrderNo
	 , DEO.CustomerId AS billToNetCustomerUrn
	 , DEO.OrderDate AS createdDate
	 , DEO.DespatchDate postedDate
	 , DEO.Channel channelType
	 , DEO.TransactionCurrencyISO AS CurrencyCode
	 , DEO.DeliveryOptionDescription AS DeliveryOption
	 , DEO.DeliveryMethodDescription AS DeliveryMethod	 	 	 
	 , isnull(DEAD.Title + ' ', '') + isnull(DEAD.FirstName + ' ', '') + isnull(DEAD.LastName, '') AS ShipToName
	 , DEAD.AddressLine1 as ShipToAddress1
	 , DEAD.AddressLine2 as ShipToAddress2
	 , DEAD.AddressLine3 as ShipToAddress3
	 , DEAD.StateCode as ShipToStateCode
	 , DEAD.Town as ShipToTown
	 , DEAD.County as ShipToCounty
	 , DEAD.PostCode as ShipToPostCode
	 , DEAD.Country	 as ShipToCountry 
	 , DEO.EmailAddress AS ShipToEmail	 
	 , DEO.PrimaryPhoneNumber AS ShipToPhoneNo
	 , 'N/A' AS ShipToPhoneType
	 , convert(money,DEO.GrossTotal) AS SalesOrderAmount
	 , convert(money,DEO.GrossTotalmaster) as  SalesOrderAmountMaster
	 , convert(money,DEO.GrossTax) as GrossTax
	 , convert(money,DEO.GrossTaxMaster) as GrossTaxMaster
	 , convert(money,isnull(DEO.TaxRate,0)) AS postageVATBusPostingGroup	 
	 , convert(money,DEO.DutyPaid) as DutyPaid
	 , convert(money,DEO.DutyPaidMaster) as DutyPaidMaster
	 , convert(money,DEO.ImportTax) as ImportTax
	 , convert(money,DEO.ImportTaxMaster) as ImportTaxMaster
	 , DEO.LinkshareSiteId as LinkshareSiteID
	 , DEO.LinkshareMID as LinkshareSiteReference
	 , CO.IsGiftOrder
	 , isnull(DEAB.Title + ' ', '') + isnull(DEAB.FirstName + ' ', '') + isnull(DEAB.LastName, '') AS BillToName
	 , DEAB.AddressLine1 as BillingToAddress1
	 , DEAB.AddressLine2 as BillingToAddress2
	 , DEAB.AddressLine3 as BillingToAddress3
	 , DEAB.StateCode as BillingToStateCode
	 , DEAB.Town as BillingToTown
	 , DEAB.County as BillingToCounty
	 , DEAB.PostCode as BillingToPostCode
	 , DEAB.Country	 as BillingToCountry 	 	 	 
FROM
	AC01.dbo.AC01_DataExportOrder AS DEO
	LEFT OUTER JOIN AC01.dbo.AC01_DataExportAddress AS DEAD
		ON DEAD.DataExportAddressId = DEO.DeliveryAddressId
	LEFT OUTER JOIN AC01.dbo.AC01_DataExportAddress AS DEAB
		ON DEAB.DataExportAddressId = DEO.BillingAddressId
	LEFT JOIN AC01..AC01_CustomerOrder CO
		ON CO.CustomerOrderId = DEO.CustomerOrderId 
where DEO.OrderType = 1 --order only
union all --orders credits header
SELECT DEO.DataExportOrderId AS salesOrderId
	 , 'Credit Order' AS salesOrderType
	 , DEO.OrderNumber AS salesOrderNo
	 , 'Quantiv' AS salesOrderSource
	 , DEO.OrderNumber AS originalSalesOrderNo
	 , DEO.CustomerId AS billToNetCustomerUrn
	 , DEO.OrderDate AS createdDate
	 , DEO.DespatchDate postedDate
	 , DEO.Channel channelType
	 , DEO.TransactionCurrencyISO AS CurrencyCode
	 , DEO.DeliveryOptionDescription AS DeliveryOption
	 , DEO.DeliveryMethodDescription AS DeliveryMethod	 	 	 
	 , isnull(DEAD.Title + ' ', '') + isnull(DEAD.FirstName + ' ', '') + isnull(DEAD.LastName, '') AS ShipToName
	 , DEAD.AddressLine1 as ShipToAddress1
	 , DEAD.AddressLine2 as ShipToAddress2
	 , DEAD.AddressLine3 as ShipToAddress3
	 , DEAD.StateCode as ShipToStateCode
	 , DEAD.Town as ShipToTown
	 , DEAD.County as ShipToCounty
	 , DEAD.PostCode as ShipToPostCode
	 , DEAD.Country	 as ShipToCountry 
	 , DEO.EmailAddress AS ShipToEmail	 
	 , DEO.PrimaryPhoneNumber AS ShipToPhoneNo
	 , 'N/A' AS ShipToPhoneType
	 , convert(money,DEO.GrossTotal) AS SalesOrderAmount
	 , convert(money,DEO.GrossTotalmaster) as  SalesOrderAmountMaster
	 , convert(money,DEO.GrossTax) as GrossTax
	 , convert(money,DEO.GrossTaxMaster) as GrossTaxMaster
	 , convert(money,isnull(DEO.TaxRate,0)) AS postageVATBusPostingGroup	 
	 , convert(money,DEO.DutyPaid) as DutyPaid
	 , convert(money,DEO.DutyPaidMaster) as DutyPaidMaster
	 , convert(money,DEO.ImportTax) as ImportTax
	 , convert(money,DEO.ImportTaxMaster) as ImportTaxMaster
	 , DEO.LinkshareSiteId as LinkshareSiteID
	 , DEO.LinkshareMID as LinkshareSiteReference
	 , CO.IsGiftOrder
	 , isnull(DEAB.Title + ' ', '') + isnull(DEAB.FirstName + ' ', '') + isnull(DEAB.LastName, '') AS BillToName
	 , DEAB.AddressLine1 as BillingToAddress1
	 , DEAB.AddressLine2 as BillingToAddress2
	 , DEAB.AddressLine3 as BillingToAddress3
	 , DEAB.StateCode as BillingToStateCode
	 , DEAB.Town as BillingToTown
	 , DEAB.County as BillingToCounty
	 , DEAB.PostCode as BillingToPostCode
	 , DEAB.Country	 as BillingToCountry 	 	 	 
FROM
	AC01.dbo.AC01_DataExportOrder AS DEO
	LEFT OUTER JOIN AC01.dbo.AC01_DataExportAddress AS DEAD
		ON DEAD.DataExportAddressId = DEO.DeliveryAddressId
	LEFT OUTER JOIN AC01.dbo.AC01_DataExportAddress AS DEAB
		ON DEAB.DataExportAddressId = DEO.BillingAddressId
	LEFT JOIN AC01..AC01_CustomerOrder CO
		ON CO.CustomerOrderId = DEO.CustomerOrderId 
where DEO.OrderType = 2 --credit only

go



--goods line

SELECT DEO.[DataExportOrderId] AS salesOrderId
	 , DEO.OrderNumber AS salesOrderNo	 	 
	 , convert(money,0) as dutyAmount	 --tbd
	 , 'Blended' AS dutyType 		 --tbd
	 , DESL.[SKU] AS salesOrderItemNo
	 , sum(convert(money,LineValue)) AS amount
	 , '.tbd' as PromoRef
	 , count(DESL.[SKU]) AS Qty
	 , DespatchDate as shippingDate
	 , convert(money,0) AS taxAmount --tbd, maybe will be remove LW
	 , convert(money,DESL.AgreedPrice) AS unitPrice	 	 
	 , convert(money,isnull(DEO.TaxRate,0)) as VatBusPostingGroup	 
	 , sum(convert(money,TaxValue)) AS vatAmount
	 , '?' as DutyPaid 			-- it's a flag if duty
	 , convert(money,0) as ImportTax 	-- tbd 
FROM
	AC01.dbo.[AC01_DataExportOrder] DEO
	INNER JOIN AC01.dbo.AC01_DataExportSaleLine DESL
		ON DESL.DataExportOrderId = DEO.DataExportOrderId
GROUP BY
	DEO.[DataExportOrderId]
  , DEO.OrderNumber
  , DESL.[SKU]
  , DEO.DespatchDate
  , convert(money,DESL.AgreedPrice)
  , convert(money,isnull(DEO.TaxRate,0))
go



--order goods adjustment lines
SELECT DEO.[DataExportOrderId] AS salesOrderId
	 , DEO.OrderNumber AS salesOrderNo
	 , convert(money,DEAD.[SignedAgreedValue]) AS amount
	 , CASE WHEN DEAD.[AdjustmentReason]='None' then chargeType ELSE DEAD.[AdjustmentReason] END as NonStockSKU	 
	 , convert(money,isnull(DEO.TaxRate,0)) as VATBusPostingGroup
	 , convert(money,isnull(DEAD.[SignedAgreedValue]*(DEO.TaxRate/100),0)) AS VatAmount	 	 
FROM
	AC01..[AC01_DataExportOrder] DEO
	INNER JOIN Ac01..[AC01_DataExportOrderAdjustmentLine] DEOAL
		ON DEOAL.DataExportOrderId = DEO.DataExportOrderId
	INNER JOIN AC01..[AC01_DataExportAdjustmentDetail] DEAD
		ON DEAD.DataExportOrderAdjustmentId = DEOAL.DataExportOrderAdjustmentLineId




--order payments
SELECT *
FROM
	(SELECT DEO.[DataExportOrderId] AS salesOrderId
		  , 'Card' as paymentType
		  , DEOTL.CardType AS CardType
		  , DEOTL.TransactionGUID AS tranasctionID		  		  
		  , convert(money,DEOTL.AmountCharged) AS transactionAmount	
		  , TransactionCurrencyISO as Currency	  
	 FROM
		 AC01..[AC01_DataExportOrder] DEO
		 INNER JOIN AC01..AC01_DataExportOrderTenderLine DEOTL
			 ON DEOTL.DataExportOrderId = DEO.DataExportOrderId
	 --where DEO.DataExportOrderId in (select orderExportId from @orderExportIds)
	 UNION ALL
	 -- Credits Redeeemed
	 SELECT DEO.[DataExportOrderId] salesOrderId
		  , 'Credit' AS PaymentType
		  , null AS CardType
		  , convert(UNIQUEIDENTIFIER, '00000000-0000-0000-0000-000000000000') AS tranasctionID		  
		  , convert(money,DEOCRL.AmountCharged) transactionAmount
		  , TransactionCurrencyISO as Currency
 
	 FROM
		 AC01..[AC01_DataExportOrder] DEO
		 INNER JOIN AC01..AC01_DataExportOrderCreditsRedeemedLine DEOCRL
			 ON DEOCRL.DataExportOrderId = DEO.DataExportOrderId
	--where DEO.DataExportOrderId in (select orderExportId from @orderExportIds)
	 ) a
