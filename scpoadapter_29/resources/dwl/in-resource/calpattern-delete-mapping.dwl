%dw 2.0
output application/java  
---
 (payload map (calPattern, indexOfCal) -> { 
 	MS_BULK_REF: calPattern.MS_BULK_REF,
	MS_REF: calPattern.MS_REF,
	INTEGRATION_STAMP: calPattern.INTEGRATION_STAMP,
	MESSAGE_TYPE: calPattern.MESSAGE_TYPE,
  	MESSAGE_ID: calPattern.MESSAGE_ID,
  	SENDER: calPattern.SENDER,	 	  	
    CAL: calPattern.CAL,
    (vars.deleteudc): 'Y'
    })
