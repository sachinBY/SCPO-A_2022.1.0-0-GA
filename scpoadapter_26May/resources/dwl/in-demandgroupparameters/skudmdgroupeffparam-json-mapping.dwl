%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var skudmdgroupeffparamEntity = vars.entityMap.skudmdgroupparam[0].skudmdgroupeffparam[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
flatten(flatten(payload.demandGroupParameters map(dmdGroupPrams, index)-> {
	data: (dmdGroupPrams.demandGroupParameters map(dmdGrpPrams, dmdIndex) -> {
		val: (dmdGrpPrams.demandGroupEffectiveParameters map(eff,index) -> {
			MS_BULK_REF: vars.storeHeaderReference.bulkReference,
			MS_REF: vars.storeMsgReference.messageReference,
			INTEGRATION_STAMP: ((vars.creationDateAndTime as DateTime + ('PT' ++ index ++ 'S') as Period) replace 'T' with '') [0 to 17],
			MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  			MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  			SENDER: vars.bulkNotificationHeaders.sender,
			DMDGROUP: dmdGrpPrams.demandGroup,
			ITEM: dmdGroupPrams.demandGroupParametersId.item.primaryId,
			SKULOC: dmdGroupPrams.demandGroupParametersId.location.primaryId,
			EFF: eff.effectiveFromDate,
			IOSERVICEPROFILE: if(eff.inventoryOptimizationServiceProfileID != null) eff.inventoryOptimizationServiceProfileID else default_value,
			
		  	(SkuDmdEffParamUDC:(lib.getUdcNameAndValue(skudmdgroupeffparamEntity, dmdGroupPrams.avpList, lib.getAvpListMap(dmdGroupPrams.avpList))[0])) 
	if ((dmdGroupPrams.documentActionCode == "ADD" or dmdGroupPrams.documentActionCode == "CHANGE_BY_REFRESH")
			and skudmdgroupeffparamEntity != null and dmdGroupPrams.avpList != null
	),  
	ACTIONCODE: dmdGroupPrams.documentActionCode
		})
	}.val)
	
}.data))
