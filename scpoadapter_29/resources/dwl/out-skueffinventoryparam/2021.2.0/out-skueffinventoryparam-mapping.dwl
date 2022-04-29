%dw 2.0
import * from dw::core::Strings
output application/json encoding = "UTF-8"
var udcs = vars.outboundUDCs.skueffinventoryparam[0].skueffinventoryparam[0]
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.skueffinventoryparam.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: "BYDM 2021.2.0",
		messageId: uuid(),
		"type": p("scpo.outbound.skueffinventoryparam.messagetype"),
		creationDateAndTime: now()
	},
	itemLocationEffectiveInventoryParameters: flatten(flatten(payload map ((item, index) -> {
    value:(flatten(item pluck($))) map  {
		creationDateTime: now() as DateTime,
		documentStatusCode: "ORIGINAL",
		documentActionCode: "CHANGE_BY_REFRESH",
		itemLocationEffectiveInventoryParametersId: {
			item: {
				primaryId: $.ITEM
			},
			location: {
				primaryId: $.LOC
			}
		},
		(avpList: (filter(udcs, (element, index) -> $[upper(element.scpoColumnName)] != null) map (udc , value) -> {
			name: udc.hostColumnName,
			value: $[upper(udc.scpoColumnName)]
		})) if (!isEmpty(udcs)),
		effectiveInventoryParameters: [ {
			effectiveFromDateTime: $.EFF as DateTime,
			maximumCoverageDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.MAXCOVDUR
			},
			maximumOnHandQuantity: {
				measurementUnitCode: "EA",
				value: $.MAXOHQTY
			},
			minimumSafetyStockQuantity: {
				measurementUnitCode: "EA",
				value: $.MINSSQTY
			},
			safetyStockCoverageDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.SSCOVDUR
			}
		}]	
}
})).value)}	