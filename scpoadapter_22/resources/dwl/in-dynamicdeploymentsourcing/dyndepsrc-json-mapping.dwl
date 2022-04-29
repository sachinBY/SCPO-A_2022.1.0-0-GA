%dw 2.0
output application/java
var dynDepSrcEntity = vars.entityMap.dyndepsrc[0].dyndepsrc[0]
var default_value = "###JDA_DEFAULT_VALUE###"
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload.dynamicDeploymentSourcing map(dynamicDeploymentSourcing, dynamicDeploymentSourcingIndex) -> {
	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference,
	(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((dynamicDeploymentSourcingIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	SENDER: vars.bulkNotificationHeaders.sender,
	ALTSRCPENALTY: if(dynamicDeploymentSourcing.alternateSourcePenaltyAmount != null) dynamicDeploymentSourcing.alternateSourcePenaltyAmount as Number else default_value,
	ARRIVCAL: if(dynamicDeploymentSourcing.arrivalCalendar != null) dynamicDeploymentSourcing.arrivalCalendar as String else default_value,
	DEST:dynamicDeploymentSourcing.dynamicDeploymentSourcingId.dropOffLocation as String,
	DISC: if(dynamicDeploymentSourcing.effectiveUpToDate != null) dynamicDeploymentSourcing.effectiveUpToDate else default_value,
	DYNDEPSRCCOST: if(dynamicDeploymentSourcing.alternateSourcingTransportCost != null) dynamicDeploymentSourcing.alternateSourcingTransportCost as Number else default_value,
	EFF:dynamicDeploymentSourcing.dynamicDeploymentSourcingId.effectiveFromDate,
	ITEM:dynamicDeploymentSourcing.dynamicDeploymentSourcingId.itemId as String,
	LOADDUR: if(dynamicDeploymentSourcing.loadingDuration.value != null) dynamicDeploymentSourcing.loadingDuration.value as Number else default_value,
	PULLFORWARDDUR: if(dynamicDeploymentSourcing.pullForwardDuration.value != null) dynamicDeploymentSourcing.pullForwardDuration.value as Number else default_value,
	SHIPCAL: if(dynamicDeploymentSourcing.shippingCalendar != null) dynamicDeploymentSourcing.shippingCalendar as String else default_value,
	SOURCE:dynamicDeploymentSourcing.dynamicDeploymentSourcingId.pickUpLocation as String,
	SOURCING: if(dynamicDeploymentSourcing.sourcingMethod != null) dynamicDeploymentSourcing.sourcingMethod as String else default_value,	
	SPLITQTY: if(dynamicDeploymentSourcing.incrementalShipmentQuantity != null) dynamicDeploymentSourcing.incrementalShipmentQuantity as Number else default_value,	
	TRANSMODE:dynamicDeploymentSourcing.dynamicDeploymentSourcingId.transportEquipmentTypeCode as String,
	UNLOADDUR: if(dynamicDeploymentSourcing.unloadingDuration.value != null) dynamicDeploymentSourcing.unloadingDuration.value as Number else default_value,
				
	(dynamicDeploymentSourcingUDC: (lib.getUdcNameAndValue(dynDepSrcEntity, dynamicDeploymentSourcing.avpList, lib.getAvpListMap(dynamicDeploymentSourcing.avpList))[0])) 
  		if (dynamicDeploymentSourcing.avpList != null and (dynamicDeploymentSourcing.documentActionCode == "ADD" or dynamicDeploymentSourcing.documentActionCode == "CHANGE_BY_REFRESH") and dynDepSrcEntity != null),
	ACTIONCODE: dynamicDeploymentSourcing.documentActionCode
})  
