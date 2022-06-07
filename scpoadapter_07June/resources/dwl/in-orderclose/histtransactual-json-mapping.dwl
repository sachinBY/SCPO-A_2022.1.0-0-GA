%dw 2.0
import * from dw::core::Arrays
output application/java
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var default_value = "###JDA_DEFAULT_VALUE###"
var histTransEntity = vars.entityMap.histtransactual[0].histtransactual[0]
---
flatten(flatten (payload.orderClose filter ($.orderTypeCode != null and ($.orderTypeCode == "10002" or $.orderTypeCode == "10005" or $.orderTypeCode == "10006" or $.orderTypeCode == "10007")) map (order, orderIndex) -> {
	(histtrans: flatten((order.lineItem map(orderLineItem, orderLineItemIndex) -> {
 (array: flatten((orderLineItem.lineItemDetail map (lineItemDetail, indexDetail) ->
{
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
	    (INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((orderIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
        MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
        ACTUALARRIVDATE: lineItemDetail.actualDeliveryDateTime as LocalDateTime as Date{format:"yyyy-MM-dd",class:"java.sql.Date"} default default_value,
        ACTUALSHIPDATE: lineItemDetail.actualExecutionDateTime as LocalDateTime as Date{format:"yyyy-MM-dd",class:"java.sql.Date"} default default_value,
        ACTUALQTY:lineItemDetail.actualQuantity as Number default 0,
 
    
    		DEST: if (lineItemDetail.orderLogisticalInformation.shipTo.primaryId != null) 
						lineItemDetail.orderLogisticalInformation.shipTo.primaryId
				else default_value,
		ITEM: if (orderLineItem.transactionalTradeItem.primaryId != null) 
						orderLineItem.transactionalTradeItem.primaryId 
				 else default_value,
		ORDERID: if (order.orderId != null) 
						order.orderId 
					else default_value,
		SOURCE:	if (lineItemDetail.orderLogisticalInformation.shipFrom.primaryId != null) 
						lineItemDetail.orderLogisticalInformation.shipFrom.primaryId
				else default_value,
		TRANSMODE: 	if (lineItemDetail.orderLogisticalInformation.shipmentTransportationInformation.transportServiceCategoryType != null 
				
					) 
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
	}.array)))
}).histtrans)  default []