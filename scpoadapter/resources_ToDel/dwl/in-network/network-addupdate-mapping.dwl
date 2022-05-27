%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"

---
 (payload map (repnet, indexOfRepnet) -> {
 		MS_BULK_REF: repnet.MS_BULK_REF,
		MS_REF: repnet.MS_REF,
		INTEGRATION_STAMP: repnet.INTEGRATION_STAMP,
		MESSAGE_TYPE: repnet.MESSAGE_TYPE,
  		MESSAGE_ID: repnet.MESSAGE_ID,
  		SENDER: repnet.SENDER,
		TRANSMODE: repnet.TRANSMODE,
		SOURCE: repnet.SOURCE,
		DEST: repnet.DEST,
		TRANSLEADTIME: repnet.TRANSLEADTIME,
		LOADTIME: repnet.LOADTIME,
		RANK: repnet.RANK,
		RATEPERCWT: repnet.RATEPERCWT,
		UNLOADTIME: repnet.UNLOADTIME,
		ORDERCOST: repnet.ORDERCOST,
		SHIPCAL: repnet.SHIPCAL,
		ARRIVCAL: repnet.ARRIVCAL,
		ORDERREVIEWCAL: repnet.ORDERREVIEWCAL,
		LEADTIMEEFFCNCYCAL: repnet.LEADTIMEEFFCNCYCAL,
	 	(repnet.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(repnet.networkUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
    	
 	 })