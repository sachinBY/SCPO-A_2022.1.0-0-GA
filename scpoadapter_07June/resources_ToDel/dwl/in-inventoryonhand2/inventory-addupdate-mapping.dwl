%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
---
 (flatten(payload) map(inventory,index)-> {
 		MS_BULK_REF: inventory.MS_BULK_REF,
		MS_REF: inventory.MS_REF,
        INTEGRATION_STAMP: inventory.INTEGRATION_STAMP,
        MESSAGE_TYPE: inventory.MESSAGE_TYPE,
  		MESSAGE_ID: inventory.MESSAGE_ID,
  		SENDER: inventory.SENDER,
	  	AVAILDATE: inventory.AVAILDATE,
	    EXPDATE: inventory.EXPDATE,
	    ITEM: inventory.ITEM,
	    LOC: inventory.LOC,
	    PROJECT: inventory.PROJECT,
	    QTY: inventory.QTY,	  	
	  	STORE: inventory.STORE,
	    EARLIESTSELLDATE: inventory.EARLIESTSELLDATE,
	  	STOCKCATEGORY: inventory.STOCKCATEGORY,
		(inventory.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
		}),
		(inventory.inventoryUDCS default [] map {
			(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
		})
  		
  })