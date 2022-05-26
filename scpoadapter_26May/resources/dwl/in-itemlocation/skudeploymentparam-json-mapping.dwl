%dw 2.0
output application/java  
var skuDeploymentParamEntity = vars.entityMap.sku[0].skudeploymentparam[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload.itemLocation map {
	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference,	
	  (INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	  MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	  MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	  SENDER: vars.bulkNotificationHeaders.sender,
	  ITEM: $.itemLocationId.item.primaryId,
	  LOC: $.itemLocationId.location.primaryId,
	  INITSTKOUTCOST:$.deploymentParameters.initialStockoutCost.value,
	  SURPLUSRESTOCKCOST:$.deploymentParameters.surplusRestockCost.value,

		SkuDeploymentParamUDC:(flatten([(lib.getUdcNameAndValue(skuDeploymentParamEntity, $.avpList, lib.getAvpListMap($.avpList) )[0]) 
	if ($.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and skuDeploymentParamEntity != null
	),
	(lib.getUdcNameAndValue(skuDeploymentParamEntity, $.deploymentParameters.avpList, lib.getAvpListMap($.deploymentParameters.avpList) )[0]) 
	if ($.deploymentParameters.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and skuDeploymentParamEntity != null
	)])),
	  ACTIONCODE: $.documentActionCode
})