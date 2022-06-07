%dw 2.0
var udcs = vars.outboundUDCs.ordersku[0].ordersku[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
output application/csv deferred=true
---
payload map {
			"documentActionCode": "CHANGE_BY_REFRESH",
			"recommendedPurchaseOrderId": $.ORDERID as String default "",
			"type":"RECOMMENDED_ORDER_PROJECTION",
			"lineItem.itemId": $.ITEM,
			"lineItem.shipTo": $.DEST,
			"lineItem.shipFrom": $.SOURCE,
			"lineItem.scheduledOnHandDate": $.ARRIVDATE as Date {format: "yyyy-MM-dd", class : "java.sql.Date"},
			"lineItem.forwardBuyDate": $.FWDBUYDATE as Date {format: "yyyy-MM-dd", class : "java.sql.Date"},
			"lineItem.lineItemDetail.delayDuration.value": $.DELAYDUR, 
			"lineItem.lineItemDetail.delayDuration.timeMeasurementUnitCode": 'DAY',
			"lineItem.lineItemDetail.finalUnitCost.value": $.FINALUNITCOST, 
			"lineItem.lineItemDetail.finalUnitCost.currencyCode": p('bydm.projorderskudetail.currencyCode'),		
			"lineItem.lineItemDetail.forwardBuyDuration.value": $.FWDBUYDUR, 
			"lineItem.lineItemDetail.forwardBuyDuration.timeMeasurementUnitCode": "DAY",
			"lineItem.lineItemDetail.forwardBuyQuantity.value": $.FWDBUYQTY, 
			"lineItem.lineItemDetail.forwardBuyQuantity.measurementUnitCode": $.UOM,
			"lineItem.lineItemDetail.suggestedOrderQuantity.value": $.SOQ, 
			"lineItem.lineItemDetail.suggestedOrderQuantity.measurementUnitCode": $.UOM,	
			"lineItem.lineItemDetail.supplementalOrderQuantity.value": $.SUPPORDERQTY, 
			"lineItem.lineItemDetail.supplementalOrderQuantity.measurementUnitCode": $.UOM,		
			"lineItem.lastOrderOptimizeDate":$.EXPDATE as Date {format: "yyyy-MM-dd", class : "java.sql.Date"},
			"lineItem.onHandPostDate": $.OHPOST as Date {format: "yyyy-MM-dd", class : "java.sql.Date"},
			"lineItem.lineItemDetail.suggestedOrderQuantityCoverageDuration.value": $.SOQCOVDUR, 
			"lineItem.lineItemDetail.suggestedOrderQuantityCoverageDuration.timeMeasurementUnitCode": "DAY",		
			"lineItem.status": $.STATUS,
			(udcs map (udc , index) -> {
			((udc.hostColumnName): lib.eval($[udc.scpoColumnName] , upper(udc.dataType)) )
	}),
}
   	   
