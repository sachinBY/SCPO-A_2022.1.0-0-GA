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
(payload map(network, networkIndex) -> {
			udcs: ((sourcingUOMConvFactorEntity map(value, index) -> {
				(scpoColumnName: value.scpoColumnName) if ((lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0)) != null),
				(scpoColumnValue: (lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0))) if ((lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0)) != null),
				(dataType: value.dataType) if ((lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0)) != null)
			})) filter sizeOf($) > 0,
			MS_BULK_REF: vars.storeHeaderReference.bulkReference,
			MS_REF: vars.storeMsgReference.messageReference,
			(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((networkIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
			MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  			MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  			SENDER: vars.bulkNotificationHeaders.sender,
			DEST: if(network.'dropOffLocation.locationId' != null) network.'dropOffLocation.locationId'
				else default_value,
			ITEM: if(network.'sourcingInformation.sourcingItem.itemId' != null) network.'sourcingInformation.sourcingItem.itemId'
				else default_value,
			RATIO: if (network.'sourcingInformation.sourcingDetails.measurementTypeConversion.ratioOfTargetPerSource' != null)
				network.'sourcingInformation.sourcingDetails.measurementTypeConversion.ratioOfTargetPerSource'
				else default_value,
			SOURCE: if(network.'pickUpLocation.locationId' != null) network.'pickUpLocation.locationId'
				else default_value,
			
			
			SOURCEUOM: if (network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode' != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH")) 
			           if(vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode'][0] == null) fail('mapping for ' ++ network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode' ++ ' UOM is missing in database.')
			           else  vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode'][0] as Number
	 			   else if (network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.timeMeasurementUnitCode' != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH")) 
				        if(vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.timeMeasurementUnitCode'][0] == null) fail('mapping for ' ++ network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.timeMeasurementUnitCode' ++ ' UOM is missing in database.')
				        else vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.timeMeasurementUnitCode'][0]   as Number
	 			   else if (network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.currencyCode' != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH")) 
				        if(vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.currencyCode'][0] == null) fail('mapping for ' ++ network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.currencyCode' ++ ' UOM is missing in database.')
				        else vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.currencyCode'][0]   as Number
	 			   else vars.uomShortLabels[p("bydm.network.default.sourceuom")][0] as Number,
			
			TARGETUOM: if (network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode' != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH")) 
					          if(vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode'][0] == null) fail('mapping for ' ++ network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode' ++ ' UOM is missing in database.')
				             else vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode'][0]   as Number
	 			   	   else if (network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.timeMeasurementUnitCode' != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH")) 
				        	  if(vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.timeMeasurementUnitCode'][0] == null) fail('mapping for ' ++ network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.timeMeasurementUnitCode' ++ ' UOM is missing in database.')
				       		 else vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.timeMeasurementUnitCode'][0]   as Number
	 			   	  else if (network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.currencyCode' != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH")) 
				        	  if(vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.currencyCode'][0] == null) fail('mapping for ' ++ network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.currencyCode' ++ ' UOM is missing in database.')
				        	  else vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.currencyCode'][0]   as Number
	 			      else vars.uomShortLabels[p("bydm.network.default.targetuom")][0] as Number,
			SOURCECATEGORY: if (network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode' != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH"))
								if(uomToCategoryTypeConversion[vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode'][0] as String][0] == null) 
								fail('mapping for ' ++ network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode' ++ ' Category is missing in codeMappings.xml in uomToCategoryTypeConversion.')
								else uomToCategoryTypeConversion[vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode'][0] as String][0] as Number 
							else if(network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.timeMeasurementUnitCode' != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH"))
								if(uomToCategoryTypeConversion[vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.timeMeasurementUnitCode'][0] as String][0] == null)
								 fail('mapping for ' ++ network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.timeMeasurementUnitCode' ++ ' Category is missing in codeMappings.xml in uomToCategoryTypeConversion.')
								else uomToCategoryTypeConversion[vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.timeMeasurementUnitCode'][0] as String][0] as Number   
							else if(network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.currencyCode' != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH"))
								if(uomToCategoryTypeConversion[vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.currencyCode'][0] as String][0] == null)
								 fail('mapping for ' ++ network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.currencyCode' ++ ' Category is missing in codeMappings.xml in uomToCategoryTypeConversion.')
								else uomToCategoryTypeConversion[vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.sourceMeasurementUnitCode.currencyCode'][0] as String][0] as Number  	
							else uomToCategoryTypeConversion[vars.uomShortLabels[p("bydm.network.default.sourceuom")][0] as String][0] as Number,
			TARGETCATEGORY: if (network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode' != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH"))
								if(uomToCategoryTypeConversion[vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode'][0] as String][0] == null) fail('mapping for ' ++ network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode' ++ ' Category is missing in codeMappings.xml in uomToCategoryTypeConversion.')
								else uomToCategoryTypeConversion[vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode'][0] as String][0] as Number  
							else if(network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.timeMeasurementUnitCode' != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH"))
								 if(uomToCategoryTypeConversion[vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.timeMeasurementUnitCode'][0] as String][0] == null) fail('mapping for ' ++ network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.timeMeasurementUnitCode' ++ ' Category is missing in codeMappings.xml in uomToCategoryTypeConversion.')
								else uomToCategoryTypeConversion[vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.timeMeasurementUnitCode'][0] as String][0] as Number   
							else if(network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.currencyCode' != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH"))
								if(uomToCategoryTypeConversion[vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.currencyCode'][0] as String][0] == null) fail('mapping for ' ++ network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.currencyCode' ++ ' Category is missing in codeMappings.xml in uomToCategoryTypeConversion.')
								else uomToCategoryTypeConversion[vars.uomShortLabels[network.'sourcingInformation.sourcingDetails.measurementTypeConversion.targetMeasurementUnitCode.currencyCode'][0] as String][0]  as Number   
							else uomToCategoryTypeConversion[vars.uomShortLabels[p("bydm.network.default.targetuom")][0] as String][0] as Number,
			TRANSMODE: if(network.'transportEquipmentTypeCode.value' != null)
				   network.'transportEquipmentTypeCode.value'
				   else default_value,
			ACTIONCODE: if (network.documentActionCode != null and !isEmpty(network.documentActionCode)) network.documentActionCode else (vars.bulknotificationHeaders.documentActionCode)
	})