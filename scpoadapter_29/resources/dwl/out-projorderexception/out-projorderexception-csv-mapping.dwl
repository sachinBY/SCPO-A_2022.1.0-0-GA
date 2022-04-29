%dw 2.0
output application/csv deferred=true
var udcs = vars.outboundUDCs.projorderexception[0].projorderexception[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload map {
	"recommendedPurchaseOrderException.documentActionCode": "CHANGE_BY_REFRESH",
	"recommendedPurchaseOrderException.recommendedPurchaseOrderExceptionIdentification.recommendedPurchaseOrderId": $.ORDERID,
	"recommendedPurchaseOrderException.recommendedPurchaseOrderExceptionIdentification.type" : "RECOMMENDED_ORDER_PROJECTION",
	"recommendedPurchaseOrderException.recommendedPurchaseOrderExceptionIdentification.shipFrom" : $.SOURCE,
	"recommendedPurchaseOrderException.recommendedPurchaseOrderExceptionIdentification.shipTo" : $.DEST,
	"recommendedPurchaseOrderException.recommendedPurchaseOrderExceptionIdentification.itemId" : $.ITEM,
	"recommendedPurchaseOrderException.recommendedPurchaseOrderExceptionIdentification.transportEquipmentTypeCode.value" : $.TRANSMODE,
	"recommendedPurchaseOrderException.recommendedPurchaseOrderExceptionIdentification.exceptionCodeNumber" : $.EXCEPTION as Number,
	"recommendedPurchaseOrderException.recommendedPurchaseOrderExceptionIdentification.orderGroupId" : $.ORDERGROUP,
	"recommendedPurchaseOrderException.recommendedPurchaseOrderExceptionIdentification.orderGroupMemberId" : $.ORDERGROUPMEMBER,
	"recommendedPurchaseOrderException.recommendedPurchaseOrderExceptionIdentification.exceptionDate" : $.EXCEPTIONDATE as Date as String {format: "yyyy-MM-dd", class : "java.sql.Date"},
	"recommendedPurchaseOrderException.description" : $.DESCR,
	"recommendedPurchaseOrderException.groupOrderId" : $.GROUPORDERID,
	"recommendedPurchaseOrderException.exceptionTime" : (($.WHEN as DateTime as String) splitBy("T"))[1],
    (udcs map (udc , index) -> {
		((udc.hostColumnName): lib.eval($[udc.scpoColumnName] , upper(udc.dataType)) )
	}),
})
