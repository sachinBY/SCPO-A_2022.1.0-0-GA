%dw 2.0
output application/java  
var skuPlanningParamEntity = vars.entityMap.sku[0].skuplanningparam[0]
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
		  ITEM: $.itemLocationId.item.primaryId,
		  LOC: $.itemLocationId.location.primaryId,
		  BUFFERLEADTIME: if($.planningParameters.supplyLeadBufferDuration.value != null) 
						if(!isEmpty($.planningParameters.supplyLeadBufferDuration.timeMeasurementUnitCode) and (validTimeMeasurementCodes contains upper($.planningParameters.supplyLeadBufferDuration.timeMeasurementUnitCode))) 		   		   			
							if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil($.planningParameters.supplyLeadBufferDuration.value * conversionToSeconds[upper($.planningParameters.supplyLeadBufferDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil($.planningParameters.supplyLeadBufferDuration.value * conversionToHours[upper($.planningParameters.supplyLeadBufferDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil($.planningParameters.supplyLeadBufferDuration.value * conversionToDays[upper($.planningParameters.supplyLeadBufferDuration.timeMeasurementUnitCode)][0]  as Number) 
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil($.planningParameters.supplyLeadBufferDuration.value * conversionToWeeks[upper($.planningParameters.supplyLeadBufferDuration.timeMeasurementUnitCode)][0]  as Number) 			
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil($.planningParameters.supplyLeadBufferDuration.value * conversionToMonths[upper($.planningParameters.supplyLeadBufferDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil($.planningParameters.supplyLeadBufferDuration.value * conversionToYears[upper($.planningParameters.supplyLeadBufferDuration.timeMeasurementUnitCode)][0]  as Number)
							else 
									
										ceil($.planningParameters.supplyLeadBufferDuration.value * conversionToMinutes[upper($.planningParameters.supplyLeadBufferDuration.timeMeasurementUnitCode)][0] as Number)
						else 
								$.planningParameters.supplyLeadBufferDuration.value
					else 
						default_value,				

		  DRPFRZDUR: if($.planningParameters.receiptFrozenDuration.value != null) 
						if(!isEmpty($.planningParameters.receiptFrozenDuration.timeMeasurementUnitCode) and (validTimeMeasurementCodes contains upper($.planningParameters.receiptFrozenDuration.timeMeasurementUnitCode))) 		   		   			
							if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil($.planningParameters.receiptFrozenDuration.value * conversionToSeconds[upper($.planningParameters.receiptFrozenDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil($.planningParameters.receiptFrozenDuration.value * conversionToHours[upper($.planningParameters.receiptFrozenDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil($.planningParameters.receiptFrozenDuration.value * conversionToDays[upper($.planningParameters.receiptFrozenDuration.timeMeasurementUnitCode)][0]  as Number) 
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil($.planningParameters.receiptFrozenDuration.value * conversionToWeeks[upper($.planningParameters.receiptFrozenDuration.timeMeasurementUnitCode)][0]  as Number) 			
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil($.planningParameters.receiptFrozenDuration.value * conversionToMonths[upper($.planningParameters.receiptFrozenDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil($.planningParameters.receiptFrozenDuration.value * conversionToYears[upper($.planningParameters.receiptFrozenDuration.timeMeasurementUnitCode)][0]  as Number)
							else 
									
										ceil($.planningParameters.receiptFrozenDuration.value * conversionToMinutes[upper($.planningParameters.receiptFrozenDuration.timeMeasurementUnitCode)][0] as Number)
						else 
								$.planningParameters.receiptFrozenDuration.value
					else 
						default_value,				

		  HOLDINGCOST: $.planningParameters.holdingCost.value,
		  INCDRPQTY: $.planningParameters.incrementalDRPQuantity.value,
		  INCMPSQTY: $.planningParameters.incrementalMPSQuantity.value,
		  INHANDLINGCOST: $.planningParameters.receivingHandlingCost.value,
		  MAXOH: $.planningParameters.maximumOnHandQuantity.value,
		  MFGFRZDUR: if($.planningParameters.manufactureDuration.value != null) 
						if(!isEmpty($.planningParameters.manufactureDuration.timeMeasurementUnitCode) and (validTimeMeasurementCodes contains upper($.planningParameters.manufactureDuration.timeMeasurementUnitCode))) 		   		   			
							if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil($.planningParameters.manufactureDuration.value * conversionToSeconds[upper($.planningParameters.manufactureDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil($.planningParameters.manufactureDuration.value * conversionToHours[upper($.planningParameters.manufactureDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil($.planningParameters.manufactureDuration.value * conversionToDays[upper($.planningParameters.manufactureDuration.timeMeasurementUnitCode)][0]  as Number) 
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil($.planningParameters.manufactureDuration.value * conversionToWeeks[upper($.planningParameters.manufactureDuration.timeMeasurementUnitCode)][0]  as Number) 			
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil($.planningParameters.manufactureDuration.value * conversionToMonths[upper($.planningParameters.manufactureDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil($.planningParameters.manufactureDuration.value * conversionToYears[upper($.planningParameters.manufactureDuration.timeMeasurementUnitCode)][0]  as Number)
							else 
									
										ceil($.planningParameters.manufactureDuration.value * conversionToMinutes[upper($.planningParameters.manufactureDuration.timeMeasurementUnitCode)][0] as Number)
						else 
								$.planningParameters.manufactureDuration.value
					else 
						default_value,				

		  MFGLEADTIME: if($.planningParameters.manufactureLeadTimeDuration.value != null)
		  					if(!isEmpty($.planningParameters.manufactureLeadTimeDuration.timeMeasurementUnitCode) and (validTimeMeasurementCodes contains upper($.planningParameters.manufactureLeadTimeDuration.timeMeasurementUnitCode)))
		  						if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "sec")
		  							ceil($.planningParameters.manufactureLeadTimeDuration.value * conversionToSeconds[upper($.planningParameters.manufactureLeadTimeDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "hour") 
									ceil($.planningParameters.manufactureLeadTimeDuration.value * conversionToHours[upper($.planningParameters.manufactureLeadTimeDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "day") 
									ceil($.planningParameters.manufactureLeadTimeDuration.value * conversionToDays[upper($.planningParameters.manufactureLeadTimeDuration.timeMeasurementUnitCode)][0]  as Number) 
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "week") 
									ceil($.planningParameters.manufactureLeadTimeDuration.value * conversionToWeeks[upper($.planningParameters.manufactureLeadTimeDuration.timeMeasurementUnitCode)][0]  as Number) 			
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "month") 
									ceil($.planningParameters.manufactureLeadTimeDuration.value * conversionToMonths[upper($.planningParameters.manufactureLeadTimeDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "year") 
									ceil($.planningParameters.manufactureLeadTimeDuration.value * conversionToYears[upper($.planningParameters.manufactureLeadTimeDuration.timeMeasurementUnitCode)][0]  as Number)
							else 
									ceil($.planningParameters.manufactureLeadTimeDuration.value * conversionToMinutes[upper($.planningParameters.manufactureLeadTimeDuration.timeMeasurementUnitCode)][0] as Number)
						else 
								$.planningParameters.manufactureLeadTimeDuration.value
					else 
						default_value,
		  MINDRPQTY: $.planningParameters.minimumDRPQuantity.value,
		  MINMPSQTY: $.planningParameters.minimumMPSQuantity.value,
		  OUTHANDLINGCOST: $.planningParameters.shippingHandlingCost.value,
		  SHRINKAGEFACTOR: if($.planningParameters.shrinkageFactor != null) 
		  					ceil($.planningParameters.shrinkageFactor) else null,
		  MPSCOVDUR: if($.planningParameters.supplyCoverageDuration.value != null) 
						if(!isEmpty($.planningParameters.supplyCoverageDuration.timeMeasurementUnitCode) and (validTimeMeasurementCodes contains upper($.planningParameters.supplyCoverageDuration.timeMeasurementUnitCode))) 		   		   			
							if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil($.planningParameters.supplyCoverageDuration.value * conversionToSeconds[upper($.planningParameters.supplyCoverageDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil($.planningParameters.supplyCoverageDuration.value * conversionToHours[upper($.planningParameters.supplyCoverageDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil($.planningParameters.supplyCoverageDuration.value * conversionToDays[upper($.planningParameters.supplyCoverageDuration.timeMeasurementUnitCode)][0]  as Number) 
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil($.planningParameters.supplyCoverageDuration.value * conversionToWeeks[upper($.planningParameters.supplyCoverageDuration.timeMeasurementUnitCode)][0]  as Number) 			
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil($.planningParameters.supplyCoverageDuration.value * conversionToMonths[upper($.planningParameters.supplyCoverageDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil($.planningParameters.supplyCoverageDuration.value * conversionToYears[upper($.planningParameters.supplyCoverageDuration.timeMeasurementUnitCode)][0]  as Number)
							else 
									
										ceil($.planningParameters.supplyCoverageDuration.value * conversionToMinutes[upper($.planningParameters.supplyCoverageDuration.timeMeasurementUnitCode)][0] as Number)
						else 
								$.planningParameters.supplyCoverageDuration.value
					else 
						default_value,				

		  ORDERINGCOST: $.planningParameters.orderingCost.value,
		  DRPCOVDUR: if($.planningParameters.receiptCoverageDuration.value != null) 
						if(!isEmpty($.planningParameters.receiptCoverageDuration.timeMeasurementUnitCode) and (validTimeMeasurementCodes contains upper($.planningParameters.receiptCoverageDuration.timeMeasurementUnitCode))) 		   		   			
							if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil($.planningParameters.receiptCoverageDuration.value * conversionToSeconds[upper($.planningParameters.receiptCoverageDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil($.planningParameters.receiptCoverageDuration.value * conversionToHours[upper($.planningParameters.receiptCoverageDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil($.planningParameters.receiptCoverageDuration.value * conversionToDays[upper($.planningParameters.receiptCoverageDuration.timeMeasurementUnitCode)][0]  as Number) 
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil($.planningParameters.receiptCoverageDuration.value * conversionToWeeks[upper($.planningParameters.receiptCoverageDuration.timeMeasurementUnitCode)][0]  as Number) 			
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil($.planningParameters.receiptCoverageDuration.value * conversionToMonths[upper($.planningParameters.receiptCoverageDuration.timeMeasurementUnitCode)][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil($.planningParameters.receiptCoverageDuration.value * conversionToYears[upper($.planningParameters.receiptCoverageDuration.timeMeasurementUnitCode)][0]  as Number)
							else 
									
										ceil($.planningParameters.receiptCoverageDuration.value * conversionToMinutes[upper($.planningParameters.receiptCoverageDuration.timeMeasurementUnitCode)][0] as Number)
						else 
								$.planningParameters.receiptCoverageDuration.value
					else 
						default_value,				


		SkuPlanningParamUDC:(flatten([(lib.getUdcNameAndValue(skuPlanningParamEntity, $.avpList, lib.getAvpListMap($.avpList) )[0]) 
	if ($.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and skuPlanningParamEntity != null
	),
	(lib.getUdcNameAndValue(skuPlanningParamEntity, $.planningParameters.avpList, lib.getAvpListMap($.planningParameters.avpList) )[0]) 
	if ($.planningParameters.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and skuPlanningParamEntity != null
	)])),
  		ACTIONCODE: $.documentActionCode
})