%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var suppOrderEntity = vars.entityMap.suppordersku[0].suppordersku[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload.supplementalOrder map { 
		  MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		  MS_REF: vars.storeMsgReference.messageReference,
		  (INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		  MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		  MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		  SENDER: vars.bulkNotificationHeaders.sender,
		  ITEM: $.supplementalOrderId.itemLocationId.item.primaryId as String,
		  LOC: $.supplementalOrderId.itemLocationId.location.primaryId as String,
		  SUPPORDERID: $.supplementalOrderId.additionalOrderId,
		  NEEDARRIVDATE: $.supplementalOrderId.requestedDeliveryDate as DateTime,
		  NEEDQTY: $.requestedQuantity.value,
		  HOLDOUTRELEASESTART: $.inventoryHoldReleaseDate as DateTime,
		  GROUPTYPE: if($.groupOrderType == "INCLUDE") 1 else if($.groupOrderType == "SEPARATE") 2 else if($.groupOrderType == "SEPARATE_BY_ORDER_ID") 3 else "",
		  TYPE: if($.supplementalOrderType == "REGULAR") 1 else if ($.supplementalOrderType == "FORCED") 2 else if ($.supplementalOrderType == "FORCED_ROUNDED") 3 else "",
		  STATUS: 1,
		  PRIORITY: 1,
		  EXTRALOADDUR: 0,
		  (SuppOrderUDC: (lib.getUdcNameAndValue(suppOrderEntity, $.avpList, lib.getAvpListMap($.avpList))[0])) 
		  if ($.avpList != null 
		  	and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		  	and suppOrderEntity != null
		  ),
		  ACTIONCODE: $.documentActionCode
})