%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var alternateBillOfMaterialEntity = vars.entityMap.billofmaterial[0].altbom[0]
---
 (payload map (altbom, indexOfaltbom) -> {
 	         MS_BULK_REF: altbom.MS_BULK_REF,
			 MS_REF: altbom.MS_REF,
 			 INTEGRATION_STAMP: altbom.INTEGRATION_STAMP,
 			 MESSAGE_TYPE: altbom.MESSAGE_TYPE,
 			 MESSAGE_ID: altbom.MESSAGE_ID,
 			 SENDER: altbom.SENDER,
			 ALTSUBORD: altbom.ALTSUBORD,
			 ALTSUBORDDISC: altbom.ALTSUBORDDISC,
			 ALTSUBORDEFF: altbom.ALTSUBORDEFF,
			 ALTSUBORDLOC: altbom.ALTSUBORDLOC,
			 BOMNUM: altbom.BOMNUM,
			 DRAWQTY: altbom.DRAWQTY,
			 EFF: altbom.EFF,
			 ITEM: altbom.ITEM,
			 LOC: altbom.LOC,
			 OFFSET: altbom.OFFSET,
			 PRIORITY: altbom.PRIORITY,
			 SUBORD: altbom.SUBORD,
			 YIELDCAL: altbom.YIELDCAL,
			 YIELDFACTOR: altbom.YIELDFACTOR,
			(altbom.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
				}),
			 (altbom.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    		})
    	
 	 })