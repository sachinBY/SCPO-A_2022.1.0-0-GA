%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
 var dmdUnitEntity = vars.entityMap.item[0].dmdunit[0]
 var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
 var lowestHierarchy= vars.codemap.hierarchyLevels
 var lowesetLevel= 0
 
fun dmdunit (item, demandUnitInformation, index) = {
	
        BRAND: if (demandUnitInformation.demandUnitDetails.brandName != null) demandUnitInformation.demandUnitDetails.brandName else default_value,
        COLLECTION: if (demandUnitInformation.demandUnitDetails.collectionId != null) demandUnitInformation.demandUnitDetails.collectionId else default_value,
        IGNOREPRICINGLVLSW: if (demandUnitInformation.demandUnitDetails.ignorePricingLevel != null) 
        						if(demandUnitInformation.demandUnitDetails.ignorePricingLevel == true) 
                                	1 as Number 
                                else 
                                	0 as Number
                            else default_value,
        ONORDERQTY: if (demandUnitInformation.demandUnitDetails.onOrderQuantity.value != null) demandUnitInformation.demandUnitDetails.onOrderQuantity.value as Number else default_value,
        PRICELINK: if (demandUnitInformation.demandUnitDetails.priceLinkId != null) demandUnitInformation.demandUnitDetails.priceLinkId else default_value,
        //PERISHABLESW: if (demandUnitInformation.demandUnitDetails.handlingInstruction.handlingInstructionCode == 'PER') 1 else 0,
        //HIERARCHYLEVEL:
        WDDCATEGORY: if (demandUnitInformation.demandUnitDetails.weatherCategory != null)demandUnitInformation.demandUnitDetails.weatherCategory else default_value,
        PACKSIZE: if (demandUnitInformation.demandUnitDetails.unitsPerPack != null)demandUnitInformation.demandUnitDetails.unitsPerPack as Number else default_value,
        UNITSIZE: if (demandUnitInformation.demandUnitDetails.unitSize != null)demandUnitInformation.demandUnitDetails.unitSize as Number else default_value,
        UOM: if (demandUnitInformation.demandUnitDetails.demandUnitBaseUnitOfMeasure != null) 
		(vars.uomShortLabels[demandUnitInformation.demandUnitDetails.demandUnitBaseUnitOfMeasure][0] as Number) 
        		else (vars.uomShortLabels[item.tradeItemBaseUnitOfMeasure][0] as Number),
         avplistUDCS:(flatten([(lib.getUdcNameAndValue(dmdUnitEntity, item.avpList, lib.getAvpListMap(item.avpList) )[0]) 
	if (item.avpList != null 
		and (item.documentActionCode == "ADD" or item.documentActionCode == "CHANGE_BY_REFRESH")
		and dmdUnitEntity != null
	),
	(lib.getUdcNameAndValue(dmdUnitEntity, demandUnitInformation.demandUnitDetails.avpList, lib.getAvpListMap(demandUnitInformation.demandUnitDetails.avpList) )[0]) 
	if (demandUnitInformation.demandUnitDetails.avpList != null 
		and (item.documentActionCode == "ADD" or item.documentActionCode == "CHANGE_BY_REFRESH")
		and dmdUnitEntity != null
	),
	(item.itemHierarchyInformation.*ancestry map {
    	UDCName: $.hierarchyLevelIdentifier,
    	UDCValue: $.memberIdentifier
  	}) 
	if (item.itemHierarchyInformation != null 
		and (item.documentActionCode == "ADD" or item.documentActionCode == "CHANGE_BY_REFRESH") and (p('bydm.dmdunit.process.ancestry') as Boolean default false) == true)])),
        ACTIONCODE: item.documentActionCode,
        (MS_BULK_REF: vars.storeHeaderReference.bulkReference),
        (MS_REF: vars.storeMsgReference.messageReference),
        (INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
        MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
		SENDER: vars.bulkNotificationHeaders.sender
}
---
flatten(flatten((payload.item map (item, itemIndex) -> {
    conversions: flatten(item.demandUnitInformation map(demandUnitInformation , index) -> {
    	val:(item.description map{
        (DMDUNIT: if (demandUnitInformation.demandUnitName != null) demandUnitInformation.demandUnitName else item.itemId.primaryId),
        DESCR: if(demandUnitInformation.demandUnitDetails.description.value != null) demandUnitInformation.demandUnitDetails.description.value else $.value,
        HIERARCHYLEVEL: lowestHierarchy[lowesetLevel][0],
        (dmdunit (item, demandUnitInformation,index)),
        })   
    }.val),
    (item.demandUnitInformation map(demandUnitInformation , index) -> {
       (conversions: ((item.itemHierarchyInformation.ancestry map (ancestry, index) -> {
        (DMDUNIT: ancestry.memberId) if ancestry.memberId != null,
        DESCR: if(ancestry.memberName != null) ancestry.memberName else default_value,
        HIERARCHYLEVEL: if(ancestry.hierarchyLevelId != null) ancestry.hierarchyLevelId else default_value,
        (dmdunit (item, demandUnitInformation,index)),
        }))) if item.itemHierarchyInformation.ancestry != null
    }) 
} pluck($))))
