%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
var resourceEntity = vars.entityMap.resource[0].res[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var conversionToSeconds=vars.codeMap."time-units-seconds-conversion"
var conversionToMinutes=vars.codeMap."time-units-minutes-conversion"
var conversionToHours=vars.codeMap."time-units-hours-conversion"
var conversionToDays=vars.codeMap."time-units-days-conversion"
var conversionToWeeks=vars.codeMap."time-units-weeks-conversion"
var conversionToMonths=vars.codeMap."time-units-months-conversion"
var conversionToYears=vars.codeMap."time-units-years-conversion"
---
flatten (flatten (payload.resource map(res , index) ->{
			
			(avplistResUDCS:(lib.getUdcNameAndValue(resourceEntity, res.avpList, lib.getAvpListMap(res.avpList))[0])) if (res.avpList != null 
				and (res.documentActionCode == "ADD" or res.documentActionCode == "CHANGE_BY_REFRESH")
				and resourceEntity != null
			),
			MS_BULK_REF: vars.storeHeaderReference.bulkReference,
			MS_REF: vars.storeMsgReference.messageReference,	
			ADJFACTOR: if(res.productionAdjustmentFactor != null) (res.productionAdjustmentFactor/100) as Number else default_value,
			(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
			MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  			MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  			SENDER: vars.bulkNotificationHeaders.sender,
			ADDONCOST: if(res.resourceAdditionalCost.value != null) res.resourceAdditionalCost.value else default_value,
			CHECKMAXCAP: if(res.capacityConstraintType != null and res.capacityConstraintType != "") res.capacityConstraintType else default_value,
			COST: if(res.resourceCost.value != null) res.resourceCost.value else default_value,
			CURRENCYUOM: if(res.resourceCost.currencyCode != null) 
							if ( vars.uomShortLabels[res.resourceCost.currencyCode][0] != null ) 					
								vars.uomShortLabels[res.resourceCost.currencyCode][0] as Number
							else 
								default_value 
						 else 
						    default_value,
			DESCR_RES: if(res.description.value != null) res.description.value else default_value,
			ENABLEOPT: if(res.businessInstanceId != null) res.businessInstanceId else default_value,
			LEVELLOADSW: if(res.isLoadLevelRequired != null) 
							if(res.isLoadLevelRequired == true) 
								1 as Number 
							else 
								0 as Number
						else default_value,
			LEVELSEQNUM: if(res.levelSequenceNumber != null) res.levelSequenceNumber else default_value,
			LOC: if(res.resourceLocation.primaryId != null) res.resourceLocation.primaryId else default_value,
			
			QTYUOM:  if (res.resourceUnitOfMeasure != null)
						if ( vars.uomShortLabels[res.resourceUnitOfMeasure][0] != null ) 					
							vars.uomShortLabels[res.resourceUnitOfMeasure][0] as Number
						else 
							default_value
					else 
							default_value,
			
			(RES: res.resourceId) if(res.resourceId != null),
			TYPE_RES: if(res.resourceCategory != null) res.resourceCategory else default_value,
			(CAL: res.resourceCalendar.calendarId) if(res.resourceCalendar.calendarId != null),
			
			SHIFTSIZE: if(res.shiftDuration.value != null) 
						if(res.shiftDuration.timeMeasurementUnitCode != null) 		   		   			
							if(lower(p("bydm.inbound.resource.timemeasurementunitcode")) startsWith "sec") 
									
										ceil(res.shiftDuration.value * conversionToSeconds[res.shiftDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.resource.timemeasurementunitcode")) startsWith "hour") 
									
										ceil(res.shiftDuration.value * conversionToHours[res.shiftDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.resource.timemeasurementunitcode")) startsWith "day") 
									
										ceil(res.shiftDuration.value * conversionToDays[res.shiftDuration.timeMeasurementUnitCode][0]  as Number) 
							else if(lower(p("bydm.inbound.resource.timemeasurementunitcode")) startsWith "week") 
									
										ceil(res.shiftDuration.value * conversionToWeeks[res.shiftDuration.timeMeasurementUnitCode][0]  as Number) 			
							else if(lower(p("bydm.inbound.resource.timemeasurementunitcode")) startsWith "month") 
									
										ceil(res.shiftDuration.value * conversionToMonths[res.shiftDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.resource.timemeasurementunitcode")) startsWith "year") 
									
										ceil(res.shiftDuration.value * conversionToYears[res.shiftDuration.timeMeasurementUnitCode][0]  as Number)
							else 
									
										ceil(res.shiftDuration.value * conversionToMinutes[res.shiftDuration.timeMeasurementUnitCode][0] as Number)
						else 
								res.shiftDuration.value
					else 
						default_value,				
			ACTIONCODE: res.documentActionCode
		}))
