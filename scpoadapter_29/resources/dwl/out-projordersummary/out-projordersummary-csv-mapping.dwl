%dw 2.0
output application/csv deferred=true
var udcs = vars.outboundUDCs.projordersummary[0].projordersummary[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
payload map {
	"documentActionCode": "CHANGE_BY_REFRESH",
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
	"transportEquipmentTypeCode.value": $.TRANSMODE,
	additionalOrderId: $.SUPPORDERID,
	totalItemCount: $.SKUCOUNT,
	totalItemCountWithSuggestedOrderQuantity: $.SKUSOQCOUNT,
	"bracketMaximumQuantity.measurementUnitCode": $.UOM as String default null,
	"bracketMaximumQuantity.value": $.CURRENTBRACKETMAXQTY,
	numberOfVehicles: $.VEHICLELOADCOUNT,
    (udcs map (udc , index) -> {
		((udc.hostColumnName): lib.eval($[udc.scpoColumnName] , upper(udc.dataType)))
	}),
}
