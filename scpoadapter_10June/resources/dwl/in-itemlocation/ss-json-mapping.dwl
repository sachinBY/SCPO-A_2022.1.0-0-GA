%dw 2.0
output application/java
var skuSSEntity = vars.entityMap.sku[0].skuss[0]
var default_value = "###JDA_DEFAULT_VALUE###"
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
--- 
flatten(flatten(payload.itemLocation map(itemLocation,indexOfItemLocation) ->
{
    (conversion: itemLocation.effectiveInventoryParameters map (effectiveInventoryParameters, indexOfEffectiveInventoryParameters) ->
    {
    	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,	
    	(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((indexOfItemLocation))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
    	MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
        ITEM: itemLocation.itemLocationId.item.primaryId,
        LOC: itemLocation.itemLocationId.location.primaryId,
        EFF: if (effectiveInventoryParameters.effectiveFromDateTime != null) effectiveInventoryParameters.effectiveFromDateTime else default_value,
        QTY: if (effectiveInventoryParameters.minimumSafetyStockQuantity.value != null) effectiveInventoryParameters.minimumSafetyStockQuantity.value as Number else null,
        DMDGROUP: if (effectiveInventoryParameters.demandChannel != null) effectiveInventoryParameters.demandChannel else null,

		SkuSSUDC:(flatten([(lib.getUdcNameAndValue(skuSSEntity, itemLocation.avpList, lib.getAvpListMap(itemLocation.avpList) )[0]) 
	if (itemLocation.avpList != null 
		and (itemLocation.documentActionCode == "ADD" or itemLocation.documentActionCode == "CHANGE_BY_REFRESH")
		and skuSSEntity != null
	),
	(lib.getUdcNameAndValue(skuSSEntity, effectiveInventoryParameters.avpList, lib.getAvpListMap(effectiveInventoryParameters.avpList) )[0]) 
	if (effectiveInventoryParameters.avpList != null 
		and (itemLocation.documentActionCode == "ADD" or itemLocation.documentActionCode == "CHANGE_BY_REFRESH")
		and skuSSEntity != null
	)])),
        ACTIONCODE: itemLocation.documentActionCode
     })
        
} pluck($)))