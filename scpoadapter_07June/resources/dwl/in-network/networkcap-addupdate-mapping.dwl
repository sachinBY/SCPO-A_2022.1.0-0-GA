%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"

---
(payload map (netcap, indexOfNetcap) -> {
			MS_BULK_REF: netcap.MS_BULK_REF,
			MS_REF: netcap.MS_REF,
			INTEGRATION_STAMP: netcap.INTEGRATION_STAMP,
			MESSAGE_TYPE: netcap.MESSAGE_TYPE,
  			MESSAGE_ID: netcap.MESSAGE_ID,
  			SENDER: netcap.SENDER,
	  		UOM: netcap.UOM,
			MINCAP: netcap.MINCAP,
			SOURCE: netcap.SOURCE,
			TRANSMODE: netcap.TRANSMODE,
			DEST: netcap.DEST,
	 		(netcap.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
			(netcap.networkCapUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
    	
 	 })