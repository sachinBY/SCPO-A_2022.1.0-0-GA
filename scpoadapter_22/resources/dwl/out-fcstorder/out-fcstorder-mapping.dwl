%dw 2.0
import * from dw::core::Strings
output application/json encoding = "UTF-8",deferred=true
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.fcstorder[0].fcstorder[0]
var DEFAULT_VALUE='DEFAULT'
var nettedForecastTypeCode=vars.codeMap.nettedForecastTypeCode
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.fcstorder.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: "BYDM 2021.8.0",
		messageId: uuid(),
		"type": p("scpo.outbound.fcstorder.messagetype"),
		creationDateAndTime: now()
	},
	nettedForecast2: (payload map {
		(avpList: (filter(udcs, (element, index) -> $[upper(element.scpoColumnName)] != null) map (udc , value) -> {
			name: udc.hostColumnName,
			value: $[upper(udc.scpoColumnName)]
		})) if (!isEmpty(udcs)),
		itemId: $.ITEM,
		locationId: $.LOC,
		demandChannel: $.DMDGROUP,
		nettedForecastTypeCode: if($.TYPE != null) nettedForecastTypeCode[$.TYPE][0] else DEFAULT_VALUE,
		lateReplenishmentToleranceMinutes: $.MAXLATEDUR,
		project: $.PROJECT,
		priority: $.PRIORITY,
		measure: [{
			requestedShipmentDateTime: $.NEEDDATE as DateTime,
			quantity: {
				value: $.QTY as Number,
			}
		}]
	})
}