%dw 2.0
output application/java
var calendarEntity = vars.entityMap.cal[0].calattribute[0]
var calendartypeCode = vars.codeMap.calendartypeCodeToSCPOTypeConversion
var default_value = "###JDA_DEFAULT_VALUE###"
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
flatten(flatten(payload.calendar  filter ($.calendarType != null and calendartypeCode[$.calendarType][0] != null) map(calendar, calendarIndex) -> {
	(calendar.pattern map(calendarPattern, calendarPatternIndex) -> {
		calendarAttributes: (calendarPattern.calendarAttribute map(calendarAttribute, calendarAttributeIndex) -> {
		    MS_BULK_REF: vars.storeHeaderReference.bulkReference,
			MS_REF: vars.storeMsgReference.messageReference,
			INTEGRATION_STAMP: ((vars.creationDateAndTime as DateTime + ('PT' ++ calendarAttributeIndex ++ 'S') as Period) replace 'T' with '') [0 to 17],
			MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
			MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
			SENDER: vars.bulkNotificationHeaders.sender,
			CAL : if(calendar.calendarId !=null) 
				calendar.calendarId
			  else  
			    default_value,
			PATTERNSEQNUM: calendarPatternIndex + 1,
			ATTRIBUTE: if (calendarAttribute.attributeType != null) 
					calendarAttribute.attributeType
			   else 
					default_value,
			VALUE: if (calendarAttribute.value != null) 
					calendarAttribute.value
			  else 
					default_value,
			(STARTTIME: ((calendarAttribute.startTime splitBy(":"))[0]*60 + (calendarAttribute.startTime splitBy(":"))[1])) if(calendarAttribute.startTime != null),
		    (ENDTIME: ((calendarAttribute.endTime splitBy(":"))[0]*60 + (calendarAttribute.endTime splitBy(":"))[1])) if(calendarAttribute.endTime != null),
			avplistUDCS:(flatten([(lib.getUdcNameAndValue(calendarEntity, calendar.avpList, lib.getAvpListMap(calendar.avpList))[0]) if (calendar.avpList != null 
				and (calendar.documentActionCode == "ADD" or calendar.documentActionCode == "CHANGE_BY_REFRESH")
				and calendarEntity != null
			),
			(lib.getUdcNameAndValue(calendarEntity, calendarPattern.avpList, lib.getAvpListMap(calendarPattern.avpList))[0]) if (calendarPattern.avpList != null 
			and (calendar.documentActionCode == "ADD" or calendar.documentActionCode == "CHANGE_BY_REFRESH")
			and calendarEntity != null
		)
		])),
			ACTIONCODE: calendar.documentActionCode
		})
	})
}pluck($)))
