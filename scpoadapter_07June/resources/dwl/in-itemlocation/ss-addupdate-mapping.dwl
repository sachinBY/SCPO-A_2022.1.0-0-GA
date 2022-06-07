%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
var skuSSEntity = vars.entityMap.sku[0].skuss[0]
---
 (payload map (ss, indexOfss) -> {
 		MS_BULK_REF: ss.MS_BULK_REF,
		MS_REF: ss.MS_REF,	
		INTEGRATION_STAMP: ss.INTEGRATION_STAMP,
		MESSAGE_TYPE: ss.MESSAGE_TYPE,
  		MESSAGE_ID: ss.MESSAGE_ID,
  		SENDER: ss.SENDER,
	    ITEM: if (ss.ITEM != null) ss.ITEM else default_value,
	    LOC: if (ss.LOC != null) ss.LOC else default_value,
	    EFF: if (ss.EFF != null) ss.EFF else default_value,
	    QTY: if (ss.QTY != null) ss.QTY else default_value,
	    DMDGROUP: if (ss.DMDGROUP != null) ss.DMDGROUP else default_value,
	    (ss.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(ss.SkuSSUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    })
   
  })