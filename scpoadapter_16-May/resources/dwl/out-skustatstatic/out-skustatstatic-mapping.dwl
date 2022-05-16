%dw 2.0
output application/json encoding = "UTF-8",deferred=true
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.skustatstatic[0].skustatstatic[0]
---
{
	header: {
			sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.skustatstatic.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: "BYDM 2021.4.0",
		messageId: uuid(),
		"type": p("scpo.outbound.skustatstatic.messagetype"),
		creationDateAndTime: now()
	},
	itemLocationStatistics: (payload map{
		creationDateTime: now(),
		documentStatusCode: "ORIGINAL",
		documentActionCode: "CHANGE_BY_REFRESH",
		(avpList: (filter(udcs, (element, index) -> $[upper(element.scpoColumnName)] != null) map (udc , value) -> {
			name: udc.hostColumnName,
			value: $[upper(udc.scpoColumnName)]
		})) if (!isEmpty(udcs)),
		itemLocationStatisticsId: {
			itemId: $.ITEM,
			locationId: $.LOC
		},
		optionSet: $.OPTIONSET,
		processDateTime: $.PROCESSDATE,
		startDateTime: $.STARTDATE,
		duration: {
			value: $.DUR
		},
		backOrders: $.BACKORDERS,
		overstockDateTime: $.OVERSTOCKDATE,
		
		constrainedOverstockDateTime: $.CONSTROVERSTOCKDATE,
		alternateConstrainedOverstockDateTime: $.ALTCONSTROVERSTOCKDATE,
		
		overstockQuantity: $.OVERSTOCKQTY,
		constrainedOverstockQuantity: $.CONSTROVERSTOCKQTY,
		
		alternateConstrainedOverstockQuantity: $.ALTCONSTROVERSTOCKQTY,
		
		overstockDuration: {
			value: $.OVERSTOCKDUR
		},
		constrainedOverstockDuration: {
			value: $.CONSTROVERSTOCKDUR
		},
		alternateConstrainedOverstockDuration: {
			value: $.ALTCONSTROVERSTOCKDUR
		},
		overstockInventoryStartDateTime: $.OVERSTOCKINVSTARTDATE,
		constrainedOverstockInventoryStartDateTime: $.CONSTROVERSTOCKINVSTARTDATE,
		alternateConstrainedOverstockInventoryStartDateTime: $.ALTCONSTROVERSTOCKINVSTARTDATE,
		overstockExcessCoverageDuration: {
			value: $.OVERSTOCKEXCESSCOVDUR
		},
		constrainedOverstockExcessCoverageDuration: {
			value: $.CONSTROVERSTOCKEXCESSCOVDUR
		},
		alternateConstrainedOverstockExcessCoverageDuration: {
			value: $.ALTCONSTROVERSTOCKEXCESSCOVDUR
		},
		maximumProjectedOnHand: $.MAXPROJOH,
		maximumConstrainedProjectedOnHand: $.MAXCONSTRPROJOH,
		maximumProjectedOnHandDateTime: $.MAXPROJOHDATE,
		
		maximumConstrainedProjectedOnHandDateTime: $.MAXCNSTRPROJOHDATE,
		minimumCoverageDuration: {
			value: $.MINCOVDUR
		},
		maximumCoverageDuration: {
			value: $.MAXCOVDUR
		},
		
		currentCoverageDuration: {
			value: $.CURCOVDUR
		},
		currentConstrainedCoverageDuration: {
			value: $.CURCONSTRCOVDUR
		},
		
		minimumCoverageDateTime: $.MINCOVDATE,
		maximumCoverageDateTime: $.MAXCOVDATE,
		
		minimumConstrainedCoverageDateTime: $.MINCONSTRCOVDATE,
		maximumConstrainedCoverageDateTime: $.MAXCONSTRCOVDATE,
		minimumConstrainedCoverageDuration: {
			value: $.MINCONSTRCOVDUR
		},
		maximumConstrainedCoverageDuration: {
			value: $.MAXCONSTRCOVDUR
		},
		stockLowDateTime: $.STOCKLOWDATE,
		constrainedStockLowDateTime: $.CONSTRSTOCKLOWDATE,
		
		alternateConstrainedStockLowDateTime: $.ALTCONSTRSTOCKLOWDATE,
		stockLowDuration: {
			value: $.STOCKLOWDUR
		},
		constrainedStockLowDuration: {
			value: $.CONSTRSTOCKLOWDUR
		},
		alternateConstrainedStockLowDuration: {
			value: $.ALTCONSTRSTOCKLOWDUR
		},
		stockLowQuantity: $.STOCKLOWQTY,
		constrainedStockLowQuantity: $.CONSTRSTOCKLOWQTY,
		
		alternateConstrainedStockLowQuantity: $.ALTCONSTRSTOCKLOWQTY,
		stockoutQuantity: $.STOCKOUTQTY,
		
		constrainedStockoutQuantity: $.CONSTRSTOCKOUTQTY,
		alternateConstrainedStockoutQuantity: $.ALTCONSTRSTOCKOUTQTY,
		
		stockoutDuration: {
			value: $.STOCKOUTDUR
		},
		constrainedStockoutDuration: {
			value: $.CONSTRSTOCKOUTDUR
		},
		alternateConstrainedStockoutDuration: {
			value: $.ALTCONSTRSTOCKOUTDUR
		},
		stockoutDateTime:$.STOCKOUTDATE,
		constrainedStockoutDateTime:$.CONSTRSTOCKOUTDATE,
		alternateConstrainedStockoutDateTime:$.ALTCONSTRSTOCKOUTDATE,
		unconstrainedNumberOfNewActions:$.UNCONNUMNEW,
		unconstrainedNumberOfPullActions:$.UNCONNUMPULL,
		unconstrainedNumberOfPushActions:$.UNCONNUMPUSH,
		
		unconstrainedNumberOfCancelActions:$.UNCONNUMCANCEL,
		unconstrainedRevenueNewActions:$.UNCONREVNEW,
		unconstrainedRevenuePullActions:$.UNCONREVPULL,
		unconstrainedRevenuePushActions:$.UNCONREVPUSH,
		unconstrainedRevenueCancelActions:$.UNCONREVCANCEL,
		firstPlanArrivalDateTime:$.FIRSTPLANARRIVDATE,
		
		
		firstPlanArrivalQuantity:$.FIRSTPLANARRIVQTY,
		unconstrainedNetAvailableQuantityAtLeadTime:$.UNCONNETAVLQTYATLT,
		unconstrainedNetAvailableNegativeDateTime:$.UNCONNETAVLNEGDATE,
		lateInTransitsIn:$.LATEINTRANSIN,
		userID:$.USERID
	})
}