%dw 2.0
output application/java  
var skuSafetyStockParamEntity = vars.entityMap.sku[0].skusafetystockparam[0]
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
  MAXSS:$.safetyStockParameters.maximumSafetyStock.value,
  MINSS: $.safetyStockParameters.minimumSafetyStock.value,
  SSCOV: if($.safetyStockParameters.safetyStockCoverageDuration.value != null) 
						if($.safetyStockParameters.safetyStockCoverageDuration.timeMeasurementUnitCode != null) 		   		   			
							if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil($.safetyStockParameters.safetyStockCoverageDuration.value * conversionToSeconds[$.safetyStockParameters.safetyStockCoverageDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil($.safetyStockParameters.safetyStockCoverageDuration.value * conversionToHours[$.safetyStockParameters.safetyStockCoverageDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil($.safetyStockParameters.safetyStockCoverageDuration.value * conversionToDays[$.safetyStockParameters.safetyStockCoverageDuration.timeMeasurementUnitCode][0]  as Number) 
							else if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil($.safetyStockParameters.safetyStockCoverageDuration.value * conversionToWeeks[$.safetyStockParameters.safetyStockCoverageDuration.timeMeasurementUnitCode][0]  as Number) 			
							else if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil($.safetyStockParameters.safetyStockCoverageDuration.value * conversionToMonths[$.safetyStockParameters.safetyStockCoverageDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil($.safetyStockParameters.safetyStockCoverageDuration.value * conversionToYears[$.safetyStockParameters.safetyStockCoverageDuration.timeMeasurementUnitCode][0]  as Number)
							else 
									
										ceil($.safetyStockParameters.safetyStockCoverageDuration.value * conversionToMinutes[$.safetyStockParameters.safetyStockCoverageDuration.timeMeasurementUnitCode][0] as Number)
						else 
								$.safetyStockParameters.safetyStockCoverageDuration.value
					else 
						default_value,
  STATSSCSL: $.safetyStockParameters.safetyStockCustomerServiceLevel,
  ACCUMDUR: if($.safetyStockParameters.accumulationDuration.value != null) 
						if($.safetyStockParameters.accumulationDuration.timeMeasurementUnitCode != null) 		   		   			
							if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil($.safetyStockParameters.accumulationDuration.value * conversionToSeconds[$.safetyStockParameters.accumulationDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil($.safetyStockParameters.accumulationDuration.value * conversionToHours[$.safetyStockParameters.accumulationDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil($.safetyStockParameters.accumulationDuration.value * conversionToDays[$.safetyStockParameters.accumulationDuration.timeMeasurementUnitCode][0]  as Number) 
							else if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil($.safetyStockParameters.accumulationDuration.value * conversionToWeeks[$.safetyStockParameters.accumulationDuration.timeMeasurementUnitCode][0]  as Number) 			
							else if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil($.safetyStockParameters.accumulationDuration.value * conversionToMonths[$.safetyStockParameters.accumulationDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil($.safetyStockParameters.accumulationDuration.value * conversionToYears[$.safetyStockParameters.accumulationDuration.timeMeasurementUnitCode][0]  as Number)
							else 
									
										ceil($.safetyStockParameters.accumulationDuration.value * conversionToMinutes[$.safetyStockParameters.accumulationDuration.timeMeasurementUnitCode][0] as Number)
						else 
								$.safetyStockParameters.accumulationDuration.value
					else 
						default_value,				

  AVGLEADTIME: $.safetyStockParameters.averageReplenishmentLeadDuration.value,
  SSRULE: $.safetyStockParameters.safetyStockRuleCode,

			SkuSafetyStockParamUDC:(flatten([(lib.getUdcNameAndValue(skuSafetyStockParamEntity, $.avpList, lib.getAvpListMap($.avpList) )[0]) 
	if ($.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and skuSafetyStockParamEntity != null
	),
	(lib.getUdcNameAndValue(skuSafetyStockParamEntity, $.safetyStockParameters.avpList, lib.getAvpListMap($.safetyStockParameters.avpList) )[0]) 
	if ($.safetyStockParameters.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and skuSafetyStockParamEntity != null
	)])),
  ACTIONCODE: $.documentActionCode
})