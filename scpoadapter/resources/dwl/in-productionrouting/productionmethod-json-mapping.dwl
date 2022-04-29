%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var productionMethodEntity = vars.entityMap.productionrouting[0].productionmethod[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
payload.productionRouting default [] map (productionmethod,productionmethodIndex) -> {
	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference,
    (INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((productionmethodIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	SENDER: vars.bulkNotificationHeaders.sender,
	PRODUCTIONMETHOD :  if (productionmethod.productionRoutingId != null) productionmethod.productionRoutingId else default_value,
	ITEM:  if (productionmethod.item != null) productionmethod.item else default_value,
	LOC:  if (productionmethod.location != null) productionmethod.location else default_value,
	BOMNUM: if (productionmethod.billOfMaterialId != null) productionmethod.billOfMaterialId as Number else default_value,
	INCQTY : if (productionmethod.incrementalLotQuantity.value != null) productionmethod.incrementalLotQuantity.value as Number else default_value,
	MAXQTY: if (productionmethod.maximumLotQuantity.value != null) productionmethod.maximumLotQuantity.value as Number else default_value,
	MINQTY :  if (productionmethod.minimumLotQuantity.value != null) productionmethod.minimumLotQuantity.value as Number else default_value,
	NONEWSUPPLYDATE: if (productionmethod.newSupplyPreventionDate != null)  (productionmethod.newSupplyPreventionDate replace 'Z' with ('')) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
	PRIORITY: if (productionmethod.priority != null) productionmethod.priority as Number else default_value,
	SPLITFACTOR: if (productionmethod.splitFactor != null) productionmethod.splitFactor as Number else default_value,
	DISC: if (productionmethod.effectiveUpToDate != null) (productionmethod.effectiveUpToDate replace 'Z' with ('')) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
	EFF: if (productionmethod.effectiveFromDate != null) (productionmethod.effectiveFromDate replace 'Z' with ('')) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
	EXPEDITECOST: if (productionmethod.expediteWIPUnitCost != null) productionmethod.expediteWIPUnitCost as Number else default_value,
	CAMPAIGNMINQTY: if (productionmethod.minimumCampaignLotQuantity.value != null) productionmethod.minimumCampaignLotQuantity.value as Number else default_value,
	CAMPAIGNPRIORITY: if (productionmethod.campaignPriority != null) productionmethod.campaignPriority as Number else default_value,
	DESCR: if (productionmethod.description != null) productionmethod.description else default_value,
	FINISHCAL: if (productionmethod.finishCalendar != null) productionmethod.finishCalendar else default_value,
	LEADTIME: if (productionmethod.leadTime != null) productionmethod.leadTime as Number else default_value,
	LEADTIMEEFFCNCYCAL: if (productionmethod.leadTimeEfficiencyCalendar != null) productionmethod.leadTimeEfficiencyCalendar else default_value,
	OFFSETTYPE: if (productionmethod.loadOffsetType != null) productionmethod.loadOffsetType as Number else default_value,
	PRODCOST: if (productionmethod.itemUnitProductionCost != null) productionmethod.itemUnitProductionCost as Number else default_value,
	PRODFAMILY: if (productionmethod.productionFamily != null) productionmethod.productionFamily else default_value,
	(ProductionMethodUDC: (lib.getUdcNameAndValue(productionMethodEntity, productionmethod.avpList, lib.getAvpListMap(productionmethod.avpList))[0])) 
  		if (productionmethod.avpList != null 
  			and productionMethodEntity != null
  		),
	ACTIONCODE: productionmethod.documentActionCode
}