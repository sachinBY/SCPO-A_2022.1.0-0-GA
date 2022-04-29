%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var dfuToSkuEntity = vars.entityMap.dfuview[0].dfutosku[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
flatten(flatten(payload.demandForecastUnit map (demandForecastUnit, index) -> {
    (demandForecastUnit.relatedItemLocationInformation map (relatedItemLocationInformation,indexOfrelatedItemLocationInformation) -> {
	   conversion: { 
	   	//udcs: ((dfuToSkuEntity map (value, index) -> {
		//		(scpoColumnName: value.scpoColumnName) if ((lib.mapHostToSCPO(demandForecastUnit, (value.hostColumnName splitBy "/"), 0)) != null),
		//		(scpoColumnValue: (lib.mapHostToSCPO(demandForecastUnit, (value.hostColumnName splitBy "/"), 0))) if ((lib.mapHostToSCPO(demandForecastUnit, (value.hostColumnName splitBy "/"), 0)) != null),
		//		(dataType: value.dataType) if ((lib.mapHostToSCPO(demandForecastUnit, (value.hostColumnName splitBy "/"), 0)) != null)
  		//})) filter sizeOf($) > 0,
  		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
  		MS_REF: vars.storeMsgReference.messageReference,    
  		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
  		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
	    DMDUNIT: if (demandForecastUnit.demandForecastUnitId.demandUnit != null) demandForecastUnit.demandForecastUnitId.demandUnit else default_value,	    	
	    DMDGROUP: if (demandForecastUnit.demandForecastUnitId.demandChannel != null)demandForecastUnit.demandForecastUnitId.demandChannel else default_value ,	    	
        DFULOC: if (demandForecastUnit.demandForecastUnitId.location.primaryId !=null) demandForecastUnit.demandForecastUnitId.location.primaryId else default_value,
        MODEL: default_value,
	    DISC: if (relatedItemLocationInformation.effectiveUpToDate != null) (relatedItemLocationInformation.effectiveUpToDate replace  "Z" with(""))as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
	    EFF: if (relatedItemLocationInformation.effectiveFromDate != null) (relatedItemLocationInformation.effectiveFromDate replace  "Z" with("") )as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
	    ITEM: if (relatedItemLocationInformation.item.primaryId != null) relatedItemLocationInformation.item.primaryId else default_value,
	    SKULOC: if (demandForecastUnit.demandForecastUnitId.location.primaryId !=null) demandForecastUnit.demandForecastUnitId.location.primaryId else default_value,
	    (avplistUDCS:(lib.getUdcNameAndValue(dfuToSkuEntity, demandForecastUnit.avpList, lib.getAvpListMap(demandForecastUnit.avpList) )[0])) if (demandForecastUnit.avpList != null 
		and (demandForecastUnit.documentActionCode == "ADD" or demandForecastUnit.documentActionCode == "CHANGE_BY_REFRESH")
		and dfuToSkuEntity != null
	),
	    ACTIONCODE: demandForecastUnit.documentActionCode
	   } 
	 })                
} pluck($)))