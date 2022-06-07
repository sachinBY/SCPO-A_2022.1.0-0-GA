%dw 2.0
output application/csv deferred=true
var udcs = vars.outboundUDCs.inventory[0].inventory[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
payload map ((item, index) ->{
	"itemId": item.ITEM,
	"locationId": item.LOC,
	"quantity.value": item.QTY,
	"bestBeforeDate": item.EXPDATE as Date default "",
	"availableForSaleDate": item.EARLIESTSELLDATE as Date default "",
	"project": item.PROJECT,
	"availableForSupplyDate": item.AVAILDATE as Date default "",
	"storageLocation": item.STORE,
	(udcs map (udc , index) -> {
		((udc.hostColumnName): lib.eval(item[udc.scpoColumnName] , upper(udc.dataType)))
	})
})