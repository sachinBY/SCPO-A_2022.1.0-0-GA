%dw 2.0
output application/java  
import * from dw::Runtime
var default_value = "###JDA_DEFAULT_VALUE###"
var dmdUnitEntity = vars.entityMap.dmdunit[0].dmdunit[0]
var UOMIsoConversion = vars.codeMap.UOMIsoConversion
var UOMConversion = vars.codeMap.UOMConversion
var hierarchyLevelConvers = vars.codeMap.hierarchyLevelConversion
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var ancestryTables = p('bydm.dmdunit.ancestry.hierarchies') splitBy(',')
import * from dw::Runtime
fun ancestryMap(ancestry) = (ancestry map {
	($.hierarchyLevelId): ($.memberId),
})
fun ancestryUDCs(data , ancestryTables) = (
	ancestryTables map {
		UDCName: ('UDC_'++$++'_ID'),
		UDCValue: if (data[$] != null) data[$][0] else default_value
	}
)
---
(payload.demandUnit map {
  (MS_BULK_REF: vars.storeHeaderReference.bulkReference),
  (MS_REF: vars.storeMsgReference.messageReference),
  (INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
  MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  SENDER: vars.bulkNotificationHeaders.sender,
  (DESCR: $.demandUnitDetails.description.value) if not $.demandUnitDetails.description.value == null,
  (DMDUNIT: $.demandUnitId) if not $.demandUnitId == null,
  (HIERARCHYLEVEL: hierarchyLevelConvers[$.demandUnitHierarchyInformation.hierarchyLevelId][0]) if $.demandUnitHierarchyInformation.hierarchyLevelId != null,
  (WDDCATEGORY: $.demandUnitDetails.weatherCategory) if not $.demandUnitDetails.weatherCategory == null,
  (PACKSIZE: $.demandUnitDetails.unitsPerPack) if not $.demandUnitDetails.unitsPerPack == null,
  (UNITSIZE: $.demandUnitDetails.unitSize) if not $.demandUnitDetails.unitSize == null,
  UOM: if ($.demandUnitDetails.demandUnitBaseUnitOfMeasure == null) fail('demandUnitBaseUnitOfMeasure in the gs1 message is null') 
  else if (vars.uomShortLabels[$.demandUnitDetails.demandUnitBaseUnitOfMeasure][0] == null) default_value
  else vars.uomShortLabels[$.demandUnitDetails.demandUnitBaseUnitOfMeasure][0] as Number,
  (BRAND: $.demandUnitDetails.brandName) if $.demandUnitDetails.brandName != null,
  (COLLECTION: $.demandUnitDetails.collectionId) if $.demandUnitDetails.collectionId != null,
 IGNOREPRICINGLVLSW:if ($.demandUnitDetails.ignorePricingLevel == true) 1 else 0,
  (ONORDERQTY: $.demandUnitDetails.onOrderQuantity.value) if $.demandUnitDetails.onOrderQuantity.value != null,
  //PERISHABLESW: if ($.demandUnitDetails.handlingInstruction.handlingInstructionCode == "PER") true else false,
  (PRICELINK: $.demandUnitDetails.priceLinkId) if $.demandUnitDetails.priceLinkId != null,
  avplistUDCS:(flatten([(lib.getUdcNameAndValue(dmdUnitEntity, $.avpList, lib.getAvpListMap($.avpList) )[0]) 
	if ($.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and dmdUnitEntity != null
	),
	(lib.getUdcNameAndValue(dmdUnitEntity, $.demandUnitDetails.avpList, lib.getAvpListMap($.demandUnitDetails.avpList) )[0]) 
	if ($.demandUnitDetails.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and dmdUnitEntity != null
	),
	(ancestryUDCs(ancestryMap($.demandUnitHierarchyInformation.ancestry) , ancestryTables))
	if ($.demandUnitHierarchyInformation != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH") and (p('bydm.dmdunit.process.ancestry') as Boolean default false) == true)])),
  ACTIONCODE: $.documentActionCode
})
