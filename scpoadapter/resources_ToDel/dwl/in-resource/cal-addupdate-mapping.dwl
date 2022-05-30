%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"  
---
(payload map (data, indexOfCal) -> {
		MS_BULK_REF: data.MS_BULK_REF,
		MS_REF: data.MS_REF,	
	 	INTEGRATION_STAMP: data.INTEGRATION_STAMP,
	 	MESSAGE_TYPE: data.MESSAGE_TYPE,
  		MESSAGE_ID: data.MESSAGE_ID,
  		SENDER: data.SENDER,  	
	    DESCR: data.DESCR_CAL,
		CAL: data.CAL,
		TYPE: if(data.TYPE != default_value) data.TYPE as Number else default_value,   
		MASTER:data.MASTER,
		PATTERNSW: if(data.PATTERNSW != default_value) data.PATTERNSW as Number else default_value,
		
		(data.avplistCalUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
	
    })