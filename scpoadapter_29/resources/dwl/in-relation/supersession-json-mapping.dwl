%dw 2.0
output application/java
var supersessionEntity = vars.entityMap.relation[0].supersession[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var default_value = "###JDA_DEFAULT_VALUE###"
---
(payload.relation filter ($.relationId.relationType == 'SUPERSESSION') map (relation, relationIndex) -> {
			MS_BULK_REF: vars.storeHeaderReference.bulkReference,
			MS_REF: vars.storeMsgReference.messageReference,	
			(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((relationIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
            MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  			MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  			SENDER: vars.bulkNotificationHeaders.sender,
            ALTITEMPRIORITY: if(relation.priority != null) relation.priority as Number else default_value,
            DISC: if(relation.effectiveUpToDate != null) relation.effectiveUpToDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
            DRAWQTY: if(relation.drawQuantity.value != null) relation.drawQuantity.value as Number else default_value,
            EFF: if(relation.effectiveFromDate != null) relation.effectiveFromDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
            ENABLEOPT: if(relation.businessInstanceId != null)relation.businessInstanceId as Number else default_value,
            (relation.relatedComponent map (relatedComponent, relatedComponentIndex) -> {
                (ALTITEM: relatedComponent.relatedTo) if (relatedComponent.componentType == 'ITEM'),
                (ITEM: relatedComponent.relatedFrom) if (relatedComponent.componentType == 'ITEM'),
                (DMDGROUP: relatedComponent.relatedFrom) if(relatedComponent.componentType == 'CHANNEL'),
                (LOC: relatedComponent.relatedFrom) if(relatedComponent.componentType == 'LOCATION')
            }),
            (avplistUDCS:(lib.getUdcNameAndValue(supersessionEntity, relation.avpList, lib.getAvpListMap(relation.avpList) )[0])) if (relation.avpList != null
		and (relation.documentActionCode == "ADD" or relation.documentActionCode == "CHANGE_BY_REFRESH")
		and supersessionEntity != null),
            ACTIONCODE: relation.documentActionCode           
})
