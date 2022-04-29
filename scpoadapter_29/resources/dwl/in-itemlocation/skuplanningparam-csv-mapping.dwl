%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var skuPlanningParamEntity = vars.entityMap.sku[0].skuplanningparam[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload map {
	udcs:((skuPlanningParamEntity map (value, index) -> {
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
	BUFFERLEADTIME: $."planningParameters.supplyLeadBufferDuration.value",
	DRPFRZDUR: $."planningParameters.receiptFrozenDuration.value",
	HOLDINGCOST: $."planningParameters.holdingCost",
	INCDRPQTY: $."planningParameters.incrementalDRPQuantity.value",
	INCMPSQTY: $."planningParameters.incrementalMPSQuantity.value",
	INHANDLINGCOST: $."planningParameters.receivingHandlingCost",
	MAXOH: $."planningParameters.maximumOnHandQuantity.value",
	MFGFRZDUR: $."planningParameters.manufactureDuration.value",
	MFGLEADTIME: $."planningParameters.manufactureLeadTimeDuration",
	MINDRPQTY: $."planningParameters.minimumDRPQuantity.value",
	MINMPSQTY: $."planningParameters.minimumMPSQuantity.value",
	OUTHANDLINGCOST: $."planningParameters.shippingHandlingCost.value",
	SHRINKAGEFACTOR: if($."planningParameters.shrinkageFactor" != null) 
		  					ceil($."planningParameters.shrinkageFactor") else null,
	MPSCOVDUR: $."planningParameters.supplyCoverageDuration.value",
	ORDERINGCOST: $."planningParameters.orderingCost.value",
	DRPCOVDUR: $."planningParameters.receiptCoverageDuration.value",
	ACTIONCODE: if ($.documentActionCode != null and !isEmpty($.documentActionCode)) $.documentActionCode else vars.bulknotificationHeaders.documentActionCode
})