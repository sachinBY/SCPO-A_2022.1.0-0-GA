%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var skuSSEntity = vars.entityMap.sku[0].skuss[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload map {
	udcs:((skuSSEntity map (value, index) -> {
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
	ITEM: $."itemLocationId.item.primaryId",
	LOC: $."itemLocationId.location.primaryId",
	EFF: if ($."effectiveInventoryParameters.effectiveFromDateTime" != null) $."effectiveInventoryParameters.effectiveFromDateTime" as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
	QTY: $."effectiveInventoryParameters.minimumSafetyStockQuantity.value",
	DMDGROUP: $."effectiveInventoryParameters.demandChannel",
	ACTIONCODE: if ($.documentActionCode != null and !isEmpty($.documentActionCode)) $.documentActionCode else vars.bulknotificationHeaders.documentActionCode
})