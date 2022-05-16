%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"	
var scheduledReceiptDetailEntity = vars.entityMap.schedrcpts[0].schedrcptsdetail[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
---
flatten(flatten(flatten(payload.scheduledReceipt filter($.status ==  null or $.status ==  "" or (lower($.status) == "open")) map (scheduledReceipt,indexOfScheduledReceipt) -> {
 (conversion: scheduledReceipt.lineItem map (scheduledReceiptLineItem,indexOfScheduledReceiptLineItem) -> {
 	(val: scheduledReceiptLineItem.productionRoutingOperationInformation map{
 	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference,		
	(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((indexOfScheduledReceiptLineItem))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	SENDER: vars.bulkNotificationHeaders.sender,
	EXPDATE: if (scheduledReceiptLineItem.supplyExpirationDate != null 
			 and funCaller.formatGS1ToSCPO(scheduledReceiptLineItem.supplyExpirationDate) != default_value
			 ) 
			 	(scheduledReceiptLineItem.supplyExpirationDate replace "Z" with("")) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} 
			 else default_value,
	ITEM: if (scheduledReceipt.scheduledReceiptId.item.primaryId != null) 
		  		scheduledReceipt.scheduledReceiptId.item.primaryId 
		  else default_value,
	LOC: if (scheduledReceipt.scheduledReceiptId.location.primaryId != null) 
			scheduledReceipt.scheduledReceiptId.location.primaryId
		else default_value,
	QTYINMOVE: if ($.nextOperationAvailableQuantity.value != null) 
					$.nextOperationAvailableQuantity.value
			   else default_value,
	QTYINQUEUE: if ($.currentOperationAvailableQuantity.value != null) 
					$.currentOperationAvailableQuantity.value 
				else default_value,
	QTYINRUN: if ($.inProcessQuantity.value != null) 
				$.inProcessQuantity.value 
			  else default_value,
	SCHEDDATE: if (scheduledReceipt.scheduledReceiptId.scheduledOnHandDate != null 
				and funCaller.formatGS1ToSCPO(scheduledReceipt.scheduledReceiptId.scheduledOnHandDate) != default_value
			   ) 
			   		(scheduledReceipt.scheduledReceiptId.scheduledOnHandDate replace "Z" with("")) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} 
			   else default_value,
	SEQNUM: if (scheduledReceiptLineItem.lineItemNumber != null) 
				scheduledReceiptLineItem.lineItemNumber 
			else default_value,
	STARTDATE: if (scheduledReceipt.scheduledReceiptId.productionStartDate != null 
				and funCaller.formatGS1ToSCPO(scheduledReceipt.scheduledReceiptId.productionStartDate) != default_value
			   ) 
			   		(scheduledReceipt.scheduledReceiptId.productionStartDate replace "Z" with("")) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} 
			   else default_value,
	STEPNUM: if ($.operationNumber != null) 
				$.operationNumber 
			 else default_value,
	STEPSCHEDDATE: if ($.scheduledOperationOnHandDate != null 
					and funCaller.formatGS1ToSCPO($.scheduledOperationOnHandDate) != default_value
				   ) 
				   		($.scheduledOperationOnHandDate replace "Z" with("")) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} 
				   else default_value,
	STEPSTARTDATE: if ($.operationStartDate != null 
				   and funCaller.formatGS1ToSCPO($.operationStartDate ) != default_value
				   ) 
				   		($.operationStartDate replace "Z" with("")) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} 
				   else default_value,
	(ScheduledReceiptDetailUDC: (lib.getUdcNameAndValue(scheduledReceiptDetailEntity, scheduledReceipt.avpList, lib.getAvpListMap(scheduledReceipt.avpList))[0])) 
  	if (scheduledReceipt.avpList != null 
		and (scheduledReceipt.documentActionCode == "ADD" or scheduledReceipt.documentActionCode == "CHANGE_BY_REFRESH")
		and scheduledReceiptDetailEntity != null
  	),
	ACTIONCODE: scheduledReceipt.documentActionCode
	})
	})
} pluck($).val)))