%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"

---
 (payload map (cust, indexOfCust) -> {
 	    MS_BULK_REF: cust.MS_BULK_REF,
	    MS_REF: cust.MS_REF,
 		INTEGRATION_STAMP: cust.INTEGRATION_STAMP,
 		MESSAGE_TYPE: cust.MESSAGE_TYPE,
  		MESSAGE_ID: cust.MESSAGE_ID,
  		SENDER: cust.SENDER,
	  	CUST: if (cust.CUST != null) cust.CUST else default_value,
	    CUSTCLASS: if (cust.CUSTCLASS != null) cust.CUSTCLASS else default_value,
	    DESCR: if (cust.DESCR != null) cust.DESCR else default_value,
	    PRIORITY: if (cust.PRIORITY != null) cust.PRIORITY else default_value,
	    (cust.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(cust.CustUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
   
  })