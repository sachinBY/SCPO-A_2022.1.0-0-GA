%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var UOMIsoConversion = vars.codeMap.UOMIsoConversion
var UOMConversion = vars.codeMap.UOMConversion
var billOfMaterialEntity = vars.entityMap.billofmaterial[0].bom[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
import * from dw::Runtime
---
(payload.billOfMaterial default [] map (billOfMaterial, index) -> {
	billofmaterial: (billOfMaterial.component default [] map(component, componentIndex) -> {
	 MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	 MS_REF: vars.storeMsgReference.messageReference,
	 INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(index)S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"},
	 MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
	 MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
	 SENDER: vars.bulkNotificationHeaders.sender,	
	 BOMNUM: if (billOfMaterial.billOfMaterialNumber != null) 
	 	billOfMaterial.billOfMaterialNumber 
	 	else default_value,
	 CONSUMSTEPNUM: if (component.productionStepNumber != null) 
	 				component.productionStepNumber 
	 				else default_value,
	 DISC: if (component.effectiveUpToDate != null) 
				(component.effectiveUpToDate)
	 	  else default_value,
	 DRAWQTY: if (component.drawQuantity.value != null) 
			  component.drawQuantity.value
	 		  else default_value,
	 DRAWTYPE: if (component.drawType != null) 
	 		   component.drawType 
	 		   else default_value,
	 EFF: if (component.effectiveFromDate != null) 
	 		(component.effectiveFromDate)
	 	 else default_value,
	 EXPLODESW:if (billOfMaterial.isBOMExploded != null) 
	 				if(billOfMaterial.isBOMExploded =="true") "1"
	 				else "0"
	 			else default_value,
	 ITEM: if (billOfMaterial.item.primaryId != null) 
	 		billOfMaterial.item.primaryId 
	 		else default_value,
	 LOC: if (billOfMaterial.location.primaryId != null) 
	 		billOfMaterial.location.primaryId
	 		else default_value,
	 MIXFACTOR: if (component.mixFactor != null) 
	 				component.mixFactor
	 				else default_value,
	 OFFSET: if ( component.offset.value != null ) 
     			(if (component.offset.timeMeasurementUnitCode == 'WEE') 
                		component.offset.value*7*24*60 
                else if (component.offset.timeMeasurementUnitCode == 'DAY') 
                		component.offset.value*24*60 
                else component.offset.value) 
			else default_value,
	 QTYUOM: if (component.drawQuantity.measurementUnitCode != null and (billOfMaterial.documentActionCode == "ADD" or billOfMaterial.documentActionCode == "CHANGE_BY_REFRESH"))( 
	 			if (vars.uomShortLabels[component.drawQuantity.measurementUnitCode][0] == null) 
				default_value
	 			else vars.uomShortLabels[component.drawQuantity.measurementUnitCode][0] as Number
	 			)else default_value,
	 SHRINKAGEFACTOR: if (component.shrinkageFactor != null) 
	 					component.shrinkageFactor 
	 					else default_value,
	 SUBORD: if (component.componentItem.primaryId != null ) 
			 component.componentItem.primaryId
	 		else default_value,
	 SUBORDLOC:  if (component.componentLocation.primaryId != null) component.componentLocation.primaryId
				 else default_value,
	 SUPERSEDESW: if (component.canBeSuperseded != null) 
	 				 if(component.canBeSuperseded == "true") "1"
	 				 else "0"
	 				else default_value,
	 YIELDCAL: if (component.yieldCalendar != null) 
	 			component.yieldCalendar 
	 			else default_value,
	 YIELDFACTOR: if (component.yieldFactor != null) 
	 			component.yieldFactor
	 			else default_value,
	avplistUDCS:(flatten([(lib.getUdcNameAndValue(billOfMaterialEntity, billOfMaterial.avpList, lib.getAvpListMap(billOfMaterial.avpList))[0]) if (billOfMaterial.avpList != null 
		and (billOfMaterial.documentActionCode == "ADD" or billOfMaterial.documentActionCode == "CHANGE_BY_REFRESH")
		and billOfMaterialEntity != null
		),
		(lib.getUdcNameAndValue(billOfMaterialEntity, component.avpList, lib.getAvpListMap(component.avpList))[0]) if (component.avpList != null 
			and (billOfMaterial.documentActionCode == "ADD" or billOfMaterial.documentActionCode == "CHANGE_BY_REFRESH")
			and billOfMaterialEntity != null
		)
		])),
   	ACTIONCODE: billOfMaterial.documentActionCode
	})
}).billofmaterial reduce ($ ++ $$)