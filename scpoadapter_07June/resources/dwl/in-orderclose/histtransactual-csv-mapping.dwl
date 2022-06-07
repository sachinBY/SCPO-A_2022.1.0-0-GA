%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var histTransEntity = vars.entityMap.histtransactual[0].histtransactual[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload filter ($.orderTypeCode != null and ($.orderTypeCode == "10002" or $.orderTypeCode == "10005" or $.orderTypeCode == "10006" or $.orderTypeCode == "10007")) map {
	udcs: (histTransEntity map (value, index) -> {
		scpoColumnName: value.scpoColumnName,
		scpoColumnValue: if ( not isEmpty(lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) ) (lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) else default_value,
		(dataType: value.dataType) if ((lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) != null),
	}),
	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference, 
	(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	SENDER: vars.bulkNotificationHeaders.sender,
	ACTUALARRIVDATE: if (not isEmpty($.'lineItem.lineItemDetail.actualDeliveryDateTime'))
					$.'lineItem.lineItemDetail.actualDeliveryDateTime' as LocalDateTime as Date{format:"yyyy-MM-dd",class:"java.sql.Date"}
				 else default_value,
	ACTUALQTY: if (not isEmpty($.'lineItem.lineItemDetail.actualQuantity'))
					$.'lineItem.lineItemDetail.actualQuantity' as Number
				 else default_value,
	ACTUALSHIPDATE: if (not isEmpty($.'lineItem.lineItemDetail.actualExecutionDateTime'))
					$.'lineItem.lineItemDetail.actualExecutionDateTime' as LocalDateTime as Date{format:"yyyy-MM-dd",class:"java.sql.Date"}
				 else default_value,
	DEST: if (not isEmpty($.'lineItem.lineItemDetail.orderLogisticalInformation.shipTo.primaryId'))
					$.'lineItem.lineItemDetail.orderLogisticalInformation.shipTo.primaryId'
				 else default_value,
	ITEM: if (not isEmpty($.'lineItem.transactionalTradeItem.primaryId'))
					$.'lineItem.transactionalTradeItem.primaryId'
				 else default_value,
	ORDERID: if (not isEmpty($.orderId))
					$.orderId
				 else default_value,
	SOURCE: if (not isEmpty($.'lineItem.lineItemDetail.orderLogisticalInformation.shipFrom.primaryId'))
					$.'lineItem.lineItemDetail.orderLogisticalInformation.shipFrom.primaryId'
				 else default_value,
	TRANSMODE: if (not isEmpty($.'lineItem.lineItemDetail.orderLogisticalInformation.shipmentTransportationInformation.transportServiceCategoryType'))
					$.'lineItem.lineItemDetail.orderLogisticalInformation.shipmentTransportationInformation.transportServiceCategoryType'
				 else default_value,
	ACTIONCODE: if (not isEmpty($.documentActionCode)) $.documentActionCode else vars.bulknotificationHeaders.documentActionCode
}) default []