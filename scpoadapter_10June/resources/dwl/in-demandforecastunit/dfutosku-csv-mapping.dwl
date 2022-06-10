%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var dfuToViewEntity = vars.entityMap.dfuview[0].dfutosku[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload map {
	udcs:((dfuToViewEntity map (value, index) -> {
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
	DFULOC: if ($."demandForecastUnitId.location.primaryId" !=null) $."demandForecastUnitId.location.primaryId" else default_value,
	DISC: if ($."relatedItemLocationInformation.effectiveUpToDate" != null) $."relatedItemLocationInformation.effectiveUpToDate" as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
	EFF: if ($."relatedItemLocationInformation.effectiveFromDate" != null) $."relatedItemLocationInformation.effectiveFromDate" as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
	ITEM: if ($."relatedItemLocationInformation.item.primaryId" != null) $."relatedItemLocationInformation.item.primaryId" else default_value,
	SKULOC: if ($."demandForecastUnitId.location.primaryId" !=null) $."demandForecastUnitId.location.primaryId" else default_value,
	ACTIONCODE: if (!isEmpty($.documentActionCode)) $.documentActionCode else if(!isEmpty(vars.bulknotificationHeaders.documentActionCode)) vars.bulknotificationHeaders.documentActionCode else "ADD"
	
})
