%dw 2.0
output application/csv deferred=true
var udcs = vars.outboundUDCs.recship[0].recship[0]
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload map {
	"plannedSupply.creationDateTime": now() >> "UTC",
	"plannedSupply.documentStatusCode": "ORIGINAL",
	"plannedSupply.documentActionCode": "CHANGE_BY_REFRESH",
	
	"plannedSupply.plannedSupplyId.item.primaryId": $.ITEM,
	"plannedSupply.plannedSupplyId.item.additionalTradeItemId.typeCode": "GTIN-14",
	"plannedSupply.plannedSupplyId.item.additionalTradeItemId.value": "00000000000000",
	
	"plannedSupply.plannedSupplyId.shipTo.primaryId": $.DEST,
	"plannedSupply.plannedSupplyId.shipTo.additionalPartyId.typeCode": "GLN",
	"plannedSupply.plannedSupplyId.shipTo.additionalPartyId.value": "0000000000000",
	
	"plannedSupply.plannedSupplyId.shipFrom.primaryId": $.SOURCE,
	"plannedSupply.plannedSupplyId.shipFrom.additionalPartyId.typeCode": "GLN",
	"plannedSupply.plannedSupplyId.shipFrom.additionalPartyId.value": "0000000000000",
	
	"plannedSupply.type": "RECSHIP",
	
	"plannedSupply.plannedSupplyDetail.scheduledOnHandDate": funCaller.formatSCPOToGS1($.SCHEDARRIVDATE),
	"plannedSupply.plannedSupplyDetail.requestedDeliveryDate": funCaller.formatSCPOToGS1($.NEEDARRIVDATE),
	"plannedSupply.plannedSupplyDetail.requestedShipDate": funCaller.formatSCPOToGS1($.NEEDSHIPDATE),
	"plannedSupply.plannedSupplyDetail.availableForSaleDate": funCaller.formatSCPOToGS1($.EARLIESTSELLDATE),
	"plannedSupply.plannedSupplyDetail.supplyExpirationDate": funCaller.formatSCPOToGS1($.EXPDATE),
	"plannedSupply.plannedSupplyDetail.requestedQuantity.value": $.QTY,
	"plannedSupply.plannedSupplyDetail.movementInformation.sourcingMethod": $.SOURCING,
	"plannedSupply.plannedSupplyDetail.movementInformation.transportEquipment.transportEquipmentTypeCode": $.TRANSMODE,
	"plannedSupply.plannedSupplyDetail.movementInformation.availableForShipDate": funCaller.formatSCPOToGS1($.AVAILTOSHIPDATE),
	"plannedSupply.plannedSupplyDetail.movementInformation.scheduledShipDate": funCaller.formatSCPOToGS1($.SCHEDSHIPDATE),
	"plannedSupply.plannedSupplyDetail.movementInformation.despatchDate": funCaller.formatSCPOToGS1($.DEPARTUREDATE),
	"plannedSupply.plannedSupplyDetail.movementInformation.reviewDespatchDate": funCaller.formatSCPOToGS1($.ORDERPLACEDATE),
	"plannedSupply.plannedSupplyDetail.movementInformation.deliveryDate": funCaller.formatSCPOToGS1($.DELIVERYDATE),
    "plannedSupply.plannedSupplyDetail.movementInformation.promotionalOrderAllocationQuantity.value": $.SUPPORDERQTY,
    (udcs map (udc , index) -> {
		((udc.hostColumnName): lib.eval($[udc.scpoColumnName] , upper(udc.dataType)))
	}),
})
