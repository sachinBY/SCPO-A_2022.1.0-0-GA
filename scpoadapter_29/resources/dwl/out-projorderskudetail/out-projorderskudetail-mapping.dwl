%dw 2.0
output application/json encoding = "UTF-8",deferred=true
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.projorderskudetail[0].projorderskudetail[0]
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.projorderskudetail.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: "BYDM 2021.3.0",
		messageId: uuid(),
		"type": p("scpo.outbound.projorderskudetail.messagetype"),
		creationDateAndTime: now()	},
	recommendedPurchaseOrder: (payload map {
		creationDateTime: now(),
		documentStatusCode: "ORIGINAL",
		documentActionCode: "CHANGE_BY_REFRESH",
		recommendedPurchaseOrderId: $.ORDERID as String default "",
		"type": "RECOMMENDED_ORDER_PROJECTION",
		(avpList: (filter(udcs, (element, index) -> $[upper(element.scpoColumnName)] != null) map (udc , value) -> {
			name: udc.hostColumnName,
			value: $[upper(udc.scpoColumnName)]
		})) if (!isEmpty(udcs)),
		lineItem: [{
			itemId: $.ITEM,
			shipTo: $.DEST,
			lineItemDetail: {
				adjustedReceiptCoverageDuration: {
					value: $.ADJSKUCOVDUR,
					timeMeasurementUnitCode: 'DAY'
				},
				scheduledDeliveryDate: $.DELIVERYDATE as Date {
					format: "yyyy-MM-dd", class : "java.sql.Date"
				},
				minimumCoverageDate: $.MINCOVDATE as Date {
					format: "yyyy-MM-dd", class : "java.sql.Date"
				},
				averageReplenishmentQuantity: {
					measurementUnitCode: $.UOM,
					value: $.AVGREPLENQTY
				},
				delayDuration: {
					value: $.DELAYDUR,
					timeMeasurementUnitCode: 'DAY'
				},
				finalUnitCost: {
					"value": $.FINALUNITCOST,
					"currencyCode": p('scpo.outbound.projorderskudetail.currencycode')
				},
				orderPointDate: $.ORDERPOINTDATE as Date {
					format: "yyyy-MM-dd", class : "java.sql.Date"
				},
				orderPointProjectedOnHandQuantity: {
					value: $.ORDERPOINTPROJOH,
					measurementUnitCode: $.UOM
				},
				orderPointSafetyStockQuantity: {
					value: $.ORDERPOINTSSQTY,
					measurementUnitCode: $.UOM
				},
				orderPointSupplementalOrderQuantity: {
					value: $.ORDERPOINTSUPPORDERQTY,
					measurementUnitCode: $.UOM
				},
				orderUpToLevelDate: $.ORDERUPTOLEVELDATE as Date {
					format: "yyyy-MM-dd", class : "java.sql.Date"
				},
				orderUpToLevelProjectedOnHandQuantity: {
					value: $.ORDERUPTOLEVELPROJOH,
					measurementUnitCode: $.UOM
				},
				orderUpToLevelSafetyStockQuantity: {
					value: $.ORDERUPTOLEVELSSQTY,
					measurementUnitCode: $.UOM
				},
				orderUpToLevelSupplementalOrderQuantity: {
					value: $.ORDERUPTOLEVELSUPPORDERQTY,
					measurementUnitCode: $.UOM
				},
				supersedeDemandQuantity: {
					value: $.PROXYDMDQTY,
					measurementUnitCode: $.UOM
				},
				supersedeSupplyQuantity: {
					value: $.PROXYSUPPLYQTY,
					measurementUnitCode: $.UOM
				}
			}
		}]
	})
}
   	   
