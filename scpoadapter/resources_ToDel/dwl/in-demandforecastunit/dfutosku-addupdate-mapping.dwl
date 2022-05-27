%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
var dfuToSkuEntity = vars.entityMap.dfuview[0].dfutosku[0]
---
 (payload map (dfuTosku, indexOfdfuTosku) -> {
 		MS_BULK_REF: dfuTosku.MS_BULK_REF,
        MS_REF: dfuTosku.MS_REF,    
 		INTEGRATION_STAMP: dfuTosku.INTEGRATION_STAMP,
 		MESSAGE_TYPE: dfuTosku.MESSAGE_TYPE,
  		MESSAGE_ID: dfuTosku.MESSAGE_ID,
  		SENDER: dfuTosku.SENDER,
  		DMDUNIT: if (dfuTosku.DMDUNIT != null) dfuTosku.DMDUNIT else default_value,
	    DMDGROUP: if (dfuTosku.DMDGROUP != null) dfuTosku.DMDGROUP else default_value,
	    DFULOC: if (dfuTosku.DFULOC != null) dfuTosku.DFULOC else default_value,
	    MODEL: dfuTosku.MODEL,
	    DISC: if (dfuTosku.DISC != null) dfuTosku.DISC else default_value,
	    EFF: if (dfuTosku.EFF != null) dfuTosku.EFF else default_value,
	    ITEM: if (dfuTosku.ITEM != null) dfuTosku.ITEM else default_value,
	    SKULOC: if (dfuTosku.SKULOC != null) dfuTosku.SKULOC else default_value,
	   	MODEL: default_value,
	    (dfuTosku.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(dfuTosku.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
  })