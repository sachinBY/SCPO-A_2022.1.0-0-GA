%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
 (payload map (dfuMovingEventMap, indexOfEvent) -> {
 		MS_BULK_REF: dfuMovingEventMap.MS_BULK_REF,
		MS_REF: dfuMovingEventMap.MS_REF,
 		INTEGRATION_STAMP: dfuMovingEventMap.INTEGRATION_STAMP,
 		MESSAGE_TYPE: dfuMovingEventMap.MESSAGE_TYPE,
  		MESSAGE_ID: dfuMovingEventMap.MESSAGE_ID,
  		SENDER: dfuMovingEventMap.SENDER,
		DMDUNIT: dfuMovingEventMap.DMDUNIT,
		DMDGROUP: dfuMovingEventMap.DMDGROUP,
		LOC: dfuMovingEventMap.LOC,
		MOVINGEVENT: dfuMovingEventMap.MOVINGEVENT,
		OVERLAPFACTOR: default_value,
	    (dfuMovingEventMap.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(dfuMovingEventMap.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
   
  })