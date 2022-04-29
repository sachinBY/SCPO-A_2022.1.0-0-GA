%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
(payload map(hist,index)-> {
		MS_BULK_REF: hist.MS_BULK_REF,
		MS_REF: hist.MS_REF,  
	    INTEGRATION_STAMP: hist.INTEGRATION_STAMP,
	    MESSAGE_TYPE: hist.MESSAGE_TYPE,
  		MESSAGE_ID: hist.MESSAGE_ID,
  		SENDER: hist.SENDER,
	  	TYPE: "1",
	    EVENT: " ",
	    DMDUNIT: hist.DMDUNIT,
	    DMDGROUP: hist.DMDGROUP,
	    LOC: hist.LOC,
	  	STARTDATE: hist.STARTDATE,
	  	HISTSTREAM: hist.HISTSTREAM,
	  	QTY: hist.QTY,
		DUR: hist.DUR,
		(hist.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
		}),
		(hist.histUDC default [] map {
			(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
		})
	})