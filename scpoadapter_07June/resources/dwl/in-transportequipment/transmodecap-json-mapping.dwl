%dw 2.0
output application/java
var UOMIsoConversion = vars.codeMap.UOMIsoConversion
var UOMConversion = vars.codeMap.UOMConversion
var transmodecapEntity = vars.entityMap.transportequipment[0].transmodecap[0]
var default_value = "###JDA_DEFAULT_VALUE###"
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
---
flatten ( payload.transportEquipment map (transmodeeqp, indexOftransmodeeqp) ->  {
    transmodevalue:(transmodeeqp.usageThresholdValues filter ($.measurementUnitCode != null) map (transmodecap, indexOftransmodecap) -> {
    	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
    	(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((indexOftransmodeeqp))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		MAXCAP: if (transmodecap.maximumAllowableValue != null) transmodecap.maximumAllowableValue 
			else default_value,
		MINCAP: if (transmodecap.minimumAllowableValue != null) transmodecap.minimumAllowableValue
			else default_value,
		TRANSMODE: if (transmodeeqp.transportEquipmentId != null) transmodeeqp.transportEquipmentId
			else default_value,
		UOM: if (transmodecap.measurementUnitCode != null )( 
	 			if(vars.uomShortLabels[transmodecap.measurementUnitCode][0] == null) 
	 				default_value
	 			else vars.uomShortLabels[transmodecap.measurementUnitCode][0] as Number
	 			)else default_value,
		//CHECKCAPSW: "", //TODO-Not Mapped
		(avplistUDCS:(lib.getUdcNameAndValue(transmodecapEntity, transmodeeqp.avpList, lib.getAvpListMap(transmodeeqp.avpList))[0])) 
		if ((transmodeeqp.documentActionCode == "ADD" or transmodeeqp.documentActionCode == "CHANGE_BY_REFRESH")
			and transmodecapEntity != null and transmodeeqp.avpList != null
	),
		ACTIONCODE: transmodeeqp.documentActionCode
	})
}).transmodevalue reduce ($ ++ $$)