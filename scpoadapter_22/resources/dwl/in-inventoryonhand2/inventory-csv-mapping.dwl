%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var inventoryEntity = vars.entityMap.inventory[0].inventory[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
 (flatten(payload) map {
 	
 		udcs:(inventoryEntity map (value, index) -> {
			scpoColumnName: value.scpoColumnName,
			scpoColumnValue: if ((lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) != null) (lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) else default_value,
			(dataType: value.dataType) if ((lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) != null),
		}),
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
	  	AVAILDATE: if ($.availableForSupplyDate != null and $.availableForSupplyDate != "" and funCaller.formatGS1ToSCPO($.availableForSupplyDate) != default_value) $.availableForSupplyDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
	  		else default_value,
	    EXPDATE: if ($.bestBeforeDate != null and $.bestBeforeDate != "" and funCaller.formatGS1ToSCPO($.bestBeforeDate) != default_value) $.bestBeforeDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
	  		else default_value,
	   	(ITEM: $.itemId) if ($.itemId != null and $.itemId != ""),
	    (LOC: $.locationId) if ($.locationId != null and $.locationId != ""),
	    PROJECT: if ($.project != null and $.project != "") $.project 
	  		else default_value,
	    QTY: if ($."quantity.value" != null and $."quantity.value" != "") $."quantity.value" 
	  		else default_value,	  	
	  	STORE: if ($.storageLocation != null and $.storageLocation != "") $.storageLocation 
	  		else default_value,
	    EARLIESTSELLDATE: if ($.availableForSaleDate != null and $.availableForSaleDate != "" and funCaller.formatGS1ToSCPO($.availableForSaleDate) != default_value) $.availableForSaleDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
	  		else default_value,
	  	STOCKCATEGORY: if(!isEmpty($.inventoryStatus)) $.inventoryStatus else default_value,
  		//BATCHNUMBER: if ($.batchNumber != null and $.batchNumber != "") $.batchNumber
  		//else default_value,
		ACTIONCODE: "ADD"
  		
  })