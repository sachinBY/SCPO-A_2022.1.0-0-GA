%dw 2.0
output application/java 
var skuSSPresentationEntity = vars.entityMap.sku[0].skusspresentation[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload.itemLocation map {
(if($.safetyStockPresentation != null) {
arr:($.safetyStockPresentation map (sspr , index) -> {
		  MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		  MS_REF: vars.storeMsgReference.messageReference,	
		  (INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		  MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		  MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		  SENDER: vars.bulkNotificationHeaders.sender,
		  ITEM:$.itemLocationId.item.primaryId,
		  LOC: $.itemLocationId.location.primaryId,
		  EFF: sspr.effectiveFromDateTime,
		  DISC: sspr.effectiveUpToDateTime,
		  PRESENTATIONQTY: sspr.presentationQuantity.value,
		  DISPLAYQTY: sspr.displayQuantity.value,
		  MAXSS: sspr.maximumSafetyStock.value,
		  MAXOH: sspr.maximumOnHandQuantity.value,
	SkuSSPresentationUDC:(flatten([(lib.getUdcNameAndValue(skuSSPresentationEntity, $.avpList, lib.getAvpListMap($.avpList) )[0]) 
	if ($.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and skuSSPresentationEntity != null
	),
	(lib.getUdcNameAndValue(skuSSPresentationEntity, sspr.avpList, lib.getAvpListMap(sspr.avpList) )[0]) 
	if (sspr.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and skuSSPresentationEntity != null
	)])),
		  ACTIONCODE: $.documentActionCode	
	})}
	else 
	{
	
arr:[{	(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	    MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,	
		ITEM:$.itemLocationId.item.primaryId,
		LOC: $.itemLocationId.location.primaryId,
		SkuSSPresentationUDC:(flatten([(lib.getUdcNameAndValue(skuSSPresentationEntity, $.avpList, lib.getAvpListMap($.avpList) )[0]) 
	if ($.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and skuSSPresentationEntity != null
	)])),
		ACTIONCODE: $.documentActionCode}]})
}).arr reduce($ ++ $$)