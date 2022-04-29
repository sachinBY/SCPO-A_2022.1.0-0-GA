%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var transmodeEntity = vars.entityMap.transportequipment[0].transmode[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
---
payload.transportEquipment map (transmodeeqp, indexOftransmodeeqp) -> {
	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference,
	(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((indexOftransmodeeqp))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),	
	MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	SENDER: vars.bulkNotificationHeaders.sender,
	DESCR: if ( transmodeeqp.description.value != null) transmodeeqp.description.value
			else default_value,
	TRANSMODE: if ( transmodeeqp.transportEquipmentId != null ) transmodeeqp.transportEquipmentId
			else default_value,
	
	(avplistUDCS:(lib.getUdcNameAndValue(transmodeEntity, transmodeeqp.avpList, lib.getAvpListMap(transmodeeqp.avpList))[0])) 
	if ((transmodeeqp.documentActionCode == "ADD" or transmodeeqp.documentActionCode == "CHANGE_BY_REFRESH")
			and transmodeEntity != null and transmodeeqp.avpList != null
	),
	ACTIONCODE: transmodeeqp.documentActionCode
}