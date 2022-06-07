%dw 2.0
output application/java  

var histEntity = vars.entityMap.hist[0].hist[0]
var default_value = "###JDA_DEFAULT_VALUE###"
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var histStreamConversion= vars.codeMap.histStreamConversion
---
flatten(payload.inventoryTransaction2 map (inventory,inventoryIndex) -> { 
    	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((inventoryIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		TYPE: "1",
		EVENT: " ",
		DMDUNIT: if(inventory.itemId != null and inventory.itemId != "") 
					inventory.itemId 
			  else default_value,
		DMDGROUP:  if(inventory.demandChannel != null and inventory.demandChannel != "") 
					inventory.demandChannel 
			  else default_value,
		
		LOC: if(inventory.locationId != null and inventory.locationId != "")
				inventory.locationId 
			else default_value,	  
		STARTDATE: 	if(inventory.startDate != null and inventory.startDate != "") 
						(inventory.startDate replace "Z" with ("")) as Date{format:"yyyy-MM-dd",class:"java.sql.Date"}
			       else default_value,
		DUR: if(inventory.durationInMinutes != null and inventory.durationInMinutes != "") 
					inventory.durationInMinutes as Number 
			  else default_value,
		HISTSTREAM: if(inventory.transactionCode != null and inventory.transactionCode != "")
				histStreamConversion[inventory.transactionCode][0] 
			else default_value,	
		QTY: if(inventory.quantity.value != null and inventory.quantity.value != "")
				inventory.quantity.value as Number
			 else default_value,		  	       
		(histUDC:(lib.getUdcNameAndValue(histEntity, inventory.avpList, lib.getAvpListMap(inventory.avpList))[0])) if (inventory.avpList != null 
		and histEntity != null),
		ACTIONCODE: inventory.documentActionCode default "ADD"
   
})