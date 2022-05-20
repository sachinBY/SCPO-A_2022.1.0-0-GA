%dw 2.0
output application/json encoding = "UTF-8",deferred=true
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.projordersummary[0].projordersummary[0]
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.projordersummary.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: "BYDM 2021.3.0",
		messageId: uuid(),
		"type": p("scpo.outbound.projordersummary.messagetype"),
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
		shipFrom: $.SOURCE,
		shipTo: $.DEST,
		scheduledOnHandDate: $.ARRIVDATE as Date {
			format: "yyyy-MM-dd", class : "java.sql.Date"
		},
		requestedShipDate: $.DEPARTUREDATE as Date {
			format: "yyyy-MM-dd", class : "java.sql.Date"
		},
		requestedDeliveryDate: $.DELIVERYDATE as Date {
			format: "yyyy-MM-dd", class : "java.sql.Date"
		},
		groupOrderId: $.GROUPORDERID as String default null,
		orderGroupId: $.ORDERGROUP,
		orderGroupMemberId: $.ORDERGROUPMEMBER,
		requestedOrderDate: $.ORDERPLACEDATE as Date {
			format: "yyyy-MM-dd", class : "java.sql.Date"
		},
		(groupOrderType: if ( $.ORDERTYPE == 1 ) "INCLUDE" 
					        	              else if ( $.ORDERTYPE == 2 ) "SEPARATE"
					        	              else "SEPARATE_BY_ORDER_ID") if ($.ORDERTYPE == 1 or $.ORDERTYPE == 2 or $.ORDERTYPE == 3),
		transportEquipmentTypeCode: {
			value: $.TRANSMODE
		},
		additionalOrderId: $.SUPPORDERID,
		totalItemCount: $.SKUCOUNT,
		totalItemCountWithSuggestedOrderQuantity: $.SKUSOQCOUNT,
		bracketMaximumQuantity: {
			measurementUnitCode: $.UOM as String default null,
			value: $.CURRENTBRACKETMAXQTY
		},
		numberOfVehicles: $.VEHICLELOADCOUNT
	})
}
