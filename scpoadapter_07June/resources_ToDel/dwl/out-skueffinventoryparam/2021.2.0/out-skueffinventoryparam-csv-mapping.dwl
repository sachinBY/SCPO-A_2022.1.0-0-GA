%dw 2.0
output application/csv
var udcs = vars.outboundUDCs.skueffinventoryparam[0].skueffinventoryparam[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
flatten(flatten(payload map ((item1, index1) -> {
    value:(flatten(item1 pluck($))) map (item, index) -> {
    	 "itemLocationEffectiveInventoryParameters.documentActionCode": "CHANGE_BY_REFRESH",	
	"itemLocationEffectiveInventoryParameters.itemLocationEffectiveInventoryParametersId.item.primaryId": item.ITEM,
	"itemLocationEffectiveInventoryParameters.itemLocationEffectiveInventoryParametersId.location.primaryId": item.LOC,
	"itemLocationEffectiveInventoryParameters.effectiveInventoryParameters.effectiveFromDateTime": item.EFF as DateTime,
	"itemLocationEffectiveInventoryParameters.effectiveInventoryParameters.maximumCoverageDuration.timeMeasurementUnitCode": "MIN",
	"itemLocationEffectiveInventoryParameters.effectiveInventoryParameters.maximumCoverageDuration.value": item.MAXCOVDUR,
	"itemLocationEffectiveInventoryParameters.effectiveInventoryParameters.maximumOnHandQuantity.measurementUnitCode": "EA",
	"itemLocationEffectiveInventoryParameters.effectiveInventoryParameters.maximumOnHandQuantity.value": item.MAXOHQTY,
	"itemLocationEffectiveInventoryParameters.effectiveInventoryParameters.minimumSafetyStockQuantity.measurementUnitCode": "EA",
	"itemLocationEffectiveInventoryParameters.effectiveInventoryParameters.minimumSafetyStockQuantity.value": item.MINSSQTY,
	"itemLocationEffectiveInventoryParameters.effectiveInventoryParameters.safetyStockCoverageDuration.timeMeasurementUnitCode": "MIN",
	"itemLocationEffectiveInventoryParameters.effectiveInventoryParameters.minimumSafetyStockQuantity.value": item.SSCOVDUR,
	(udcs map (udc , index) -> {
		((udc.hostColumnName): lib.eval(item[udc.scpoColumnName] , upper(udc.dataType)))
	}),
}})).value)