%dw 2.0
import * from dw::core::Strings
output application/json encoding = "UTF-8",deferred=true
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.inventory[0].inventory[0]
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.inventory.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: "BYDM 2021.5.0",
		messageId: uuid(),
		"type": p("scpo.outbound.inventory.messagetype"),
		creationDateAndTime: now()
	},
	inventoryOnHand2: (payload map {
		(avpList: (filter(udcs, (element, index) -> $[upper(element.scpoColumnName)] != null) map (udc , value) -> {
			name: udc.hostColumnName,
			value: $[upper(udc.scpoColumnName)]
		})) if (!isEmpty(udcs)),
		itemId: $.ITEM,
		locationId: $.LOC,
		quantity : {
			value: $.QTY
		},
		bestBeforeDate: $.EXPDATE as Date default "",
		availableForSaleDate: $.EARLIESTSELLDATE as Date default "",
		project: $.PROJECT,
		availableForSupplyDate: $.AVAILDATE as Date default "",
		storageLocation : $.STORE
	})
}