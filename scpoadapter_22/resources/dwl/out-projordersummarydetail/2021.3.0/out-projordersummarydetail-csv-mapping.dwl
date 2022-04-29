%dw 2.0
output application/csv deferred=true
var udcs = vars.outboundUDCs.projordersummarydetail[0].projordersummarydetail[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload map {
	"documentActionCode": "CHANGE_BY_REFRESH",
	"recommendedPurchaseOrderId":$.ORDERID as String default "",
	"type": "RECOMMENDED_ORDER_PROJECTION",
	"recommendedPurchaseOrder.orderDetail.delayDuration.value": $.DELAYDUR,
	"recommendedPurchaseOrder.orderDetail.delayDuration.timeMeasurementUnitCode" : "DAY",
	"recommendedPurchaseOrder.orderDetail.finalCoverageDuration.value" : $.FINALCOVDUR,
	"recommendedPurchaseOrder.orderDetail.finalCoverageDuration.timeMeasurementUnitCode" : "DAY",
	"recommendedPurchaseOrder.orderDetail.minimumCoverageDuration.value" : $.MINCOVDUR,
	"recommendedPurchaseOrder.orderDetail.minimumCoverageDuration.timeMeasurementUnitCode" : "DAY",
	"recommendedPurchaseOrder.orderDetail.minimumCoverageDate" : $.MINCOVDATE,
	"recommendedPurchaseOrder.orderDetail.orderCoverageDuration.value" : $.NEEDCOVDUR,
	"recommendedPurchaseOrder.orderDetail.orderCoverageDuration.timeMeasurementUnitCode" : "DAY",
	"recommendedPurchaseOrder.orderDetail.orderProcessingDate" : $.SOURCEPROCESSINGDATE,
	"recommendedPurchaseOrder.orderDetail.orderGroupBuildRule" : if($.ORDERGROUPBUILDRULE == 0) "NONE" else if ($.ORDERGROUPBUILDRULE == 1) "BUILD_TO_GROUP" else if ($.ORDERGROUPBUILDRULE == 2) "BUILD_TO_MEMBER" else "",
    (udcs map (udc , index) -> {
		((udc.hostColumnName): lib.eval($[udc.scpoColumnName] , upper(udc.dataType)))
	}),
})
