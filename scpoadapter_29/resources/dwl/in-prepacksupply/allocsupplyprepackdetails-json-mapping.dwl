%dw 2.0
output application/java

var allocSupplyPrepackDetailsEntity = vars.entityMap.prepacksupply[0].allocsupplyprepackdetails[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var default_value = "###JDA_DEFAULT_VALUE###"
import * from dw::Runtime
---
(payload.prepackSupply map (prepack , index) -> {
	val:(prepack.prepackDetail map (prepackDetail, index) -> {
	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference,	
	(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	SENDER: vars.bulkNotificationHeaders.sender,
	ITEM: if(prepackDetail.primaryId == null) fail("prepack.prepackDetail.additionalTradeItemIdentification is mandatory field in SCPO") 
	else prepackDetail.primaryId,
	LOC: if (prepack.location == null) fail ("prepack.location is mandatory field in SCPO") else prepack.location,
	QTYPERPACK: if(prepackDetail.quantityOfNextLowerLevelTradeItem != null) prepackDetail.quantityOfNextLowerLevelTradeItem else default_value,
	SUPPLYID: if (prepack.prepackSupplyId == null) fail("prepack.prepackSupplyIdentification.entityIdentification is mandatory field in SCPO") else prepack.prepackSupplyId,
	
	AllocSupplyDetailsUDC: flatten([(lib.getUdcNameAndValue(allocSupplyPrepackDetailsEntity, prepack.avpList, lib.getAvpListMap(prepack.avpList))[0]) 
		  if (prepack.avpList != null and (prepack.documentActionCode == "ADD" or prepack.documentActionCode == "CHANGE_BY_REFRESH") and allocSupplyPrepackDetailsEntity != null),
		  (lib.getUdcNameAndValue(allocSupplyPrepackDetailsEntity, prepackDetail.avpList, lib.getAvpListMap(prepackDetail.avpList))[0]) 
		  if (prepackDetail.avpList != null and (prepack.documentActionCode == "ADD" or prepack.documentActionCode == "CHANGE_BY_REFRESH") and allocSupplyPrepackDetailsEntity != null)]),
		  
	ACTIONCODE: prepack.documentActionCode
})
}).val reduce ($ ++ $$)