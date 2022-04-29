%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"  
---
(payload map {
		MS_BULK_REF: $.MS_BULK_REF,
		MS_REF: $.MS_REF,	
		INTEGRATION_STAMP: $.INTEGRATION_STAMP,
		MESSAGE_TYPE: $.MESSAGE_TYPE,
  		MESSAGE_ID: $.MESSAGE_ID,
  		SENDER: $.SENDER,
		CAL: $.CAL,    
		DESCR: $.DESCR,
	    STARTDATE: $.STARTDATE,   
		ENDDATE: $.ENDDATE,
		RANK: if ($.RANK != default_value) ($.RANK as Number) else default_value,
		REPEATEVERYNDAYS: if ($.REPEATEVERYNDAYS != default_value) ($.REPEATEVERYNDAYS as Number) else default_value,
	    PATTERNSEQNUM: if ($.PATTERNSEQNUM != default_value) ($.PATTERNSEQNUM as Number) else default_value,
	    PATTERN: if ($.PATTERN != default_value) ($.PATTERN as Number) else default_value,
	    DAY: if ($.DAY != default_value) ($.DAY as Number) else default_value,
	    MONDAYSW: if ($.MONDAYSW != default_value) ($.MONDAYSW as Number) else default_value,
	    TUESDAYSW: if ($.TUESDAYSW != default_value) ($.TUESDAYSW as Number) else default_value,
	    WEDNESDAYSW: if ($.WEDNESDAYSW != default_value) ($.WEDNESDAYSW as Number) else default_value,
	    THURSDAYSW: if ($.THURSDAYSW != default_value) ($.THURSDAYSW as Number) else default_value,
	    FRIDAYSW: if ( $.FRIDAYSW != default_value) ($.FRIDAYSW as Number) else default_value,
	    SATURDAYSW: if ($.SATURDAYSW != default_value) ($.SATURDAYSW as Number) else default_value,
	    SUNDAYSW: if ($.SUNDAYSW != default_value) ($.SUNDAYSW as Number) else default_value,
	    ($.patternUDCs map {
					(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
									else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
									else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
									else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
									else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
		}),
		($.avplistPatternUDCS default [] map {
      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
							else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
							else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
							else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
							else $.UDCValue) if ($ != null and $.UDCName != null)
    	})
	  
	})