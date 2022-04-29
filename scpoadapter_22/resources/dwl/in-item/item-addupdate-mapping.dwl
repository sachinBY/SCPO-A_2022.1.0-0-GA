%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"

---
(payload map (item, indexOfItem) -> { 
		MS_BULK_REF: item.MS_BULK_REF,
		MS_REF: item.MS_REF, 	  	
   		INTEGRATION_STAMP: item.INTEGRATION_STAMP,
   		MESSAGE_TYPE: item.MESSAGE_TYPE,
 		MESSAGE_ID: item.MESSAGE_ID,
 		SENDER: item.SENDER,
    	DEFAULTUOM: if(item.DEFAULTUOM != null) item.DEFAULTUOM else default_value,    
	    DESCR:  if(item.DESCR != null) item.DESCR else default_value,
	    DISCRETESW: if(item.DISCRETESW != null) item.DISCRETESW else default_value,
	    ITEM:  if(item.ITEM != null) item.ITEM else default_value,
	    ITEMCLASS: if(item.ITEMCLASS != null) item.ITEMCLASS else default_value,
	    PERISHABLESW: if(item.PERISHABLESW != null) item.PERISHABLESW else default_value,
	    PRIORITY: if(item.PRIORITY != null) item.PRIORITY else default_value,
	    STORAGEGROUP: if(item.STORAGEGROUP != null) item.STORAGEGROUP else default_value,
	    UNITSPERPALLET: if(item.UNITSPERPALLET != null) item.UNITSPERPALLET else default_value,
	    UOM: if(item.UOM != null) item.UOM else default_value,
	    VOL: if(item.VOL != null) item.VOL else default_value,
	    WGT: if(item.WGT != null) item.WGT else default_value,
	    (item.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(item.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
   
  })