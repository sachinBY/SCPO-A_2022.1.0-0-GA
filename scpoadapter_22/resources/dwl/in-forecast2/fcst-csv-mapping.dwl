%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"  
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var forecastEntity = vars.entityMap.fcst[0].fcst[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
payload map (forecast2,forecast2index) -> {
		udcs: (forecastEntity map (value, index) -> {
			scpoColumnName: value.scpoColumnName,
			scpoColumnValue: if ( not isEmpty(lib.mapHostToSCPO(forecast2, (value.hostColumnName splitBy "/"), 0)) ) (lib.mapHostToSCPO(forecast2, (value.hostColumnName splitBy "/"), 0)) else default_value,
			(dataType: value.dataType) if ((lib.mapHostToSCPO(forecast2, (value.hostColumnName splitBy "/"), 0)) != null),
			}),
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
		INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(forecast2index)S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"},	
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		DMDUNIT: forecast2.itemId,
		DMDGROUP: if(forecast2.demandChannel != null and forecast2.demandChannel != "") forecast2.demandChannel else "*UNKNOWN",
		LOC: forecast2.locationId,
		STARTDATE: if (forecast2.'measure.forecastStartDate' != null and forecast2.'measure.forecastStartDate' != "" and funCaller.formatGS1ToSCPO(forecast2.'measure.forecastStartDate') != default_value) forecast2.'measure.forecastStartDate' as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
		TYPE: if(forecast2.forecastTypeCode != null and forecast2.forecastTypeCode != "") forecast2.forecastTypeCode else 1,
		QTY: if(forecast2.'measure.quantity.value' != null and forecast2.'measure.quantity.value' != "") forecast2.'measure.quantity.value' as Number else default_value,
		MODEL: if(forecast2.modelId != null and forecast2.modelId != "") forecast2.modelId else default_value,
		DUR: if(forecast2.'measure.durationInMinutes' != null and forecast2.'measure.durationInMinutes' != "") forecast2.'measure.durationInMinutes' as Number else default_value,
		FCSTID: "LDE",
		ACTIONCODE: if (forecast2.documentActionCode != null) forecast2.documentActionCode else if (vars.bulknotificationHeaders.documentActionCode != null) vars.bulknotificationHeaders.documentActionCode else "CHANGE_BY_REFRESH"
}