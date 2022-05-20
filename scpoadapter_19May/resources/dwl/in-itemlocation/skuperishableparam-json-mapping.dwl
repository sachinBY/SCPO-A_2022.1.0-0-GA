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
						if($.perishableParameters.minimumShelfLifeDuration.timeMeasurementUnitCode != null) 		   		   			
							if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil($.perishableParameters.minimumShelfLifeDuration.value * conversionToSeconds[$.perishableParameters.minimumShelfLifeDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil($.perishableParameters.minimumShelfLifeDuration.value * conversionToHours[$.perishableParameters.minimumShelfLifeDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil($.perishableParameters.minimumShelfLifeDuration.value * conversionToDays[$.perishableParameters.minimumShelfLifeDuration.timeMeasurementUnitCode][0]  as Number) 
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil($.perishableParameters.minimumShelfLifeDuration.value * conversionToWeeks[$.perishableParameters.minimumShelfLifeDuration.timeMeasurementUnitCode][0]  as Number) 			
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil($.perishableParameters.minimumShelfLifeDuration.value * conversionToMonths[$.perishableParameters.minimumShelfLifeDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil($.perishableParameters.minimumShelfLifeDuration.value * conversionToYears[$.perishableParameters.minimumShelfLifeDuration.timeMeasurementUnitCode][0]  as Number)
							else 
									
										ceil($.perishableParameters.minimumShelfLifeDuration.value * conversionToMinutes[$.perishableParameters.minimumShelfLifeDuration.timeMeasurementUnitCode][0] as Number)
						else 
								$.perishableParameters.minimumShelfLifeDuration.value
					else 
						default_value,				

	  MINSHIPSHELFLIFEDUR: if($.perishableParameters.minimumShipmentShelfLifeDuration.value != null) 
						if($.perishableParameters.minimumShipmentShelfLifeDuration.timeMeasurementUnitCode != null) 		   		   			
							if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil($.perishableParameters.minimumShipmentShelfLifeDuration.value * conversionToSeconds[$.perishableParameters.minimumShipmentShelfLifeDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil($.perishableParameters.minimumShipmentShelfLifeDuration.value * conversionToHours[$.perishableParameters.minimumShipmentShelfLifeDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil($.perishableParameters.minimumShipmentShelfLifeDuration.value * conversionToDays[$.perishableParameters.minimumShipmentShelfLifeDuration.timeMeasurementUnitCode][0]  as Number) 
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil($.perishableParameters.minimumShipmentShelfLifeDuration.value * conversionToWeeks[$.perishableParameters.minimumShipmentShelfLifeDuration.timeMeasurementUnitCode][0]  as Number) 			
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil($.perishableParameters.minimumShipmentShelfLifeDuration.value * conversionToMonths[$.perishableParameters.minimumShipmentShelfLifeDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil($.perishableParameters.minimumShipmentShelfLifeDuration.value * conversionToYears[$.perishableParameters.minimumShipmentShelfLifeDuration.timeMeasurementUnitCode][0]  as Number)
							else 
									
										ceil($.perishableParameters.minimumShipmentShelfLifeDuration.value * conversionToMinutes[$.perishableParameters.minimumShipmentShelfLifeDuration.timeMeasurementUnitCode][0] as Number)
						else 
								$.perishableParameters.minimumShipmentShelfLifeDuration.value
					else 
						default_value,				

	  SHELFLIFEDUR: if($.perishableParameters.shelfLifeDuration.value != null) 
						if($.perishableParameters.shelfLifeDuration.timeMeasurementUnitCode != null) 		   		   			
							if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil($.perishableParameters.shelfLifeDuration.value * conversionToSeconds[$.perishableParameters.shelfLifeDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil($.perishableParameters.shelfLifeDuration.value * conversionToHours[$.perishableParameters.shelfLifeDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil($.perishableParameters.shelfLifeDuration.value * conversionToDays[$.perishableParameters.shelfLifeDuration.timeMeasurementUnitCode][0]  as Number) 
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil($.perishableParameters.shelfLifeDuration.value * conversionToWeeks[$.perishableParameters.shelfLifeDuration.timeMeasurementUnitCode][0]  as Number) 			
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil($.perishableParameters.shelfLifeDuration.value * conversionToMonths[$.perishableParameters.shelfLifeDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuperishableparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil($.perishableParameters.shelfLifeDuration.value * conversionToYears[$.perishableParameters.shelfLifeDuration.timeMeasurementUnitCode][0]  as Number)
							else 
									
										ceil($.perishableParameters.shelfLifeDuration.value * conversionToMinutes[$.perishableParameters.shelfLifeDuration.timeMeasurementUnitCode][0] as Number)
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