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
  MAXSS:$.safetyStockParameters.maximumSafetyStock.value,
  MINSS: $.safetyStockParameters.minimumSafetyStock.value,
  SSCOV: if($.safetyStockParameters.safetyStockCoverageDuration.value != null) 
						if(!isEmpty($.safetyStockParameters.safetyStockCoverageDuration.timeMeasurementUnitCode) and (validTimeMeasurementCodes contains upper($.safetyStockParameters.safetyStockCoverageDuration.timeMeasurementUnitCode))) 		   		   			
							if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil($.safetyStockParameters.safetyStockCoverageDuration.value * conversionToSeconds[upper($.safetyStockParameters.safetyStockCoverageDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil($.safetyStockParameters.safetyStockCoverageDuration.value * conversionToHours[upper($.safetyStockParameters.safetyStockCoverageDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil($.safetyStockParameters.safetyStockCoverageDuration.value * conversionToDays[upper($.safetyStockParameters.safetyStockCoverageDuration.timeMeasurementUnitCode)][0]  as Number) 
							else if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil($.safetyStockParameters.safetyStockCoverageDuration.value * conversionToWeeks[upper($.safetyStockParameters.safetyStockCoverageDuration.timeMeasurementUnitCode)][0]  as Number) 			
							else if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil($.safetyStockParameters.safetyStockCoverageDuration.value * conversionToMonths[upper($.safetyStockParameters.safetyStockCoverageDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil($.safetyStockParameters.safetyStockCoverageDuration.value * conversionToYears[upper($.safetyStockParameters.safetyStockCoverageDuration.timeMeasurementUnitCode)][0]  as Number)
							else 
									
										ceil($.safetyStockParameters.safetyStockCoverageDuration.value * conversionToMinutes[upper($.safetyStockParameters.safetyStockCoverageDuration.timeMeasurementUnitCode)][0] as Number)
						else 
								$.safetyStockParameters.safetyStockCoverageDuration.value
					else 
						default_value,
  STATSSCSL: $.safetyStockParameters.safetyStockCustomerServiceLevel,
  ACCUMDUR: if($.safetyStockParameters.accumulationDuration.value != null) 
						if(!isEmpty($.safetyStockParameters.accumulationDuration.timeMeasurementUnitCode) and (validTimeMeasurementCodes contains upper($.safetyStockParameters.accumulationDuration.timeMeasurementUnitCode))) 		   		   			
							if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil($.safetyStockParameters.accumulationDuration.value * conversionToSeconds[upper($.safetyStockParameters.accumulationDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil($.safetyStockParameters.accumulationDuration.value * conversionToHours[upper($.safetyStockParameters.accumulationDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil($.safetyStockParameters.accumulationDuration.value * conversionToDays[upper($.safetyStockParameters.accumulationDuration.timeMeasurementUnitCode)][0]  as Number) 
							else if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil($.safetyStockParameters.accumulationDuration.value * conversionToWeeks[upper($.safetyStockParameters.accumulationDuration.timeMeasurementUnitCode)][0]  as Number) 			
							else if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil($.safetyStockParameters.accumulationDuration.value * conversionToMonths[upper($.safetyStockParameters.accumulationDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skusafetystockparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil($.safetyStockParameters.accumulationDuration.value * conversionToYears[upper($.safetyStockParameters.accumulationDuration.timeMeasurementUnitCode)][0]  as Number)
							else 
									
										ceil($.safetyStockParameters.accumulationDuration.value * conversionToMinutes[upper($.safetyStockParameters.accumulationDuration.timeMeasurementUnitCode)][0] as Number)
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