%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var skuEFFIOParamEntity = vars.entityMap.sku[0].skueffioparam[0]
---
(payload map {
		udcs:((skuEFFIOParamEntity map (value, index) -> {
			scpoColumnName: value.scpoColumnName,
			scpoColumnValue: if (lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0) != null and trim(lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) != '') (lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) else default_value,
			(dataType: value.dataType) if ((lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) != null),
		}) filter sizeOf($) > 0),
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	    MS_REF: vars.storeMsgReference.messageReference,	
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		ITEM: $."itemLocationId.item.primaryId",
		LOC: $."itemLocationId.location.primaryId",
		UNITCOST: $."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.unitCost.value",
		STOCKOUTPENALTY: $."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.stockOutPenaltyAmount.value",
		REVIEWPERIOD: $."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.reviewPeriodDuration.value",
		REPLENPOLICY: if($."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.replenishmentPolicy"== "1" or $."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.replenishmentPolicy" =="2" or $."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.replenishmentPolicy"=="3" or $."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.replenishmentPolicy" =="4") $."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.replenishmentPolicy"  else "2",
		OVERSTOCKPENALTY: $."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.overStockPenaltyAmount.value",
		ORDERCOST: $."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.orderCost.value",
		MINREORDERQTY: $."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.minimumReOrderQuantity.value",
		MAXREORDERQTY: $."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.maximumReOrderQuantity.value",
		IOSERVICEPROFILE: $."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.inventoryOptimizationServiceProfile",
		HOLDINGCOST: $."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.holdingCost.value",
		HANDLINGCOST: $."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.handlingCost.value",
		EVENTTYPE: $."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.eventType",
		ENDOFLIFEDMD: $."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.endOfLifeDemand",
		//(EFF: $."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.effectiveDate" as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}) if not $."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.effectiveDate"==null,
		COEFFVAR: $."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.coefficientVariation",
		BACKORDERPENALTY: $."inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters.backOrderPenaltyAmount.value",
	
	ACTIONCODE: if ($.documentActionCode != null and !isEmpty($.documentActionCode)) $.documentActionCode else vars.bulknotificationHeaders.documentActionCode
})