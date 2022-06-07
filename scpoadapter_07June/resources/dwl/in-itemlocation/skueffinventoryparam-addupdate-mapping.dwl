%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
var skuEffInventoryParamEntity = vars.entityMap.sku[0].skueffinventoryparam[0]
---
 (payload map (sep, indexOfsep) -> {
 		MS_BULK_REF: sep.MS_BULK_REF,
		MS_REF: sep.MS_REF,	
		INTEGRATION_STAMP: sep.INTEGRATION_STAMP,
		MESSAGE_TYPE: sep.MESSAGE_TYPE,
  		MESSAGE_ID: sep.MESSAGE_ID,
  		SENDER: sep.SENDER,
	    ITEM: if (sep.ITEM != null) sep.ITEM else default_value,
	    LOC: if (sep.LOC != null) sep.LOC else default_value,
	    MAXOHQTY: if (sep.MAXOHQTY != null) sep.MAXOHQTY else default_value,
	    MINSSQTY: if (sep.MINSSQTY != null) sep.MINSSQTY else default_value,
	    SSCOVDUR: if (sep.SSCOVDUR != null) (sep.SSCOVDUR) else default_value,
	    EFF: if (sep.EFF != null) sep.EFF else default_value,
	    (sep.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(sep.SkuEffInventoryParamUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    })
   
  })