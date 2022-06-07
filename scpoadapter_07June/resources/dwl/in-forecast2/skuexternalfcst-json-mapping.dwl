%dw 2.0
var default_value = "###JDA_DEFAULT_VALUE###"
var forecastEntity = vars.entityMap.fcst[0].skuexternalfcst[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
output application/java  
---
flatten(payload.forecast2 map ((forecast2,forecast2index) ->
  forecast2.measure map ((measure,measureindex) ->
  {
  	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference,
	(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((forecast2index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	SENDER: vars.bulkNotificationHeaders.sender,
    STARTDATE: if(!isEmpty(measure.forecastStartDate)) (measure.forecastStartDate replace "Z" with ("")) as Date {format: "yyyy-MM-dd", class: "java.sql.Date"} else default_value,
    DUR: if(measure.durationInMinutes != null and measure.durationInMinutes != "") measure.durationInMinutes as Number else default_value,
    QTY: if(measure.quantity.value != null and measure.quantity.value != "") measure.quantity.value as Number else default_value,
    ITEM: forecast2.itemId,
    LOC: forecast2.locationId,
    PROJECT: if(forecast2.project != null and forecast2.project != "") forecast2.project else default_value,
    ACTIONCODE: forecast2.documentActionCode default "CHANGE_BY_REFRESH",
    	(FCSTUDC: (lib.getUdcNameAndValue(forecastEntity, forecast2.avpList, lib.getAvpListMap(forecast2.avpList))[0])
 	) 
  			if (forecast2.avpList != null 
  			and forecastEntity != null),
	 }
)))