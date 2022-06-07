%dw 2.0
output application/java
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var default_value = "###JDA_DEFAULT_VALUE###"
var custOrderEntity = vars.entityMap.custorder[0].custorder[0]
var dateUtil = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
---
flatten (payload.customerOrder map (order, orderIndex) -> {
	customerorder: flatten((order.lineItem filter (lower($.lineStatus) == 'open') map(orderLineItem, orderLineItemIndex) -> {
		(array: flatten((orderLineItem.lineItemDetail map (lineItemDetail, indexDetail) -> {
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	    MS_REF: vars.storeMsgReference.messageReference,
		INTEGRATION_STAMP: ((vars.creationDateAndTime as DateTime + ('PT' ++ orderIndex ++ 'S') as Period) replace 'T' with '') [0 to 17],
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
	 	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
	 	SENDER: vars.bulkNotificationHeaders.sender, 
		DMDGROUP: if (orderLineItem.demandChannel != null) orderLineItem.demandChannel else default_value,
		FCSTSW: if (orderLineItem.isForecastOrder != null) if(orderLineItem.isForecastOrder) 1 else 0 else default_value,
		FCSTTYPE: if (orderLineItem.forecastType != null) orderLineItem.forecastType else default_value,
		QTY: if (orderLineItem.totalOpenQuantity.value != null) orderLineItem.totalOpenQuantity.value else default_value,
		RESERVATION: if (orderLineItem.isReservedOrder != null) if(orderLineItem.isReservedOrder) 1 else 0 else default_value,
		RESEXP: if (orderLineItem.reservationExpirationDateTime != null)orderLineItem.reservationExpirationDateTime else default_value,
		STATUS: if (orderLineItem.planningStatus != null) orderLineItem.planningStatus else default_value,
		SUPERSEDESW: if (orderLineItem.isSubstitutionAllowed != null) if(orderLineItem.isSubstitutionAllowed) 1 else 0 else default_value,
		CUST: if (order.buyer.primaryId != null ) 
						order.buyer.primaryId 
				 else default_value,
		DELIVERYDATE: if (lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateTime.date != null) 
						lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateTime.date
				 else default_value,
		DFULOC: if (lineItemDetail.orderLogisticalInformation.shipFrom.primaryId != null) 
						lineItemDetail.orderLogisticalInformation.shipFrom.primaryId 
				else default_value,
		DEST: if (lineItemDetail.orderLogisticalInformation.shipTo.primaryId != null) 
						lineItemDetail.orderLogisticalInformation.shipTo.primaryId 
				else default_value,
		DMDUNIT: if (orderLineItem.transactionalTradeItem.primaryId != null) 
						orderLineItem.transactionalTradeItem.primaryId 
				 else default_value,
		HEADEREXTREF: if (order.orderId != null) 
							order.orderId 
						 else default_value,
		ITEM: if (orderLineItem.transactionalTradeItem.primaryId != null) 
						orderLineItem.transactionalTradeItem.primaryId 
				 else default_value,
		LINEITEMEXTREF: if (orderLineItem.lineItemNumber != null) 
								orderLineItem.lineItemNumber 
						   else default_value,
		LOC: if (lineItemDetail.orderLogisticalInformation.shipFrom.primaryId != null) 
						lineItemDetail.orderLogisticalInformation.shipFrom.primaryId 
				else default_value,
		MAXEARLYDUR: if (lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.date != null
							and lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateRange.beginDate != null
								) 
							ceil(dateUtil.utcToSeconds(lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.date)
									- 
								dateUtil.utcToSeconds(lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateRange.beginDate))
						else default_value,
		MAXLATEDUR: if (lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.date != null
							and lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateRange.endDate != null
								) 
							ceil(dateUtil.utcToSeconds(lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateRange.endDate) 
									- 
								dateUtil.utcToSeconds(lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.date))
						else default_value,
		ORDERID: if (order.orderId != null) 
						order.orderId ++"_"++ orderLineItem.lineItemNumber
					else default_value,
		//CO_ORDERSEQNUM: (lookup('increment-custordersequence-number','')),
		PRIORITY: if (orderLineItem.orderLinePriority != null) 
					orderLineItem.orderLinePriority 
					else default_value,
		SHIPDATE: if (lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.date != null
				and lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.time == null) 
						lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.date
					else if (lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.date != null
				and lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.time != null) 
						lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.date
						++ 'T' 
					++ lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.time
					 else default_value,				
		UNITPRICE: if (orderLineItem.netPrice.value != null) 
						orderLineItem.netPrice.value 
					  else default_value,
		avplistUDCS:(flatten([(lib.getUdcNameAndValue(custOrderEntity, order.avpList, lib.getAvpListMap(order.avpList))[0]) if (order.avpList != null 
		and (order.documentActionCode == "ADD" or order.documentActionCode == "CHANGE_BY_REFRESH")
		and custOrderEntity != null
		),
		(lib.getUdcNameAndValue(custOrderEntity, orderLineItem.avpList, lib.getAvpListMap(orderLineItem.avpList))[0]) if (orderLineItem.avpList != null 
			and (order.documentActionCode == "ADD" or order.documentActionCode == "CHANGE_BY_REFRESH")
			and custOrderEntity != null
		)
		])),	  
		ACTIONCODE: order.documentActionCode
        })))
	}.array))
}).customerorder reduce ($ ++ $$)