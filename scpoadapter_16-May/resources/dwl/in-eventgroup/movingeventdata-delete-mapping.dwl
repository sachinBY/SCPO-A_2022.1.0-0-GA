%dw 2.0
output application/java
---
 (payload map (movingEventData, indexOfEvent) -> {
 	MS_BULK_REF: movingEventData.MS_BULK_REF,
	MS_REF: movingEventData.MS_REF,
 	INTEGRATION_STAMP: movingEventData.INTEGRATION_STAMP,
 	MESSAGE_TYPE: movingEventData.MESSAGE_TYPE,
  	MESSAGE_ID: movingEventData.MESSAGE_ID,
  	SENDER: movingEventData.SENDER,
    MOVINGEVENT: movingEventData.MOVINGEVENT,
    YEAR: movingEventData.YEAR,
    (vars.deleteudc): 'Y'
  })