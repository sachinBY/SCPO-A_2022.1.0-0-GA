%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"  
---
(payload map (resource, indexOfresource) -> { 
		MS_BULK_REF: resource.MS_BULK_REF,
		MS_REF: resource.MS_REF,	
		INTEGRATION_STAMP: resource.INTEGRATION_STAMP,
		MESSAGE_TYPE: resource.MESSAGE_TYPE,
  		MESSAGE_ID: resource.MESSAGE_ID,
  		SENDER: resource.SENDER, 	  	
	    ADJFACTOR: if(resource.ADJFACTOR != default_value) resource.ADJFACTOR as Number else default_value,
	    ADDONCOST: if(resource.ADDONCOST != default_value) resource.ADDONCOST as Number else default_value, 
	    CHECKMAXCAP:  if(resource.CHECKMAXCAP != default_value) resource.CHECKMAXCAP as Number else default_value,
	    COST:  if(resource.COST != default_value) resource.COST as Number else default_value,
	    CURRENCYUOM: if(resource.CURRENCYUOM != default_value) resource.CURRENCYUOM else default_value,
	    DESCR: resource.DESCR_RES,
	    ENABLEOPT: if(resource.ENABLEOPT != default_value) resource.ENABLEOPT as Number else default_value,
	    LEVELLOADSW: if(resource.LEVELLOADSW != default_value) resource.LEVELLOADSW as String else default_value,
	    LEVELSEQNUM: if(resource.LEVELSEQNUM != default_value) resource.LEVELSEQNUM as Number else default_value,
	    QTYUOM: if(resource.QTYUOM != default_value) resource.QTYUOM as String else default_value,
	    SHIFTSIZE: if(resource.SHIFTSIZE != default_value) resource.SHIFTSIZE as Number else default_value,
	    TYPE: if(resource.TYPE_RES != default_value) resource.TYPE_RES as Number else default_value,
	    CAL: resource.CAL,
	    LOC: resource.LOC,
	    RES: resource.RES,
	   
		(resource.avplistResUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
    })