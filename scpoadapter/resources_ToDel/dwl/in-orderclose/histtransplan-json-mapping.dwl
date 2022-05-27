%dw 2.0
output application/java
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var default_value = "###JDA_DEFAULT_VALUE###"
var histTransEntity = vars.entityMap.histtransactual[0].histtransplan[0]

---
flatten(flatten(payload.orderClose filter ($.orderTypeCode != null and ($.orderTypeCode == "10002" or $.orderTypeCode == "10005" or $.orderTypeCode == "10006" or $.orderTypeCode == "10007"))  map (order, orderIndex) -> {
	histtrans: flatten((order.lineItem map(orderLineItem, orderLineItemIndex) -> {
		(array: flatten((orderLineItem.lineItemDetail map (lineItemDetail, indexDetail) -> {
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
	    (INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((orderIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		DEST: if (lineItemDetail.orderLogisticalInformation.shipTo.primaryId != null) 
						lineItemDetail.orderLogisticalInformation.shipTo.primaryId 
				else default_value,
		ITEM: if (orderLineItem.transactionalTradeItem.primaryId != null) 
						orderLineItem.transactionalTradeItem.primaryId
				 else default_value,
		ORDERID: if (order.orderId != null) 
						order.orderId 
					else default_value,
		PLANDATE: "1970-01-01" as Date {format: "yyyy-MM-dd", class : "java.sql.Date"},
		SCHEDARRIVDATE: if (lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateTime.date != null) 
							lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateTime.date as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} 
						else default_value,
		SCHEDQTY: if(lineItemDetail.requestedQuantity.value != null)
					lineItemDetail.requestedQuantity.value as Number
					else 0,
		SCHEDSHIPDATE: 	if (lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.date != null) 
							lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.date as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} 
						else default_value,
		SOURCE: if (lineItemDetail.orderLogisticalInformation.shipFrom.primaryId != null) 
						lineItemDetail.orderLogisticalInformation.shipFrom.primaryId 
				else default_value,
		TRANSMODE: if (lineItemDetail.orderLogisticalInformation.shipmentTransportationInformation.transportServiceCategoryType != null ) 
						lineItemDetail.orderLogisticalInformation.shipmentTransportationInformation.transportServiceCategoryType 
				else default_value,			
		
		
		HistTransUDC: (flatten([(lib.getUdcNameAndValue(histTransEntity, order.avpList, lib.getAvpListMap(order.avpList))[0]) if (order.avpList != null 
		and (order.documentActionCode == "ADD" or order.documentActionCode == "CHANGE_BY_REFRESH")
		and histTransEntity != null
		),
		(lib.getUdcNameAndValue(histTransEntity, orderLineItem.avpList, lib.getAvpListMap(orderLineItem.avpList))[0]) if (orderLineItem.avpList != null 
			and (order.documentActionCode == "ADD" or order.documentActionCode == "CHANGE_BY_REFRESH")
			and histTransEntity != null
		),
		(lib.getUdcNameAndValue(histTransEntity, lineItemDetail.avpList, lib.getAvpListMap(lineItemDetail.avpList))[0]) if (lineItemDetail.avpList != null 
			and (order.documentActionCode == "ADD" or order.documentActionCode == "CHANGE_BY_REFRESH")
			and histTransEntity != null
		)
		])),
		ACTIONCODE: order.documentActionCode
        })))
	}.array))
}).histtrans) default []