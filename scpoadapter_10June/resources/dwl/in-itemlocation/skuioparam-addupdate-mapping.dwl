%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
---
 (payload map (skuio, indexOfss) -> {
 		MS_BULK_REF: skuio.MS_BULK_REF,
		MS_REF: skuio.MS_REF,	
		INTEGRATION_STAMP: skuio.INTEGRATION_STAMP,
		MESSAGE_TYPE: skuio.MESSAGE_TYPE,
  		MESSAGE_ID: skuio.MESSAGE_ID,
  		SENDER: skuio.SENDER,
	    ITEM: if (skuio.ITEM != null) skuio.ITEM else default_value,
	    LOC: if (skuio.LOC != null) skuio.LOC else default_value,
	    AVGRQSNSIZE: if (skuio.AVGRQSNSIZE != null) skuio.AVGRQSNSIZE else default_value,
	    GROUPNAME: if (skuio.GROUPNAME != null) skuio.GROUPNAME else default_value,
	    NUMRQSN: if (skuio.NUMRQSN != null) skuio.NUMRQSN else default_value,
		REVIEWGROUP: if (skuio.REVIEWGROUP != null) skuio.REVIEWGROUP else default_value,
	    SENSITIVITYPROFILE: if (skuio.SENSITIVITYPROFILE != null) skuio.SENSITIVITYPROFILE else default_value,
	    (skuio.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(skuio.SkuIOParamUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    })
   
  })