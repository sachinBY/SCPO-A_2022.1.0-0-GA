%dw 2.0
output application/csv deferred=true
var DEFAULT_VALUE='DEFAULT'
var udcs = vars.outboundUDCs.fcstorder[0].fcstorder[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var nettedForecastTypeCode=vars.codeMap.nettedForecastTypeCode
---
payload map ((item, index) ->{
	"itemId": item.ITEM,
	"locationId": item.LOC,
	"demandChannel": item.DMDGROUP,
	"nettedForecastTypeCode": if(item.TYPE != null) nettedForecastTypeCode[item.TYPE][0] else DEFAULT_VALUE,
	"lateReplenishmentToleranceMinutes": item.MAXLATEDUR,
	"project": item.PROJECT,
	"priority": item.PRIORITY,
	"measure.quantity.requestedShipmentDateTime": item.NEEDDATE as DateTime,
	"measure.quantity.value": item.QTY,
	(udcs map (udc , index) -> {
		((udc.hostColumnName): lib.eval(item[udc.scpoColumnName] , upper(udc.dataType)))
	}),
})