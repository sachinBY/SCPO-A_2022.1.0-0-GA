%dw 2.0
output application/java
---
(payload map (calendarAttribute, calendarAttributeIndex) -> {
	//How to mitigate 
	MS_BULK_REF: calendarAttribute.MS_BULK_REF,
	MS_REF: calendarAttribute.MS_REF,
	INTEGRATION_STAMP: calendarAttribute.INTEGRATION_STAMP,
	MESSAGE_TYPE: calendarAttribute.MESSAGE_TYPE,
	MESSAGE_ID: calendarAttribute.MESSAGE_ID,
	SENDER: calendarAttribute.SENDER,
	CAL: calendarAttribute.CAL,
	ATTRIBUTE: calendarAttribute.ATTRIBUTE,
	(vars.deleteudc): 'Y'
})
