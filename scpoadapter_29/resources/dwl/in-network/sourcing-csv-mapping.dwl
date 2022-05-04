%dw 2.0
output application/java
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
ns ns0 urn:jda:master:network:xsd:3
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var sourcingEntity = vars.entityMap.networkmap[0].sourcing[0]
---
(payload map (network, networkIndex) -> {
		udcs: ((sourcingEntity map(value, index) -> {
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
		ARRIVCAL: if(network.arrivalCalendar != null)
				network.arrivalCalendar
				else default_value,
		DEST: if(network.'dropOffLocation.locationId' != null) network.'dropOffLocation.locationId'
				else default_value,
		DISC: if(network.'sourcingInformation.sourcingDetails.effectiveUpToDate' != null )
			(network.'sourcingInformation.sourcingDetails.effectiveUpToDate' replace 'Z' with('')) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
			else default_value,
		EFF: if(network.'sourcingInformation.sourcingDetails.effectiveFromDate' != null )
			(network.'sourcingInformation.sourcingDetails.effectiveFromDate' replace 'Z' with('')) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
			else default_value,
		FACTOR: if(network.'sourcingInformation.sourcingDetails.sourcingPercentage' != null)
			(network.'sourcingInformation.sourcingDetails.sourcingPercentage'/100) as Number
			else default_value,
		ITEM: if(network.'sourcingInformation.sourcingItem.itemId' != null) network.'sourcingInformation.sourcingItem.itemId'
			else default_value,
		LOADDUR: if(network.'freightCharacteristics.loadingDuration.value' != null)
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
	MAJORSHIPQTY: if(network.'sourcingInformation.sourcingDetails.majorThresholdShipQuantity.value' != null)
			network.'sourcingInformation.sourcingDetails.majorThresholdShipQuantity.value'
			else default_value,
		MAXSHIPQTY: if(network.'sourcingInformation.sourcingDetails.maximumShipQuantity.value' != null)
			network.'sourcingInformation.sourcingDetails.maximumShipQuantity.value'
			else default_value,
		MINORSHIPQTY: if(network.'sourcingInformation.sourcingDetails.minorThresholdShipQuantity.value' != null)
			network.'sourcingInformation.sourcingDetails.minorThresholdShipQuantity.value'
			else default_value,
		NONEWSUPPLYDATE: if(network.'sourcingInformation.sourcingDetails.noNewSupplyBeforeDate' != null)
			(network.'sourcingInformation.sourcingDetails.noNewSupplyBeforeDate' replace 'Z' with('')) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
			else default_value,
		PRIORITY: if(network.'sourcingInformation.sourcingDetails.priority' != null)
			network.'sourcingInformation.sourcingDetails.priority'
			else default_value,
		SHIPCAL: if(network.shippingCalendar != null)
				network.shippingCalendar
				else default_value,
		SHRINKAGEFACTOR: if(network.'sourcingInformation.sourcingDetails.shrinkagePercentage' != null)
			network.'sourcingInformation.sourcingDetails.shrinkagePercentage'
			else default_value,
		SOURCE: if(network.'pickUpLocation.locationId' != null) network.'pickUpLocation.locationId'
				else default_value,
		SOURCING: if(network.'sourcingInformation.sourcingMethod' != null)
				network.'sourcingInformation.sourcingMethod'
				else default_value,
		SOURCINGCOST: if(network.'sourcingInformation.sourcingDetails.cost.value' != null)
			network.'sourcingInformation.sourcingDetails.cost.value'
			else default_value,
		TRANSMODE: if (network.'transportEquipmentTypeCode.value' == "*UNKNOWN") 
					p("bydm.network.default.transmode")
			   else if(network.'transportEquipmentTypeCode.value' != null)
					network.'transportEquipmentTypeCode.value'
			   else default_value,
		UNLOADDUR: if(network.'freightCharacteristics.unloadingDuration.value' != null)
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
						network.'freightCharacteristics.unloadingDuration.value'
				else
						network.'freightCharacteristics.unloadingDuration.value'	
			  else default_value,
		ACTIONCODE: if (network.documentActionCode != null and !isEmpty(network.documentActionCode)) network.documentActionCode else (vars.bulknotificationHeaders.documentActionCode)
	
} )