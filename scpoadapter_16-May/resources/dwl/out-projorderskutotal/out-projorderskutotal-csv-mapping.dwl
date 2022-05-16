%dw 2.0
output application/csv deferred=true
var udcs = vars.outboundUDCs.projorderskutotal[0].projorderskutotal[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
payload map {
	"documentActionCode": "CHANGE_BY_REFRESH",
	recommendedPurchaseOrderId: $.ORDERID as String default "",
	"type": "RECOMMENDED_ORDER_PROJECTION",
	"lineItem.itemId": $.ITEM,
	"lineItem.shipTo": $.DEST,
	"lineItem.lineItemTotal.unitOfMeasure": $.UOM as String default "",
	"lineItem.lineItemTotal.forwardBuyQuantityOrAmount": $.FWDBUYQTY,
	"lineItem.lineItemTotal.supplementalOrderQuantityOrAmount": $.SUPPORDERQTY,
	"lineItem.lineItemTotal.totalOrderQuantityOrAmount": $.QTY,
    (udcs map (udc , index) -> {
		((udc.hostColumnName): lib.eval($[udc.scpoColumnName] , upper(udc.dataType))) 
	}),
}
