%dw 2.0
output application/csv deferred=true
var udcs = vars.outboundUDCs.fcst[0].dfutoskufcst[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
payload map ((item, index) ->{

"itemId": item.ITEM,	
"locationId":item.SKULOC,	
 "demandChannel":item.DMDGROUP,	
"forecastTypeCode":if(item.TYPE != null) item.TYPE as String else '',	
"measure.forecastStartDate":item.STARTDATE,	
"measure.durationInMinutes": item.DUR,	
"measure.quantity.value":item.TOTFCST,
(udcs map (udc , index) -> {
		((udc.hostColumnName): lib.eval(item[udc.scpoColumnName] , upper(udc.dataType)))
}),	
}
 )