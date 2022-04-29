%dw 2.0
output application/json deferred=true
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.recship[0].recship[0]
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.recship.receivers") , ",") map {
			(receiver: $) if ($ != null and $ != '')
		}).receiver,
		messageVersion: "BYDM 2021.2.0",
		messageId: uuid(),
		"type": p('scpo.outbound.recship.messagetype'),
		creationDateAndTime: now()
	},
	plannedSupply: (payload map {
		creationDateTime: now(),
		documentStatusCode: "ORIGINAL",
		documentActionCode: "CHANGE_BY_REFRESH",
		(avpList: (filter(udcs, (element, index) -> $[upper(element.scpoColumnName)] != null) map (udc , value) -> {
			name: udc.hostColumnName,
			value: $[upper(udc.scpoColumnName)]
		})) if (!isEmpty(udcs)),
		"plannedSupplyId": {
			"item": {
				"primaryId": $.ITEM,
				"additionalTradeItemId": [{
					"typeCode": "GTIN-14",
					"value": "00000000000000"
				}]
			},
			"shipTo": {
				"primaryId": $.DEST,
				"additionalPartyId": [{
					"typeCode": "GLN",
					"value": "0000000000000"
				}]
			},
			"shipFrom": {
				"primaryId": $.SOURCE,
				"additionalPartyId": [{
					"typeCode": "GLN",
					"value": "0000000000000"
				}]
			}
		},
		"type": "REC_SHIP",
		plannedSupplyDetail: [{
			scheduledOnHandDate: funCaller.formatSCPOToGS1($.SCHEDARRIVDATE),
			requestedDeliveryDate: funCaller.formatSCPOToGS1($.NEEDARRIVDATE),
			requestedShipDate: funCaller.formatSCPOToGS1($.NEEDSHIPDATE),
			availableForSaleDate: funCaller.formatSCPOToGS1($.EARLIESTSELLDATE),
			supplyExpirationDate: funCaller.formatSCPOToGS1($.EXPDATE),
			"requestedQuantity": {
				"value": $.QTY
			},
			"movementInformation": {
				"sourcingMethod": $.SOURCING,
				"transportEquipment": {
					"transportEquipmentTypeCode": {
						value: $.TRANSMODE}
				},
				"availableForShipDate": funCaller.formatSCPOToGS1($.AVAILTOSHIPDATE),
				"scheduledShipDate": funCaller.formatSCPOToGS1($.SCHEDSHIPDATE),
				"despatchDate": funCaller.formatSCPOToGS1($.DEPARTUREDATE),
				"reviewDespatchDate": funCaller.formatSCPOToGS1($.ORDERPLACEDATE),
				"deliveryDate": funCaller.formatSCPOToGS1($.DELIVERYDATE),
				promotionalOrderAllocationQuantity: {
					value: $.SUPPORDERQTY
				}
			}
		}]
	})
}
