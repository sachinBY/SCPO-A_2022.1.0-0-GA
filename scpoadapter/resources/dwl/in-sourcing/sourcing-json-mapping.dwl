%dw 2.0
output application/java
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var default_value = "###JDA_DEFAULT_VALUE###"
var sourcingEntity = vars.entityMap.sourcing[0].sourcing[0]
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
---
(payload.sourcing map (sourcing, sourcingIndex) -> {
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((sourcingIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		ARRIVCAL: if(sourcing.arrivalCalendar != null) sourcing.arrivalCalendar
				else default_value,
		DEST: if(sourcing.sourcingId.dropOffLocation.locationId != null) sourcing.sourcingId.dropOffLocation.locationId
				else default_value,
		DISC: if(sourcing.sourcingDetails.effectiveUpToDate != null and funCaller.formatGS1ToSCPO(sourcing.sourcingDetails.effectiveUpToDate replace 'Z' with('')) != default_value)
				(sourcing.sourcingDetails.effectiveUpToDate replace 'Z' with('')) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
				else default_value,
		EFF: if(sourcing.sourcingDetails.effectiveFromDate != null and funCaller.formatGS1ToSCPO(sourcing.sourcingDetails.effectiveFromDate replace 'Z' with('')) != default_value)
			    (sourcing.sourcingDetails.effectiveFromDate replace 'Z' with('')) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
				else default_value,
		FACTOR: if(sourcing.sourcingDetails.sourcingPercentage != null) sourcing.sourcingDetails.sourcingPercentage
				else default_value,
		ITEM: if(sourcing.sourcingId.item.itemId != null) sourcing.sourcingId.item.itemId
				else default_value,
		LOADDUR: if(sourcing.loadingDuration.value != null) sourcing.loadingDuration.value
				else default_value,
		MAJORSHIPQTY: if(sourcing.sourcingDetails.majorThresholdShipQuantity.value != null) sourcing.sourcingDetails.majorThresholdShipQuantity.value
				else default_value,
		MAXSHIPQTY: if(sourcing.sourcingDetails.maximumShipQuantity.value != null) sourcing.sourcingDetails.maximumShipQuantity.value
				else default_value,
		MINORSHIPQTY: if(sourcing.sourcingDetails.minorThresholdShipQuantity.value != null) sourcing.sourcingDetails.minorThresholdShipQuantity.value
				else default_value,
		NONEWSUPPLYDATE: if(sourcing.sourcingDetails.noNewSupplyBeforeDate != null and funCaller.formatGS1ToSCPO(sourcing.sourcingDetails.noNewSupplyBeforeDate replace 'Z' with('')) != default_value)
			               (sourcing.sourcingDetails.noNewSupplyBeforeDate replace 'Z' with('')) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
				         else default_value,
		PRIORITY: if(sourcing.sourcingDetails.priority != null) sourcing.sourcingDetails.priority
				else default_value,
		SHIPCAL:  if(sourcing.shippingCalendar != null) sourcing.shippingCalendar
				else default_value,
		SHRINKAGEFACTOR: if(sourcing.sourcingDetails.shrinkagePercentage != null) sourcing.sourcingDetails.shrinkagePercentage
				else default_value,
		SOURCE: if(sourcing.sourcingId.pickUpLocation.locationId != null) sourcing.sourcingId.pickUpLocation.locationId
				else default_value,
		SOURCING: if(sourcing.sourcingId.sourcingMethod != null) sourcing.sourcingId.sourcingMethod
				else default_value,
		SOURCINGCOST: if(sourcing.sourcingDetails.cost.value != null) sourcing.sourcingDetails.cost.value
				else default_value,
		TRANSMODE: if(sourcing.transportEquipment.transportEquipmentTypeCode.value != null) sourcing.transportEquipment.transportEquipmentTypeCode.value
				else default_value,
		UNLOADDUR: if(sourcing.unloadingDuration.value != null) sourcing.unloadingDuration.value
				else default_value,
		avplistUDCS:(flatten([(lib.getUdcNameAndValue(sourcingEntity, sourcing.avpList, lib.getAvpListMap(sourcing.avpList))[0]) if (sourcing.avpList != null 
		and (sourcing.documentActionCode == "ADD" or sourcing.documentActionCode == "CHANGE_BY_REFRESH")
		and sourcingEntity != null
		),
		(lib.getUdcNameAndValue(sourcingEntity, sourcing.sourcingDetails.avpList, lib.getAvpListMap(sourcing.sourcingDetails.avpList))[0]) if (sourcing.sourcingDetails.avpList != null 
			and (sourcing.sourcingDetails.documentActionCode == "ADD" or sourcing.sourcingDetails.documentActionCode == "CHANGE_BY_REFRESH")
			and sourcingEntity != null
		)
		])),
		
		ACTIONCODE: sourcing.documentActionCode,
		
	})