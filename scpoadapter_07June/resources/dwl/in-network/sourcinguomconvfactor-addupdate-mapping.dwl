%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"

---
(payload map (sourcingconv, indexOfSourcingConv) -> {
			MS_BULK_REF: sourcingconv.MS_BULK_REF,
			MS_REF: sourcingconv.MS_REF,
			INTEGRATION_STAMP: sourcingconv.INTEGRATION_STAMP,
			MESSAGE_TYPE: sourcingconv.MESSAGE_TYPE,
  			MESSAGE_ID: sourcingconv.MESSAGE_ID,
  			SENDER: sourcingconv.SENDER,
			DEST: sourcingconv.DEST,
			ITEM: sourcingconv.ITEM,
			RATIO: sourcingconv.RATIO,
			SOURCE: sourcingconv.SOURCE,
			SOURCECATEGORY: sourcingconv.SOURCECATEGORY,
			SOURCEUOM: sourcingconv.SOURCEUOM,
			TARGETCATEGORY: sourcingconv.TARGETCATEGORY,
			TARGETUOM: sourcingconv.TARGETUOM,
			TRANSMODE: sourcingconv.TRANSMODE,
		    (sourcingconv.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
			(sourcingconv.sourcinguomconvfactorUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
  })