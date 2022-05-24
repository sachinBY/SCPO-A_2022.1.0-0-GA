%dw 2.0
output application/java
var calendarEntity = vars.entityMap.cal[0].calpattern[0]
var calendartypeCode = vars.codeMap.calendartypeCodeToSCPOTypeConversion
var default_value = "###JDA_DEFAULT_VALUE###"
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
---
flatten(payload.calendar filter ($.calendarType != null and calendartypeCode[$.calendarType][0] != null) map(calendar, calendarIndex)->{
	calendarPatterns: ( calendar.pattern map(calendarPattern, calendarPatternIndex)-> {
	    MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
		INTEGRATION_STAMP: ((vars.creationDateAndTime as DateTime + ('PT' ++ calendarPatternIndex ++ 'S') as Period) replace 'T' with '') [0 to 17],
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
	 	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
	 	SENDER: vars.bulkNotificationHeaders.sender,
		CAL : if(calendar.calendarId !=null) 
				calendar.calendarId
			  else  
			    default_value,
		//Check how to generate the sequence number PATTERNSEQNUM
		PATTERNSEQNUM: calendarPatternIndex+1,
		STARTDATE: if (calendarPattern.startDate != null) 
					calendarPattern.startDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
			   else 
					default_value,
		ENDDATE: if (calendarPattern.endDate != null) 
						if (calendarPattern.endDate == calendarPattern.startDate) 
							(calendarPattern.endDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} + |P1D|) ++ 'T00:00:00'
						else 
							calendarPattern.endDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
			  	 else 
					default_value,
		(PATTERN: if(calendarPattern.patternFrequencyCode=="EVERY_DAY") 2 
				 else if(calendarPattern.patternFrequencyCode=="EVERY_ORDINAL_DAY") 3 
				 else if(calendarPattern.patternFrequencyCode=="EVERY_WEEKDAY") 4
				 else if(calendarPattern.patternFrequencyCode=="DAY_OF_WEEK") (if(calendarPattern.patternFrequency.weekly.weeksOfRecurrence == null or calendarPattern.patternFrequency.weekly.weeksOfRecurrence == 1) 1 else 3)
				 else if(calendarPattern.patternFrequencyCode=="MONTHLY_ON_DAY_OF_MONTH")(
				 	if(calendarPattern.patternFrequency.monthly.monthsOfRecurrence == 1) 6 else 7)
				 else 7) if(calendarPattern.patternFrequencyCode != null),
		DESCR: if (calendarPattern.name != null) 
					calendarPattern.name
				else 
					default_value,
		//Since for column RANK the default value is hard coded to null and while inserting data to main table it is throwing exception
		// so hard coding it to 1
		RANK: if (calendarPattern.rank != null) 
					calendarPattern.rank
				else 
					1,
		MONDAYSW: if  (calendarPattern.patternFrequency.weekly.dayOfWeek != null and (calendarPattern.patternFrequency.weekly.dayOfWeek contains "MONDAY")) 1 else 0,
		TUESDAYSW: if  (calendarPattern.patternFrequency.weekly.dayOfWeek != null and (calendarPattern.patternFrequency.weekly.dayOfWeek contains "TUESDAY")) 1 else 0,
		WEDNESDAYSW: if  (calendarPattern.patternFrequency.weekly.dayOfWeek != null and (calendarPattern.patternFrequency.weekly.dayOfWeek contains "WEDNESDAY")) 1 else 0,
		THURSDAYSW: if  (calendarPattern.patternFrequency.weekly.dayOfWeek != null and (calendarPattern.patternFrequency.weekly.dayOfWeek contains "THURSDAY")) 1 else 0,
		FRIDAYSW: if  (calendarPattern.patternFrequency.weekly.dayOfWeek != null and (calendarPattern.patternFrequency.weekly.dayOfWeek contains "FRIDAY")) 1 else 0,
		SATURDAYSW: if  (calendarPattern.patternFrequency.weekly.dayOfWeek != null and (calendarPattern.patternFrequency.weekly.dayOfWeek contains "SATURDAY")) 1 else 0,
		SUNDAYSW: if  (calendarPattern.patternFrequency.weekly.dayOfWeek != null and (calendarPattern.patternFrequency.weekly.dayOfWeek contains "SUNDAY")) 1 else 0,
		REPEATEVERYNDAYS: if (calendarPattern.patternFrequency.everyOrdinalDay != null) 
								calendarPattern.patternFrequency.everyOrdinalDay
						  else 
								default_value,
		//Check how to convert
		DAY: if(calendarPattern.startDate != null and calendarPattern.patternFrequencyCode != null and calendarPattern.patternFrequencyCode == "SINGLE_DAY") 
				funCaller.calculateNumericalDayOfYear(calendarPattern.startDate) 
			 else default_value,
		avplistUDCS:(flatten([(lib.getUdcNameAndValue(calendarEntity, calendar.avpList, lib.getAvpListMap(calendar.avpList))[0]) if (calendar.avpList != null 
				and (calendar.documentActionCode == "ADD" or calendar.documentActionCode == "CHANGE_BY_REFRESH")
				and calendarEntity != null
			),
			(lib.getUdcNameAndValue(calendarEntity, calendarPattern.avpList, lib.getAvpListMap(calendarPattern.avpList))[0]) if (calendarPattern.avpList != null 
			and (calendar.documentActionCode == "ADD" or calendar.documentActionCode == "CHANGE_BY_REFRESH")
			and calendarEntity != null
		)
		])),
		ACTIONCODE: calendar.documentActionCode,
        (calendar)
	})
}.calendarPatterns)
