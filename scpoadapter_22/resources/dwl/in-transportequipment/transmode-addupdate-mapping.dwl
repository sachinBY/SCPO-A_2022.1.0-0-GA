%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
(payload map (tranmodeeqp, indexOftransmodeeqp) -> {
		MS_BULK_REF: tranmodeeqp.MS_BULK_REF,
		MS_REF: tranmodeeqp.MS_REF,
		INTEGRATION_STAMP: tranmodeeqp.INTEGRATION_STAMP,
		MESSAGE_TYPE: tranmodeeqp.MESSAGE_TYPE,
  		MESSAGE_ID: tranmodeeqp.MESSAGE_ID,
  		SENDER: tranmodeeqp.SENDER,
		DESCR: if (tranmodeeqp.DESCR != null) tranmodeeqp.DESCR else default_value,
		TRANSMODE: if (tranmodeeqp.TRANSMODE != null) tranmodeeqp.TRANSMODE else default_value,
		(tranmodeeqp.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
				}),
			 (tranmodeeqp.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    		})

})