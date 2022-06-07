%dw 2.0
output application/java

var allocSupplyPrepackEntity = vars.entityMap.prepacksupply[0].allocsupplyprepack[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var default_value = "###JDA_DEFAULT_VALUE###"
import * from dw::Runtime
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
---
(payload.prepackSupply map (prepack , index) -> {
	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference,
	(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((index))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	SENDER: vars.bulkNotificationHeaders.sender,
	AVAILDATE: if (prepack.scheduledOnHandDate != null and funCaller.formatGS1ToSCPO(prepack.scheduledOnHandDate) != default_value) prepack.scheduledOnHandDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
	LOC: if (prepack.location != null) prepack.location else default_value,
	NUMPACKS: if (prepack.quantity != null) prepack.quantity as Number else default_value,
	SUPPLYID: if (prepack.prepackSupplyId == null) fail("prepack.prepackSupplyIdentification.entityIdentification is mandatory field in SCPO") else prepack.prepackSupplyId ,
	SUPPLYTYPE: if (prepack."type" != null and prepack."type" == 'SCHEDULED_RECEIPT') 6 else if (prepack."type" != null and prepack."type" == 'ON_HAND') 16 
				else if (prepack."type" != null and prepack."type" == 'INVENTORY') 15 else if (prepack."type" != null and prepack."type" == 'IN_TRANSIT') 5 else default_value,
	
	(AllocSupplyUDC: (lib.getUdcNameAndValue(allocSupplyPrepackEntity, prepack.avpList, lib.getAvpListMap(prepack.avpList))[0])) 
		  if (prepack.avpList != null and (prepack.documentActionCode == "ADD" or prepack.documentActionCode == "CHANGE_BY_REFRESH") and allocSupplyPrepackEntity != null),
	ACTIONCODE: prepack.documentActionCode
})