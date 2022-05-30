%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var skudmdgroupparamEntity = vars.entityMap.skudmdgroupparam[0].skudmdgroupparam[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var conversionToSeconds=vars.codeMap."time-units-seconds-conversion"
var conversionToMinutes=vars.codeMap."time-units-minutes-conversion"
var conversionToHours=vars.codeMap."time-units-hours-conversion"
var conversionToDays=vars.codeMap."time-units-days-conversion"
var conversionToWeeks=vars.codeMap."time-units-weeks-conversion"
var conversionToMonths=vars.codeMap."time-units-months-conversion"
var conversionToYears=vars.codeMap."time-units-years-conversion"
---
flatten(payload.demandGroupParameters map(dmdgrpParams, indexDmdParams) ->  {
	
	data : (dmdgrpParams.demandGroupParameters map(dmdGroupPrams, dmdIndex)-> {
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
		INTEGRATION_STAMP: ((vars.creationDateAndTime as DateTime + ('PT' ++ indexDmdParams ++ 'S') as Period) replace 'T' with '') [0 to 17],
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		DMDCAL: if(dmdGroupPrams.demandCalendar != null) dmdGroupPrams.demandCalendar else default_value,
		DMDGROUP: dmdGroupPrams.demandGroup,
		DMDPOSTDATE: if (dmdGroupPrams.demandPostDate != null) dmdGroupPrams.demandPostDate else default_value,
		ITEM: dmdgrpParams.demandGroupParametersId.item.primaryId,
		SKULOC: dmdgrpParams.demandGroupParametersId.location.primaryId,
		ERRORPERIOD: if(dmdGroupPrams.numberOfErrorPeriods != null) dmdGroupPrams.numberOfErrorPeriods else default_value,
		FCSTLAG: if(dmdGroupPrams.forecastLag != null) dmdGroupPrams.forecastLag else default_value,
		GROUPNAME: if(dmdGroupPrams.demandGroup != null) dmdGroupPrams.demandGroup else default_value,
		HIGHERBUCKETDMDCAL: if(dmdGroupPrams.parentDemandCalendar != null) dmdGroupPrams.parentDemandCalendar else default_value,
		MINOLTDUR: if(dmdGroupPrams.minimumOrderLeadTimeDuration.value != null) 
						if(dmdGroupPrams.minimumOrderLeadTimeDuration.timeMeasurementUnitCode != null) 		   		   			
							if(lower(p("bydm.inbound.skudemandgruopparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil(dmdGroupPrams.minimumOrderLeadTimeDuration.value * conversionToSeconds[dmdGroupPrams.minimumOrderLeadTimeDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skudemandgruopparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil(dmdGroupPrams.minimumOrderLeadTimeDuration.value * conversionToHours[dmdGroupPrams.minimumOrderLeadTimeDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skudemandgruopparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil(dmdGroupPrams.minimumOrderLeadTimeDuration.value * conversionToDays[dmdGroupPrams.minimumOrderLeadTimeDuration.timeMeasurementUnitCode][0]  as Number) 
							else if(lower(p("bydm.inbound.skudemandgruopparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil(dmdGroupPrams.minimumOrderLeadTimeDuration.value * conversionToWeeks[dmdGroupPrams.minimumOrderLeadTimeDuration.timeMeasurementUnitCode][0]  as Number) 			
							else if(lower(p("bydm.inbound.skudemandgruopparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil(dmdGroupPrams.minimumOrderLeadTimeDuration.value * conversionToMonths[dmdGroupPrams.minimumOrderLeadTimeDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skudemandgruopparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil(dmdGroupPrams.minimumOrderLeadTimeDuration.value * conversionToYears[dmdGroupPrams.minimumOrderLeadTimeDuration.timeMeasurementUnitCode][0]  as Number)
							else 
									
										ceil(dmdGroupPrams.minimumOrderLeadTimeDuration.value * conversionToMinutes[dmdGroupPrams.minimumOrderLeadTimeDuration.timeMeasurementUnitCode][0] as Number)
						else 
								dmdGroupPrams.minimumOrderLeadTimeDuration.value
					else 
						default_value,				

		MAXOLTDUR:if(dmdGroupPrams.maximumOrderLeadTimeDuration.value != null) 
						if(dmdGroupPrams.maximumOrderLeadTimeDuration.timeMeasurementUnitCode != null) 		   		   			
							if(lower(p("bydm.inbound.skudemandgruopparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil(dmdGroupPrams.maximumOrderLeadTimeDuration.value * conversionToSeconds[dmdGroupPrams.maximumOrderLeadTimeDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skudemandgruopparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil(dmdGroupPrams.maximumOrderLeadTimeDuration.value * conversionToHours[dmdGroupPrams.maximumOrderLeadTimeDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skudemandgruopparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil(dmdGroupPrams.maximumOrderLeadTimeDuration.value * conversionToDays[dmdGroupPrams.maximumOrderLeadTimeDuration.timeMeasurementUnitCode][0]  as Number) 
							else if(lower(p("bydm.inbound.skudemandgruopparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil(dmdGroupPrams.maximumOrderLeadTimeDuration.value * conversionToWeeks[dmdGroupPrams.maximumOrderLeadTimeDuration.timeMeasurementUnitCode][0]  as Number) 			
							else if(lower(p("bydm.inbound.skudemandgruopparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil(dmdGroupPrams.maximumOrderLeadTimeDuration.value * conversionToMonths[dmdGroupPrams.maximumOrderLeadTimeDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skudemandgruopparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil(dmdGroupPrams.maximumOrderLeadTimeDuration.value * conversionToYears[dmdGroupPrams.maximumOrderLeadTimeDuration.timeMeasurementUnitCode][0]  as Number)
							else 
									
										ceil(dmdGroupPrams.maximumOrderLeadTimeDuration.value * conversionToMinutes[dmdGroupPrams.maximumOrderLeadTimeDuration.timeMeasurementUnitCode][0] as Number)
						else 
								dmdGroupPrams.maximumOrderLeadTimeDuration.value
					else 
						default_value,				

		OLTPROFILEID: if(dmdGroupPrams.orderLeadTimeProfileID != null) dmdGroupPrams.orderLeadTimeProfileID else 0,
		
		(SkuDmdParamUDC:(lib.getUdcNameAndValue(skudmdgroupparamEntity, dmdgrpParams.avpList, lib.getAvpListMap(dmdgrpParams.avpList))[0])) 
	if ((dmdgrpParams.documentActionCode == "ADD" or dmdgrpParams.documentActionCode == "CHANGE_BY_REFRESH")
			and skudmdgroupparamEntity != null and dmdgrpParams.avpList != null
	),
	ACTIONCODE: dmdgrpParams.documentActionCode  
	})
	
}.data)
