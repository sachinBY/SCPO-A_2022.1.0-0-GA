%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
 (payload map (custOrderHeader, indexOfCustOrderHeader) -> {
 	            MS_BULK_REF: custOrderHeader.MS_BULK_REF,
			 	MS_REF: custOrderHeader.MS_REF,
 				INTEGRATION_STAMP: custOrderHeader.INTEGRATION_STAMP,
 				MESSAGE_TYPE: custOrderHeader.MESSAGE_TYPE,
				MESSAGE_ID: custOrderHeader.MESSAGE_ID,
				SENDER: custOrderHeader.SENDER,
				CUST: custOrderHeader.CUST,
				EXTREF: custOrderHeader.EXTREF,
				CREATIONDATE: custOrderHeader.CREATIONDATE,
				DMDGROUP: custOrderHeader.DMDGROUP,
				PRIORITY: custOrderHeader.PRIORITY,
				(custOrderHeader.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if($ != null and $.scpoColumnName != null)
				}),
				(custOrderHeader.CustOrderHeaderUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if($ != null and $.UDCName != null)
	    		})
		   
    	})