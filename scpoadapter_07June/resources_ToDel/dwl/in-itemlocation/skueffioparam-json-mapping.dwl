%dw 2.0
output application/java
var skuEffIOParamEntity = vars.entityMap.sku[0].skueffioparam[0]
var default_value = "###JDA_DEFAULT_VALUE###"
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var conversionToSeconds=vars.codeMap."time-units-seconds-conversion"
var conversionToMinutes=vars.codeMap."time-units-minutes-conversion"
var conversionToHours=vars.codeMap."time-units-hours-conversion"
var conversionToDays=vars.codeMap."time-units-days-conversion"
var conversionToWeeks=vars.codeMap."time-units-weeks-conversion"
var conversionToMonths=vars.codeMap."time-units-months-conversion"
var conversionToYears=vars.codeMap."time-units-years-conversion"
---
(payload.itemLocation map(itemLocation,index) -> {
(if(itemLocation.inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters != null) {
arr:(itemLocation.inventoryOptimizationParameters.inventoryOptimizationEffectiveParameters map (eff,index) -> {
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,	
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		ITEM: itemLocation.itemLocationId.item.primaryId,
		LOC: itemLocation.itemLocationId.location.primaryId,
		UNITCOST: eff.unitCost.value,
		STOCKOUTPENALTY: eff.stockOutPenaltyAmount.value,
		REVIEWPERIOD: if(eff.reviewPeriodDuration.value != null) 
						if(eff.reviewPeriodDuration.timeMeasurementUnitCode != null) 		   		   			
							if(lower(p("bydm.inbound.skueffioparam.timemeasurementunitcode")) startsWith "sec") 
									
										ceil(eff.reviewPeriodDuration.value * conversionToSeconds[eff.reviewPeriodDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skueffioparam.timemeasurementunitcode")) startsWith "hour") 
									
										ceil(eff.reviewPeriodDuration.value * conversionToHours[eff.reviewPeriodDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skueffioparam.timemeasurementunitcode")) startsWith "day") 
									
										ceil(eff.reviewPeriodDuration.value * conversionToDays[eff.reviewPeriodDuration.timeMeasurementUnitCode][0]  as Number) 
							else if(lower(p("bydm.inbound.skueffioparam.timemeasurementunitcode")) startsWith "week") 
									
										ceil(eff.reviewPeriodDuration.value * conversionToWeeks[eff.reviewPeriodDuration.timeMeasurementUnitCode][0]  as Number) 			
							else if(lower(p("bydm.inbound.skueffioparam.timemeasurementunitcode")) startsWith "month") 
									
										ceil(eff.reviewPeriodDuration.value * conversionToMonths[eff.reviewPeriodDuration.timeMeasurementUnitCode][0]  as Number)
							else if(lower(p("bydm.inbound.skueffioparam.timemeasurementunitcode")) startsWith "year") 
									
										ceil(eff.reviewPeriodDuration.value * conversionToYears[eff.reviewPeriodDuration.timeMeasurementUnitCode][0]  as Number)
							else 
									
										ceil(eff.reviewPeriodDuration.value * conversionToMinutes[eff.reviewPeriodDuration.timeMeasurementUnitCode][0] as Number)
						else 
								eff.reviewPeriodDuration.value
					else 
						default_value,				

		REPLENPOLICY: if(eff.replenishmentPolicy== "1" or eff.replenishmentPolicy =="2" or eff.replenishmentPolicy=="3" or eff.replenishmentPolicy =="4") eff.replenishmentPolicy  else "2",
		OVERSTOCKPENALTY: eff.overStockPenaltyAmount.value,
		ORDERCOST: eff.orderCost.value,
		MINREORDERQTY: eff.minimumReOrderQuantity.value,
		MAXREORDERQTY: eff.maximumReOrderQuantity.value,
		IOSERVICEPROFILE: eff.inventoryOptimizationServiceProfile,
		HOLDINGCOST: eff.holdingCost.value,
		HANDLINGCOST: eff.handlingCost.value,
		EVENTTYPE: eff.eventType,
		ENDOFLIFEDMD: eff.endOfLifeDemand,
		(EFF: eff.effectiveFromDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}) if not eff.effectiveFromDate==null,
		COEFFVAR: eff.coefficientVariation,
		BACKORDERPENALTY: eff.backOrderPenaltyAmount.value,

			SKUEffIOParamUDC:(flatten([(lib.getUdcNameAndValue(skuEffIOParamEntity, itemLocation.avpList, lib.getAvpListMap(itemLocation.avpList) )[0]) 
	if (itemLocation.avpList != null 
		and (itemLocation.documentActionCode == "ADD" or itemLocation.documentActionCode == "CHANGE_BY_REFRESH")
		and skuEffIOParamEntity != null
	),
	(lib.getUdcNameAndValue(skuEffIOParamEntity, itemLocation.inventoryOptimizationParameters.avpList, lib.getAvpListMap(itemLocation.inventoryOptimizationParameters.avpList) )[0]) 
	if (itemLocation.inventoryOptimizationParameters.avpList != null 
		and (itemLocation.documentActionCode == "ADD" or itemLocation.documentActionCode == "CHANGE_BY_REFRESH")
		and skuEffIOParamEntity != null
	)])),
	ACTIONCODE: itemLocation.documentActionCode
	})}
else {
arr:[{(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference,	
	ITEM:itemLocation.itemLocationId.item.primaryId,
    LOC:itemLocation.itemLocationId.location.primaryId,
	SKUEffIOParamUDC:(flatten([(lib.getUdcNameAndValue(skuEffIOParamEntity, itemLocation.avpList, lib.getAvpListMap(itemLocation.avpList) )[0]) 
	if (itemLocation.avpList != null 
		and (itemLocation.documentActionCode == "ADD" or itemLocation.documentActionCode == "CHANGE_BY_REFRESH")
		and skuEffIOParamEntity != null
	)])),
	ACTIONCODE: itemLocation.documentActionCode}]	
})	
}).arr reduce($ ++ $$)