%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var forecastEntity = vars.entityMap.fcst[0].skuexternalfcst[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
---
payload map(forecast,forecastIndex) -> {
		MS_BULK_REF: forecast.MS_BULK_REF,
		MS_REF: forecast.MS_REF,
		INTEGRATION_STAMP: forecast.INTEGRATION_STAMP,
		MESSAGE_TYPE: forecast.MESSAGE_TYPE,
  		MESSAGE_ID: forecast.MESSAGE_ID,
  		SENDER: forecast.SENDER,
		ITEM: forecast.ITEM, 
		LOC: forecast.LOC,
		STARTDATE: forecast.STARTDATE,
		DUR: forecast.DUR,
		QTY: forecast.QTY,
		PROJECT: forecast.PROJECT,
	  	(forecast.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(forecast.FCSTUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
	
}
