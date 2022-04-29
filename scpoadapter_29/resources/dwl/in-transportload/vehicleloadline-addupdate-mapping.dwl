%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
 (payload map (vehicleLoadLine, indexOfVehicleLoadLineData) -> {
 		MS_BULK_REF: vehicleLoadLine.MS_BULK_REF,
		MS_REF: vehicleLoadLine.MS_REF,
 		INTEGRATION_STAMP: vehicleLoadLine.INTEGRATION_STAMP,
 		MESSAGE_TYPE: vehicleLoadLine.MESSAGE_TYPE,
  		MESSAGE_ID: vehicleLoadLine.MESSAGE_ID,
  		SENDER: vehicleLoadLine.SENDER,
	 	DEST: vehicleLoadLine.DEST,
		EXPDATE: vehicleLoadLine.EXPDATE,
		ITEM: vehicleLoadLine.ITEM,
		LOADID: vehicleLoadLine.LOADID,
		LOADLINEID: vehicleLoadLine.LOADLINEID,
		PRIMARYITEM: vehicleLoadLine.PRIMARYITEM,
		QTY: vehicleLoadLine.QTY,
		SCHEDARRIVDATE: vehicleLoadLine.SCHEDARRIVDATE,
		SCHEDSHIPDATE: vehicleLoadLine.SCHEDSHIPDATE,
		SEQNUM: vehicleLoadLine.SEQNUM,
		SOURCE: vehicleLoadLine.SOURCE,
		SOURCING: vehicleLoadLine.SOURCING,
	    (vehicleLoadLine.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(vehicleLoadLine.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
    
  })