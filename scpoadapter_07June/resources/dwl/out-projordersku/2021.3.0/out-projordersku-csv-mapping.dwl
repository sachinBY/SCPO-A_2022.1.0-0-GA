%dw 2.0
output application/csv deferred=true
var udcs = vars.outboundUDCs.projordersku[0].projordersku[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
payload map
{
	"documentActionCode": "CHANGE_BY_REFRESH",
	recommendedPurchaseOrderId: $.ORDERID as String default "",
	"type": "RECOMMENDED_ORDER_PROJECTION",
	"lineItem.itemId": $.ITEM,
	"lineItem.shipFrom": $.SOURCE,
	"lineItem.shipTo": $.DEST,
	"lineItem.breakPointAdjustmentQuantity.value": $.BREAKPOINTADJQTY,
	"lineItem.breakPointAdjustmentQuantity.measurementUnitCode": $.UOM,
	"lineItem.breakPointMargin": $.BREAKPOINTMARGIN,
	"lineItem.dealId": $.DEAL,
	"lineItem.requestedShipDate": $.DEPARTUREDATE as Date {
		format: "yyyy-MM-dd", class : "java.sql.Date"
	},
	"lineItem.scheduledOnHandDate": $.ARRIVDATE as Date {
		format: "yyyy-MM-dd", class : "java.sql.Date"
	},
	"lineItem.forwardBuyDate": $.FWDBUYDATE as Date {
		format: "yyyy-MM-dd", class : "java.sql.Date"
	},
	"lineItem.forwardBuyDuration.value": $.FWDBUYDUR,
	"lineItem.forwardBuyDuration.timeMeasurementUnitCode": "DAY",
	"lineItem.forwardBuyQuantity.value": $.FWDBUYQTY,
	"lineItem.forwardBuyQuantity.measurementUnitCode": $.UOM,
	"lineItem.suggestedOrderQuantity.value": $.SOQ,
	"lineItem.suggestedOrderQuantity.measurementUnitCode": $.UOM,
	"lineItem.supplementalOrderQuantity.value": $.SUPPORDERQTY,
	"lineItem.supplementalOrderQuantity.measurementUnitCode": $.UOM,
    (udcs map (udc , index) -> {
			((udc.hostColumnName): lib.eval($[udc.scpoColumnName] , upper(udc.dataType)) )
	}),
}
