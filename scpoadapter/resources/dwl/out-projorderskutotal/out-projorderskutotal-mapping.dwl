%dw 2.0
output application/json encoding = "UTF-8",deferred=true
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.projorderskutotal[0].projorderskutotal[0]
---
{
	header: {
			sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.projordertotal.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: "BYDM 2021.3.0",
		messageId: uuid(),
		"type": p("scpo.outbound.projordertotal.messagetype"),
		creationDateAndTime: now()
	},
	recommendedPurchaseOrder: (payload map {
		creationDateTime: now(),
		documentStatusCode: "ORIGINAL",
		documentActionCode: "CHANGE_BY_REFRESH",
		(avpList: (filter(udcs, (element, index) -> $[upper(element.scpoColumnName)] != null) map (udc , value) -> {
			name: udc.hostColumnName,
			value: $[upper(udc.scpoColumnName)]
		})) if (!isEmpty(udcs)),
		recommendedPurchaseOrderId: $.ORDERID as String default "",
		"type": "RECOMMENDED_ORDER_PROJECTION",
		lineItem: [{
			itemId: $.ITEM,
			shipTo: $.DEST,
			lineItemTotal: [{
				unitOfMeasure: $.UOM as String default "",
				forwardBuyQuantityOrAmount: $.FWDBUYQTY,
				supplementalOrderQuantityOrAmount: $.SUPPORDERQTY,
				totalOrderQuantityOrAmount: $.QTY
			}]
		}]
	})
}
