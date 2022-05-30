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
						if(!isEmpty($.planningParameters.supplyLeadBufferDuration.timeMeasurementUnitCode)) 		   		   			
							if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil($.planningParameters.supplyLeadBufferDuration.value * conversionToSeconds[$.planningParameters.supplyLeadBufferDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil($.planningParameters.supplyLeadBufferDuration.value * conversionToHours[$.planningParameters.supplyLeadBufferDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil($.planningParameters.supplyLeadBufferDuration.value * conversionToDays[$.planningParameters.supplyLeadBufferDuration.timeMeasurementUnitCode][0]  as Number) 
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil($.planningParameters.supplyLeadBufferDuration.value * conversionToWeeks[$.planningParameters.supplyLeadBufferDuration.timeMeasurementUnitCode][0]  as Number) 			
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil($.planningParameters.supplyLeadBufferDuration.value * conversionToMonths[$.planningParameters.supplyLeadBufferDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil($.planningParameters.supplyLeadBufferDuration.value * conversionToYears[$.planningParameters.supplyLeadBufferDuration.timeMeasurementUnitCode][0]  as Number)
							else 
									
										ceil($.planningParameters.supplyLeadBufferDuration.value * conversionToMinutes[$.planningParameters.supplyLeadBufferDuration.timeMeasurementUnitCode][0] as Number)
						else 
								$.planningParameters.supplyLeadBufferDuration.value
					else 
						default_value,				

		  DRPFRZDUR: if($.planningParameters.receiptFrozenDuration.value != null) 
						if(!isEmpty($.planningParameters.receiptFrozenDuration.timeMeasurementUnitCode)) 		   		   			
							if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil($.planningParameters.receiptFrozenDuration.value * conversionToSeconds[$.planningParameters.receiptFrozenDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil($.planningParameters.receiptFrozenDuration.value * conversionToHours[$.planningParameters.receiptFrozenDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil($.planningParameters.receiptFrozenDuration.value * conversionToDays[$.planningParameters.receiptFrozenDuration.timeMeasurementUnitCode][0]  as Number) 
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil($.planningParameters.receiptFrozenDuration.value * conversionToWeeks[$.planningParameters.receiptFrozenDuration.timeMeasurementUnitCode][0]  as Number) 			
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil($.planningParameters.receiptFrozenDuration.value * conversionToMonths[$.planningParameters.receiptFrozenDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil($.planningParameters.receiptFrozenDuration.value * conversionToYears[$.planningParameters.receiptFrozenDuration.timeMeasurementUnitCode][0]  as Number)
							else 
									
										ceil($.planningParameters.receiptFrozenDuration.value * conversionToMinutes[$.planningParameters.receiptFrozenDuration.timeMeasurementUnitCode][0] as Number)
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
						if(!isEmpty($.planningParameters.manufactureDuration.timeMeasurementUnitCode)) 		   		   			
							if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil($.planningParameters.manufactureDuration.value * conversionToSeconds[$.planningParameters.manufactureDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil($.planningParameters.manufactureDuration.value * conversionToHours[$.planningParameters.manufactureDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil($.planningParameters.manufactureDuration.value * conversionToDays[$.planningParameters.manufactureDuration.timeMeasurementUnitCode][0]  as Number) 
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil($.planningParameters.manufactureDuration.value * conversionToWeeks[$.planningParameters.manufactureDuration.timeMeasurementUnitCode][0]  as Number) 			
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil($.planningParameters.manufactureDuration.value * conversionToMonths[$.planningParameters.manufactureDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil($.planningParameters.manufactureDuration.value * conversionToYears[$.planningParameters.manufactureDuration.timeMeasurementUnitCode][0]  as Number)
							else 
									
										ceil($.planningParameters.manufactureDuration.value * conversionToMinutes[$.planningParameters.manufactureDuration.timeMeasurementUnitCode][0] as Number)
						else 
								$.planningParameters.manufactureDuration.value
					else 
						default_value,				

		  MFGLEADTIME: if($.planningParameters.manufactureLeadTimeDuration.value != null)
		  					if(!isEmpty($.planningParameters.manufactureLeadTimeDuration.timeMeasurementUnitCode))
		  						if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "sec")
		  							ceil($.planningParameters.manufactureLeadTimeDuration.value * conversionToSeconds[$.planningParameters.manufactureLeadTimeDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "hour") 
									ceil($.planningParameters.manufactureLeadTimeDuration.value * conversionToHours[$.planningParameters.manufactureLeadTimeDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "day") 
									ceil($.planningParameters.manufactureLeadTimeDuration.value * conversionToDays[$.planningParameters.manufactureLeadTimeDuration.timeMeasurementUnitCode][0]  as Number) 
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "week") 
									ceil($.planningParameters.manufactureLeadTimeDuration.value * conversionToWeeks[$.planningParameters.manufactureLeadTimeDuration.timeMeasurementUnitCode][0]  as Number) 			
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "month") 
									ceil($.planningParameters.manufactureLeadTimeDuration.value * conversionToMonths[$.planningParameters.manufactureLeadTimeDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "year") 
									ceil($.planningParameters.manufactureLeadTimeDuration.value * conversionToYears[$.planningParameters.manufactureLeadTimeDuration.timeMeasurementUnitCode][0]  as Number)
							else 
									ceil($.planningParameters.manufactureLeadTimeDuration.value * conversionToMinutes[$.planningParameters.manufactureLeadTimeDuration.timeMeasurementUnitCode][0] as Number)
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
						if(!isEmpty($.planningParameters.supplyCoverageDuration.timeMeasurementUnitCode)) 		   		   			
							if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil($.planningParameters.supplyCoverageDuration.value * conversionToSeconds[$.planningParameters.supplyCoverageDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil($.planningParameters.supplyCoverageDuration.value * conversionToHours[$.planningParameters.supplyCoverageDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil($.planningParameters.supplyCoverageDuration.value * conversionToDays[$.planningParameters.supplyCoverageDuration.timeMeasurementUnitCode][0]  as Number) 
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil($.planningParameters.supplyCoverageDuration.value * conversionToWeeks[$.planningParameters.supplyCoverageDuration.timeMeasurementUnitCode][0]  as Number) 			
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil($.planningParameters.supplyCoverageDuration.value * conversionToMonths[$.planningParameters.supplyCoverageDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil($.planningParameters.supplyCoverageDuration.value * conversionToYears[$.planningParameters.supplyCoverageDuration.timeMeasurementUnitCode][0]  as Number)
							else 
									
										ceil($.planningParameters.supplyCoverageDuration.value * conversionToMinutes[$.planningParameters.supplyCoverageDuration.timeMeasurementUnitCode][0] as Number)
						else 
								$.planningParameters.supplyCoverageDuration.value
					else 
						default_value,				

		  ORDERINGCOST: $.planningParameters.orderingCost.value,
		  DRPCOVDUR: if($.planningParameters.receiptCoverageDuration.value != null) 
						if(!isEmpty($.planningParameters.receiptCoverageDuration.timeMeasurementUnitCode)) 		   		   			
							if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil($.planningParameters.receiptCoverageDuration.value * conversionToSeconds[$.planningParameters.receiptCoverageDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil($.planningParameters.receiptCoverageDuration.value * conversionToHours[$.planningParameters.receiptCoverageDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil($.planningParameters.receiptCoverageDuration.value * conversionToDays[$.planningParameters.receiptCoverageDuration.timeMeasurementUnitCode][0]  as Number) 
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil($.planningParameters.receiptCoverageDuration.value * conversionToWeeks[$.planningParameters.receiptCoverageDuration.timeMeasurementUnitCode][0]  as Number) 			
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil($.planningParameters.receiptCoverageDuration.value * conversionToMonths[$.planningParameters.receiptCoverageDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skuplanningparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil($.planningParameters.receiptCoverageDuration.value * conversionToYears[$.planningParameters.receiptCoverageDuration.timeMeasurementUnitCode][0]  as Number)
							else 
									
										ceil($.planningParameters.receiptCoverageDuration.value * conversionToMinutes[$.planningParameters.receiptCoverageDuration.timeMeasurementUnitCode][0] as Number)
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