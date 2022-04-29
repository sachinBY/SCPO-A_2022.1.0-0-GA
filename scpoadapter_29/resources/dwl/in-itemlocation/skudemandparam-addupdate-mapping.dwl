%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var skuDemandParamEntity = vars.entityMap.sku[0].skudemandparam[0]
---
 (payload map (sdmd, indexOfsdmd) -> {
 		MS_BULK_REF: sdmd.MS_BULK_REF,
		MS_REF: sdmd.MS_REF,	
		INTEGRATION_STAMP: sdmd.INTEGRATION_STAMP,
		MESSAGE_TYPE: sdmd.MESSAGE_TYPE,
  		MESSAGE_ID: sdmd.MESSAGE_ID,
  		SENDER: sdmd.SENDER,
	  	ITEM: if (sdmd.ITEM != null) sdmd.ITEM else default_value,
	    LOC: if (sdmd.LOC != null) sdmd.LOC else default_value,
	    INDDMDUNITCOST: if (sdmd.INDDMDUNITCOST != null) sdmd.INDDMDUNITCOST else default_value,
	    INDDMDUNITMARGIN: if (sdmd.INDDMDUNITMARGIN != null) sdmd.INDDMDUNITMARGIN else default_value,
	    UNITCARCOST: if (sdmd.UNITCARCOST != null) sdmd.UNITCARCOST else default_value,
	    UNITPRICE: if (sdmd.UNITPRICE != null) sdmd.UNITPRICE else default_value,
	    DMDTODATE: if (sdmd.DMDTODATE != null) sdmd.DMDTODATE else default_value,
	    (sdmd.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(sdmd.SkuDemandParamUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    })
   
  })