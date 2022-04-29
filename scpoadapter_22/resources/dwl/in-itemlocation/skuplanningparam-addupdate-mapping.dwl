%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var skuPlanningParamEntity = vars.entityMap.sku[0].skuplanningparam[0]
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
	    BUFFERLEADTIME: if (spp.BUFFERLEADTIME != null) (spp.BUFFERLEADTIME) else default_value,
	    DRPFRZDUR: if (spp.DRPFRZDUR != null) spp.DRPFRZDUR else default_value,
	    HOLDINGCOST: if (spp.HOLDINGCOST != null) spp.HOLDINGCOST else default_value,
	    INCDRPQTY: if (spp.INCDRPQTY != null) spp.INCDRPQTY else default_value,
	    INCMPSQTY: if (spp.INCMPSQTY != null) spp.INCMPSQTY else default_value,
	    INHANDLINGCOST: if (spp.INHANDLINGCOST != null) spp.INHANDLINGCOST else default_value,
	    MAXOH: if (spp.MAXOH != null) spp.MAXOH else default_value,
	    MFGFRZDUR: if (spp.MFGFRZDUR != null) (spp.MFGFRZDUR) else default_value,
	    MFGLEADTIME: if (spp.MFGLEADTIME != null) (spp.MFGLEADTIME) else default_value,
	    MINDRPQTY: if (spp.MINDRPQTY != null) spp.MINDRPQTY else default_value,
	    MINMPSQTY: if (spp.MINMPSQTY != null) spp.MINMPSQTY else default_value,
	    OUTHANDLINGCOST: if (spp.OUTHANDLINGCOST != null) spp.OUTHANDLINGCOST else default_value,
	    SHRINKAGEFACTOR: if (spp.SHRINKAGEFACTOR != null) spp.SHRINKAGEFACTOR else default_value,
	    MPSCOVDUR: if (spp.MPSCOVDUR != null) spp.MPSCOVDUR else default_value,
	    ORDERINGCOST: if (spp.ORDERINGCOST != null) spp.ORDERINGCOST else default_value,
	    DRPCOVDUR: if (spp.DRPCOVDUR != null) spp.DRPCOVDUR else default_value,
	    (spp.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(spp.SkuPlanningParamUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    })
   
  })