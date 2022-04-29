%dw 2.0
output application/java 
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var forecastEntity = vars.entityMap.fcst[0].fcst[0]
---
(payload map (forecast2, indexOfForecast2) -> {
		MS_BULK_REF: forecast2.MS_BULK_REF,
		MS_REF: forecast2.MS_REF,
		INTEGRATION_STAMP: forecast2.INTEGRATION_STAMP,
		MESSAGE_TYPE: forecast2.MESSAGE_TYPE,
  		MESSAGE_ID: forecast2.MESSAGE_ID,
  		SENDER: forecast2.SENDER,
		DMDUNIT: forecast2.DMDUNIT,
		DMDGROUP: forecast2.DMDGROUP,
		LOC: forecast2.LOC,
		STARTDATE: forecast2.STARTDATE,
		TYPE: forecast2.TYPE,
		FCSTID: forecast2.FCSTID,
		(vars.deleteudc): 'Y'
})