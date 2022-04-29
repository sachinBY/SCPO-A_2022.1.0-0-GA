%dw 2.0
output application/java  
var dfuviewEntity = vars.entityMap.dfuview[0].dfuview[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
payload.demandForecastUnit map {
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference, 
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
	    (DMDUNIT: $.demandForecastUnitId.demandUnit) 
	    		if not $.demandForecastUnitId.demandUnit == null,
	    (DMDGROUP: $.demandForecastUnitId.demandChannel) 
	    		if not $.demandForecastUnitId.demandChannel == null,
	    (ENABLEOPT: $.businessInstanceId as Number) 
	    		if not $.businessInstanceId == null,
	    (LOC: $.demandForecastUnitId.location.primaryId) 
	    	if not $.demandForecastUnitId.location.primaryId == null,
	    (avplistUDCS:(lib.getUdcNameAndValue(dfuviewEntity, $.avpList, lib.getAvpListMap($.avpList))[0])) if ($.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and dfuviewEntity != null
	),
	    ACTIONCODE: $.documentActionCode
}