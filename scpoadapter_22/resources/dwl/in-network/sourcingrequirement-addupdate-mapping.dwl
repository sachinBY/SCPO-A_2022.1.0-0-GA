%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"

---
 (payload map (sourcingreq, indexOfSourcingReq) -> {
 			MS_BULK_REF: sourcingreq.MS_BULK_REF,
			MS_REF: sourcingreq.MS_REF,
 			INTEGRATION_STAMP: sourcingreq.INTEGRATION_STAMP,
 			MESSAGE_TYPE: sourcingreq.MESSAGE_TYPE,
  			MESSAGE_ID: sourcingreq.MESSAGE_ID,
  			SENDER: sourcingreq.SENDER,
			DEST: sourcingreq.DEST,
			EFF: sourcingreq.EFF,
			ITEM: sourcingreq.ITEM,
			RATE: sourcingreq.RATE,
			RES: sourcingreq.RES,
			SOURCE: sourcingreq.SOURCE,
			SOURCING: sourcingreq.SOURCING,
			STEPNUM: sourcingreq.STEPNUM,
			(sourcingreq.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
			(sourcingreq.sourcingrequirementUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
    	
 	 })