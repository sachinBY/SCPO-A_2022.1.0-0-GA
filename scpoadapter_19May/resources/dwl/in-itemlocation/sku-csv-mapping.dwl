%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var skuEntity = vars.entityMap.sku[0].sku[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload map {
	udcs:((skuEntity map (value, index) -> {
			scpoColumnName: value.scpoColumnName,
			scpoColumnValue: if (lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0) != null and trim(lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) != '') (lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) else default_value,
			(dataType: value.dataType) if ((lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) != null),
		}) filter sizeOf($) > 0),
	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference,		
	(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	SENDER: vars.bulkNotificationHeaders.sender,
	CREATIONDATE: $.creationDateTime as DateTime as String,
	ENABLEOPT: $.businessInstanceId,
	INFINITESUPPLYSW: if($.hasInfiniteSupply == "true") 1 else 0 ,
	REPLENMETHOD: if($.replenishmentMethod == "REPLENISHMENT_ONLY") 1 else if($.replenishmentMethod == "ALLOCATION_ONLY") 2 else if($.replenishmentMethod == "REPLENISHMENT_AND_ALLOCATION") 3 else default_value,
	REPLENTYPE: if($.replenishmentType == "TRANSFERRED") 1 else if($.replenishmentType == "ASSEMBLED") 2 else if($.replenishmentType == "INTERFACE") 4 else if($.replenishmentType == "MPS") 5 else default_value,
	ITEM: $."itemLocationId.item.primaryId",
	LOC: $."itemLocationId.location.primaryId",
	OH: $.onHandInventoryQuantity,
	(OHPOST: $.onHandInventoryPostingDate as DateTime as String) if not $.onHandInventoryPostingDate == null,
	ACTIONCODE: if ($.documentActionCode != null and !isEmpty($.documentActionCode)) $.documentActionCode else (vars.bulknotificationHeaders.documentActionCode)
})