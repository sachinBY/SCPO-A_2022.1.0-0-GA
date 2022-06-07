%dw 2.0
output application/json encoding = "UTF-8",deferred=true
var dateUtil = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.orderlink[0].orderlink[0]
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.orderlink.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: "BYDM 2021.2.0",
		messageId: uuid(),
		"type": p("scpo.outbound.orderlink.messagetype"),
		creationDateAndTime: now()
	},
	supplyDemandLink: (payload map() -> {
		creationDateTime: now(),
		documentStatusCode: "ORIGINAL",
		documentActionCode: "CHANGE_BY_REFRESH",
		lastUpdateDateTime: now(),
		(avpList: (filter(udcs, (element, index) -> $[upper(element.scpoColumnName)] != null) map (udc , value) -> {
			name: udc.hostColumnName,
			value: $[upper(udc.scpoColumnName)]
		})) if (!isEmpty(udcs)),
		supplyDemandLinkId: {
			itemId: $.ITEM,
			locationId: $.LOC,
			demandTypeCode: $.DMDTYPE,
			demandOrderSequence: $.DMDSEQNUM,
			orderId: $.ORDERID,
			shipDate: dateUtil.formatSCPOToGS1($.SHIPDATE),
			supplyTypeCode: $.SUPPLYTYPE,
			supplyOrderSequence: $.SUPPLYSEQNUM,
			parentLocationId: $.PARENTLOC,
			parentItemId: $.PARENTITEM
		},
		linkProcessAction: $.ACTION,
		demandChannel: $.DMDGROUP,
		customer: $.CUST,
		needByDate: dateUtil.formatSCPOToGS1($.DMDNEEDDATE),
		demandScheduleDate: dateUtil.formatSCPOToGS1($.DMDSCHEDDATE),
		supplyAvailableDate: dateUtil.formatSCPOToGS1($.SUPPLYAVAILDATE),
		peggingQuantity: $.PEGQTY,
		supplySplitSequence: $.SUPPLYSEQNUM,
		(parentSupplyTypeCode: $.PARENTSUPPLYTYPE) if ($.PARENTSUPPLYTYPE != 0),
		parentSupplySequence: $.PARENTSUPPLYSEQNUM
	})
}
