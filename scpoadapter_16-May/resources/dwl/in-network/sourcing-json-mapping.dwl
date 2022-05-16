%dw 2.0
output application/java
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var sourcingEntity = vars.entityMap.networkmap[0].sourcing[0]
var conversionToSeconds=vars.codeMap."time-units-seconds-conversion"
var conversionToMinutes=vars.codeMap."time-units-minutes-conversion"
var conversionToHours=vars.codeMap."time-units-hours-conversion"
var conversionToDays=vars.codeMap."time-units-days-conversion"
var conversionToWeeks=vars.codeMap."time-units-weeks-conversion"
var conversionToMonths=vars.codeMap."time-units-months-conversion"
var conversionToYears=vars.codeMap."time-units-years-conversion"
---
flatten(flatten(payload.network map (network, networkIndex) -> {
	sourcing: (network.sourcingInformation map(sourcingInformation, sourcingInformationIndex) -> {
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((sourcingInformationIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		DEST: if(network.dropOffLocation.locationId != null) network.dropOffLocation.locationId
				else default_value,
		DISC: if(sourcingInformation.sourcingDetails.effectiveUpToDate != null )
			(sourcingInformation.sourcingDetails.effectiveUpToDate replace 'Z' with('')) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
			else default_value,
		EFF: if(sourcingInformation.sourcingDetails.effectiveFromDate != null )
			(sourcingInformation.sourcingDetails.effectiveFromDate replace 'Z' with('')) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
			else default_value,
		FACTOR: if(sourcingInformation.sourcingDetails.sourcingPercentage != null)
			(sourcingInformation.sourcingDetails.sourcingPercentage/100) as Number
			else default_value,
		ITEM: if(sourcingInformation.sourcingItem.itemId != null) sourcingInformation.sourcingItem.itemId
			else default_value,
		MAJORSHIPQTY: if(sourcingInformation.sourcingDetails.majorThresholdShipQuantity.value != null)
			sourcingInformation.sourcingDetails.majorThresholdShipQuantity.value
			else default_value,
		MAXSHIPQTY: if(sourcingInformation.sourcingDetails.maximumShipQuantity.value != null)
			sourcingInformation.sourcingDetails.maximumShipQuantity.value
			else default_value,
		MINORSHIPQTY: if(sourcingInformation.sourcingDetails.minorThresholdShipQuantity.value != null)
			sourcingInformation.sourcingDetails.minorThresholdShipQuantity.value
			else default_value,
		NONEWSUPPLYDATE: if(sourcingInformation.sourcingDetails.noNewSupplyBeforeDate != null)
			(sourcingInformation.sourcingDetails.noNewSupplyBeforeDate replace 'Z' with('')) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
			else default_value,
		PRIORITY: if(sourcingInformation.sourcingDetails.priority != null)
			sourcingInformation.sourcingDetails.priority
			else default_value,
		SHRINKAGEFACTOR: if(sourcingInformation.sourcingDetails.shrinkagePercentage != null)
			sourcingInformation.sourcingDetails.shrinkagePercentage
			else default_value,
		SOURCE: if(network.pickUpLocation.locationId != null) network.pickUpLocation.locationId
				else default_value,
		SOURCING: if(sourcingInformation.sourcingMethod != null)
				sourcingInformation.sourcingMethod
				else default_value,
		SOURCINGCOST: if(sourcingInformation.sourcingDetails.cost.value != null)
			sourcingInformation.sourcingDetails.cost.value
			else default_value,
		TRANSMODE: if (network.transportEquipmentTypeCode.value == "*UNKNOWN") 
					p("bydm.network.default.transmode")
			   else if(network.transportEquipmentTypeCode.value != null)
					network.transportEquipmentTypeCode.value
			   else default_value,
		ARRIVCAL: if(network.arrivalCalendar != null)
				network.arrivalCalendar
				else default_value,
		SHIPCAL: if(network.shippingCalendar != null)
				network.shippingCalendar
				else default_value,
		LOADDUR: if(network.freightCharacteristics.loadingDuration.value != null) 
					if(network.freightCharacteristics.loadingDuration.timeMeasurementUnitCode != null) 		   		   			
				if(lower(p("bydm.inbound.sourcing.timemeasurementunitcode")) startsWith "sec") 
						ceil(network.freightCharacteristics.loadingDuration.value * conversionToSeconds[network.freightCharacteristics.loadingDuration.timeMeasurementUnitCode][0]  as Number)
				else if(lower(p("bydm.inbound.sourcing.timemeasurementunitcode")) startsWith "hour") 
						ceil(network.freightCharacteristics.loadingDuration.value * conversionToHours[network.freightCharacteristics.loadingDuration.timeMeasurementUnitCode][0]  as Number)
				else if(lower(p("bydm.inbound.sourcing.timemeasurementunitcode")) startsWith "day") 
						ceil(network.freightCharacteristics.loadingDuration.value * conversionToDays[network.freightCharacteristics.loadingDuration.timeMeasurementUnitCode][0]  as Number) 
				else if(lower(p("bydm.inbound.sourcing.timemeasurementunitcode")) startsWith "week") 
						ceil(network.freightCharacteristics.loadingDuration.value * conversionToWeeks[network.freightCharacteristics.loadingDuration.timeMeasurementUnitCode][0]  as Number) 		
				else if(lower(p("bydm.inbound.sourcing.timemeasurementunitcode")) startsWith "month") 
					
						ceil(network.freightCharacteristics.loadingDuration.value * conversionToMonths[network.freightCharacteristics.loadingDuration.timeMeasurementUnitCode][0]  as Number)
				else if(lower(p("bydm.inbound.sourcing.timemeasurementunitcode")) startsWith "year") 
						ceil(network.freightCharacteristics.loadingDuration.value * conversionToYears[network.freightCharacteristics.loadingDuration.timeMeasurementUnitCode][0]  as Number)
				else 
						ceil(network.freightCharacteristics.loadingDuration.value * conversionToMinutes[network.freightCharacteristics.loadingDuration.timeMeasurementUnitCode][0]  as Number)

				else 
					network.freightCharacteristics.loadingDuration.value
			else 
				default_value,
		UNLOADDUR: if(network.freightCharacteristics.unloadingDuration.value != null) 
					if(network.freightCharacteristics.unloadingDuration.timeMeasurementUnitCode != null) 		   		   			
				if(lower(p("bydm.inbound.sourcing.timemeasurementunitcode")) startsWith "sec") 
					
						ceil(network.freightCharacteristics.unloadingDuration.value * conversionToSeconds[network.freightCharacteristics.unloadingDuration.timeMeasurementUnitCode][0]  as Number)
				else if(lower(p("bydm.inbound.sourcing.timemeasurementunitcode")) startsWith "hour") 
					
						ceil(network.freightCharacteristics.unloadingDuration.value * conversionToHours[network.freightCharacteristics.unloadingDuration.timeMeasurementUnitCode][0]  as Number)
				else if(lower(p("bydm.inbound.sourcing.timemeasurementunitcode")) startsWith "day") 
					
						ceil(network.freightCharacteristics.unloadingDuration.value * conversionToDays[network.freightCharacteristics.unloadingDuration.timeMeasurementUnitCode][0]  as Number )
				else if(lower(p("bydm.inbound.sourcing.timemeasurementunitcode")) startsWith "week") 
						ceil(network.freightCharacteristics.unloadingDuration.value * conversionToWeeks[network.freightCharacteristics.unloadingDuration.timeMeasurementUnitCode][0]  as Number)		
				else if(lower(p("bydm.inbound.sourcing.timemeasurementunitcode")) startsWith "month") 
					
						ceil(network.freightCharacteristics.unloadingDuration.value * conversionToMonths[network.freightCharacteristics.unloadingDuration.timeMeasurementUnitCode][0]  as Number)
				else if(lower(p("bydm.inbound.sourcing.timemeasurementunitcode")) startsWith "year") 
					
						ceil(network.freightCharacteristics.unloadingDuration.value * conversionToYears[network.freightCharacteristics.unloadingDuration.timeMeasurementUnitCode][0]  as Number)
				else 
					
						
						ceil(network.freightCharacteristics.unloadingDuration.value * conversionToMinutes[network.freightCharacteristics.unloadingDuration.timeMeasurementUnitCode][0]  as Number)

				else 
					network.freightCharacteristics.unloadingDuration.value
			else 
				default_value,
	sourcingUDC:flatten([(lib.getUdcNameAndValue(sourcingEntity, network.avpList, lib.getAvpListMap(network.avpList))[0]) 
	if (not isEmpty(network.avpList) and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH") and sourcingEntity != null),
	(lib.getUdcNameAndValue(sourcingEntity, sourcingInformation.sourcingDetails.avpList, lib.getAvpListMap(sourcingInformation.sourcingDetails.avpList))[0]) 
	if (not isEmpty(sourcingInformation.sourcingDetails.avpList) and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH") and sourcingEntity != null)
	]),
		ACTIONCODE: network.documentActionCode
	})
} pluck($)))