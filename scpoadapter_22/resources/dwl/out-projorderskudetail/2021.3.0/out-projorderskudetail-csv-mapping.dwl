%dw 2.0
output application/csv deferred=true
var udcs = vars.outboundUDCs.projorderskudetail[0].projorderskudetail[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
payload map {
	"documentActionCode": "CHANGE_BY_REFRESH",
	"recommendedPurchaseOrderId": $.ORDERID as String default "",
	"type": "RECOMMENDED_ORDER_PROJECTION",
	"lineItem.itemId": $.ITEM,
	"lineItem.shipTo": $.DEST,
	"lineItem.lineItemDetail.adjustedReceiptCoverageDuration.value": $.ADJSKUCOVDUR,
	"lineItem.lineItemDetail.adjustedReceiptCoverageDuration.timeMeasurementUnitCode": 'DAY',
	"lineItem.lineItemDetail.scheduledDeliveryDate": $.DELIVERYDATE as Date {
		format: "yyyy-MM-dd", class : "java.sql.Date"
	},
	"lineItem.lineItemDetail.minimumCoverageDate": $.MINCOVDATE as Date {
		format: "yyyy-MM-dd", class : "java.sql.Date"
	},
	"lineItem.lineItemDetail.averageReplenishmentQuantity.value": $.AVGREPLENQTY,
	"lineItem.lineItemDetail.averageReplenishmentQuantity.measurementUnitCode": $.UOM,
	"lineItem.lineItemDetail.delayDuration.value": $.DELAYDUR,
	"lineItem.lineItemDetail.delayDuration.timeMeasurementUnitCode": 'DAY',
	"lineItem.lineItemDetail.finalUnitCost.value": $.FINALUNITCOST,
	"lineItem.lineItemDetail.finalUnitCost.currencyCode": p('scpo.outbound.projorderskudetail.currencycode'),
	"lineItem.lineItemDetail.orderPointDate": $.ORDERPOINTDATE as Date {
		format: "yyyy-MM-dd", class : "java.sql.Date"
	},
	"lineItem.lineItemDetail.orderPointProjectedOnHandQuantity.value": $.ORDERPOINTPROJOH,
	"lineItem.lineItemDetail.orderPointProjectedOnHandQuantity.measurementUnitCode": $.UOM,
	"lineItem.lineItemDetail.orderPointSafetyStockQuantity.value": $.ORDERPOINTSSQTY,
	"lineItem.lineItemDetail.orderPointSafetyStockQuantity.measurementUnitCode": $.UOM,
	"lineItem.lineItemDetail.orderPointSupplementalOrderQuantity.value": $.ORDERPOINTSUPPORDERQTY,
	"lineItem.lineItemDetail.orderPointSupplementalOrderQuantity.measurementUnitCode": $.UOM,
	"lineItem.lineItemDetail.orderUpToLevelDate": $.ORDERUPTOLEVELDATE as Date {
		format: "yyyy-MM-dd", class : "java.sql.Date"
	},
	"lineItem.lineItemDetail.orderUpToLevelProjectedOnHandQuantity.value": $.ORDERUPTOLEVELPROJOH,
	"lineItem.lineItemDetail.orderUpToLevelProjectedOnHandQuantity.measurementUnitCode": $.UOM,
	"lineItem.lineItemDetail.orderUpToLevelSafetyStockQuantity.value": $.ORDERUPTOLEVELSSQTY,
	"lineItem.lineItemDetail.orderUpToLevelSafetyStockQuantity.measurementUnitCode": $.UOM,
	"lineItem.lineItemDetail.orderUpToLevelSupplementalOrderQuantity.value": $.ORDERUPTOLEVELSUPPORDERQTY,
	"lineItem.lineItemDetail.orderUpToLevelSupplementalOrderQuantity.measurementUnitCode": $.UOM,
	"lineItem.lineItemDetail.supersedeDemandQuantity.value": $.PROXYDMDQTY,
	"lineItem.lineItemDetail.supersedeDemandQuantity.measurementUnitCode": $.UOM,
	"lineItem.lineItemDetail.supersedeSupplyQuantity.value": $.PROXYSUPPLYQTY,
	"lineItem.lineItemDetail.supersedeSupplyQuantity.measurementUnitCode": $.UOM,
    (udcs map (udc , index) -> {
		((udc.hostColumnName): lib.eval($[udc.scpoColumnName] , upper(udc.dataType)))
	}),
}
   	   
