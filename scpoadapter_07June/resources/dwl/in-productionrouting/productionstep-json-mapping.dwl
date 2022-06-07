%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var productionStepEntity = vars.entityMap.productionrouting[0].productionstep[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var conversionToSeconds=vars.codeMap."time-units-seconds-conversion"
var conversionToMinutes=vars.codeMap."time-units-minutes-conversion"
var conversionToHours=vars.codeMap."time-units-hours-conversion"
var conversionToDays=vars.codeMap."time-units-days-conversion"
var conversionToWeeks=vars.codeMap."time-units-weeks-conversion"
var conversionToMonths=vars.codeMap."time-units-months-conversion"
var conversionToYears=vars.codeMap."time-units-years-conversion"
---
flatten(flatten(flatten(payload.productionRouting default [] map (productionRouting, productionRoutingIndex) -> {
	steps:(productionRouting.productionRoutingOperation map (productionstep, productionstepIndex) -> {
		val:(productionstep.productionResource map(item,index)->{
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,	
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((productionRoutingIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		STEPNUM: if (productionstep.operationNumber != null) productionstep.operationNumber as Number else default_value,
		RES: if (item.resourceId != null) item.resourceId else default_value,
		EFF: if (productionRouting.effectiveFromDate != null) (productionRouting.effectiveFromDate replace 'Z' with ('')) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
		PRODRATE: if (item.resourceCapacityUsageRate != null) item.resourceCapacityUsageRate as Number else default_value,
		FIXEDRESREQ: if (productionstep.fixedResourceRequirement != null) productionstep.fixedResourceRequirement as Number else default_value,
		DESCR: if (productionstep.description != null) productionstep.description else default_value,
		NEXTSTEPTIMING: if (productionstep.nextOperationTiming != null) productionstep.nextOperationTiming as Number else default_value,
		PRODCOST: if (productionstep.itemUnitOperationCost != null) productionstep.itemUnitOperationCost as Number else default_value,
		PRODDUR: if(productionstep.operationDuration.value != null) 
						if(productionstep.operationDuration.timeMeasurementUnitCode != null) 		   		   			
							if(lower(p("bydm.inbound.productionstep.timemeasurementunitcode")) startsWith "sec") 
									
										ceil(productionstep.operationDuration.value * conversionToSeconds[productionstep.operationDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.productionstep.timemeasurementunitcode")) startsWith "hour") 
									
										ceil(productionstep.operationDuration.value * conversionToHours[productionstep.operationDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.productionstep.timemeasurementunitcode")) startsWith "day") 
									
										ceil(productionstep.operationDuration.value * conversionToDays[productionstep.operationDuration.timeMeasurementUnitCode][0]  as Number) 
							else if(lower(p("bydm.inbound.productionstep.timemeasurementunitcode")) startsWith "week") 
									
										ceil(productionstep.operationDuration.value * conversionToWeeks[productionstep.operationDuration.timeMeasurementUnitCode][0]  as Number) 			
							else if(lower(p("bydm.inbound.productionstep.timemeasurementunitcode")) startsWith "month") 
									
										ceil(productionstep.operationDuration.value * conversionToMonths[productionstep.operationDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.productionstep.timemeasurementunitcode")) startsWith "year") 
									
										ceil(productionstep.operationDuration.value * conversionToYears[productionstep.operationDuration.timeMeasurementUnitCode][0]  as Number)
							else 
									
										ceil(productionstep.operationDuration.value * conversionToMinutes[productionstep.operationDuration.timeMeasurementUnitCode][0] as Number)
						else 
								productionstep.operationDuration.value
					else 
						default_value,
		LOADOFFSETDUR: if(productionstep.loadOffsetDuration.value != null) 
						if(productionstep.loadOffsetDuration.timeMeasurementUnitCode != null) 		   		   			
							if(lower(p("bydm.inbound.productionstep.timemeasurementunitcode")) startsWith "sec") 
									
										ceil(productionstep.loadOffsetDuration.value * conversionToSeconds[productionstep.loadOffsetDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.productionstep.timemeasurementunitcode")) startsWith "hour") 
									
										ceil(productionstep.loadOffsetDuration.value * conversionToHours[productionstep.loadOffsetDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.productionstep.timemeasurementunitcode")) startsWith "day") 
									
										ceil(productionstep.loadOffsetDuration.value * conversionToDays[productionstep.loadOffsetDuration.timeMeasurementUnitCode][0]  as Number) 
							else if(lower(p("bydm.inbound.productionstep.timemeasurementunitcode")) startsWith "week") 
									
										ceil(productionstep.loadOffsetDuration.value * conversionToWeeks[productionstep.loadOffsetDuration.timeMeasurementUnitCode][0]  as Number) 			
							else if(lower(p("bydm.inbound.productionstep.timemeasurementunitcode")) startsWith "month") 
									
										ceil(productionstep.loadOffsetDuration.value * conversionToMonths[productionstep.loadOffsetDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.productionstep.timemeasurementunitcode")) startsWith "year") 
									
										ceil(productionstep.loadOffsetDuration.value * conversionToYears[productionstep.loadOffsetDuration.timeMeasurementUnitCode][0]  as Number)
							else 
									
										ceil(productionstep.loadOffsetDuration.value * conversionToMinutes[productionstep.loadOffsetDuration.timeMeasurementUnitCode][0] as Number)
						else 
								productionstep.loadOffsetDuration.value
					else 
						default_value,		
		PRODRATECAL: if (productionstep.productionRateCalendar != null) productionstep.productionRateCalendar else default_value,
		PRODFAMILY: if (productionstep.productionFamily != null) productionstep.productionFamily else default_value,
		PRODUCTIONMETHOD: if (productionRouting.productionRoutingId != null) productionRouting.productionRoutingId else default_value,
		ITEM: if (productionRouting.item != null) productionRouting.item else default_value,
		LOC: if (productionRouting.location != null) productionRouting.location else default_value,
		PRODOFFSET: if(productionstep.productionOffsetDuration.value != null) 
						if(productionstep.productionOffsetDuration.timeMeasurementUnitCode != null) 		   		   			
							if(lower(p("bydm.inbound.productionstep.timemeasurementunitcode")) startsWith "sec") 
									
										ceil(productionstep.productionOffsetDuration.value * conversionToSeconds[productionstep.productionOffsetDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.productionstep.timemeasurementunitcode")) startsWith "hour") 
									
										ceil(productionstep.productionOffsetDuration.value * conversionToHours[productionstep.productionOffsetDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.productionstep.timemeasurementunitcode")) startsWith "day") 
									
										ceil(productionstep.productionOffsetDuration.value * conversionToDays[productionstep.productionOffsetDuration.timeMeasurementUnitCode][0]  as Number) 
							else if(lower(p("bydm.inbound.productionstep.timemeasurementunitcode")) startsWith "week") 
									
										ceil(productionstep.productionOffsetDuration.value * conversionToWeeks[productionstep.productionOffsetDuration.timeMeasurementUnitCode][0]  as Number) 			
							else if(lower(p("bydm.inbound.productionstep.timemeasurementunitcode")) startsWith "month") 
									
										ceil(productionstep.productionOffsetDuration.value * conversionToMonths[productionstep.productionOffsetDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.productionstep.timemeasurementunitcode")) startsWith "year") 
									
										ceil(productionstep.productionOffsetDuration.value * conversionToYears[productionstep.productionOffsetDuration.timeMeasurementUnitCode][0]  as Number)
							else 
									
										ceil(productionstep.productionOffsetDuration.value * conversionToMinutes[productionstep.productionOffsetDuration.timeMeasurementUnitCode][0] as Number)
						else 
								productionstep.productionOffsetDuration.value
					else 
						default_value,
		avplistUDCS:(flatten([(lib.getUdcNameAndValue(productionStepEntity, productionRouting.avpList, lib.getAvpListMap(productionRouting.avpList))[0]) if (productionRouting.avpList != null 
		and (productionRouting.documentActionCode == "ADD" or productionRouting.documentActionCode == "CHANGE_BY_REFRESH")
		and productionStepEntity != null
		),
		(lib.getUdcNameAndValue(productionStepEntity, productionstep.avpList, lib.getAvpListMap(productionstep.avpList))[0]) if (productionstep.avpList != null 
			and (productionRouting.documentActionCode == "ADD" or productionRouting.documentActionCode == "CHANGE_BY_REFRESH")
			and productionStepEntity != null
		)
		])),
		ACTIONCODE: productionRouting.documentActionCode
		})
	}.val)
}pluck($))))