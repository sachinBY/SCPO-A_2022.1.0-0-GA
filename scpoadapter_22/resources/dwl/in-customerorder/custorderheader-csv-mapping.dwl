%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var dateUtil = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var custOrderHeaderEntity = vars.entityMap.custorder[0].custorderheader[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload filter (lower($.'lineItem.lineStatus') == 'open') map {
	udcs: (custOrderHeaderEntity map (value, index) -> {
		scpoColumnName: value.scpoColumnName,
		scpoColumnValue: if ( not isEmpty(lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) ) (lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) else default_value,
		(dataType: value.dataType) if ((lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) != null),
	}),
	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference,
	INTEGRATION_STAMP: ((vars.creationDateAndTime as DateTime + ('PT' ++ $$ ++ 'S') as Period) replace 'T' with '') [0 to 17],
	MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
	SENDER: vars.bulkNotificationHeaders.sender,
	CUST: if (not isEmpty($.'buyer.primaryId'))
					$.'buyer.primaryId'
				 else default_value,
	EXTREF: if (not isEmpty($.orderId))
					$.orderId
				 else default_value,
	CREATIONDATE: if (not isEmpty($.creationDateTime))
					$.creationDateTime
				 else default_value,
	DMDGROUP: if (not isEmpty($.demandChannel))
					$.demandChannel
				 else default_value,
	PRIORITY: if (not isEmpty($.orderPriority))
					$.orderPriority
				 else default_value,
	ACTIONCODE: if (not isEmpty($.documentActionCode)) $.documentActionCode else vars.bulknotificationHeaders.documentActionCode
}) 
