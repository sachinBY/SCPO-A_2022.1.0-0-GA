%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
var calEntity = vars.entityMap.resource[0].cal[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
---
flatten (flatten (payload.resource map(res , index) ->{
			
			
			(avplistCalUDCS:(lib.getUdcNameAndValue(calEntity, res.avpList, lib.getAvpListMap(res.avpList))[0]))
							if (res.avpList != null and (res.documentActionCode == "ADD" or res.documentActionCode == "CHANGE_BY_REFRESH")
							and calEntity != null),
			MS_BULK_REF: vars.storeHeaderReference.bulkReference,
			MS_REF: vars.storeMsgReference.messageReference,	
			(CAL: res.resourceCalendar.calendarId) if(res.resourceCalendar.calendarId != null),
			(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
			MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  			MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  			SENDER: vars.bulkNotificationHeaders.sender,
			DESCR_CAL: if(res.resourceCalendar.description.value != null) res.resourceCalendar.description.value else default_value,
			TYPE: if(res.resourceCalendar.calendarType == 'PRODUCTION_CAPACITY') 10 else default_value,
			MASTER: if(res.resourceCalendar.masterCalendar != null) res.resourceCalendar.masterCalendar else default_value,
			PATTERNSW: "1",
			ACTIONCODE: res.documentActionCode
			
			}))
