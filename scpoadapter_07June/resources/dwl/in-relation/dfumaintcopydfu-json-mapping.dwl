%dw 2.0 
output application/java
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var relationEntity = vars.entityMap.relation[0].dfumaintcopydfu[0]
var default_value = "###JDA_DEFAULT_VALUE###"
---
(payload.relation filter ($.relationId.relationType=='RELATION' or $.relationId.relationType == null) map (relation, relationIndex) -> {
			MS_BULK_REF: vars.storeHeaderReference.bulkReference,
			MS_REF: vars.storeMsgReference.messageReference,	
		    (INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((relationIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"} ),
            MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  			MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  			SENDER: vars.bulkNotificationHeaders.sender,
            ACTION_GROUP_SET_ID : 1,
            ACTION_NUMBER: 1,
            FROMDISCDATE: if(relation.fromDemandForecastUnitDiscontinueDate != null) relation.fromDemandForecastUnitDiscontinueDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
            FROMHISTSTART: if(relation.effectiveFromDate != null) relation.effectiveFromDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
            REQUESTID: if(relation.relationId.relationId != null) relation.relationId.relationId else default_value,
            TODISCDATE: if(relation.toDemandForecastUnitEffectiveUpToDate != null) relation.toDemandForecastUnitEffectiveUpToDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
            TOEFFDATE: if(relation.toDemandForecastUnitEffectiveFromDate != null) relation.toDemandForecastUnitEffectiveFromDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
            TONPIINDDATE: if(relation.effectiveUpToDate != null) relation.effectiveUpToDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
            TONPISCALINGFACTOR: if(relation.scaleFactor != null) relation.scaleFactor else default_value,
            HISTSTREAM: " ",
            (relation.relatedComponent map (relatedComponent, relatedComponentIndex) -> {
            	(FROMDMDGROUP: relatedComponent.relatedFrom) if (relatedComponent.componentType == 'CHANNEL'),
            	(TODMDGROUP: relatedComponent.relatedTo) if (relatedComponent.componentType == 'CHANNEL'),
            	(FROMDMDUNIT: relatedComponent.relatedFrom) if (relatedComponent.componentType == 'ITEM'),
            	(TODMDUNIT: relatedComponent.relatedTo) if (relatedComponent.componentType == 'ITEM'),
            	(FROMLOC: relatedComponent.relatedFrom) if (relatedComponent.componentType == 'LOCATION'),
            	(TOLOC: relatedComponent.relatedTo) if (relatedComponent.componentType == 'LOCATION'),
            	(FROMMODEL: relatedComponent.relatedFrom) if (relatedComponent.componentType == 'MODEL'),
            	(TOMODEL: relatedComponent.relatedTo) if (relatedComponent.componentType == 'MODEL')
            }),
            (avplistUDCS:(lib.getUdcNameAndValue(relationEntity, relation.avpList, lib.getAvpListMap(relation.avpList) )[0])) if (relation.avpList != null
		and (relation.documentActionCode == "ADD" or relation.documentActionCode == "CHANGE_BY_REFRESH")
		and relationEntity != null),
            ACTIONCODE: relation.documentActionCode,
})