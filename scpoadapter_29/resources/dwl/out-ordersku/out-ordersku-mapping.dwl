%dw 2.0
output application/json encoding = "UTF-8",deferred=true
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.ordersku[0].ordersku[0]
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.ordersku.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: "BYDM 2021.3.0",
		messageId: uuid(),
		"type": p("scpo.outbound.ordersku.messagetype"),
		creationDateAndTime: now()
	},
	recommendedPurchaseOrder:(payload map {
		
			creationDateTime: now(),
			documentStatusCode: "ORIGINAL",
			documentActionCode: "CHANGE_BY_REFRESH",
			recommendedPurchaseOrderId: $.ORDERID as String default "",
			"type":"RECOMMENDED_ORDER_PROJECTION",
	
	 (avpList: 
					(filter(udcs, (element, index) -> $[upper(element.scpoColumnName)] != null) map (udc , value) -> {
						name: udc.hostColumnName,
						value: $[upper(udc.scpoColumnName)]
					})
				) if (!isEmpty(udcs)),
			
			lineItem:[{
				itemId: $.ITEM,
				shipTo: $.DEST,
				shipFrom: $.SOURCE,
				scheduledOnHandDate: $.ARRIVDATE as Date {format: "yyyy-MM-dd", class : "java.sql.Date"},
				forwardBuyDate: $.FWDBUYDATE as Date {format: "yyyy-MM-dd", class : "java.sql.Date"},
				forwardBuyDuration:{
					value: $.FWDBUYDUR,
					timeMeasurementUnitCode: "DAY"
				},
				forwardBuyQuantity:{
					value: $.FWDBUYQTY,
					measurementUnitCode: $.UOM
				},
				suggestedOrderQuantity:{
					value: $.SOQ,
					measurementUnitCode: $.UOM
				},
				supplementalOrderQuantity:{
					value: $.SUPPORDERQTY,
					measurementUnitCode: $.UOM
				},
				lastOrderOptimizeDate:$.EXPDATE as Date {format: "yyyy-MM-dd", class : "java.sql.Date"},
				onHandPostDate: $.OHPOST as Date {format: "yyyy-MM-dd", class : "java.sql.Date"},
				suggestedOrderQuantityCoverageDuration:{
					value: $.SOQCOVDUR,
					timeMeasurementUnitCode: "DAY"
				},
				status: $.STATUS as String,
				lineItemDetail: {
					finalUnitCost: {
						"value": $.FINALUNITCOST,
						"currencyCode": p('bydm.projorderskudetail.currencyCode')
					},
					delayDuration: {
						value: $.DELAYDUR,
						timeMeasurementUnitCode: 'DAY'
					},
				}
			}]
		}
	)
}
   	   
