%dw 2.0
import * from dw::core::Strings
output application/json encoding="UTF-8"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.fcst[0].fcst[0]
var DEFAULT_VALUE='DEFAULT'
var forecastTypeCodeForFcst=vars.codeMap.forecastTypeCodeForFcst
---
{header:{
   sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.fcst.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: "BYDM 2021.5.0",
		messageId: uuid(),
		"type": p("scpo.outbound.fcst.messagetype"),
		creationDateAndTime: now()},
    forecast2:(payload map {
        itemId:$.DMDUNIT,
        locationId:$.LOC,
        demandChannel:$.DMDGROUP,
         (avpList: 
					(filter(udcs, (element, index) -> $[upper(element.scpoColumnName)] != null) map (udc , value) -> {
						name: udc.hostColumnName,
						value: $[upper(udc.scpoColumnName)]
					})
				) if (!isEmpty(udcs)),
    		forecastId: $.FCSTID,
    		forecastTypeCode: if($.TYPE != null) forecastTypeCodeForFcst[$.TYPE][0] else DEFAULT_VALUE,
    		modelId:$.MODEL,
    		measure:[{
    			forecastStartDate: substringBefore($.'FN_STARTDATE',"T"),
    			durationInMinutes: $.DUR,
    			quantity:{
    				value: if($.'TMP_QTY' != null) $.'TMP_QTY' else (($.QTY as Number default 0) + ($[('PERIOD') ++ ((($.'FN_STARTDATE' as Date - $.STARTDATE as Date).days + (vars.temp.noOfDays as Number default 1) as String))] as Number default 0)),
    			}
    		}]
    })}