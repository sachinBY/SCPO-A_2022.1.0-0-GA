%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
payload map(dynamicDeploymentSourcing, dynamicDeploymentSourcingIndex) -> {
	MS_BULK_REF: dynamicDeploymentSourcing.MS_BULK_REF,
	MS_REF: dynamicDeploymentSourcing.MS_REF,
	INTEGRATION_STAMP: dynamicDeploymentSourcing.INTEGRATION_STAMP,
	MESSAGE_TYPE: dynamicDeploymentSourcing.MESSAGE_TYPE,
  	MESSAGE_ID: dynamicDeploymentSourcing.MESSAGE_ID,
  	SENDER: dynamicDeploymentSourcing.SENDER,
	ALTSRCPENALTY:dynamicDeploymentSourcing.ALTSRCPENALTY ,
	ARRIVCAL: dynamicDeploymentSourcing.ARRIVCAL,
	DEST:dynamicDeploymentSourcing.DEST,
	DISC:dynamicDeploymentSourcing.DISC,
	DYNDEPSRCCOST:dynamicDeploymentSourcing.DYNDEPSRCCOST,
	EFF:dynamicDeploymentSourcing.EFF,
	ITEM:dynamicDeploymentSourcing.ITEM,
	LOADDUR:dynamicDeploymentSourcing.LOADDUR,
	PULLFORWARDDUR:dynamicDeploymentSourcing.PULLFORWARDDUR,
	SHIPCAL:dynamicDeploymentSourcing.SHIPCAL,
	SOURCE:dynamicDeploymentSourcing.SOURCE,
	SOURCING:dynamicDeploymentSourcing.SOURCING,	
	SPLITQTY:dynamicDeploymentSourcing.SPLITQTY,	
	TRANSMODE:dynamicDeploymentSourcing.TRANSMODE,
	UNLOADDUR:dynamicDeploymentSourcing.UNLOADDUR,
		
	  
		(dynamicDeploymentSourcing.dynamicDeploymentSourcingUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
}
