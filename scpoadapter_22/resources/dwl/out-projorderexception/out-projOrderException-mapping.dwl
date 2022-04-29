%dw 2.0
output application/json encoding = "UTF-8",deferred=true
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.projorderexception[0].projorderexception[0]
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.projorderexception.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: "BYDM 2021.3.0",
		messageId: uuid(),
		"type": p("scpo.outbound.projorderexception.messagetype"),
		creationDateAndTime: now()
	},
	recommendedPurchaseOrderException: (payload map {
		creationDateTime: now(),
		documentStatusCode: "ORIGINAL",
		documentActionCode: "CHANGE_BY_REFRESH",
		(avpList: (filter(udcs, (element, index) -> $[upper(element.scpoColumnName)] != null) map (udc , value) -> {
			name: udc.hostColumnName,
			value: $[upper(udc.scpoColumnName)]
		})) if (!isEmpty(udcs)),
		recommendedPurchaseOrderExceptionIdentification: {
			recommendedPurchaseOrderId: $.ORDERID as String default "",
			"type": "RECOMMENDED_ORDER_PROJECTION",
			"shipFrom": $.SOURCE,
			"shipTo": $.DEST,
			"itemId": $.ITEM,
			"transportEquipmentTypeCode": {
				"value": $.TRANSMODE
			},
			"exceptionCodeNumber": $.EXCEPTION as Number,
			"orderGroupId": $.ORDERGROUP,
			"orderGroupMemberId": $.ORDERGROUPMEMBER,
			"exceptionDate": $.EXCEPTIONDATE as Date as String {
				format: "yyyy-MM-dd", class : "java.sql.Date"
			},
		},
		"description": $.DESCR,
		"groupOrderId": $.GROUPORDERID as String,
		"exceptionTime": (($.WHEN as DateTime as String) splitBy("T"))[1] default "",
	})
}
