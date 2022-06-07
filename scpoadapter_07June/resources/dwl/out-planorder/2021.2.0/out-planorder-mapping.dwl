%dw 2.0
output application/json encoding = "UTF-8",deferred=true
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.planorder[0].planorder[0]
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.planorder.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: "BYDM 2021.2.0",
		messageId: uuid(),
		"type": p("scpo.outbound.planorder.messagetype"),
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
				"primaryId": $.LOC,
				"additionalPartyId": [{
					"typeCode": "GLN",
					"value": "0000000000000"
				}]
			}
		},
		"type": "PLAN_ORDER",
		plannedSupplyDetail: [{
			scheduledOnHandDate: funCaller.formatSCPOToGS1($.SCHEDDATE),
			requestedDeliveryDate: funCaller.formatSCPOToGS1($.NEEDDATE),
			availableForSaleDate: funCaller.formatSCPOToGS1($.EARLIESTSELLDATE),
			supplyExpirationDate: funCaller.formatSCPOToGS1($.EXPDATE),
			isFirmPlannedSupply: if ($.FIRMPLANSW == 1) true else false,
			project: $.PROJECT,
			"requestedQuantity": {
				"value": $.QTY
			},
			allowedSupersedeQuantity: {
				value: $.SUBSTQTY
			},
			productionInformation: {
				productionRoutingId: $.PRODUCTIONMETHOD,
				productionStartDate: funCaller.formatSCPOToGS1($.STARTDATE),
				dependentDemandOrder: {
					"type": $.COPRODORDERTYPE,
					item: {
						primaryId: $.COPRODPRIMARYITEM,
						"additionalTradeItemId": [{
							"typeCode": "GTIN-14",
							"value": "00000000000000"
						}]
					}
				}
			}
		}]
	})
}
