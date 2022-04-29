%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"

---

(payload map (sourcinguomconvfactor, sourcinguomconvfactorIndex) -> {
		MS_BULK_REF: sourcinguomconvfactor.MS_BULK_REF,
		MS_REF: sourcinguomconvfactor.MS_REF,
		INTEGRATION_STAMP: sourcinguomconvfactor.INTEGRATION_STAMP,
		MESSAGE_TYPE: sourcinguomconvfactor.MESSAGE_TYPE,
  		MESSAGE_ID: sourcinguomconvfactor.MESSAGE_ID,
  		SENDER: sourcinguomconvfactor.SENDER,
		DEST: sourcinguomconvfactor.DEST,
		ITEM: sourcinguomconvfactor.ITEM,
		RATIO:  sourcinguomconvfactor.RATIO,
		SOURCE: sourcinguomconvfactor.SOURCE,
		SOURCEUOM: sourcinguomconvfactor.SOURCEUOM,
		TARGETUOM:  sourcinguomconvfactor.TARGETUOM,
		SOURCECATEGORY: sourcinguomconvfactor.SOURCECATEGORY,
		TARGETCATEGORY: sourcinguomconvfactor.TARGETCATEGORY,
		TRANSMODE: sourcinguomconvfactor.TRANSMODE,

		(sourcinguomconvfactor.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(sourcinguomconvfactor.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
	})