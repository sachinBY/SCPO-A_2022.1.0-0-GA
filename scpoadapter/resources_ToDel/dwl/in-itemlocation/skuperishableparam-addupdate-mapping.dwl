%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
var skuPerishableParamEntity = vars.entityMap.sku[0].skuperishableparam[0]
---
 (payload map (spp, indexOfspp) -> {
 		MS_BULK_REF: spp.MS_BULK_REF,
		MS_REF: spp.MS_REF,	
		INTEGRATION_STAMP: spp.INTEGRATION_STAMP,
		MESSAGE_TYPE: spp.MESSAGE_TYPE,
  		MESSAGE_ID: spp.MESSAGE_ID,
  		SENDER: spp.SENDER,
	    ITEM: if (spp.ITEM != null) spp.ITEM else default_value,
	    LOC: if (spp.LOC != null) spp.LOC else default_value,
	    MINSHELFLIFEDUR: if (spp.MINSHELFLIFEDUR != null) spp.MINSHELFLIFEDUR else default_value,
	    MINSHIPSHELFLIFEDUR: if (spp.MINSHIPSHELFLIFEDUR != null) spp.MINSHIPSHELFLIFEDUR else default_value,
	    SHELFLIFEDUR: if (spp.SHELFLIFEDUR != null) spp.SHELFLIFEDUR else default_value,
	    (spp.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(spp.SkuPerishableParamUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    })
   
  })