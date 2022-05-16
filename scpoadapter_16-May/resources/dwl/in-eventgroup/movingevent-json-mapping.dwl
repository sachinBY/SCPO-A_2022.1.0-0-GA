%dw 2.0
output application/java

var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var movingEventEntity = vars.entityMap.movingevent[0].movingevent[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload.eventGroup  map (eventGroup, index) -> {
	movingevents: (eventGroup.event filter ($.isMovingEvent == true) map (eventData, indexOfEvent) -> {
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		MOVINGEVENT: if(eventData.eventName != null) eventData.eventName else default_value,
		DESCR: if(eventData.description.value != null) eventData.description.value else default_value,
		NUMPERIODS: if(eventData.numberOfPeriodsAffectedByMovingEvent != null) eventData.numberOfPeriodsAffectedByMovingEvent else default_value,
		YEAR: if(eventData.eventDate.eventDate[0] != null) ((eventData.eventDate.eventDate[0] replace "Z" with ("")) as Date).year else default_value,
		STARTDATE: if(eventData.eventDate.eventDate[0] != null and funCaller.formatGS1ToSCPO(eventData.eventDate.eventDate[0]) != default_value) (eventData.eventDate.eventDate[0] replace "Z" with ("")) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
		avplistUDCS:(flatten([(lib.getUdcNameAndValue(movingEventEntity, eventGroup.avpList, lib.getAvpListMap(eventGroup.avpList))[0]) if (eventGroup.avpList != null 
		and (eventGroup.documentActionCode == "ADD" or eventGroup.documentActionCode == "CHANGE_BY_REFRESH")
		and movingEventEntity != null
		),
		(lib.getUdcNameAndValue(movingEventEntity, eventData.avpList, lib.getAvpListMap(eventData.avpList))[0]) if (eventData.avpList != null 
			and (eventGroup.documentActionCode == "ADD" or eventGroup.documentActionCode == "CHANGE_BY_REFRESH")
			and movingEventEntity != null
		)
		])),
		ACTIONCODE: eventGroup.documentActionCode
	})
}).movingevents reduce ($ ++ $$)