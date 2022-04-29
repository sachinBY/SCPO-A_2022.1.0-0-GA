%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"  
---
(payload map (data, index) -> {
			MS_BULK_REF: data.MS_BULK_REF,
			MS_REF: data.MS_REF,	
			INTEGRATION_STAMP: data.INTEGRATION_STAMP,
			MESSAGE_TYPE: data.MESSAGE_TYPE,
  			MESSAGE_ID: data.MESSAGE_ID,
  			SENDER: data.SENDER,
			CAL: data.CAL,
		    (ATTRIBUTE: data.ATTRIBUTE) if (data.ATTRIBUTE != null),   
			(VALUE: data.VALUE as Number) if (data.VALUE != default_value),
			(STARTTIME: data.STARTTIME) if (data.STARTTIME != null),
			(ENDTIME: data.ENDTIME) if(data.ENDTIME != null),
		    PATTERNSEQNUM: data.PATTERNSEQNUM,
		    (data.attributeUDCs map {
					(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
									else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
									else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
									else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
									else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
			(data.avplistAttributeUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
		   
    })