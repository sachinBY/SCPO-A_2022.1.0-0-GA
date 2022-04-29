%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
---
 (flatten(flatten(payload)) map (skueffdmd, indexOfss) -> {
 		MS_BULK_REF: skueffdmd.MS_BULK_REF,
		MS_REF: skueffdmd.MS_REF,
 		INTEGRATION_STAMP: skueffdmd.INTEGRATION_STAMP,
 		MESSAGE_TYPE: skueffdmd.MESSAGE_TYPE,
  		MESSAGE_ID: skueffdmd.MESSAGE_ID,
  		SENDER: skueffdmd.SENDER,
	    ITEM: if (skueffdmd.ITEM != null) skueffdmd.ITEM else default_value,
	    SKULOC: if (skueffdmd.SKULOC != null) skueffdmd.SKULOC else default_value,
	    DMDGROUP: if (skueffdmd.DMDGROUP != null) skueffdmd.DMDGROUP else default_value,
	    EFF: if (skueffdmd.EFF != null) skueffdmd.EFF else default_value,
	    IOSERVICEPROFILE: if (skueffdmd.IOSERVICEPROFILE != null) skueffdmd.IOSERVICEPROFILE else default_value,
		(skueffdmd.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(skueffdmd.SkuDmdEffParamUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    })
    
  })