%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
var attributeEntity = vars.entityMap.resource[0].calattribute[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")

---
flatten(flatten(flatten(flatten (flatten (payload.resource map(res , index) ->{
	patterns: (res.resourceCalendar.pattern map (pattern , patternIndex) -> {
		attributes: (pattern.calendarAttribute map (attribute , index) -> {
			
				(avplistAttributeUDCS:(lib.getUdcNameAndValue(attributeEntity, res.avpList, lib.getAvpListMap(res.avpList))[0])) if (res.avpList != null 
					and (res.documentActionCode == "ADD" or res.documentActionCode == "CHANGE_BY_REFRESH")
					and attributeEntity != null
				),
				MS_BULK_REF: vars.storeHeaderReference.bulkReference,
				MS_REF: vars.storeMsgReference.messageReference,	
				(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
				MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  				MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  				SENDER: vars.bulkNotificationHeaders.sender,
				(CAL: res.resourceCalendar.calendarId) if(res.resourceCalendar.calendarId != null),
				ACTIONCODE: res.documentActionCode,
				PATTERNSEQNUM: patternIndex+1,
				(ATTRIBUTE: attribute.attributeType) if(attribute.attributeType != null),
				VALUE: if(attribute.value != null) attribute.value else default_value,
			STARTTIME: if(attribute.startTime != null) ((attribute.startTime splitBy(":"))[0]*60+(attribute.startTime splitBy(":"))[1]) else default_value,
				ENDTIME: if(attribute.endTime != null) ((attribute.endTime splitBy(":"))[0]*60+(attribute.endTime splitBy(":"))[1]) else default_value			})
		}.attributes)
		
}pluck($))))))