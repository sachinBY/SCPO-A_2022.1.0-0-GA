%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
var patternEntity = vars.entityMap.resource[0].calpattern[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")

---
(flatten (flatten (payload.resource map(res , index) ->{
			patterns: (res.resourceCalendar.pattern map (pattern , patternIndex) -> {
			avplistPatternUDCS: (flatten([(lib.getUdcNameAndValue(patternEntity, res.avpList, lib.getAvpListMap(res.avpList))[0]) if (res.avpList != null 
				and (res.documentActionCode == "ADD" or res.documentActionCode == "CHANGE_BY_REFRESH")
				and patternEntity != null
			),
			(lib.getUdcNameAndValue(patternEntity, pattern.avpList, lib.getAvpListMap(pattern.avpList))[0]) if (pattern.avpList != null 
				and (res.documentActionCode == "ADD" or res.documentActionCode == "CHANGE_BY_REFRESH")
				and patternEntity != null
			)])),
			MS_BULK_REF: vars.storeHeaderReference.bulkReference,
			MS_REF: vars.storeMsgReference.messageReference,
			MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  			MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  			SENDER: vars.bulkNotificationHeaders.sender,	
			(CAL: res.resourceCalendar.calendarId) if(res.resourceCalendar.calendarId != null),
			ACTIONCODE: res.documentActionCode,
			(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((patternIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
			PATTERNSEQNUM: patternIndex+1,
			(STARTDATE: pattern.startDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}) if(pattern.startDate != null and funCaller.formatGS1ToSCPO(pattern.startDate) != default_value),
			(ENDDATE: pattern.endDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}) if(pattern.endDate != null and funCaller.formatGS1ToSCPO(pattern.endDate) != default_value),
			(PATTERN: if(pattern.patternFrequencyCode=="EVERY_DAY") 2 
				 else if(pattern.patternFrequencyCode=="EVERY_ORDINAL_DAY") 3 
				 else if(pattern.patternFrequencyCode=="EVERY_WEEKDAY") 4
				 else if(pattern.patternFrequencyCode=="DAY_OF_WEEK")(
				 	if(pattern.patternFrequency.weekly.weeksOfRecurrence == null or pattern.patternFrequency.weekly.weeksOfRecurrence == 1) 1 else 3)
				 else if(pattern.patternFrequencyCode=="MONTHLY_ON_DAY_OF_MONTH")(
				 	if(pattern.patternFrequency.monthly.monthsOfRecurrence == 1) 6 else 7)
				 else 7) if(pattern.patternFrequencyCode != null),
			DESCR: if(pattern.name != null) pattern.name else default_value,
			RANK: if(pattern.rank != null) pattern.rank else default_value,
			MONDAYSW: if(pattern.patternFrequency.weekly.dayOfWeek != null and((pattern.patternFrequency.weekly.dayOfWeek) contains "MONDAY") ) 1 else default_value,
			TUESDAYSW: if(pattern.patternFrequency.weekly.dayOfWeek != null and((pattern.patternFrequency.weekly.dayOfWeek) contains "TUESDAY") ) 1 else default_value,
			WEDNESDAYSW: if(pattern.patternFrequency.weekly.dayOfWeek != null and((pattern.patternFrequency.weekly.dayOfWeek) contains "WEDNESDAY") ) 1 else default_value,
			THURSDAYSW: if(pattern.patternFrequency.weekly.dayOfWeek != null and ((pattern.patternFrequency.weekly.dayOfWeek) contains "THURSDAY") ) 1 else default_value,
			FRIDAYSW: if(pattern.patternFrequency.weekly.dayOfWeek != null and ((pattern.patternFrequency.weekly.dayOfWeek) contains "FRIDAY")) 1 else default_value,
			SATURDAYSW: if(pattern.patternFrequency.weekly.dayOfWeek != null and ((pattern.patternFrequency.weekly.dayOfWeek) contains "SATURDAY") ) 1 else default_value,
			SUNDAYSW: if(pattern.patternFrequency.weekly.dayOfWeek != null and ((pattern.patternFrequency.weekly.dayOfWeek) contains "SUNDAY") ) 1 else default_value,
			REPEATEVERYNDAYS: if(pattern.patternFrequency.everyOrdinalDay != null) pattern.patternFrequency.everyOrdinalDay else default_value,
			DAY: if(pattern.startDate != null and pattern.patternFrequencyCode != null and pattern.patternFrequencyCode == "SINGLE_DAY") 12 else default_value,

		})
}pluck($))))