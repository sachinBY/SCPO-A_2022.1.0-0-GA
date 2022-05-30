%dw 2.0
output application/csv
var DEFAULT_VALUE='DEFAULT'
var forecastTypeCodeForFcst=vars.codeMap.forecastTypeCodeForFcst
---
payload map ((item, index) ->{
"forecast2.itemId": item.DMDUNIT,	
"forecast2.locationId":item.LOC,	
"forecast2.demandChannel":item.DMDGROUP,
"forecast2.forecastId":item.FCSTID,	
"forecast2.forecastTypeCode": if(item.TYPE != null) forecastTypeCodeForFcst[item.TYPE][0] else DEFAULT_VALUE,
"forecast2.modelId":item.MODEL,	
"forecast2.measure.forecastStartDate":item.'FN_STARTDATE',	
"forecast2.measure.durationInMinutes": item.DUR,
"forecast2.measure.quantity.value": if(item.'TMP_QTY' != null) item.'TMP_QTY' else ((item.QTY as Number default 0) + (item[('PERIOD') ++ (((item.'FN_STARTDATE' as Date - item.STARTDATE as Date).days + (vars.temp.noOfDays as Number default 1) as String))] as Number default 0))
}
 )