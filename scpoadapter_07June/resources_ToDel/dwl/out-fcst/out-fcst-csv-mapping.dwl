%dw 2.0
output application/csv deferred=true
var DEFAULT_VALUE='DEFAULT'
var forecastTypeCodeForFcst=vars.codeMap.forecastTypeCodeForFcst
var udcs = vars.outboundUDCs.fcst[0].fcst[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
payload map ((item, index) ->{

"forecast2.itemId": item.DMDUNIT,	
"forecast2.locationId":item.LOC,	
"forecast2.demandChannel":item.DMDGROUP,
"forecast2.forecastId":item.FCSTID,	
"forecast2.forecastTypeCode":if(item.TYPE != null) forecastTypeCodeForFcst[item.TYPE][0] else DEFAULT_VALUE,
"forecast2.modelId":item.MODEL,	
"forecast2.measure.forecastStartDate":item.STARTDATE,	
"forecast2.measure.durationInMinutes": item.DUR,
"forecast2.measure.quantity.value":item.QTY,
(udcs map (udc , index) -> {
		((udc.hostColumnName): lib.eval(item[udc.scpoColumnName] , upper(udc.dataType))) 
}),	
}
 )