%dw 2.0
var default_value = "###JDA_DEFAULT_VALUE###"
var forecastEntity = vars.entityMap.fcst[0].fcst[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
import * from dw::Runtime
output application/java
---
flatten(flatten(payload.forecast2 map (forecast2,forecast2index) -> { 
    conversion: forecast2.measure map(measure,measureindex) ->
    {
    	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference, 
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((forecast2index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		DMDUNIT: forecast2.itemId,
		DMDGROUP: if(forecast2.demandChannel != null and forecast2.demandChannel != "") forecast2.demandChannel else "*UNKNOWN",
		LOC: forecast2.locationId,
		STARTDATE: (measure.forecastStartDate replace "Z" with ("")) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"},
		TYPE: if(forecast2.forecastTypeCode != null and forecast2.forecastTypeCode != "") forecast2.forecastTypeCode else 1,
		QTY: if(measure.quantity.value != null and measure.quantity.value != "") measure.quantity.value as Number else default_value,
		MODEL: if(forecast2.modelId != null and forecast2.modelId != "") forecast2.modelId else default_value,
		DUR: if(measure.durationInMinutes != null and measure.durationInMinutes != "") measure.durationInMinutes as Number else default_value,
		FCSTID: forecast2.forecastId default "LDE",
		(FCSTUDC: (lib.getUdcNameAndValue(forecastEntity, forecast2.avpList, lib.getAvpListMap(forecast2.avpList))[0])
 	) 
  			if (forecast2.avpList != null 
  			and forecastEntity != null),
		ACTIONCODE: forecast2.documentActionCode default "CHANGE_BY_REFRESH"
    }
}pluck($)))