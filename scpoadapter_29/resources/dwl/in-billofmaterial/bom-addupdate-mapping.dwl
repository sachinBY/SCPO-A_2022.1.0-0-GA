%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var billOfMaterialEntity = vars.entityMap.billofmaterial[0].bom[0]
---
 (payload map (bom, indexOfBom) -> {
 	         MS_BULK_REF: bom.MS_BULK_REF,
			 MS_REF: bom.MS_REF,
 			 INTEGRATION_STAMP: bom.INTEGRATION_STAMP,
 			 MESSAGE_TYPE: bom.MESSAGE_TYPE,
 		 	 MESSAGE_ID: bom.MESSAGE_ID,
 		 	 SENDER: bom.SENDER,
			 BOMNUM: bom.BOMNUM,
			 CONSUMSTEPNUM: bom.CONSUMSTEPNUM,
			 DISC: bom.DISC,
			 DRAWQTY: bom.DRAWQTY,
			 DRAWTYPE: bom.DRAWTYPE,
			 EFF: bom.EFF,
			 EXPLODESW: bom.EXPLODESW,
			 ITEM: bom.ITEM,
			 LOC: bom.LOC,
			 MIXFACTOR: bom.MIXFACTOR,
			 OFFSET: bom.OFFSET,
			 QTYUOM: bom.QTYUOM,
			 SHRINKAGEFACTOR: bom.SHRINKAGEFACTOR,
			 SUBORD: bom.SUBORD,
			 SUBORDLOC: bom.SUBORDLOC,
			 SUPERSEDESW: bom.SUPERSEDESW,
			 YIELDCAL: bom.YIELDCAL,
			 YIELDFACTOR: bom.YIELDFACTOR,
			 (bom.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
				}),
			 (bom.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    		})
    	
 	 })