%dw 2.0
output application/java
import * from dw::Runtime
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var UOMIsoConversion = vars.codeMap.UOMIsoConversion
var UOMConversion = vars.codeMap.UOMConversion
var uomToCategoryTypeConversion = vars.codemap.uomToCategoryTypeConversion
var itemUomCatConvFactorEntity = vars.entityMap.item[0].uomcategoryconvfactor[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
fun findCategory(inputPayload) = if(inputPayload != null) 
								((vars.uomCategories)."$(inputPayload)")[0] 
								else null
---
flatten(if(p("bydm.automatic.uomconversion") == "true")
	flatten([(flatten(flatten((payload.item map (item, itemIndex) -> {
	itemLogisticUnitInformation:(item.itemLogisticUnitInformation map (itemLogisticUnitInformation , index) -> {
		itemLogisticUnits:(itemLogisticUnitInformation.itemLogisticUnit map (itemLogisticUnit , index) -> {
			(LOGISTICUNITNAME: itemLogisticUnit.logisticUnitName) if (itemLogisticUnit.logisticUnitName != null and itemLogisticUnit.logisticUnitName != ""),
			(TRADEITEMQUANTITY: itemLogisticUnit.tradeItemQuantity.value) if (itemLogisticUnit.tradeItemQuantity.value != null and itemLogisticUnit.tradeItemQuantity.value != ""),
			(ITEM: item.itemId.primaryId)if (item.itemId.primaryId != null and item.itemId.primaryId != ""),
  			(avplistUDCS:(lib.getUdcNameAndValue(itemUomCatConvFactorEntity, itemLogisticUnit.avpList, lib.getAvpListMap(itemLogisticUnit.avpList) )[0])) if (itemLogisticUnit.avpList != null and (itemLogisticUnitInformation.actionCode == "ADD" or itemLogisticUnitInformation.actionCode == "CHANGE_BY_REFRESH") and itemUomCatConvFactorEntity != null),
  			ACTIONCODE: itemLogisticUnitInformation.actionCode,
  			(MS_BULK_REF: vars.storeHeaderReference.bulkReference),
			(MS_REF: vars.storeMsgReference.messageReference),
			(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
			MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
	 		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
	 		SENDER: vars.bulkNotificationHeaders.sender
		})
	})
}pluck($)))) filter sizeOf($) > 0 map ($.itemLogisticUnits orderBy ($.TRADEITEMQUANTITY)) map (logisticUnitInfo , index) -> {
			(ITEM: logisticUnitInfo[sizeOf(logisticUnitInfo) - 1].ITEM),
			(TARGETCATEGORY: if (vars.uomShortLabels[logisticUnitInfo[0].LOGISTICUNITNAME][0] != null)
				                  findCategory(vars.uomShortLabels[logisticUnitInfo[0].LOGISTICUNITNAME][0])
							 else 
							      fail('mapping for ' ++ logisticUnitInfo[0].LOGISTICUNITNAME ++ ' UOM is missing in database.') 
							     ),
			(TARGETUOM:  if (vars.uomShortLabels[logisticUnitInfo[0].LOGISTICUNITNAME][0] != null)
				                  vars.uomShortLabels[logisticUnitInfo[0].LOGISTICUNITNAME][0]
							 else 
							      fail('mapping for ' ++ logisticUnitInfo[0].LOGISTICUNITNAME ++ ' UOM is missing in database.')
			),
			(SOURCEUOM: (if (vars.uomShortLabels[logisticUnitInfo[sizeOf(logisticUnitInfo) - 1].LOGISTICUNITNAME][0] != null) vars.uomShortLabels[logisticUnitInfo[sizeOf(logisticUnitInfo) - 1].LOGISTICUNITNAME][0]
				         else 
				          fail('mapping for ' ++ logisticUnitInfo[sizeOf(logisticUnitInfo) - 1].LOGISTICUNITNAME ++ ' UOM is missing in database.')
			)),
			(SOURCECATEGORY: 
				if (vars.uomShortLabels[logisticUnitInfo[sizeOf(logisticUnitInfo) - 1].LOGISTICUNITNAME][0] != null) 
				      findCategory(vars.uomShortLabels[logisticUnitInfo[sizeOf(logisticUnitInfo) - 1].LOGISTICUNITNAME][0])
				else 
				      
				      fail('mapping for ' ++ logisticUnitInfo[sizeOf(logisticUnitInfo) - 1].LOGISTICUNITNAME ++ ' UOM is missing in database.')	
			),
			(RATIO: logisticUnitInfo[sizeOf(logisticUnitInfo) - 1].TRADEITEMQUANTITY),
			(ACTIONCODE: logisticUnitInfo[sizeOf(logisticUnitInfo) - 1].ACTIONCODE),
			(avplistUDCS: flatten(logisticUnitInfo.avplistUDCS)),
			(MS_BULK_REF: vars.storeHeaderReference.bulkReference),
			(MS_REF: vars.storeMsgReference.messageReference),
			(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
			MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
	 		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
	 		SENDER: vars.bulkNotificationHeaders.sender,
	}),(flatten(flatten(flatten((payload.item map (item, itemIndex) -> {
	itemLogisticUnitInformation:(item.itemLogisticUnitInformation map (itemLogisticUnitInformation , index) -> {
		itemLogisticUnits:(itemLogisticUnitInformation.itemLogisticUnit map (itemLogisticUnit , index) -> {
			LOGISTICUNITNAME: itemLogisticUnit.logisticUnitName,
			TRADEITEMQUANTITY: itemLogisticUnit.tradeItemQuantity.value,
			(ITEM: item.itemId.primaryId) if (item.itemId.primaryId != null),
  			SOURCEUOM_WEIGHT: if (itemLogisticUnit.grossWeight.measurementUnitCode != null and vars.uomShortLabels[itemLogisticUnit.grossWeight.measurementUnitCode][0] == null) fail('mapping for ' ++ itemLogisticUnit.grossWeight.measurementUnitCode ++ ' UOM is not present in the database')
  			else if(itemLogisticUnit.grossWeight.measurementUnitCode != null and itemLogisticUnit.grossWeight.measurementUnitCode != "" and vars.uomShortLabels[itemLogisticUnit.grossWeight.measurementUnitCode][0] != null) vars.uomShortLabels[itemLogisticUnit.grossWeight.measurementUnitCode][0] as Number
  								else 10,
  			SOURCECATEGORY_WEIGHT: if (itemLogisticUnit.grossWeight.measurementUnitCode != null and vars.uomShortLabels[itemLogisticUnit.grossWeight.measurementUnitCode][0] == null) fail('mapping for ' ++ itemLogisticUnit.grossWeight.measurementUnitCode ++ ' UOM is not present in the database')
  			else if(itemLogisticUnit.grossWeight.measurementUnitCode != null and itemLogisticUnit.grossWeight.measurementUnitCode != "" and vars.uomShortLabels[itemLogisticUnit.grossWeight.measurementUnitCode][0] != null) findCategory(vars.uomShortLabels[itemLogisticUnit.grossWeight.measurementUnitCode][0]) else findCategory(10),
  			(RATIO_WEIGHT: itemLogisticUnit.grossWeight.value as Number) if(itemLogisticUnit.grossWeight.value != null and itemLogisticUnit.grossWeight.value != ""),
  			
  			SOURCEUOM_VOL: if (itemLogisticUnit.grossVolume.measurementUnitCode != null and vars.uomShortLabels[itemLogisticUnit.grossVolume.measurementUnitCode][0] == null) fail('mapping for ' ++ itemLogisticUnit.grossVolume.measurementUnitCode ++ ' UOM is not present in the database.')
  			else if(itemLogisticUnit.grossVolume.measurementUnitCode != null and itemLogisticUnit.grossVolume.measurementUnitCode != "" and vars.uomShortLabels[itemLogisticUnit.grossVolume.measurementUnitCode][0] != null) vars.uomShortLabels[itemLogisticUnit.grossVolume.measurementUnitCode][0]  as Number
  								else 70,
  			SOURCECATEGORY_VOL: if (itemLogisticUnit.grossVolume.measurementUnitCode != null and vars.uomShortLabels[itemLogisticUnit.grossVolume.measurementUnitCode][0] == null) fail('mapping for ' ++ itemLogisticUnit.grossVolume.measurementUnitCode ++ ' UOM is not present in the database.')
  			else if(itemLogisticUnit.grossVolume.measurementUnitCode != null and itemLogisticUnit.grossVolume.measurementUnitCode != "" and vars.uomShortLabels[itemLogisticUnit.grossVolume.measurementUnitCode][0] != null) findCategory(vars.uomShortLabels[itemLogisticUnit.grossVolume.measurementUnitCode][0]) else findCategory(10),
  			(RATIO_VOL: itemLogisticUnit.grossVolume.value as Number) if(itemLogisticUnit.grossVolume.value != null and itemLogisticUnit.grossVolume.value != ""),
  			
  			SOURCEUOM_DEPTH: if (itemLogisticUnit.dimensionsOfLogisticUnit.depth.measurementUnitCode != null and vars.uomShortLabels[itemLogisticUnit.dimensionsOfLogisticUnit.depth.measurementUnitCode][0] == null) fail('mapping for ' ++ itemLogisticUnit.dimensionsOfLogisticUnit.depth.measurementUnitCode ++ ' UOM is not present in the database.')
  			else if(itemLogisticUnit.dimensionsOfLogisticUnit.depth.measurementUnitCode != null and itemLogisticUnit.dimensionsOfLogisticUnit.depth.measurementUnitCode != "" and vars.uomShortLabels[itemLogisticUnit.dimensionsOfLogisticUnit.depth.measurementUnitCode][0] != null) vars.uomShortLabels[itemLogisticUnit.dimensionsOfLogisticUnit.depth.measurementUnitCode][0] as Number
  								else 30,
  			SOURCECATEGORY_DEPTH:  if (itemLogisticUnit.dimensionsOfLogisticUnit.depth.measurementUnitCode != null and vars.uomShortLabels[itemLogisticUnit.dimensionsOfLogisticUnit.depth.measurementUnitCode][0] == null) fail('mapping for ' ++ itemLogisticUnit.dimensionsOfLogisticUnit.depth.measurementUnitCode ++ ' UOM is not present in the database.')
  			else if(itemLogisticUnit.dimensionsOfLogisticUnit.depth.measurementUnitCode != null and itemLogisticUnit.dimensionsOfLogisticUnit.depth.measurementUnitCode != "" and vars.uomShortLabels[itemLogisticUnit.dimensionsOfLogisticUnit.depth.measurementUnitCode][0] != null) findCategory(vars.uomShortLabels[itemLogisticUnit.dimensionsOfLogisticUnit.depth.measurementUnitCode][0]) else findCategory(30),
  			(RATIO_DEPTH: itemLogisticUnit.dimensionsOfLogisticUnit.depth.value as Number) if(itemLogisticUnit.dimensionsOfLogisticUnit.depth.value != null and itemLogisticUnit.dimensionsOfLogisticUnit.depth.value != ""),
  			(avplistUDCS:(lib.getUdcNameAndValue(itemUomCatConvFactorEntity, itemLogisticUnit.avpList, lib.getAvpListMap(itemLogisticUnit.avpList) )[0])) if (itemLogisticUnit.avpList != null and itemUomCatConvFactorEntity != null),
  			ACTIONCODE: itemLogisticUnitInformation.actionCode,
  			(MS_BULK_REF: vars.storeHeaderReference.bulkReference),
			(MS_REF: vars.storeMsgReference.messageReference),
			(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
			MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
	 		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
	 		SENDER: vars.bulkNotificationHeaders.sender,
		})
	})
}pluck($)))) filter sizeOf($) > 0 map ($.itemLogisticUnits orderBy ($.TRADEITEMQUANTITY)) map (logisticUnitInfo , index) -> {
	logistics_weight:({
			ITEM: logisticUnitInfo[0].ITEM,
			TARGETCATEGORY: findCategory(logisticUnitInfo[0].TRADEITEMQUANTITY),
			TARGETUOM: logisticUnitInfo[0].TRADEITEMQUANTITY,
			SOURCEUOM: logisticUnitInfo[0].SOURCEUOM_WEIGHT,
			SOURCECATEGORY: logisticUnitInfo[0].SOURCECATEGORY_WEIGHT,
			RATIO: logisticUnitInfo[0].RATIO_WEIGHT,
			ACTIONCODE: logisticUnitInfo[0].ACTIONCODE,
			(MS_BULK_REF: vars.storeHeaderReference.bulkReference),
			(MS_REF: vars.storeMsgReference.messageReference),
			(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
			MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
	 		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
	 		SENDER: vars.bulkNotificationHeaders.sender,
	 
		}),
		logistics_vol:({
			ITEM: logisticUnitInfo[0].ITEM,
			TARGETCATEGORY: findCategory(logisticUnitInfo[0].TRADEITEMQUANTITY),
			TARGETUOM: logisticUnitInfo[0].TRADEITEMQUANTITY,
			SOURCEUOM: logisticUnitInfo[0].SOURCEUOM_VOL,
			SOURCECATEGORY: logisticUnitInfo[0].SOURCECATEGORY_VOL,
			RATIO: logisticUnitInfo[0].RATIO_VOL,
			ACTIONCODE: logisticUnitInfo[0].ACTIONCODE,
			(MS_BULK_REF: vars.storeHeaderReference.bulkReference),
			(MS_REF: vars.storeMsgReference.messageReference),
			(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
			MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
	 		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
	 		SENDER: vars.bulkNotificationHeaders.sender,
		}),
		logistics_depth:({
			ITEM: logisticUnitInfo[0].ITEM,
			TARGETCATEGORY: findCategory(logisticUnitInfo[0].TRADEITEMQUANTITY),
			TARGETUOM: logisticUnitInfo[0].TRADEITEMQUANTITY,
			SOURCEUOM: logisticUnitInfo[0].SOURCEUOM_DEPTH,
			SOURCECATEGORY: logisticUnitInfo[0].SOURCECATEGORY_DEPTH,
			RATIO: logisticUnitInfo[0].RATIO_DEPTH,
			ACTIONCODE: logisticUnitInfo[0].ACTIONCODE,
			(MS_BULK_REF: vars.storeHeaderReference.bulkReference),
			(MS_REF: vars.storeMsgReference.messageReference),
			(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
			MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
	 		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
	 		SENDER: vars.bulkNotificationHeaders.sender,
		})
	}pluck($))),flatten(flatten((payload.item map (item, itemIndex) -> {
	conversions: (item.measurementTypeConversion map(measurementTypeConversion , index) -> {
		(ITEM: item.itemId.primaryId) if (item.itemId.primaryId != null),
		(RATIO: measurementTypeConversion.ratioOfTargetPerSource) if (measurementTypeConversion.ratioOfTargetPerSource != null and measurementTypeConversion.ratioOfTargetPerSource != ""),
		
		(SOURCEUOM: if ( vars.uomShortLabels[measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode][0] == null) fail('mapping for ' ++ measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode ++ ' UOM is not present in the database.') 
			else vars.uomShortLabels[measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode][0]
		) if (measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode != null and measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode != ""),
		
		(SOURCECATEGORY: if (vars.uomShortLabels[measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode][0] == null) fail('mapping for ' ++ measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode ++ ' UOM is not present in the database.') 
			else findCategory(vars.uomShortLabels[measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode][0])
		) if (measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode != null and measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode != ""),
		
		(TARGETUOM:  if (vars.uomShortLabels[measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode][0] == null) fail('mapping for ' ++ measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode ++ ' UOM is not present in the database.') 
			else vars.uomShortLabels[measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode][0]
		) if (measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode != null and measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode != ""),
		
		(TARGETCATEGORY:  if (vars.uomShortLabels[measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode][0] == null) fail('mapping for ' ++ measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode ++ ' UOM is not present in the database.')
			else findCategory(vars.uomShortLabels[measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode][0])
		) if (measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode != null and measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode != ""),
		ACTIONCODE: item.documentActionCode,
		(MS_BULK_REF: vars.storeHeaderReference.bulkReference),
		(MS_REF: vars.storeMsgReference.messageReference),
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
	 	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
	 	SENDER: vars.bulkNotificationHeaders.sender,
	})
} pluck($))))])

else
	
flatten(flatten((payload.item map (item, itemIndex) -> {
	conversions: (item.measurementTypeConversion map(measurementTypeConversion , index) -> {
		(ITEM: item.itemId.primaryId) if (item.itemId.primaryId != null),
		(RATIO: measurementTypeConversion.ratioOfTargetPerSource) if (measurementTypeConversion.ratioOfTargetPerSource != null and measurementTypeConversion.ratioOfTargetPerSource != ""),
		
		(SOURCEUOM: if ( vars.uomShortLabels[measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode][0] == null) fail('mapping for ' ++ measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode ++ ' UOM is not present in the database.') 
			else vars.uomShortLabels[measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode][0]
		) if (measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode != null and measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode != ""),
		
		(SOURCECATEGORY: if (vars.uomShortLabels[measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode][0] == null) fail('mapping for ' ++ measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode ++ ' UOM is not present in the database.') 
			else findCategory(vars.uomShortLabels[measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode][0])
		) if (measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode != null and measurementTypeConversion.sourceMeasurementUnitCode.measurementUnitCode != ""),
		
		(TARGETUOM:  if (vars.uomShortLabels[measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode][0] == null) fail('mapping for ' ++ measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode ++ ' UOM is not present in the database.') 
			else vars.uomShortLabels[measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode][0]
		) if (measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode != null and measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode != ""),
		
		(TARGETCATEGORY:  if (vars.uomShortLabels[measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode][0] == null) fail('mapping for ' ++ measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode ++ ' UOM is not present in the database.')
			else findCategory(vars.uomShortLabels[measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode][0])
		) if (measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode != null and measurementTypeConversion.targetMeasurementUnitCode.measurementUnitCode != ""),
		ACTIONCODE: item.documentActionCode,
		(MS_BULK_REF: vars.storeHeaderReference.bulkReference),
		(MS_REF: vars.storeMsgReference.messageReference),
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		(avplistUDCS:(lib.getUdcNameAndValue(itemUomCatConvFactorEntity, measurementTypeConversion.avpList, lib.getAvpListMap(measurementTypeConversion.avpList) )[0])) if (measurementTypeConversion.avpList != null and (item.documentActionCode == "ADD" or item.documentActionCode == "CHANGE_BY_REFRESH") and itemUomCatConvFactorEntity != null),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
	 	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
	 	SENDER: vars.bulkNotificationHeaders.sender,
	 	
	 	
	})
} pluck($)))))  map (uomCategoryConvFactor, indexOfUomCategoryConvFactor) -> {
			ITEM: uomCategoryConvFactor.ITEM,
			RATIO: uomCategoryConvFactor.RATIO,
			SOURCECATEGORY: uomCategoryConvFactor.SOURCECATEGORY,
			SOURCEUOM: uomCategoryConvFactor.SOURCEUOM,
			TARGETCATEGORY: uomCategoryConvFactor.TARGETCATEGORY,
			TARGETUOM: uomCategoryConvFactor.TARGETUOM,
			avplistUDCS: uomCategoryConvFactor.avplistUDCS,
			ACTIONCODE: uomCategoryConvFactor.ACTIONCODE,
			(MS_BULK_REF: vars.storeHeaderReference.bulkReference),
			(MS_REF: vars.storeMsgReference.messageReference),
			(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((indexOfUomCategoryConvFactor))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
			MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
	 		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
	 		SENDER: vars.bulkNotificationHeaders.sender,
			}