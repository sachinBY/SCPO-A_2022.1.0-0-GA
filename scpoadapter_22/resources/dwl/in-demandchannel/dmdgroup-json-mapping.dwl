%dw 2.0
output application/java  

var dmdgroupEntity = vars.entityMap.dmdgroup[0].dmdgroup[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload.demandChannel map {
  (MS_BULK_REF: vars.storeHeaderReference.bulkReference),
  (MS_REF: vars.storeMsgReference.messageReference),
  (INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
  MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  SENDER: vars.bulkNotificationHeaders.sender,
  (DMDGROUP: $.demandChannelId) if not $.demandChannelId == null,
  (DESCR: $.description.value) if not $.description.value == null,
 
  (DemandChannelUDC: (lib.getUdcNameAndValue(dmdgroupEntity, $.avpList, lib.getAvpListMap($.avpList) )[0])) if ($.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and dmdgroupEntity != null
	),
  
  ACTIONCODE: $.documentActionCode
})