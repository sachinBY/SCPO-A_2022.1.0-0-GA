%dw 2.0
output application/java  
var skuEffInventoryParamEntity = vars.entityMap.sku[0].skueffinventoryparam[0]
var default_value = "###JDA_DEFAULT_VALUE###"
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var conversionToSeconds=vars.codeMap."time-units-seconds-conversion"
var conversionToMinutes=vars.codeMap."time-units-minutes-conversion"
var conversionToHours=vars.codeMap."time-units-hours-conversion"
var conversionToDays=vars.codeMap."time-units-days-conversion"
var conversionToWeeks=vars.codeMap."time-units-weeks-conversion"
var conversionToMonths=vars.codeMap."time-units-months-conversion"
var conversionToYears=vars.codeMap."time-units-years-conversion"
---
(payload.itemLocation map {
(if($.effectiveInventoryParameters != null) {
arr:($.effectiveInventoryParameters map(EFF,index)->{
	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference,	
	(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	SENDER: vars.bulkNotificationHeaders.sender,
    ITEM:$.itemLocationId.item.primaryId,
    LOC:$.itemLocationId.location.primaryId,
    EFF:EFF.effectiveFromDateTime,
    MAXOHQTY:EFF.maximumOnHandQuantity.value,
	MINSSQTY:EFF.minimumSafetyStockQuantity.value,
	SSCOVDUR:if(EFF.safetyStockCoverageDuration.value != null) 
						if(!isEmpty(EFF.safetyStockCoverageDuration.timeMeasurementUnitCode)) 		   		   			
							if(lower(p("bydm.inbound.skueffinventoryparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil(EFF.safetyStockCoverageDuration.value * conversionToSeconds[EFF.safetyStockCoverageDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skueffinventoryparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil(EFF.safetyStockCoverageDuration.value * conversionToHours[EFF.safetyStockCoverageDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skueffinventoryparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil(EFF.safetyStockCoverageDuration.value * conversionToDays[EFF.safetyStockCoverageDuration.timeMeasurementUnitCode][0]  as Number) 
							else if(lower(p("bydm.inbound.skueffinventoryparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil(EFF.safetyStockCoverageDuration.value * conversionToWeeks[EFF.safetyStockCoverageDuration.timeMeasurementUnitCode][0]  as Number) 			
							else if(lower(p("bydm.inbound.skueffinventoryparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil(EFF.safetyStockCoverageDuration.value * conversionToMonths[EFF.safetyStockCoverageDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skueffinventoryparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil(EFF.safetyStockCoverageDuration.value * conversionToYears[EFF.safetyStockCoverageDuration.timeMeasurementUnitCode][0]  as Number)
							else 
									
										ceil(EFF.safetyStockCoverageDuration.value * conversionToMinutes[EFF.safetyStockCoverageDuration.timeMeasurementUnitCode][0] as Number)
						else 
								EFF.safetyStockCoverageDuration.value
					else 
						default_value,				

	SkuEffInventoryParamUDC:(flatten([(lib.getUdcNameAndValue(skuEffInventoryParamEntity, $.avpList, lib.getAvpListMap($.avpList) )[0]) 
	if ($.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and skuEffInventoryParamEntity != null
	),
	(lib.getUdcNameAndValue(skuEffInventoryParamEntity, $.effectiveInventoryParameters.avpList, lib.getAvpListMap($.effectiveInventoryParameters.avpList) )[0]) 
	if ($.effectiveInventoryParameters.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and skuEffInventoryParamEntity != null
	)])),
	ACTIONCODE: $.documentActionCode
})}
else 
{
arr:[{(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference,	
	ITEM:$.itemLocationId.item.primaryId,
    LOC:$.itemLocationId.location.primaryId,
	SkuEffInventoryParamUDC:(flatten([(lib.getUdcNameAndValue(skuEffInventoryParamEntity, $.avpList, lib.getAvpListMap($.avpList) )[0]) 
	if ($.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and skuEffInventoryParamEntity != null
	)])),
	ACTIONCODE: $.documentActionCode}]})
}).arr reduce($ ++ $$)