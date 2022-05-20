%dw 2.0
output application/java  
var codetypeCodeToLocTypeConvers = vars.codeMap.typeCodeToLocTypeConversion
var codeparentRoleToLocTypeConvers = vars.codeMap.parentRoleToLocTypeConversion
var locEntity = vars.entityMap.loc[0].loc[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload.location map {
  (MS_BULK_REF: vars.storeHeaderReference.bulkReference),
  (MS_REF: vars.storeMsgReference.messageReference),
  (INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
  MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  SENDER: vars.bulkNotificationHeaders.sender,
  (BORROWINGPCT: $.planningDetails.borrowingPercentage) 
  				if( $.planningDetails.borrowingPercentage != "" and $.planningDetails.borrowingPercentage != null),
  (CURRENCY: $.basicLocation.address.currencyOfPartyCode) 
  			if ($.basicLocation.address.currencyOfPartyCode != "" and $.basicLocation.address.currencyOfPartyCode != null),
  (COUNTRY: $.basicLocation.address.countryCode) 
  			if ($.basicLocation.address.countryCode != "" and $.basicLocation.address.countryCode != null),
  (DESCR: $.basicLocation.locationName) 
  		if ( $.basicLocation.locationName != "" and $.basicLocation.locationName != null),
  (FRZSTART: $.planningDetails.beginFreezeDate) 
  			if ($.planningDetails.beginFreezeDate != "" and $.planningDetails.beginFreezeDate != null),
  (LAT: $.basicLocation.address.geographicalCoordinates.latitude) 
  		if ($.basicLocation.address.geographicalCoordinates.latitude != "" and $.basicLocation.address.geographicalCoordinates.latitude != null),
  (LOC: $.locationId) 
  		if ( $.locationId != "" and $.locationId != null),
  (if ($.parentParty.parentRole == 'CORPORATE_ENTITY') {
  	(LOC_TYPE: codetypeCodeToLocTypeConvers[$.basicLocation.locationTypeCode][0]) if ($.basicLocation.locationTypeCode != null)
  } else {
  	(LOC_TYPE: codeparentRoleToLocTypeConvers[$.parentParty.parentRole][0]) if ($.parentParty.parentRole != null)
  }),
  (LON: $.basicLocation.address.geographicalCoordinates.longitude) 
  		if ($.basicLocation.address.geographicalCoordinates.longitude != "" and $.basicLocation.address.geographicalCoordinates.longitude != null),
  (OHPOST: $.planningDetails.lastOnHandPostDate) 
  		if ($.planningDetails.lastOnHandPostDate != "" and $.planningDetails.lastOnHandPostDate != null),
  (POSTALCODE: $.basicLocation.address.postalCode) 
  				if ($.basicLocation.address.postalCode != "" and $.basicLocation.address.postalCode != null),
  (WDDAREA: $.planningDetails.weatherArea) 
  			if ($.planningDetails.weatherArea != "" and $.planningDetails.weatherArea != null),
  (WorkingCal: $.planningDetails.calendarId) 
  			if ($.planningDetails.calendarId != "" and $.planningDetails.calendarId != null),
  (avplistUDCS:(lib.getUdcNameAndValue(locEntity, $.avpList, lib.getAvpListMap($.avpList) )[0])) if ($.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and locEntity != null
	),
  ACTIONCODE: $.documentActionCode
})
