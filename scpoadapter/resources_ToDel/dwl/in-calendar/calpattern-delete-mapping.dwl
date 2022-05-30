%dw 2.0
output application/java
---
(payload map (calendarPattern, calendarPatternPatternIndex) -> {
	//How to mitigate pattern sequence number
	MS_BULK_REF: calendarPattern.MS_BULK_REF,
	MS_REF: calendarPattern.MS_REF,
	INTEGRATION_STAMP: calendarPattern.INTEGRATION_STAMP,
	MESSAGE_TYPE: calendarPattern.MESSAGE_TYPE,
	MESSAGE_ID: calendarPattern.MESSAGE_ID,
	SENDER: calendarPattern.SENDER,
	CAL: calendarPattern.CAL,
	(vars.deleteudc): 'Y' 
})
