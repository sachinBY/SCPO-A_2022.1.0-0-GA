%dw 2.0
var default_value = "###JDA_DEFAULT_VALUE###"
var inventoryEntity = vars.entityMap.inventory[0].inventory[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
import * from dw::Runtime
output application/java
---
flatten(payload.inventoryOnHand2 map (inventory,inventoryIndex) -> { 
    	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((inventoryIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		AVAILDATE: if(inventory.availableForSupplyDate != null and inventory.availableForSupplyDate != "") 
						(inventory.availableForSupplyDate replace "Z" with ("")) as Date{format:"yyyy-MM-dd",class:"java.sql.Date"}
			       else default_value,
		EXPDATE: if(inventory.bestBeforeDate != null and inventory.bestBeforeDate != "")
						(inventory.bestBeforeDate replace "Z" with ("")) as Date{format:"yyyy-MM-dd",class:"java.sql.Date"}
				 else default_value,
		ITEM: if(inventory.itemId != null and inventory.itemId != "") 
					inventory.itemId 
			  else default_value,
		LOC: if(inventory.locationId != null and inventory.locationId != "")
				inventory.locationId 
			else default_value,
		PROJECT: if(inventory.project != null and inventory.project != "")
					inventory.project 
				else default_value,
		QTY: if(inventory.quantity.value != null and inventory.quantity.value != "")
				inventory.quantity.value as Number
			 else default_value,
		STORE: if(inventory.storageLocation != null and inventory.storageLocation != "")
				inventory.storageLocation 
			else default_value,
		EARLIESTSELLDATE: if(inventory.availableForSaleDate != null and inventory.availableForSaleDate != "")
							(inventory.availableForSaleDate replace "Z" with ("")) as Date{format:"yyyy-MM-dd",class:"java.sql.Date"}
						  else default_value,
		STOCKCATEGORY: if(!isEmpty(inventory.inventoryStatus)) inventory.inventoryStatus else default_value,				  
		//BATCHNUMBER: if (inventory.batchNumber != null and inventory.batchNumber != "") inventory.batchNumber
  		//else default_value,				  
		(inventoryUDCS:(lib.getUdcNameAndValue(inventoryEntity, inventory.avpList, lib.getAvpListMap(inventory.avpList))[0])) if (inventory.avpList != null 
		and inventoryEntity != null
		),
		
		ACTIONCODE: inventory.documentActionCode default "ADD"
   
})