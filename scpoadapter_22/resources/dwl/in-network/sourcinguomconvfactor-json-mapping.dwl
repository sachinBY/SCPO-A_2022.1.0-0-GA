%dw 2.0
output application/java
import * from dw::Runtime
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
ns ns0 urn:jda:master:network:xsd:3
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var UOMIsoConversion = vars.codeMap.UOMIsoConversion
var UOMConversion = vars.codeMap.UOMConversion
var uomToCategoryTypeConversion = vars.codemap.uomToCategoryTypeConversion
var sourcingUOMConvFactorEntity = vars.entityMap.networkmap[0].sourcinguomconvfactor[0]
---
flatten(flatten(flatten(flatten(payload.network map(network, networkIndex) -> {
	sourcing: (network.sourcingInformation map(sourcingInformation, sourcingInformationIndex) -> {
		conversion: (sourcingInformation.sourcingDetails.measurementTypeConversion map(measurementTypeConversion, measurementTypeConversionIndex) -> {
			//udcs: ((sourcingUOMConvFactorEntity map(value, index) -> {
			//	(scpoColumnName: value.scpoColumnName) if ((lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0)) != null),
			//	(scpoColumnValue: (lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0))) if ((lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0)) != null),
			//	(dataType: value.dataType) if ((lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0)) != null)
			//})) filter sizeOf($) > 0,
			RATIO: if (measurementTypeConversion.ratioOfTargetPerSource != null)
				measurementTypeConversion.ratioOfTargetPerSource
				else default_value,
			MS_BULK_REF: vars.storeHeaderReference.bulkReference,
			MS_REF: vars.storeMsgReference.messageReference,
			(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((measurementTypeConversionIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
			MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  			MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  			SENDER: vars.bulkNotificationHeaders.sender,
			SOURCE: if(network.pickUpLocation.locationId != null) network.pickUpLocation.locationId
				else default_value,
			TRANSMODE: if(network.transportEquipmentTypeCode.value != null)
						network.transportEquipmentTypeCode.value
				   else default_value,
			DEST: if(network.dropOffLocation.locationId != null) network.dropOffLocation.locationId
				else default_value,
			SOURCEUOM: if (measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH")) 
			           if(vars.uomShortLabels[measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode][0] == null) fail('mapping for ' ++ measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode ++ ' UOM is missing in database.')
			           else  vars.uomShortLabels[measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode][0] as Number default default_value
	 			   else if (measurementTypeConversion.sourceMeasurementUnitCode.timeMeasurementUnitCode != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH")) 
				        if(vars.uomShortLabels[measurementTypeConversion.sourceMeasurementUnitCode.timeMeasurementUnitCode][0] == null) fail('mapping for ' ++ measurementTypeConversion.sourceMeasurementUnitCode.timeMeasurementUnitCode ++ ' UOM is missing in database.')
				        else vars.uomShortLabels[measurementTypeConversion.sourceMeasurementUnitCode.timeMeasurementUnitCode][0]   as Number default default_value
	 			   else if (measurementTypeConversion.sourceMeasurementUnitCode.currencyCode != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH")) 
				        if(vars.uomShortLabels[measurementTypeConversion.sourceMeasurementUnitCode.currencyCode][0] == null) fail('mapping for ' ++ measurementTypeConversion.sourceMeasurementUnitCode.currencyCode ++ ' UOM is missing in database.')
				        else vars.uomShortLabels[measurementTypeConversion.sourceMeasurementUnitCode.currencyCode][0]   as Number default default_value
	 			   else vars.uomShortLabels[p("bydm.network.default.sourceuom")][0] as Number default default_value,
			SOURCECATEGORY: if (measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH"))
								if(uomToCategoryTypeConversion[vars.uomShortLabels[measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode][0] as String][0] == null) 
								fail('mapping for ' ++ measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode ++ ' Category is missing in codeMappings.xml in uomToCategoryTypeConversion.')
								else uomToCategoryTypeConversion[vars.uomShortLabels[measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode][0] as String][0] as Number default default_value 
							else if(measurementTypeConversion.sourceMeasurementUnitCode.timeMeasurementUnitCode != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH"))
								if(uomToCategoryTypeConversion[vars.uomShortLabels[measurementTypeConversion.sourceMeasurementUnitCode.timeMeasurementUnitCode][0] as String][0] == null)
								 fail('mapping for ' ++ measurementTypeConversion.sourceMeasurementUnitCode.timeMeasurementUnitCode ++ ' Category is missing in codeMappings.xml in uomToCategoryTypeConversion.')
								else uomToCategoryTypeConversion[vars.uomShortLabels[measurementTypeConversion.sourceMeasurementUnitCode.timeMeasurementUnitCode][0] as String][0] as Number default default_value   
							else if(measurementTypeConversion.sourceMeasurementUnitCode.currencyCode != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH"))
								if(uomToCategoryTypeConversion[vars.uomShortLabels[measurementTypeConversion.sourceMeasurementUnitCode.currencyCode][0] as String][0] == null)
								fail('mapping for ' ++ measurementTypeConversion.sourceMeasurementUnitCode.currencyCode ++ ' Category is missing in codeMappings.xml in uomToCategoryTypeConversion.')
								else uomToCategoryTypeConversion[vars.uomShortLabels[measurementTypeConversion.sourceMeasurementUnitCode.currencyCode][0] as String][0] as Number default default_value  	
							else uomToCategoryTypeConversion[vars.uomShortLabels[p("bydm.network.default.sourceuom")][0] as String][0] as Number default default_value,
			TARGETUOM: if (measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH")) 
					          if(vars.uomShortLabels[measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode][0] == null) fail('mapping for ' ++ measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode ++ ' UOM is missing in database.')
				             else vars.uomShortLabels[measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode][0]   as Number default default_value
	 			   	   else if (measurementTypeConversion.targetMeasurementUnitCode.timeMeasurementUnitCode != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH")) 
				        	  if(vars.uomShortLabels[measurementTypeConversion.targetMeasurementUnitCode.timeMeasurementUnitCode][0] == null) fail('mapping for ' ++ measurementTypeConversion.targetMeasurementUnitCode.timeMeasurementUnitCode ++ ' UOM is missing in database.')
				       		 else vars.uomShortLabels[measurementTypeConversion.targetMeasurementUnitCode.timeMeasurementUnitCode][0]   as Number default default_value
	 			   	  else if (measurementTypeConversion.targetMeasurementUnitCode.currencyCode != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH")) 
				        	  if(vars.uomShortLabels[measurementTypeConversion.targetMeasurementUnitCode.currencyCode][0] == null) fail('mapping for ' ++ measurementTypeConversion.targetMeasurementUnitCode.currencyCode ++ ' UOM is missing in database.')
				        	  else vars.uomShortLabels[measurementTypeConversion.targetMeasurementUnitCode.currencyCode][0]   as Number default default_value
	 			      else vars.uomShortLabels[p("bydm.network.default.targetuom")][0] as Number default default_value,
	 		TARGETCATEGORY: if (measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH"))
								if(uomToCategoryTypeConversion[vars.uomShortLabels[measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode][0] as String][0] == null) fail('mapping for ' ++ measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode ++ ' Category is missing in codeMappings.xml in uomToCategoryTypeConversion.')
								else uomToCategoryTypeConversion[vars.uomShortLabels[measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode][0] as String][0] as Number default default_value  
							else if(measurementTypeConversion.targetMeasurementUnitCode.timeMeasurementUnitCode != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH"))
								 if(uomToCategoryTypeConversion[vars.uomShortLabels[measurementTypeConversion.targetMeasurementUnitCode.timeMeasurementUnitCode][0] as String][0] == null) fail('mapping for ' ++ measurementTypeConversion.targetMeasurementUnitCode.targetMeasurementUnitCode ++ ' Category is missing in codeMappings.xml in uomToCategoryTypeConversion.')
								else uomToCategoryTypeConversion[vars.uomShortLabels[measurementTypeConversion.targetMeasurementUnitCode.timeMeasurementUnitCode][0] as String][0] as Number default default_value   
							else if(measurementTypeConversion.targetMeasurementUnitCode.currencyCode != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH"))
								if(uomToCategoryTypeConversion[vars.uomShortLabels[measurementTypeConversion.targetMeasurementUnitCode.currencyCode][0] as String][0] == null) fail('mapping for ' ++ measurementTypeConversion.targetMeasurementUnitCode.currencyCode ++ ' Category is missing in codeMappings.xml in uomToCategoryTypeConversion.')
								else uomToCategoryTypeConversion[vars.uomShortLabels[measurementTypeConversion.targetMeasurementUnitCode.currencyCode][0] as String][0]  as Number default default_value   
							else uomToCategoryTypeConversion[vars.uomShortLabels[p("bydm.network.default.targetuom")][0] as String][0] as Number default default_value,
			ITEM: if(sourcingInformation.sourcingItem.itemId != null) sourcingInformation.sourcingItem.itemId
				else default_value,
	sourcinguomconvfactorUDC:flatten([(lib.getUdcNameAndValue(sourcingUOMConvFactorEntity, network.avpList, lib.getAvpListMap(network.avpList))[0]) 
	if (network.avpList != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH") and sourcingUOMConvFactorEntity != null),
	(lib.getUdcNameAndValue(sourcingUOMConvFactorEntity, sourcingInformation.sourcingDetails.avpList, lib.getAvpListMap(sourcingInformation.sourcingDetails.avpList))[0]) 
	if (sourcingInformation.sourcingDetails.avpList != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH") and sourcingUOMConvFactorEntity != null),
	(lib.getUdcNameAndValue(sourcingUOMConvFactorEntity, measurementTypeConversion.avpList, lib.getAvpListMap(measurementTypeConversion.avpList))[0]) 
	if (measurementTypeConversion.avpList != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH") and sourcingUOMConvFactorEntity != null)
	]),
			ACTIONCODE: network.documentActionCode
		})
	} pluck ($))
} pluck($)))))