%dw 2.0
output application/java 
var default_value = "###JDA_DEFAULT_VALUE###"
var itemlocdmdgroupmap = vars.entityMap.itemlocdmdgroupmap[0].itemlocdmdgroupmap[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload.itemLocationDemandGroupMap map {
  MS_BULK_REF: vars.storeHeaderReference.bulkReference,
  MS_REF: vars.storeMsgReference.messageReference,
  (INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
  MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  SENDER: vars.bulkNotificationHeaders.sender,
  DMDGROUP: $.itemLocationDemandGroupMapId.demandChannel,
  EFF: if ($.effectiveFromDate != null) $.effectiveFromDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else "1970-01-01" as Date {format: "yyyy-MM-dd", class : "java.sql.Date"},
  ITEM : $.itemLocationDemandGroupMapId.item.primaryId,
  LOC : $.itemLocationDemandGroupMapId.location.primaryId,
  OPPLANPARAM: if ($.orderPromiserPlanningParameters != null) $.orderPromiserPlanningParameters else default_value,
  ROOTSW: if ($.isProductRootedAtSeller != null and  $.isProductRootedAtSeller == true) 1 else 0,
  (ItemLocDemandGroupMapUDC: (lib.getUdcNameAndValue(itemlocdmdgroupmap, $.avpList, lib.getAvpListMap($.avpList) )[0])) if ($.avpList != null and itemlocdmdgroupmap != null
	),
  ACTIONCODE: $.documentActionCode default "CHANGE_BY_REFRESH"
})