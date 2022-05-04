%dw 2.0
output application/java  
var skuDemandParamEntity = vars.entityMap.sku[0].skudemandparam[0]
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
  INDDMDUNITCOST: $.demandParameters.unitCost.value,
  INDDMDUNITMARGIN: $.demandParameters.unitMargin.value,
  UNITCARCOST: $.demandParameters.unitInventoryCarryingCost.value,
  UNITPRICE: $.demandParameters.unitPrice.value,
  DMDTODATE: $.demandParameters.cumulativeDemandQuantity.value,

SkuDemandParamUDC:(flatten([(lib.getUdcNameAndValue(skuDemandParamEntity, $.avpList, lib.getAvpListMap($.avpList) )[0]) 
	if ($.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and skuDemandParamEntity != null
	),
	(lib.getUdcNameAndValue(skuDemandParamEntity, $.demandParameters.avpList, lib.getAvpListMap($.demandParameters.avpList) )[0]) 
	if ($.demandParameters.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and skuDemandParamEntity != null
	)])),
	
  ACTIONCODE: $.documentActionCode
})