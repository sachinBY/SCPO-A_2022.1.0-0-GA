%dw 2.0
output application/java  
---
(payload map (calData, indexOfCal) -> { 
	MS_BULK_REF: calData.MS_BULK_REF,
	MS_REF: calData.MS_REF,
	INTEGRATION_STAMP: calData.INTEGRATION_STAMP,
	MESSAGE_TYPE: calData.MESSAGE_TYPE,
  	MESSAGE_ID: calData.MESSAGE_ID,
  	SENDER: calData.SENDER,	 	  	
	CAL: calData.CAL
    })