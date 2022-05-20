%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"

---

(payload map (sourcing, sourcingIndex) -> {
		MS_BULK_REF: sourcing.MS_BULK_REF,
		MS_REF: sourcing.MS_REF,
		INTEGRATION_STAMP: sourcing.INTEGRATION_STAMP,
		MESSAGE_TYPE: sourcing.MESSAGE_TYPE,
  		MESSAGE_ID: sourcing.MESSAGE_ID,
  		SENDER: sourcing.SENDER,
		ARRIVCAL: sourcing.ARRIVCAL,
		DEST: sourcing.DEST,
		DISC: sourcing.DISC,
		EFF: sourcing.EFF,
		FACTOR: sourcing.FACTOR,
		ITEM: sourcing.ITEM,
		LOADDUR: sourcing.LOADDUR,
		MAJORSHIPQTY: sourcing.MAJORSHIPQTY,
		MAXSHIPQTY: sourcing.MAXSHIPQTY,
		MINORSHIPQTY: sourcing.MINORSHIPQTY,
		NONEWSUPPLYDATE: sourcing.NONEWSUPPLYDATE,
		PRIORITY: sourcing.PRIORITY,
		SHIPCAL:  sourcing.SHIPCAL,
		SHRINKAGEFACTOR: sourcing.SHRINKAGEFACTOR,
		SOURCE: sourcing.SOURCE,
		SOURCING: sourcing.SOURCING,
		SOURCINGCOST: sourcing.SOURCINGCOST,
		TRANSMODE: sourcing.TRANSMODE,
		UNLOADDUR: sourcing.UNLOADDUR,
		
		(sourcing.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(sourcing.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
	})