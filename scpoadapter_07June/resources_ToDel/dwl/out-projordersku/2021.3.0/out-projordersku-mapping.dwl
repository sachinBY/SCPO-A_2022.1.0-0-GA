%dw 2.0
output application/json encoding = "UTF-8",deferred=true
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.projordersku[0].projordersku[0]
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.projordersku.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: "BYDM 2021.3.0",
		messageId: uuid(),
		"type": p("scpo.outbound.projordersku.messagetype"),
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
			shipFrom: $.SOURCE,
			shipTo: $.DEST,
			breakPointAdjustmentQuantity: {
				value: $.BREAKPOINTADJQTY,
				measurementUnitCode: $.UOM
			},
			breakPointMargin: $.BREAKPOINTMARGIN,
			dealId: $.DEAL,
			requestedShipDate: $.DEPARTUREDATE as Date {
				format: "yyyy-MM-dd", class : "java.sql.Date"
			},
			scheduledOnHandDate: $.ARRIVDATE as Date {
				format: "yyyy-MM-dd", class : "java.sql.Date"
			},
			forwardBuyDate: $.FWDBUYDATE as Date {
				format: "yyyy-MM-dd", class : "java.sql.Date"
			},
			forwardBuyDuration: {
				value: $.FWDBUYDUR,
				timeMeasurementUnitCode: 'DAY'
			},
			forwardBuyQuantity: {
				value: $.FWDBUYQTY,
				measurementUnitCode: $.UOM
			},
			suggestedOrderQuantity: {
				value: $.SOQ,
				measurementUnitCode: $.UOM
			},
			supplementalOrderQuantity: {
				value: $.SUPPORDERQTY,
				measurementUnitCode: $.UOM
			}
		}]
	})
}
