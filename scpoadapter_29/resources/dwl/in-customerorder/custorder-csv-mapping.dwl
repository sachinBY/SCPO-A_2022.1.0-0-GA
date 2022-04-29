%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var dateUtil = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var custOrderEntity = vars.entityMap.custorder[0].custorder[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload filter (lower($.'lineItem.lineStatus') == 'open') map {
	udcs: (custOrderEntity map (value, index) -> {
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
	DMDGROUP: if (not isEmpty($.'lineItem.demandChannel'))
					$.'lineItem.demandChannel'
				 else default_value,
	FCSTSW: if (not isEmpty($.'lineItem.isForecastOrder'))
					if (lower($.'lineItem.isForecastOrder') == "true") 1 else 0
				 else default_value,
	FCSTTYPE: if (not isEmpty($.'lineItem.forecastType'))
					$.'lineItem.forecastType'
				 else default_value,
	QTY: if (not isEmpty($.'lineItem.totalOpenQuantity.value'))
					$.'lineItem.totalOpenQuantity.value'
				 else default_value,
	RESERVATION: if (not isEmpty($.'lineItem.isReservedOrder'))
					if (lower($.'lineItem.isReservedOrder') == "true") 1 else 0
				 else default_value,
	RESEXP: if (!isEmpty($.'lineItem.reservationExpirationDateTime') and lower($.'lineItem.isReservedOrder') == "true")
					$.'lineItem.reservationExpirationDateTime'
				 else default_value,
	STATUS: if (not isEmpty($.'lineItem.planningStatus'))
					$.'lineItem.planningStatus'
				 else default_value,
	SUPERSEDESW: if (not isEmpty($.'lineItem.isSubstitutionAllowed'))
					if (lower($.'lineItem.isSubstitutionAllowed') == "true") 1 else 0
				 else default_value,
	CUST: if (not isEmpty($.'buyer.primaryId'))
					$.'buyer.primaryId'
				 else default_value,
	DELIVERYDATE: if (not isEmpty($.'lineItem.lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateTime.date'))
					$.'lineItem.lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateTime.date'[0 to 9]
					as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
				 else default_value,
	DFULOC: if (not isEmpty($.'lineItem.lineItemDetail.orderLogisticalInformation.shipFrom.primaryId'))
					$.'lineItem.lineItemDetail.orderLogisticalInformation.shipFrom.primaryId'
				 else default_value,
	DEST: if (not isEmpty($.'lineItem.lineItemDetail.orderLogisticalInformation.shipTo.primaryId'))
					$.'lineItem.lineItemDetail.orderLogisticalInformation.shipTo.primaryId'
				 else default_value,
	DMDUNIT: if (not isEmpty($.'lineItem.transactionalTradeItem.primaryId'))
					$.'lineItem.transactionalTradeItem.primaryId'
				 else default_value,
	HEADEREXTREF: if (not isEmpty($.orderId))
					$.orderId
				 else default_value,
	ITEM: if (not isEmpty($.'lineItem.transactionalTradeItem.primaryId'))
					$.'lineItem.transactionalTradeItem.primaryId'
				 else default_value,
	LINEITEMEXTREF: if (not isEmpty($.'lineItem.lineItemNumber'))
					$.'lineItem.lineItemNumber'
				 else default_value,
	LOC: if (not isEmpty($.'lineItem.lineItemDetail.orderLogisticalInformation.shipFrom.primaryId'))
					$.'lineItem.lineItemDetail.orderLogisticalInformation.shipFrom.primaryId'
				 else default_value,
	MAXEARLYDUR: if (!isEmpty($.'lineItem.lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.date') 
						and !isEmpty($.'lineItem.lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateRange.beginDate'))
						ceil(dateUtil.utcToSeconds($.'lineItem.lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.date')
								- 
							dateUtil.utcToSeconds($.'lineItem.lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateRange.beginDate'))
				 else default_value,
	MAXLATEDUR: if (!isEmpty($.'lineItem.lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.date') 
						and !isEmpty($.'lineItem.lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateRange.endDate'))
						ceil(dateUtil.utcToSeconds($.'lineItem.lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateRange.endDate')
								- 
							dateUtil.utcToSeconds($.'lineItem.lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.date'))
				 else default_value,
	ORDERID: if (!isEmpty($.orderId) and !isEmpty($.'lineItem.lineItemNumber'))
					$.orderId ++ "_" ++ $.'lineItem.lineItemNumber'
				 else default_value,
	PRIORITY: if (not isEmpty($.'lineItem.orderLinePriority'))
					$.'lineItem.orderLinePriority'
				 else default_value,
	SHIPDATE: if (!isEmpty($.'lineItem.lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.date') and !isEmpty($.'lineItem.lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.time'))
					$.'lineItem.lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.date'[0 to 9]
					++ 'T' 
					++ $.'lineItem.lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedShipDateTime.time'
				 else default_value,
	UNITPRICE: if (not isEmpty($.'lineItem.netPrice.value'))
					$.'lineItem.netPrice.value'
				  else default_value,
	ACTIONCODE: if (not isEmpty($.documentActionCode)) $.documentActionCode else vars.bulknotificationHeaders.documentActionCode
})
