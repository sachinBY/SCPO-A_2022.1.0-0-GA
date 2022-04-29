%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
---
 (payload map (dmdgroup, indexOfDmdgroup) -> {
 	    MS_BULK_REF: dmdgroup.MS_BULK_REF,
		MS_REF: dmdgroup.MS_REF,
 	    INTEGRATION_STAMP: dmdgroup.INTEGRATION_STAMP,
 	    MESSAGE_TYPE: dmdgroup.MESSAGE_TYPE,
		MESSAGE_ID: dmdgroup.MESSAGE_ID,
		SENDER: dmdgroup.SENDER,
	  	DMDGROUP: if (dmdgroup.DMDGROUP != null) dmdgroup.DMDGROUP else default_value,
	    DESCR: if (dmdgroup.DESCR != null) dmdgroup.DESCR else default_value,
	    
	    (dmdgroup.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(dmdgroup.DemandChannelUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
    
 })