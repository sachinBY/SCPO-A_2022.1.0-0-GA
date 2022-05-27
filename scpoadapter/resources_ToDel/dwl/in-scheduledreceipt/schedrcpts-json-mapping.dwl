%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"	
var scheduledReceiptEntity = vars.entityMap.schedrcpts[0].schedrcpts[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
---
flatten(flatten(payload.scheduledReceipt filter($.status ==  null or $.status ==  "" or (lower($.status) == "open")) map (scheduledReceipt,indexOfScheduledReceipt) -> {
   (conversion: scheduledReceipt.lineItem map (scheduledReceiptLineItem,indexOfScheduledReceiptLineItem) -> {
   	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference,		
	ACTIONALLOWEDSW: "0",
	(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((indexOfScheduledReceiptLineItem))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	SENDER: vars.bulkNotificationHeaders.sender,
	EXPDATE: if (scheduledReceiptLineItem.supplyExpirationDate != null 
			 and funCaller.formatGS1ToSCPO(scheduledReceiptLineItem.supplyExpirationDate) != default_value
			 ) 
			 	(scheduledReceiptLineItem.supplyExpirationDate replace "Z" with("")) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} 
			 else default_value,
	EXPLODESW: if (scheduledReceiptLineItem.isDependentDemandRequired != null) 
					if(scheduledReceiptLineItem.isDependentDemandRequired == true) "1" else "0" 
			   else default_value,
	ITEM: if (scheduledReceipt.scheduledReceiptId.item.primaryId != null) 
		  		scheduledReceipt.scheduledReceiptId.item.primaryId 
		  else default_value,
	LASTCOMPLETEDSTEP: if (scheduledReceiptLineItem.lastCompletedOperationNumber != null) 
							scheduledReceiptLineItem.lastCompletedOperationNumber 
					   else default_value,
	LOC: if (scheduledReceipt.scheduledReceiptId.location.primaryId != null) 
			scheduledReceipt.scheduledReceiptId.location.primaryId
		else default_value,
	PCTCOMPLETE: if (scheduledReceiptLineItem.currentOperationCompletionPercentage != null) 
					scheduledReceiptLineItem.currentOperationCompletionPercentage 
				 else default_value,
	PRIORITY: if (scheduledReceiptLineItem.priority != null) 
				scheduledReceiptLineItem.priority 
			  else default_value,
	PRODUCTIONMETHOD: if (scheduledReceiptLineItem.productionRoutingId != null) 
							scheduledReceiptLineItem.productionRoutingId 
					  else default_value,
	PROJECT: if (scheduledReceiptLineItem.project != null) 
				scheduledReceiptLineItem.project 
			 else default_value,
	QTY: if (scheduledReceiptLineItem.proposedQuantity.value != null) 
			scheduledReceiptLineItem.proposedQuantity.value 
		 else default_value,
	QTYRECEIVED: if (scheduledReceiptLineItem.receivedQuantity.value != null) 
					scheduledReceiptLineItem.receivedQuantity.value 
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
	(ScheduledReceiptUDC: (lib.getUdcNameAndValue(scheduledReceiptEntity, scheduledReceipt.avpList, lib.getAvpListMap(scheduledReceipt.avpList))[0])) 
  	if (scheduledReceipt.avpList != null 
		and (scheduledReceipt.documentActionCode == "ADD" or scheduledReceipt.documentActionCode == "CHANGE_BY_REFRESH")
		and scheduledReceiptEntity != null
  	),
	ACTIONCODE: scheduledReceipt.documentActionCode
    })
} pluck($)))
