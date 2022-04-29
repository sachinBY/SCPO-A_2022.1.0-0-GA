%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
(payload map(calendarPattern, calendarPatternPatternIndex) -> {
	    MS_BULK_REF: calendarPattern.MS_BULK_REF,
	    MS_REF: calendarPattern.MS_REF,
		INTEGRATION_STAMP: calendarPattern.INTEGRATION_STAMP,
		MESSAGE_TYPE: calendarPattern.MESSAGE_TYPE,
		MESSAGE_ID: calendarPattern.MESSAGE_ID,
		SENDER: calendarPattern.SENDER,
		CAL : calendarPattern.CAL,
		PATTERNSEQNUM: calendarPattern.PATTERNSEQNUM,
		// Check how to generate the sequence number PATTERNSEQNUM
		STARTDATE: calendarPattern.STARTDATE,
		ENDDATE: calendarPattern.ENDDATE,
		// Add a lookup for patternFrequencyCode
		PATTERN: if (calendarPattern.PATTERN != null) 
					calendarPattern.PATTERN 
				 else 
				 	default_value,
		DESCR: calendarPattern.DESCR,
		RANK: calendarPattern.RANK,
		MONDAYSW: calendarPattern.MONDAYSW,
		TUESDAYSW: calendarPattern.TUESDAYSW,
		WEDNESDAYSW: calendarPattern.WEDNESDAYSW,
		THURSDAYSW: calendarPattern.THURSDAYSW,
		FRIDAYSW: calendarPattern.FRIDAYSW,
		SATURDAYSW: calendarPattern.SATURDAYSW,
		SUNDAYSW: calendarPattern.SUNDAYSW,
		REPEATEVERYNDAYS: calendarPattern.REPEATEVERYNDAYS,
		DAY: calendarPattern.DAY,
		(calendarPattern.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(calendarPattern.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
	
})
