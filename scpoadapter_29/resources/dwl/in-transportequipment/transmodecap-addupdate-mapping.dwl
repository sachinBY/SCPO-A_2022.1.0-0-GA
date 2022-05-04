%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
(payload map (transmodecap, indexOftransmodecap) ->  {
		MS_BULK_REF: transmodecap.MS_BULK_REF,
		MS_REF: transmodecap.MS_REF,
		INTEGRATION_STAMP: transmodecap.INTEGRATION_STAMP,
		MESSAGE_TYPE: transmodecap.MESSAGE_TYPE,
  		MESSAGE_ID: transmodecap.MESSAGE_ID,
  		SENDER: transmodecap.SENDER,
		MAXCAP: if (transmodecap.MAXCAP != null) transmodecap.MAXCAP else default_value,
		MINCAP: if (transmodecap.MINCAP != null) transmodecap.MINCAP else default_value,
		TRANSMODE: if (transmodecap.TRANSMODE != null) transmodecap.TRANSMODE else default_value,
		UOM: if (transmodecap.UOM != null) transmodecap.UOM else default_value,
		(transmodecap.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
				}),
			 (transmodecap.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    		})
})