%dw 2.0
output application/java
var calendarEntity = vars.entityMap.cal[0].cal[0]
var calendartypeCode = vars.codeMap.calendartypeCodeToSCPOTypeConversion
var default_value = "###JDA_DEFAULT_VALUE###"
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload.calendar filter ($.calendarType != null and calendartypeCode[$.calendarType][0] != null) map(calendar, calendarIndex) -> {
	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference,
	INTEGRATION_STAMP: ((vars.creationDateAndTime as DateTime + ('PT' ++ calendarIndex ++ 'S') as Period) replace 'T' with '') [0 to 17],
	MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
	SENDER: vars.bulkNotificationHeaders.sender,
	CAL : if(calendar.calendarId !=null) 
			calendar.calendarId
		  else  
		    default_value,
	DESCR: if (calendar.description.value != null) 
				calendar.description.value
		   else 
				default_value,
	// Add a lookup for calendar type
	TYPE: if (calendar.calendarType != null) 
				calendartypeCode[calendar.calendarType][0] 
		  else 
				default_value,
	MASTER: if (calendar.masterCalendar != null) 
				calendar.masterCalendar
			else 
				default_value,
	PATTERNSW: 1,			
	(CalendarUDC: (lib.getUdcNameAndValue(calendarEntity, calendar.avpList, lib.getAvpListMap(calendar.avpList))[0])) 
  		if (calendar.avpList != null and (calendar.documentActionCode == "ADD" or calendar.documentActionCode == "CHANGE_BY_REFRESH") and calendarEntity != null),
	ACTIONCODE: calendar.documentActionCode
})  
