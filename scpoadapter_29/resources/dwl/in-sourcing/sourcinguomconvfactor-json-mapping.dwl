%dw 2.0
output application/java
import * from dw::Runtime
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var default_value = "###JDA_DEFAULT_VALUE###"
var UOMIsoConversion = vars.codeMap.UOMIsoConversion
var UOMConversion = vars.codeMap.UOMConversion
var uomToCategoryTypeConversion = vars.codemap.uomToCategoryTypeConversion
var sourcingUOMConvFactorEntity = vars.entityMap.sourcing[0].sourcinguomconvfactor[0]

---

flatten((payload.sourcing map (sourcing, sourcingIndex) -> {
	(val:sourcing.sourcingDetails.measurementTypeConversion map()-> {
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((sourcingIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		DEST: if(sourcing.sourcingId.dropOffLocation.locationId != null) sourcing.sourcingId.dropOffLocation.locationId
				else default_value,
		ITEM: if(sourcing.sourcingId.item.itemId != null) sourcing.sourcingId.item.itemId
				else default_value,
		RATIO:  if($.ratioOfTargetPerSource != null) $.ratioOfTargetPerSource
				else default_value,
		SOURCE: if(sourcing.sourcingId.pickUpLocation.locationId != null) sourcing.sourcingId.pickUpLocation.locationId
				else default_value,
		TRANSMODE: if(sourcing.transportEquipment.transportEquipmentTypeCode.value != null) sourcing.transportEquipment.transportEquipmentTypeCode.value
				else default_value,
				
		SOURCEUOM: if ($.sourceMeasurementUnitCode.measurementUnitCode != null and (sourcing.documentActionCode == "ADD" or sourcing.documentActionCode == "CHANGE_BY_REFRESH")) 
	 				 if (vars.uomShortLabels[$.sourceMeasurementUnitCode.measurementUnitCode][0] == null)
	 				 	fail('mapping for ' ++ $.sourceMeasurementUnitCode.measurementUnitCode ++ ' UOM is missing in database.')
	 				 else 
	 				  vars.uomShortLabels[$.sourceMeasurementUnitCode.measurementUnitCode][0] as Number
	 			   else if ($.sourceMeasurementUnitCode.timeMeasurementUnitCode != null and (sourcing.documentActionCode == "ADD" or sourcing.documentActionCode == "CHANGE_BY_REFRESH")) 
	 				    	if(vars.uomShortLabels[$.sourceMeasurementUnitCode.timeMeasurementUnitCode][0] == null)
	 				    		fail('mapping for ' ++ $.sourceMeasurementUnitCode.timeMeasurementUnitCode ++ ' UOM is missing in database.')
	 				    	else vars.uomShortLabels[$.sourceMeasurementUnitCode.timeMeasurementUnitCode][0] as Number
	 			   else if ($.sourceMeasurementUnitCode.currencyCode != null and (sourcing.documentActionCode == "ADD" or sourcing.documentActionCode == "CHANGE_BY_REFRESH")) 
	 				    	if (vars.uomShortLabels[$.sourceMeasurementUnitCode.currencyCode][0] == null)
	 				    		fail('mapping for ' ++ $.sourceMeasurementUnitCode.currencyCode ++ ' UOM is missing in database.')
	 				    	else vars.uomShortLabels[$.sourceMeasurementUnitCode.currencyCode][0] as Number
	 			   else vars.uomShortLabels[p("bydm.network.default.sourceuom")][0] as Number,
		SOURCECATEGORY: if ($.sourceMeasurementUnitCode.measurementUnitCode != null) 
	 				       if (uomToCategoryTypeConversion[vars.uomShortLabels[$.sourceMeasurementUnitCode.measurementUnitCode][0] as String][0] != null)
	 				       uomToCategoryTypeConversion[vars.uomShortLabels[$.sourceMeasurementUnitCode.measurementUnitCode][0] as String][0] as Number
	 				       else fail('mapping for ' ++ $.sourceMeasurementUnitCode.measurementUnitCode ++ ' Category is missing in codeMappings.xml in uomToCategoryTypeConversion.')
	 			        else if ($.sourceMeasurementUnitCode.timeMeasurementUnitCode != null and (sourcing.documentActionCode == "ADD" or sourcing.documentActionCode == "CHANGE_BY_REFRESH")) 
	 				         if (uomToCategoryTypeConversion[vars.uomShortLabels[$.sourceMeasurementUnitCode.timeMeasurementUnitCode][0] as String][0] != null)
	 				         uomToCategoryTypeConversion[vars.uomShortLabels[$.sourceMeasurementUnitCode.timeMeasurementUnitCode][0] as String][0] as Number
	 				         else fail('mapping for ' ++ $.sourceMeasurementUnitCode.timeMeasurementUnitCode ++ ' Category is missing in codeMappings.xml in uomToCategoryTypeConversion.')
		 			   else if ($.sourceMeasurementUnitCode.currencyCode != null and (sourcing.documentActionCode == "ADD" or sourcing.documentActionCode == "CHANGE_BY_REFRESH")) 
		 					if (uomToCategoryTypeConversion[vars.uomShortLabels[$.sourceMeasurementUnitCode.currencyCode][0] as String][0] != null) 
		 					uomToCategoryTypeConversion[vars.uomShortLabels[$.sourceMeasurementUnitCode.currencyCode][0] as String][0] as Number
		 					else fail('mapping for ' ++ $.sourceMeasurementUnitCode.currencyCode ++ ' Category is missing in codeMappings.xml in uomToCategoryTypeConversion.')
		 			   else uomToCategoryTypeConversion[vars.uomShortLabels[p("bydm.network.default.sourceuom")][0] as String][0] as Number,
		TARGETUOM: if ($.targetMeasurementUnitCode.measurementUnitCode != null and (sourcing.documentActionCode == "ADD" or sourcing.documentActionCode == "CHANGE_BY_REFRESH")) 
	 				if(vars.uomShortLabels[$.targetMeasurementUnitCode.measurementUnitCode][0] == null)
	 					fail('mapping for ' ++ $.targetMeasurementUnitCode.measurementUnitCode ++ ' UOM is missing in database.')
	 				else 
	 				    vars.uomShortLabels[$.targetMeasurementUnitCode.measurementUnitCode][0] as Number
	 			   else if ($.targetMeasurementUnitCode.timeMeasurementUnitCode != null and (sourcing.documentActionCode == "ADD" or sourcing.documentActionCode == "CHANGE_BY_REFRESH")) 
	 				    if (vars.uomShortLabels[$.targetMeasurementUnitCode.timeMeasurementUnitCode][0] == null) 
	 				      fail('mapping for ' ++ $.targetMeasurementUnitCode.timeMeasurementUnitCode ++ ' UOM is missing in database.')
	 				    else vars.uomShortLabels[$.targetMeasurementUnitCode.timeMeasurementUnitCode][0] as Number
	 			   else if ($.targetMeasurementUnitCode.currencyCode != null and (sourcing.documentActionCode == "ADD" or sourcing.documentActionCode == "CHANGE_BY_REFRESH")) 
	 				    if (vars.uomShortLabels[$.targetMeasurementUnitCode.currencyCode][0] == null)
	 				      fail('mapping for ' ++ $.targetMeasurementUnitCode.currencyCode ++ ' UOM is missing in database.')
	 				    else vars.uomShortLabels[$.targetMeasurementUnitCode.currencyCode][0] as Number
	 			   else vars.uomShortLabels[p("bydm.network.default.targetuom")][0] as Number,
		TARGETCATEGORY:if ($.targetMeasurementUnitCode.measurementUnitCode != null) 
	 				       if (uomToCategoryTypeConversion[vars.uomShortLabels[$.targetMeasurementUnitCode.measurementUnitCode][0] as String][0] != null)
	 				       uomToCategoryTypeConversion[vars.uomShortLabels[$.targetMeasurementUnitCode.measurementUnitCode][0] as String][0] as Number
	 				       else fail('mapping for ' ++ $.targetMeasurementUnitCode.measurementUnitCode ++ ' Category is missing in codeMappings.xml in uomToCategoryTypeConversion.')
	 			        else if ($.targetMeasurementUnitCode.timeMeasurementUnitCode != null and (sourcing.documentActionCode == "ADD" or sourcing.documentActionCode == "CHANGE_BY_REFRESH")) 
	 				         if (uomToCategoryTypeConversion[vars.uomShortLabels[$.targetMeasurementUnitCode.timeMeasurementUnitCode][0] as String][0] != null)
	 				         uomToCategoryTypeConversion[vars.uomShortLabels[$.targetMeasurementUnitCode.timeMeasurementUnitCode][0] as String][0] as Number
	 				         else fail('mapping for ' ++ $.targetMeasurementUnitCode.timeMeasurementUnitCode ++ ' Category is missing in codeMappings.xml in uomToCategoryTypeConversion.')
		 			   else if ($.targetMeasurementUnitCode.currencyCode != null and (sourcing.documentActionCode == "ADD" or sourcing.documentActionCode == "CHANGE_BY_REFRESH")) 
		 					if (uomToCategoryTypeConversion[vars.uomShortLabels[$.targetMeasurementUnitCode.currencyCode][0] as String][0] != null) 
		 					uomToCategoryTypeConversion[vars.uomShortLabels[$.targetMeasurementUnitCode.currencyCode][0] as String][0] as Number
		 					else fail('mapping for ' ++ $.targetMeasurementUnitCode.currencyCode ++ ' Category is missing in codeMappings.xml in uomToCategoryTypeConversion.')
		 			   else uomToCategoryTypeConversion[vars.uomShortLabels[p("bydm.network.default.sourceuom")][0] as String][0] as Number,
	    avplistUDCS:(flatten([(lib.getUdcNameAndValue(sourcingUOMConvFactorEntity, sourcing.avpList, lib.getAvpListMap(sourcing.avpList))[0]) if (sourcing.avpList != null 
		and (sourcing.documentActionCode == "ADD" or sourcing.documentActionCode == "CHANGE_BY_REFRESH")
		and sourcingUOMConvFactorEntity != null
		),
		(lib.getUdcNameAndValue(sourcingUOMConvFactorEntity, sourcing.sourcingDetails.avpList, lib.getAvpListMap(sourcing.sourcingDetails.avpList))[0]) if (sourcing.sourcingDetails.avpList != null 
			and (sourcing.sourcingDetails.documentActionCode == "ADD" or sourcing.sourcingDetails.documentActionCode == "CHANGE_BY_REFRESH")
			and sourcingUOMConvFactorEntity != null
		)
		])),
		
		ACTIONCODE: sourcing.documentActionCode,
		
		})
	}).val)