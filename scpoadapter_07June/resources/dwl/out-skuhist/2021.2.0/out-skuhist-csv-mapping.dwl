%dw 2.0
output application/csv deferred=true
var udcs = vars.outboundUDCs.skuhist[0].skuhist[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
payload map (value, index) -> {
	"demandHistory.documentActionCode": "CHANGE_BY_REFRESH",
	"demandHistory.itemId": value.ITEM,
	"demandHistory.locationId": value.LOC,
	"demandHistory.durationInMinutes": value.DUR,
	"demandHistory.demandQuantity.value": value.QTY,
	"demandHistory.startDateTime": value.STARTDATE,
	"demandHistory.isNetTotalHistory": value.TYPE,
    (udcs map (udc , index) -> {
		((udc.hostColumnName): lib.eval(value[udc.scpoColumnName] , upper(udc.dataType))) 
	}),
}
