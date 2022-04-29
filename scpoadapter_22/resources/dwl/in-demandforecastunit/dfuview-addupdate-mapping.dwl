%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
var dfuviewEntity = vars.entityMap.dfuview[0].dfuview[0]
---
(payload map (dfu, indexOfDfu) -> {
		MS_BULK_REF: dfu.MS_BULK_REF,
		MS_REF: dfu.MS_REF, 
		INTEGRATION_STAMP: dfu.INTEGRATION_STAMP,
		MESSAGE_TYPE: dfu.MESSAGE_TYPE,
  		MESSAGE_ID: dfu.MESSAGE_ID,
  		SENDER: dfu.SENDER,
	  	DMDUNIT: if (dfu.DMDUNIT != null) dfu.DMDUNIT else default_value,
	    DMDGROUP: if (dfu.DMDGROUP != null) dfu.DMDGROUP else default_value,
	    LOC: if (dfu.LOC != null) dfu.LOC else default_value,
	    ENABLEOPT: if (dfu.ENABLEOPT != null) dfu.ENABLEOPT as Number else default_value,
	    (dfu.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(dfu.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
  })