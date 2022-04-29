%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var dfuMovingEventMapEntity = vars.entityMap.movingevent[0].dfumovingeventmap[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
flatten(flatten(payload.eventGroup  map (eventGroup, index) -> {
	movingevents: (eventGroup.event filter ($.isMovingEvent == true) map (eventData, indexOfEvent) -> {
		movingeventlocations: (eventGroup.eventLocation map (eventLocationData, indexOfEventLocation) -> {
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		DMDUNIT: if(eventLocationData.demandUnit != null) eventLocationData.demandUnit else "*UNKNOWN",
		DMDGROUP: if(eventLocationData.demandChannel != null) eventLocationData.demandChannel else "*UNKNOWN",
		LOC: eventLocationData.location.primaryId,
		MOVINGEVENT: if(eventData.eventName != null) eventData.eventName else default_value,
		avplistUDCS:(flatten([(lib.getUdcNameAndValue(dfuMovingEventMapEntity, eventGroup.avpList, lib.getAvpListMap(eventGroup.avpList))[0]) if (eventGroup.avpList != null 
		and (eventGroup.documentActionCode == "ADD" or eventGroup.documentActionCode == "CHANGE_BY_REFRESH")
		and dfuMovingEventMapEntity != null
		),
		(lib.getUdcNameAndValue(dfuMovingEventMapEntity, eventData.avpList, lib.getAvpListMap(eventData.avpList))[0]) if (eventData.avpList != null 
			and (eventGroup.documentActionCode == "ADD" or eventGroup.documentActionCode == "CHANGE_BY_REFRESH")
			and dfuMovingEventMapEntity != null
		)
		])),
		ACTIONCODE: eventGroup.documentActionCode
		})
	}.movingeventlocations)  
}.movingevents))
