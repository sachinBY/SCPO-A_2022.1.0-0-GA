%dw 2.0
output application/java
var skuStorageRequirement = vars.entityMap.sku[0].skustoragerequirement[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var default_value = "###JDA_DEFAULT_VALUE###"
---
(payload.itemLocation map {
(if($.resource != null){
	resources:($.resource map (res, index) -> {
	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference,		
	(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	SENDER: vars.bulkNotificationHeaders.sender,	
	ITEM: $.itemLocationId.item.primaryId,
	LOC: $.itemLocationId.location.primaryId,
	RES: res,
	
	SkuSTORAGEREQUIREMENTUDC:(flatten([(lib.getUdcNameAndValue(skuStorageRequirement, $.avpList, lib.getAvpListMap($.avpList) )[0]) 
	if ($.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and skuStorageRequirement != null
	)])),
          
	ACTIONCODE: $.documentActionCode
	})} 
	else
	resources:[]) 
}).resources reduce($ ++ $$)
