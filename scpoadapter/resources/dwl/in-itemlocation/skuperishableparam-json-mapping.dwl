%dw 2.0
output application/java  
var skuPerishableParamEntity = vars.entityMap.sku[0].skuperishableparam[0]
var default_value = "###JDA_DEFAULT_VALUE###"
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var conversionToSeconds=vars.codeMap."time-units-seconds-conversion"
var conversionToMinutes=vars.codeMap."time-units-minutes-conversion"
var conversionToHours=vars.codeMap."time-units-hours-conversion"
var conversionToDays=vars.codeMap."time-units-days-conversion"
var conversionToWeeks=vars.codeMap."time-units-weeks-conversion"
var conversionToMonths=vars.codeMap."time-units-months-conversion"
var conversionToYears=vars.codeMap."time-units-years-conversion"
var validTimeMeasurementCodes = ['ANN','B98','C26','C47','DAY','H70','HUR','MIN','MON','QAN','SEC','WEE','15M']
---
(payload.itemLocation map {
	  MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	  MS_REF: vars.storeMsgReference.messageReference,	
	  (INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	  MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	  MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	  SENDER: vars.bulkNotificationHeaders.sender,
	  ITEM:$.itemLocationId.item.primaryId,
	  LOC: $.itemLocationId.location.primaryId,
	  MINSHELFLIFEDUR: if($.perishableParameters.minimumShelfLifeDuration.value != null) 
						if(!isEmpty($.perishableParameters.minimumShelfLifeDuration.timeMeasurementUnitCode) and (validTimeMeasurementCodes contains upper($.perishableParameters.minimumShelfLifeDuration.timeMeasurementUnitCode))) 		   		   			
							if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil($.perishableParameters.minimumShelfLifeDuration.value * conversionToSeconds[upper($.perishableParameters.minimumShelfLifeDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil($.perishableParameters.minimumShelfLifeDuration.value * conversionToHours[upper($.perishableParameters.minimumShelfLifeDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil($.perishableParameters.minimumShelfLifeDuration.value * conversionToDays[upper($.perishableParameters.minimumShelfLifeDuration.timeMeasurementUnitCode)][0]  as Number) 
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil($.perishableParameters.minimumShelfLifeDuration.value * conversionToWeeks[upper($.perishableParameters.minimumShelfLifeDuration.timeMeasurementUnitCode)][0]  as Number) 			
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil($.perishableParameters.minimumShelfLifeDuration.value * conversionToMonths[upper($.perishableParameters.minimumShelfLifeDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil($.perishableParameters.minimumShelfLifeDuration.value * conversionToYears[upper($.perishableParameters.minimumShelfLifeDuration.timeMeasurementUnitCode)][0]  as Number)
							else 
									
										ceil($.perishableParameters.minimumShelfLifeDuration.value * conversionToMinutes[upper($.perishableParameters.minimumShelfLifeDuration.timeMeasurementUnitCode)][0] as Number)
						else 
								$.perishableParameters.minimumShelfLifeDuration.value
					else 
						default_value,				

	  MINSHIPSHELFLIFEDUR: if($.perishableParameters.minimumShipmentShelfLifeDuration.value != null) 
						if(!isEmpty($.perishableParameters.minimumShipmentShelfLifeDuration.timeMeasurementUnitCode) and (validTimeMeasurementCodes contains upper($.perishableParameters.minimumShipmentShelfLifeDuration.timeMeasurementUnitCode))) 		   		   			
							if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil($.perishableParameters.minimumShipmentShelfLifeDuration.value * conversionToSeconds[upper($.perishableParameters.minimumShipmentShelfLifeDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil($.perishableParameters.minimumShipmentShelfLifeDuration.value * conversionToHours[upper($.perishableParameters.minimumShipmentShelfLifeDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil($.perishableParameters.minimumShipmentShelfLifeDuration.value * conversionToDays[upper($.perishableParameters.minimumShipmentShelfLifeDuration.timeMeasurementUnitCode)][0]  as Number) 
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil($.perishableParameters.minimumShipmentShelfLifeDuration.value * conversionToWeeks[upper($.perishableParameters.minimumShipmentShelfLifeDuration.timeMeasurementUnitCode)][0]  as Number) 			
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil($.perishableParameters.minimumShipmentShelfLifeDuration.value * conversionToMonths[upper($.perishableParameters.minimumShipmentShelfLifeDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil($.perishableParameters.minimumShipmentShelfLifeDuration.value * conversionToYears[upper($.perishableParameters.minimumShipmentShelfLifeDuration.timeMeasurementUnitCode)][0]  as Number)
							else 
									
										ceil($.perishableParameters.minimumShipmentShelfLifeDuration.value * conversionToMinutes[$.perishableParameters.minimumShipmentShelfLifeDuration.timeMeasurementUnitCode][0] as Number)
						else 
								$.perishableParameters.minimumShipmentShelfLifeDuration.value
					else 
						default_value,				

	  SHELFLIFEDUR: if($.perishableParameters.shelfLifeDuration.value != null) 
						if(!isEmpty($.perishableParameters.shelfLifeDuration.timeMeasurementUnitCode) and (validTimeMeasurementCodes contains upper($.perishableParameters.shelfLifeDuration.timeMeasurementUnitCode))) 		   		   			
							if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil($.perishableParameters.shelfLifeDuration.value * conversionToSeconds[upper($.perishableParameters.shelfLifeDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil($.perishableParameters.shelfLifeDuration.value * conversionToHours[upper($.perishableParameters.shelfLifeDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil($.perishableParameters.shelfLifeDuration.value * conversionToDays[upper($.perishableParameters.shelfLifeDuration.timeMeasurementUnitCode)][0]  as Number) 
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil($.perishableParameters.shelfLifeDuration.value * conversionToWeeks[upper($.perishableParameters.shelfLifeDuration.timeMeasurementUnitCode)][0]  as Number) 			
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil($.perishableParameters.shelfLifeDuration.value * conversionToMonths[upper($.perishableParameters.shelfLifeDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil($.perishableParameters.shelfLifeDuration.value * conversionToYears[upper($.perishableParameters.shelfLifeDuration.timeMeasurementUnitCode)][0]  as Number)
							else 
									
										ceil($.perishableParameters.shelfLifeDuration.value * conversionToMinutes[upper($.perishableParameters.shelfLifeDuration.timeMeasurementUnitCode)][0] as Number)
						else 
								$.perishableParameters.shelfLifeDuration.value
					else 
						default_value,				


			SkuPerishableParamUDC:(flatten([(lib.getUdcNameAndValue(skuPerishableParamEntity, $.avpList, lib.getAvpListMap($.avpList) )[0]) 
	if ($.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and skuPerishableParamEntity != null
	),
	(lib.getUdcNameAndValue(skuPerishableParamEntity, $.perishableParameters.avpList, lib.getAvpListMap($.perishableParameters.avpList) )[0]) 
	if ($.perishableParameters.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and skuPerishableParamEntity != null
	)])),
	  ACTIONCODE: $.documentActionCode
})