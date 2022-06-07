%dw 2.0
output application/java

var default_value = "###JDA_DEFAULT_VALUE###"
var alternateBillOfMaterialEntity = vars.entityMap.billofmaterial[0].altbom[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
flatten(flatten(payload.billOfMaterial default [] map (billOfMaterial, billOfMaterialIndex) -> {
	altbillofmaterial: (billOfMaterial.component default [] map(component, componentIndex) -> {
		(comps: (component.substituteComponent default [] map(substituteComponent, substituteComponentIndex) -> {
			MS_BULK_REF: vars.storeHeaderReference.bulkReference,
			MS_REF: vars.storeMsgReference.messageReference,
			INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(billOfMaterialIndex)S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"},
			MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
			MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
			SENDER: vars.bulkNotificationHeaders.sender,
			ALTSUBORD: if ( substituteComponent.substituteItem.primaryId != null ) substituteComponent.substituteItem.primaryId
							else default_value,
			ALTSUBORDDISC: if ( substituteComponent.effectiveUpToDate != null) substituteComponent.effectiveUpToDate
							else default_value,
			ALTSUBORDEFF: if (substituteComponent.effectiveFromDate != null) substituteComponent.effectiveFromDate
							else default_value,
			ALTSUBORDLOC: if ( substituteComponent.substituteLocation.primaryId != null ) substituteComponent.substituteLocation.primaryId
							  else default_value,
			BOMNUM: if ( billOfMaterial.billOfMaterialNumber != null ) billOfMaterial.billOfMaterialNumber
							else default_value,
			DRAWQTY: if (substituteComponent.drawQuantity.value != null ) substituteComponent.drawQuantity.value 
						 else default_value,
			EFF: if ( component.effectiveFromDate != null) component.effectiveFromDate
						else default_value,
			ITEM: if ( billOfMaterial.item.primaryId != null ) billOfMaterial.item.primaryId
						else default_value,
			LOC: if ( billOfMaterial.location.primaryId != null ) billOfMaterial.location.primaryId 
						else default_value,
			OFFSET: if ( component.offset.value != null ) (if (component.offset.timeMeasurementUnitCode == 'WEE') component.offset.value*7*24*60 else if (component.offset.timeMeasurementUnitCode == 'DAY') component.offset.value*24*60 else component.offset.value) 
						else default_value,
			PRIORITY: if ( substituteComponent.priority != null ) substituteComponent.priority 
							else default_value,
			SUBORD: if ( component.componentItem.primaryId != null ) component.componentItem.primaryId
							else default_value,
			YIELDCAL: if ( substituteComponent.yieldCalendar != null ) substituteComponent.yieldCalendar 
						 else default_value,
			YIELDFACTOR: if ( substituteComponent.yieldFactor != null ) substituteComponent.yieldFactor 
						 else default_value,
			avplistUDCS: (flatten([(lib.getUdcNameAndValue(alternateBillOfMaterialEntity, billOfMaterial.avpList, lib.getAvpListMap(billOfMaterial.avpList))[0]) if (billOfMaterial.avpList != null and (billOfMaterial.documentActionCode == "ADD" or billOfMaterial.documentActionCode == "CHANGE_BY_REFRESH") and alternateBillOfMaterialEntity != null),
			(lib.getUdcNameAndValue(alternateBillOfMaterialEntity, component.avpList, lib.getAvpListMap(component.avpList))[0]) if (component.avpList != null and (billOfMaterial.documentActionCode == "ADD" or billOfMaterial.documentActionCode == "CHANGE_BY_REFRESH") and alternateBillOfMaterialEntity != null),
			(lib.getUdcNameAndValue(alternateBillOfMaterialEntity, substituteComponent.avpList, lib.getAvpListMap(substituteComponent.avpList))[0]) if (substituteComponent.avpList != null and (billOfMaterial.documentActionCode == "ADD" or billOfMaterial.documentActionCode == "CHANGE_BY_REFRESH") and alternateBillOfMaterialEntity != null)])),
			ACTIONCODE: billOfMaterial.documentActionCode
		})) if (component.*substituteComponent != null)
	}.comps)
}.altbillofmaterial))
