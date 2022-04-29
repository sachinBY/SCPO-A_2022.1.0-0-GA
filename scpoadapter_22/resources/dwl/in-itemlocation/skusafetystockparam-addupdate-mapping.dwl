%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
var skuSafetyStockParamEntity = vars.entityMap.sku[0].skusafetystockparam[0]
---
 (payload map (ssp, indexOfssp) -> {
 		MS_BULK_REF: ssp.MS_BULK_REF,
		MS_REF: ssp.MS_REF,	
		INTEGRATION_STAMP: ssp.INTEGRATION_STAMP,
		MESSAGE_TYPE: ssp.MESSAGE_TYPE,
  		MESSAGE_ID: ssp.MESSAGE_ID,
  		SENDER: ssp.SENDER,
	    ITEM: if (ssp.ITEM != null) ssp.ITEM else default_value,
	    LOC: if (ssp.LOC != null) ssp.LOC else default_value,
	    MAXSS: if (ssp.MAXSS != null) ssp.MAXSS else default_value,
	    MINSS: if (ssp.MINSS != null) ssp.MINSS else default_value,
	    SSCOV: if (ssp.SSCOV != null) (ssp.SSCOV) else default_value,
	   
		STATSSCSL: if (ssp.STATSSCSL != null and ssp.STATSSCSL > 0 and ssp.STATSSCSL < 1) ssp.STATSSCSL else default_value,
	    ACCUMDUR: if (ssp.ACCUMDUR != null) ssp.ACCUMDUR else default_value,
	    AVGLEADTIME: if (ssp.AVGLEADTIME != null) ssp.AVGLEADTIME else default_value,
	    SSRULE: if(ssp.SSRULE != null) ssp.SSRULE else default_value,
	    (ssp.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(ssp.SkuSafetyStockParamUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    })
	})