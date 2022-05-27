%dw 2.0
output application/java
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var dfuviewEntity = vars.entityMap.dfuview[0].dfuview[0]
var default_value = "###JDA_DEFAULT_VALUE###"
---
(payload map {
	udcs:((dfuviewEntity map (value, index) -> {
			scpoColumnName: value.scpoColumnName,
			scpoColumnValue: if (lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0) != null and trim(lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) != '') (lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) else default_value,
			(dataType: value.dataType) if ((lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) != null),
	}) filter sizeOf($) > 0),
	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference, 
	(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	SENDER: vars.bulkNotificationHeaders.sender,
	(DMDUNIT: $."demandForecastUnitId.demandUnit") 
	    		if not $."demandForecastUnitId.demandUnit" == null,
	(DMDGROUP: $."demandForecastUnitId.demandChannel") 
	    		if not $."demandForecastUnitId.demandChannel" == null,
	(ENABLEOPT: $."businessInstanceId" as Number) 
	    		if not $."businessInstanceId" == null,
	(LOC: $."demandForecastUnitId.location.primaryId") 
	    	if not $."demandForecastUnitId.location.primaryId" == null,
	ACTIONCODE: if (!isEmpty($.documentActionCode)) $.documentActionCode else if(!isEmpty(vars.bulknotificationHeaders.documentActionCode)) vars.bulknotificationHeaders.documentActionCode else "ADD"
})
