%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"  
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var forecastEntity = vars.entityMap.fcst[0].skuexternalfcst[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload map {
	
		udcs: (forecastEntity map (value, index) -> {
			scpoColumnName: value.scpoColumnName,
			scpoColumnValue: if ( not isEmpty(lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) ) (lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) else default_value,
			(dataType: value.dataType) if ((lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) != null),
			}),
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
		INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$($$)S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"},	
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		STARTDATE: if($.'measure.forecastStartDate' != null and $.'measure.forecastStartDate' != "") ($.'measure.forecastStartDate' replace "Z" with ("")) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
		DUR: if($.'measure.durationInMinutes' != null and $.'measure.durationInMinutes' != "") $.'measure.durationInMinutes' as Number else default_value,
		QTY: if($.'measure.quantity.value' != null and $.'measure.quantity.value' != "") $.'measure.quantity.value' as Number else default_value,
		ITEM: if($.itemId != null and $.itemId != "") $.itemId else default_value,
		LOC: if($.locationId != null and $.locationId != "") $.locationId else default_value,
		PROJECT: if($.project != null and $.project != "") $.project else default_value,
		ACTIONCODE: if ($.documentActionCode != null) $.documentActionCode else if (vars.bulknotificationHeaders.documentActionCode != null) vars.bulknotificationHeaders.documentActionCode else "CHANGE_BY_REFRESH"
})