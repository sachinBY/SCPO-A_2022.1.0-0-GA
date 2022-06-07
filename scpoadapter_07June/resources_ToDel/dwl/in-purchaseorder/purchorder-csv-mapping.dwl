%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var purchOrderEntity = vars.entityMap.purchorder[0].purchorder[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
flatten(flatten(payload filter(lower($.'lineItem.lineStatus') != 'deleted' and lower($.'lineItem.lineStatus') != 'inactive') groupBy (($.documentActionCode default vars.bulknotificationHeaders.documentActionCode) ++ ($.orderId default default_value) ++ ($."lineItem.lineItemNumber" default default_value)) pluck ($) map (line, indexLine) -> {
	// loop through data on lineItemDetail level
	line: line map {
		udcs: (purchOrderEntity map (value, index) -> {
			scpoColumnName: value.scpoColumnName,
			scpoColumnValue: if ( not isEmpty(lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) ) (lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) else default_value,
			(dataType: value.dataType) if ((lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) != null),
		}),
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	  	MS_REF: vars.storeMsgReference.messageReference,	
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((indexLine))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,			
		PROJECT: if ( not isEmpty($."lineItem.project") ) $."lineItem.project"
						  else if ( not isEmpty($.project) ) $.project
						  else default_value,
		PURCHMETHOD: if ( not isEmpty($."lineItem.purchaseMethod") ) $."lineItem.purchaseMethod"
						  else if ( not isEmpty($.purchaseMethod) ) $.purchaseMethod
						  else default_value,
		ORDERNUM: if ( not isEmpty($.orderId) ) $.orderId else default_value,
		ITEM: if ( not isEmpty($."lineItem.transactionalTradeItem.primaryId") ) $."lineItem.transactionalTradeItem.primaryId" 
					  else default_value,
		LINENUM: if ( not isEmpty($."lineItem.lineItemNumber") ) ($."lineItem.lineItemNumber" ++ "_" ++ $$)
						 else default_value,
		DUEDATE: if ( not isEmpty($."lineItem.lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateTime.date") ) $."lineItem.lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateTime.date"
						 else default_value,
		LOC: if ( not isEmpty($."lineItem.lineItemDetail.orderLogisticalInformation.shipTo.primaryId") ) $."lineItem.lineItemDetail.orderLogisticalInformation.shipTo.primaryId" 
					 else default_value,
		QTY: if ( not isEmpty($."lineItem.lineItemDetail.requestedQuantity.value") ) $."lineItem.lineItemDetail.requestedQuantity.value" 
					 else default_value,
		EXPDATE: if ( not isEmpty($."lineItem.transactionalTradeItem.transactionalItemData.itemExpirationDate") ) $."lineItem.transactionalTradeItem.transactionalItemData.itemExpirationDate" 
						 else default_value,
		ACTIONCODE: if ( not isEmpty($.documentActionCode) ) $.documentActionCode else vars.bulknotificationHeaders.documentActionCode
	}
} pluck ($)
))
