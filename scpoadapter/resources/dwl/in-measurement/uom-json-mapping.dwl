%dw 2.0
output application/java
import * from dw::Runtime
var measurementEntity = vars.entityMap.uom[0].uom[0]
var UOMIsoConversion = vars.codeMap.UOMIsoConversion
var UOMConversion = vars.codeMap.UOMConversion
var scpoTypeUomCategory = vars.codeMap.uomCategoryToSCPOTypeConversion
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var default_value = "###JDA_DEFAULT_VALUE###"
fun getUom(inputPayload, index1, index2) =  if (UOMIsoConversion[inputPayload default ""][0] != null)
										if(UOMConversion[UOMIsoConversion[inputPayload][0] default ""][0] != null)
											UOMConversion[UOMIsoConversion[inputPayload][0] default ""][0] as Number
										else
											fail('mapping for ' ++ inputPayload ++ ' is missing in codeMappings.xml')	
					   		  else 
									vars.maxUom + index1 + index2 + 1
fun getUomCategory(inputPayload, index1, index2) =  if (scpoTypeUomCategory[inputPayload][0] != null)
												if(scpoTypeUomCategory[inputPayload][0] != null)
													scpoTypeUomCategory[inputPayload][0] as Number
												else 
													fail('mapping for ' ++ inputPayload ++ ' is missing in codeMappings.xml')	
					   		  		  else 
											vars.maxUomCategory + index1 + index2 + 1	
---
(payload.measurement  map (measurementUnitCode, measurementUnitCodeIndex) -> {
	measurementUnitCode: (measurementUnitCode.measurementUnitCodeInformation map (measurementUnitCodeInf, measurementUnitCodeInfIndex) -> {
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
	    (INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((measurementUnitCodeIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	    MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		UOM : if(measurementUnitCode.measurementTypeCategory == "TIME") 
					if(measurementUnitCodeInf.measurementUnitCode.timeMeasurementUnitCode == null)
						fail('timeMeasurementUnitCode is not available in input message')
					else	
						getUom(measurementUnitCodeInf.measurementUnitCode.timeMeasurementUnitCode, measurementUnitCodeIndex*10, measurementUnitCodeInfIndex)
		      else  if(measurementUnitCode.measurementTypeCategory =="CURRENCY") 
		      			if(measurementUnitCodeInf.measurementUnitCode.currencyCode == null)
							fail('currencyCode is not available in input message')
						else
		      				getUom(measurementUnitCodeInf.measurementUnitCode.currencyCode, measurementUnitCodeIndex*10, measurementUnitCodeInfIndex)
		      else  
		      		getUom(measurementUnitCodeInf.measurementUnitCode.measurementUnitCode, measurementUnitCodeIndex*10, measurementUnitCodeInfIndex),
		SINGULARLABEL:(measurementUnitCodeInf.measurementUnitCodeDescription filter ($.descriptionType == "SINGULAR_LABEL"))[0].value,
		PLURALLABEL:(measurementUnitCodeInf.measurementUnitCodeDescription filter ($.descriptionType == "PLURAL_LABEL"))[0].value,	
		RATIO:  if (measurementUnitCodeInf.basesPerUnit != null) 
					measurementUnitCodeInf.basesPerUnit
				else 
					default_value,
		CATEGORY:  if (measurementUnitCode.measurementTypeCategory != null) 
						getUomCategory(measurementUnitCode.measurementTypeCategory, measurementUnitCodeIndex*10, measurementUnitCodeInfIndex)
				   else 
				   		default_value,				  		
		SHORTLABEL: if(measurementUnitCode.measurementTypeCategory == "TIME") 
						measurementUnitCodeInf.measurementUnitCode.timeMeasurementUnitCode
		             else  if(measurementUnitCode.measurementTypeCategory == "CURRENCY") 
		             	measurementUnitCodeInf.measurementUnitCode.currencyCode
		             else  
		             	measurementUnitCodeInf.measurementUnitCode.measurementUnitCode,
		avplistUDCS:(flatten([(lib.getUdcNameAndValue(measurementEntity, measurementUnitCode.avpList, lib.getAvpListMap(measurementUnitCode.avpList))[0]) if (measurementUnitCode.avpList != null 
		and (measurementUnitCode.documentActionCode == "ADD" or measurementUnitCode.documentActionCode == "CHANGE_BY_REFRESH")
		and measurementEntity != null
		),
		(lib.getUdcNameAndValue(measurementEntity, measurementUnitCodeInf.avpList, lib.getAvpListMap(measurementUnitCodeInf.avpList))[0]) if (measurementUnitCodeInf.avpList != null 
			and (measurementUnitCode.documentActionCode == "ADD" or measurementUnitCode.documentActionCode == "CHANGE_BY_REFRESH")
			and measurementEntity != null
		)
		])),
		ACTIONCODE: measurementUnitCode.documentActionCode
	})  
}).measurementUnitCode reduce ($ ++ $$)
