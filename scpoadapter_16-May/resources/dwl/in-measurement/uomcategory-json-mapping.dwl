%dw 2.0
output application/java

var measurementEntity = vars.entityMap.uom[0].uomcategory[0]
var UOMIsoConversion = vars.codeMap.UOMIsoConversion
var UOMConversion = vars.codeMap.UOMConversion
var scpoTypeUomCategory = vars.codeMap.uomCategoryToSCPOTypeConversion
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var default_value = "###JDA_DEFAULT_VALUE###"
fun getUom(inputPayload) =  if (UOMIsoConversion[inputPayload][0] != null)
							UOMConversion[UOMIsoConversion[inputPayload][0]][0] as Number
					   else 
							default_value
fun getUomCategory(inputPayload, index) =  if (scpoTypeUomCategory[inputPayload][0] != null)
											scpoTypeUomCategory[inputPayload][0] as Number
					   		  		  else 
											vars.maxUomCategory + 1	
---
flatten(flatten(payload.measurement  map (measurementUnitCode, measurementUnitCodeIndex) -> {
	array:(measurementUnitCode.measurementUnitCodeInformation map (measurementUnitCodeInf, measurementUnitCodeInfIndex) -> {
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
	    (INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((measurementUnitCodeIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	    MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		CATEGORY:  getUomCategory(measurementUnitCode.measurementTypeCategory, measurementUnitCodeIndex),	
		LABEL:  if (measurementUnitCode.measurementTypeDescription.value != null)
						measurementUnitCode.measurementTypeDescription.value
				else 
				   		default_value,	

		STDUOM : if (measurementUnitCodeInf.isBaseMeasurementUnitCode == true) 
				if(measurementUnitCode.measurementTypeCategory == "TIME") 
						getUom(measurementUnitCodeInf.measurementUnitCode.timeMeasurementUnitCode)
		      		else  if(measurementUnitCode.measurementTypeCategory =="CURRENCY") 
		      			getUom(measurementUnitCodeInf.measurementUnitCode.currencyCode)
		      		else  
		      			getUom(measurementUnitCodeInf.measurementUnitCode.measurementUnitCode)
		      	 else
		      	 	default_value,
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
}pluck($)))
