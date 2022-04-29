%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
(payload map(calendarAttribute, calendarAttributeIndex) -> {
	    MS_BULK_REF: calendarAttribute.MS_BULK_REF,
	    MS_REF: calendarAttribute.MS_REF,
	    INTEGRATION_STAMP: calendarAttribute.INTEGRATION_STAMP,
		MESSAGE_TYPE: calendarAttribute.MESSAGE_TYPE,
		MESSAGE_ID: calendarAttribute.MESSAGE_ID,
		SENDER: calendarAttribute.SENDER,
		CAL : calendarAttribute.CAL,
		PATTERNSEQNUM: calendarAttribute.PATTERNSEQNUM,
		ATTRIBUTE: calendarAttribute.ATTRIBUTE,
		VALUE: calendarAttribute.VALUE,
		STARTTIME: if (calendarAttribute.STARTTIME != null) 
						calendarAttribute.STARTTIME 
				   else 
				 		default_value,
		ENDTIME: if (calendarAttribute.ENDTIME != null) 
					calendarAttribute.ENDTIME 
				 else 
				 	default_value,
		(calendarAttribute.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(calendarAttribute.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
	
})