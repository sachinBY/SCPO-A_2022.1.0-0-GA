%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
 (payload map (relation, indexOfRelation) -> {
 		MS_BULK_REF: relation.MS_BULK_REF,
		MS_REF: relation.MS_REF,	
	    INTEGRATION_STAMP: relation.INTEGRATION_STAMP,
	    MESSAGE_TYPE: relation.MESSAGE_TYPE,
  		MESSAGE_ID: relation.MESSAGE_ID,
  		SENDER: relation.SENDER,
		ALTITEMPRIORITY: relation.ALTITEMPRIORITY,
		DISC: relation.DISC,
		DRAWQTY: relation.DRAWQTY,
		EFF: relation.EFF,
		ENABLEOPT: relation.ENABLEOPT,
		ALTITEM: relation.ALTITEM,
		ITEM: relation.ITEM,
		DMDGROUP: relation.DMDGROUP,
		LOC: relation.LOC,
	 	(relation.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(relation.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
    	
 	 })