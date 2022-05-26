%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
---
(payload map (cust, indexOfCust) -> {
	MS_BULK_REF: cust.MS_BULK_REF,
	MS_REF: cust.MS_REF,
	INTEGRATION_STAMP: cust.INTEGRATION_STAMP,
	MESSAGE_TYPE: cust.MESSAGE_TYPE,
  	MESSAGE_ID: cust.MESSAGE_ID,
  	SENDER: cust.SENDER,
  	CUST: if (cust.CUST != null) cust.CUST else default_value,
  	(vars.deleteudc): 'Y'
  })