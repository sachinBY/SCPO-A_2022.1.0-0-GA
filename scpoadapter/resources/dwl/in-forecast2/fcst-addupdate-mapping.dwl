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
		QTY: forecast2.QTY,
		DUR: forecast2.DUR,
		MODEL: forecast2.MODEL,
	    (forecast2.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(forecast2.FCSTUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
})