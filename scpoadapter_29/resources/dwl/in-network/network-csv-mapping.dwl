%dw 2.0
output application/java
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var UOMIsoConversion = vars.codeMap.UOMIsoConversion
var UOMConversion = vars.codeMap.UOMConversion
var networkEntity = vars.entityMap.networkmap[0].network[0]
---
(payload map (network, networkIndex) -> {
	udcs: ((networkEntity map (value, index) -> {
			(scpoColumnName: value.scpoColumnName) if ((lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0)) != null),
			(scpoColumnValue: (lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0))) if ((lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0)) != null),
			(dataType: value.dataType) if ((lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0)) != null)
		})) filter sizeOf($) > 0,
	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference,
	(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((networkIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	SENDER: vars.bulkNotificationHeaders.sender,
	TRANSMODE: if(network.'transportEquipmentTypeCode.value' != null)
					network.'transportEquipmentTypeCode.value'
			   else default_value,
	SOURCE:	if(network.'pickUpLocation.locationId' != null) network.'pickUpLocation.locationId'
				else default_value,
	DEST: if(network.'dropOffLocation.locationId' != null) network.'dropOffLocation.locationId'
				else default_value,
	TRANSLEADTIME:if(network.'freightCharacteristics.transitDuration.value' != null)
					if(network.'freightCharacteristics.transitDuration.timeMeasurementUnitCode' != null) 		   		   			
					if(network.'freightCharacteristics.transitDuration.timeMeasurementUnitCode' == "ANN")
						ceil(network.'freightCharacteristics.transitDuration.value'*365*24*60)
					else if(network.'freightCharacteristics.transitDuration.timeMeasurementUnitCode' == "B98")
						ceil(network.'freightCharacteristics.transitDuration.value'/60000000)	
					else if(network.'freightCharacteristics.transitDuration.timeMeasurementUnitCode' == "C26")
						ceil(network.'freightCharacteristics.transitDuration.value'/60000)
					else if(network.'freightCharacteristics.transitDuration.timeMeasurementUnitCode' == "C47")
						ceil(network.'freightCharacteristics.transitDuration.value'/60000000000)
					else if(network.'freightCharacteristics.transitDuration.timeMeasurementUnitCode' == "DAY")
						ceil(network.'freightCharacteristics.transitDuration.value'*24*60)	
					else if(network.'freightCharacteristics.transitDuration.timeMeasurementUnitCode' == "H70")
						ceil(network.'freightCharacteristics.transitDuration.value'/60000000000000)	
					else if(network.'freightCharacteristics.transitDuration.timeMeasurementUnitCode' == "HUR")
						ceil(network.'freightCharacteristics.transitDuration.value'*60)	
					else if(network.'freightCharacteristics.transitDuration.timeMeasurementUnitCode' == "MON")
						ceil(network.'freightCharacteristics.transitDuration.value'*30*24*60)
					else if(network.'freightCharacteristics.transitDuration.timeMeasurementUnitCode' == "QAN")
						ceil(network.'freightCharacteristics.transitDuration.value'*90*24*60)
					else if(network.'freightCharacteristics.transitDuration.timeMeasurementUnitCode' == "SEC")
						ceil(network.'freightCharacteristics.transitDuration.value'/60)
					else if(network.'freightCharacteristics.transitDuration.timeMeasurementUnitCode' == "WEE")
						ceil(network.'freightCharacteristics.transitDuration.value'*7*24*60)
					else
						network.'freightCharacteristics.transitDuration.value'
				else
						network.'freightCharacteristics.transitDuration.value'		
			else default_value,
	LOADTIME: if(network.'freightCharacteristics.loadingDuration.value' != null)
				if(network.'freightCharacteristics.loadingDuration.timeMeasurementUnitCode' != null) 		   		   			
				if(network.'freightCharacteristics.loadingDuration.timeMeasurementUnitCode' == "ANN")
						ceil(network.'freightCharacteristics.loadingDuration.value'*365*24*60)
					else if(network.'freightCharacteristics.loadingDuration.timeMeasurementUnitCode' == "B98")
						ceil(network.'freightCharacteristics.loadingDuration.value'/60000000)	
					else if(network.'freightCharacteristics.loadingDuration.timeMeasurementUnitCode' == "C26")
						ceil(network.'freightCharacteristics.loadingDuration.value'/60000)
					else if(network.'freightCharacteristics.loadingDuration.timeMeasurementUnitCode' == "C47")
						ceil(network.'freightCharacteristics.loadingDuration.value'/60000000000)
					else if(network.'freightCharacteristics.loadingDuration.timeMeasurementUnitCode' == "DAY")
						ceil(network.'freightCharacteristics.loadingDuration.value'*24*60)	
					else if(network.'freightCharacteristics.loadingDuration.timeMeasurementUnitCode' == "H70")
						ceil(network.'freightCharacteristics.loadingDuration.value'/60000000000000)	
					else if(network.'freightCharacteristics.loadingDuration.timeMeasurementUnitCode' == "HUR")
						ceil(network.'freightCharacteristics.loadingDuration.value'*60)	
					else if(network.'freightCharacteristics.loadingDuration.timeMeasurementUnitCode' == "MON")
						ceil(network.'freightCharacteristics.loadingDuration.value'*30*24*60)
					else if(network.'freightCharacteristics.loadingDuration.timeMeasurementUnitCode' == "QAN")
						ceil(network.'freightCharacteristics.loadingDuration.value'*90*24*60)
					else if(network.'freightCharacteristics.loadingDuration.timeMeasurementUnitCode' == "SEC")
						ceil(network.'freightCharacteristics.loadingDuration.value'/60)
					else if(network.'freightCharacteristics.loadingDuration.timeMeasurementUnitCode' == "WEE")
						ceil(network.'freightCharacteristics.loadingDuration.value'*7*24*60)
					else
						network.'freightCharacteristics.loadingDuration.value'
				else
						network.'freightCharacteristics.loadingDuration.value'	
			  else default_value,
	RANK: if(network.transportationModePriority != null)
			network.transportationModePriority
			else default_value,
	RATEPERCWT:  if(network.'freightCharacteristics.transportationCostPerHundredWeight.value' != null)
					network.'freightCharacteristics.transportationCostPerHundredWeight.value'
					else default_value,
	UNLOADTIME: if(network.'freightCharacteristics.unloadingDuration.value' != null)
				if(network.'freightCharacteristics.unloadingDuration.timeMeasurementUnitCode' != null) 		   		   			
				if(network.'freightCharacteristics.unloadingDuration.timeMeasurementUnitCode' == "ANN")
						ceil(network.'freightCharacteristics.unloadingDuration.value'*365*24*60)
					else if(network.'freightCharacteristics.unloadingDuration.timeMeasurementUnitCode' == "B98")
						ceil(network.'freightCharacteristics.unloadingDuration.value'/60000000)	
					else if(network.'freightCharacteristics.unloadingDuration.timeMeasurementUnitCode' == "C26")
						ceil(network.'freightCharacteristics.unloadingDuration.value'/60000)
					else if(network.'freightCharacteristics.unloadingDuration.timeMeasurementUnitCode' == "C47")
						ceil(network.'freightCharacteristics.unloadingDuration.value'/60000000000)
					else if(network.'freightCharacteristics.unloadingDuration.timeMeasurementUnitCode' == "DAY")
						ceil(network.'freightCharacteristics.unloadingDuration.value'*24*60)	
					else if(network.'freightCharacteristics.unloadingDuration.timeMeasurementUnitCode' == "H70")
						ceil(network.'freightCharacteristics.unloadingDuration.value'/60000000000000)	
					else if(network.'freightCharacteristics.unloadingDuration.timeMeasurementUnitCode' == "HUR")
						ceil(network.'freightCharacteristics.unloadingDuration.value'*60)	
					else if(network.'freightCharacteristics.unloadingDuration.timeMeasurementUnitCode' == "MON")
						ceil(network.'freightCharacteristics.unloadingDuration.value'*30*24*60)
					else if(network.'freightCharacteristics.unloadingDuration.timeMeasurementUnitCode' == "QAN")
						ceil(network.'freightCharacteristics.unloadingDuration.value'*90*24*60)
					else if(network.'freightCharacteristics.unloadingDuration.timeMeasurementUnitCode' == "SEC")
						ceil(network.'freightCharacteristics.unloadingDuration.value'/60)
					else if(network.'freightCharacteristics.unloadingDuration.timeMeasurementUnitCode' == "WEE")
						ceil(network.'freightCharacteristics.unloadingDuration.value'*7*24*60)
					else
						network.freightCharacteristics.unloadingDuration.value
				else
						network.freightCharacteristics.unloadingDuration.value	
			  else default_value,			  	
	ORDERCOST: if(network.'freightCharacteristics.orderCost.value' != null)
					network.'freightCharacteristics.orderCost.value'
					else default_value,
	SHIPCAL: if(network.shippingCalendar != null) 
					network.shippingCalendar
					else default_value,
	ARRIVCAL: if(network.arrivalCalendar != null) 
					network.arrivalCalendar
					else default_value,
	ORDERREVIEWCAL: if(network.orderReviewCalendar != null) 
					network.orderReviewCalendar
					else default_value,
	LEADTIMEEFFCNCYCAL: if(network.leadTimeEfficiencyCalendar != null) 
					network.leadTimeEfficiencyCalendar
					else default_value,
   	ACTIONCODE: if (network.documentActionCode != null and !isEmpty(network.documentActionCode)) network.documentActionCode else (vars.bulknotificationHeaders.documentActionCode)
})