%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var SkuSSPresentationUDC = vars.entityMap.sku[0].skusspresentation[0]
---
(payload map (value, indexOf) -> {
		MS_BULK_REF: value.MS_BULK_REF,
		MS_REF: value.MS_REF,	
		INTEGRATION_STAMP: value.INTEGRATION_STAMP,
		MESSAGE_TYPE: value.MESSAGE_TYPE,
  		MESSAGE_ID: value.MESSAGE_ID,
  		SENDER: value.SENDER,
	    ITEM: if (value.ITEM != null) value.ITEM else default_value,
	    LOC: if (value.LOC != null) value.LOC else default_value,
	    EFF: if (value.EFF != null) value.EFF else default_value,
	    DISC: if (value.DISC != null) value.DISC else default_value,
	    PRESENTATIONQTY: if (value.PRESENTATIONQTY != null) value.PRESENTATIONQTY else default_value,
	    DISPLAYQTY: if (value.DISPLAYQTY != null) value.DISPLAYQTY else default_value,
	    MAXSS: if (value.MAXSS != null) value.MAXSS else default_value,
	    MAXOH: if (value.MAXOH != null) value.MAXOH else default_value,
        DMDGROUP: default_value,
	    (value.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(value.SkuSSPresentationUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    })
  })
