%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
---
 (flatten(payload) map (skueffio, indexOfss) -> {
 		MS_BULK_REF: skueffio.MS_BULK_REF,
		MS_REF: skueffio.MS_REF,	
		INTEGRATION_STAMP: skueffio.INTEGRATION_STAMP,
		MESSAGE_TYPE: skueffio.MESSAGE_TYPE,
  		MESSAGE_ID: skueffio.MESSAGE_ID,
  		SENDER: skueffio.SENDER,
	    ITEM: if (skueffio.ITEM != null) skueffio.ITEM else default_value,
	    LOC: if (skueffio.LOC != null) skueffio.LOC else default_value,
	    UNITCOST: if (skueffio.UNITCOST != null) skueffio.UNITCOST else default_value,
	    STOCKOUTPENALTY: if (skueffio.STOCKOUTPENALTY != null) skueffio.STOCKOUTPENALTY else default_value,
	    REVIEWPERIOD: if (skueffio.REVIEWPERIOD != null) skueffio.REVIEWPERIOD else default_value,
		REPLENPOLICY: if (skueffio.REPLENPOLICY != null) skueffio.REPLENPOLICY else default_value,
	    OVERSTOCKPENALTY: if (skueffio.OVERSTOCKPENALTY != null) skueffio.OVERSTOCKPENALTY else default_value,
	    ORDERCOST: if (skueffio.ORDERCOST != null) skueffio.ORDERCOST else default_value,
	    MINREORDERQTY: if (skueffio.MINREORDERQTY != null) skueffio.MINREORDERQTY else default_value,
	    MAXREORDERQTY: if (skueffio.MAXREORDERQTY != null) skueffio.MAXREORDERQTY else default_value,
		IOSERVICEPROFILE: if (skueffio.IOSERVICEPROFILE != null) skueffio.IOSERVICEPROFILE else ' ',
	    HOLDINGCOST: if (skueffio.HOLDINGCOST != null) skueffio.HOLDINGCOST else default_value,
	    HANDLINGCOST: if (skueffio.HANDLINGCOST != null) skueffio.HANDLINGCOST else default_value,
	    EVENTTYPE: if (skueffio.EVENTTYPE != null) skueffio.EVENTTYPE else default_value,
	    ENDOFLIFEDMD: if (skueffio.ENDOFLIFEDMD != null) skueffio.ENDOFLIFEDMD else default_value,
		EFF: if (skueffio.EFF != null) skueffio.EFF else default_value,
	    COEFFVAR: if (skueffio.COEFFVAR != null) skueffio.COEFFVAR else default_value,
	    BACKORDERPENALTY: if (skueffio.BACKORDERPENALTY != null) skueffio.BACKORDERPENALTY else default_value,
	    (skueffio.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(skueffio.SKUEffIOParamUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    })
   
  })