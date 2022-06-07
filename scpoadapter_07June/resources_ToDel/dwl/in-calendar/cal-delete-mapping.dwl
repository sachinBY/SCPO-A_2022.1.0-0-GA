%dw 2.0
output application/java
---
(payload map (calendar, calendarIndex) -> {
	MS_BULK_REF: calendar.MS_BULK_REF,
	MS_REF: calendar.MS_REF,
	INTEGRATION_STAMP: calendar.INTEGRATION_STAMP,
	MESSAGE_TYPE: calendar.MESSAGE_TYPE,
	MESSAGE_ID: calendar.MESSAGE_ID,
	SENDER: calendar.SENDER,
	CAL: calendar.CAL,
	(vars.deleteudc): 'Y'
})
