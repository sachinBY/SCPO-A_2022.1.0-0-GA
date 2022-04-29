%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
 (payload map (movingEventData, indexOfEvent) -> {
 		MS_BULK_REF: movingEventData.MS_BULK_REF,
		MS_REF: movingEventData.MS_REF,
 		INTEGRATION_STAMP: movingEventData.INTEGRATION_STAMP,
 		MESSAGE_TYPE: movingEventData.MESSAGE_TYPE,
  		MESSAGE_ID: movingEventData.MESSAGE_ID,
  		SENDER: movingEventData.SENDER,
	    MOVINGEVENT: movingEventData.MOVINGEVENT,
	    YEAR: movingEventData.YEAR,
	    STARTDATE: movingEventData.STARTDATE,
	    (movingEventData.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(movingEventData.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)})
   
  })