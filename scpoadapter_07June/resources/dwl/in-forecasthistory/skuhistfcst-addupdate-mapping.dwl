%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
(flatten(payload.data) map(fcstHist, index) -> {
		MS_BULK_REF: fcstHist.MS_BULK_REF,
		MS_REF: fcstHist.MS_REF,
		INTEGRATION_STAMP: fcstHist.INTEGRATION_STAMP,
		MESSAGE_TYPE: fcstHist.MESSAGE_TYPE,
  		MESSAGE_ID: fcstHist.MESSAGE_ID,
  		SENDER: fcstHist.SENDER,
		ITEM: if (fcstHist.ITEM != null) fcstHist.ITEM else default_value,
		LOC: if (fcstHist.LOC != null) fcstHist.LOC else default_value,
		DUR: if (fcstHist.DUR != null) fcstHist.DUR else default_value,
		BASEFCST: if (fcstHist.BASEFCST != null) fcstHist.BASEFCST else default_value,
		FCSTDATE: if (fcstHist.FCSTDATE != null) fcstHist.FCSTDATE else default_value,
		LAG: if (fcstHist.LAG != null) fcstHist.LAG else default_value,
		NONBASEFCST: if (fcstHist.NONBASEFCST != null) fcstHist.NONBASEFCST else default_value,
		STARTDATE: if (fcstHist.STARTDATE != null) fcstHist.STARTDATE else default_value,
		(fcstHist.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
		}),
		(fcstHist.fcstUDC default [] map {
			(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
		})
})