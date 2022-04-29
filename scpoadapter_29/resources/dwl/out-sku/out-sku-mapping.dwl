%dw 2.0
output application/json encoding = "UTF-8",deferred=true
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.sku[0].sku[0]
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.sku.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: "BYDM 2021.10.0.1",
		messageId: uuid(),
		"type": p("scpo.outbound.sku.messagetype"),
		creationDateAndTime: now()

	},
	itemLocation: (payload map {
		creationDateTime: ($.CREATIONDATE),
		documentStatusCode: "ORIGINAL",
		documentActionCode: "CHANGE_BY_REFRESH",
		(avpList: (filter(udcs, (element, index) -> $[upper(element.scpoColumnName)] != null) map (udc , value) -> {
			name: udc.hostColumnName,
			value: $[upper(udc.scpoColumnName)]
		})) if (!isEmpty(udcs)),
		itemLocationId: {
			item: {
				primaryId: $.ITEM
			},
			location: {
				primaryId: $.LOC
			}
		},
		(businessInstanceId: $.ENABLEOPT) if($.ENABLEOPT != null),
		statusCode: "ACTIVE",
		(onHandInventoryQuantity: {
			value: $.OH
		}) if($.OH != null),
		(onHandInventoryPostingDate: ($.OHPOST) as DateTime) if($.OHPOST != null),
		(resource: [$.RES]) if($.RES != null),
		hasInfiniteSupply: if($.INFINITESUPPLYSW == 0) false else true,
		isStorable: if($.STORABLESW == 0) false else true,
		replenishmentMethod: if($.REPLENMETHOD == 1) 'REPLENISHMENT_ONLY' else if($.REPLENMETHOD == 2) 'ALLOCATION_ONLY' else if($.REPLENMETHOD == 3) 'REPLENISHMENT_AND_ALLOCATION' else null,
		replenishmentType: if($.REPLENTYPE == 1) 'TRANSFERRED' else if($.REPLENTYPE == 2) 'ASSEMBLED' else if($.REPLENTYPE == 4) 'INTERFACE' else if($.REPLENTYPE == 5) 'MPS' else null,
		(demandParameters: {
			(cumulativeDemandQuantity: {
				value: $.DMDTODATE
			}) if($.DMDTODATE != null),
			(unitCost: {
				currencyCode: "USD",
				value: $.INDDMDUNITCOST
			}) if($.INDDMDUNITCOST != null),
			(unitMargin: {
				currencyCode: "USD",
				value: $.INDDMDUNITMARGIN
			}) if($.INDDMDUNITMARGIN != null),
			(unitInventoryCarryingCost: {
				currencyCode: "USD",
				value: $.UNITCARCOST
			}) if($.UNITCARCOST != null),
			(unitPrice: {
				currencyCode: "USD",
				value: $.UNITPRICE
			}) if($.UNITPRICE != null),
			(pricingCalendar: $.PRICECAL) if($.PRICECAL != null)
		}) if($.DMDTODATE != null or $.INDDMDUNITCOST != null or $.INDDMDUNITMARGIN != null or $.UNITCARCOST != null or $.UNITPRICE != null or $.PRICECAL != null),
		(deploymentParameters: {
			(initialStockoutCost: {
				currencyCode: "USD",
				value: $.INITSTKOUTCOST
			}) if($.INITSTKOUTCOST != null),
			(surplusRestockCost: {
				currencyCode: "USD",
				value: $.SURPLUSRESTOCKCOST
			}) if($.SURPLUSRESTOCKCOST != null)
		}) if($.INITSTKOUTCOST != null or $.SURPLUSRESTOCKCOST != null),
		(effectiveInventoryParameters: [{
			(effectiveFromDateTime: ($.EFFINV_EFF) as DateTime)if($.EFFINV_EFF != null),
			(maximumCoverageDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.MAXCOVDUR
			}) if($.MAXCOVDUR != null),
			(maximumOnHandQuantity: {
				measurementUnitCode: "EA",
				value: $.MAXOHQTY
			}) if($.MAXOHQTY != null),
			(minimumSafetyStockQuantity: {
				measurementUnitCode: "EA",
				value: $.MINSSQTY
			}) if($.MINSSQTY != null),
			(safetyStockCoverageDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.SSCOVDUR
			}) if($.SSCOVDUR != null),
			(demandChannel: $.DMDGROUP) if($.DMDGROUP != null)
		}]) if($.EFFINV_EFF != null or $.MAXCOVDUR != null or $.MAXOHQTY != null or $.MINSSQTY != null or $.SSCOVDUR != null or $.DMDGROUP != null),
		(inventoryOptimizationParameters: {
			(averageRequisitionQuantity: {
				measurementUnitCode: "EA",
				value: $.AVGRQSNSIZE
			}) if($.AVGRQSNSIZE != null),
			(groupName: $.GROUPNAME) if($.GROUPNAME != null),
			(annualRequisitionNumber: $.NUMRQSN) if($.NUMRQSN != null),
			(reviewGroup: $.REVIEWGROUP) if($.REVIEWGROUP != null),
			(sensitivityProfile: $.SENSITIVITYPROFILE) if($.SENSITIVITYPROFILE != null),
			(inventoryOptimizationEffectiveParameters: [{
				(backOrderPenaltyAmount: {
					currencyCode: "USD",
					value: $.BACKORDERPENALTY
				}) if($.BACKORDERPENALTY != null),
				(coefficientVariation: $.COEFFVAR) if($.COEFFVAR != null),
				(effectiveFromDate: ($.EFFIO_EFF) as Date{format:"yyyy-MM-dd",class:"java.sql.Date"}) if($.EFFIO_EFF != null),
				(endOfLifeDemand: $.ENDOFLIFEDMD) if($.ENDOFLIFEDMD != null),
				(eventType: $.EVENTTYPE as String) if($.EVENTTYPE != null),
				(handlingCost: {
					currencyCode: "USD",
					value: $.HANDLINGCOST
				}) if($.HANDLINGCOST != null),
				(holdingCost: {
					currencyCode: "USD",
					value: $.EFFIO_HOLDINGCOST
				}) if($.EFFIO_HOLDINGCOST != null),
				(inventoryOptimizationServiceProfile: $.IOSERVICEPROFILE) if($.IOSERVICEPROFILE != null),
				(maximumReOrderQuantity: {
					measurementUnitCode: "EA",
					value: $.MAXREORDERQTY
				}) if($.MAXREORDERQTY != null),
				(minimumReOrderQuantity: {
					measurementUnitCode: "EA",
					value: $.MINREORDERQTY
				}) if($.MINREORDERQTY != null),
				(orderCost: {
					currencyCode: "USD",
					value: $.ORDERCOST
				}) if($.ORDERCOST != null),
				(overStockPenaltyAmount: {
					currencyCode: "USD",
					value: $.OVERSTOCKPENALTY
				}) if($.OVERSTOCKPENALTY != null),
				(replenishmentPolicy: $.REPLENPOLICY) if($.REPLENPOLICY != null),
				(reviewPeriodDuration: {
					timeMeasurementUnitCode: "MIN",
					value: $.REVIEWPERIOD
				}) if($.REVIEWPERIOD != null),
				(stockOutPenaltyAmount: {
					currencyCode: "USD",
					value: $.STOCKOUTPENALTY
				}) if($.STOCKOUTPENALTY != null),
				(unitCost: {
					currencyCode: "USD",
					value: $.UNITCOST
				}) if($.UNITCOST != null)
			}]) if($.BACKORDERPENALTY != null
		or $.COEFFVAR != null or $.EFFIO_EFF != null or $.ENDOFLIFEDMD != null or $.EVENTTYPE != null or $.HorLINGCOST != null or $.EFFIO_HOLDINGCOST != null or 
		$.IOSERVICEPROFILE != null or $.MAXREORDERQTY != null or $.MINREORDERQTY != null or $.ORDERCOST != null or $.OVERSTOCKPENALTY != null or 
		$.REPLENPOLICY != null or $.REVIEWPERIOD != null or $.STOCKOUTPENALTY != null or $.UNITCOST != null)
		}) if($.AVGRQSNSIZE != null or $.GROUPNAME != null or $.NUMRQSN != null or $.REVIEWGROUP != null or $.SENSITIVITYPROFILE != null),
		(perishableParameters: {
			(shelfLifeDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.SHELFLIFEDUR
			})if($.SHELFLIFEDUR != null),
			(minimumShelfLifeDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.MINSHELFLIFEDUR
			}) if($.MINSHELFLIFEDUR != null),
			(minimumShipmentShelfLifeDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.MINSHIPSHELFLIFEDUR
			}) if($.MINSHIPSHELFLIFEDUR != null),
			(maximumShelfLifeDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.MAXSHELFLIFEDUR
			}) if($.MAXSHELFLIFEDUR != null),
		}) if($.SHELFLIFEDUR != null or $.MINSHELFLIFEDUR != null or $.MINSHIPSHELFLIFEDUR != null or $.MAXSHELFLIFEDUR != null),
		(planningParameters: {
			(supplyLeadBufferDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.BUFFERLEADTIME
			}) if($.BUFFERLEADTIME != null),
			(receiptCoverageDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.DRPCOVDUR
			}) if($.DRPCOVDUR != null),
			(supplyCoverageDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.MPSCOVDUR
			}) if($.MPSCOVDUR != null),
			(receiptFrozenDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.DRPFRZDUR
			}) if($.DRPFRZDUR != null),
			(holdingCost: {
				currencyCode: "USD",
				value: $.PLANPARAM_HOLDINGCOST
			}) if($.PLANPARAM_HOLDINGCOST != null),
			(incrementalDRPQuantity: {
				value: $.INCDRPQTY
			}) if($.INCDRPQTY != null),
			(incrementalMPSQuantity: {
				value: $.INCMPSQTY
			}) if($.INCMPSQTY != null),
			(receivingHandlingCost: {
				currencyCode: "USD",
				value: $.INHANDLINGCOST
			}) if($.INHANDLINGCOST != null),
			(maximumOnHandQuantity: {
				measurementUnitCode: "EA",
				value: $.PLANPARAM_MAXOH
			}) if($.PLANPARAM_MAXOH != null),
			(manufactureDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.MFGFRZDUR
			}) if($.MFGFRZDUR != null),
			(manufactureLeadTimeDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.MFGLEADTIME
			}) if($.MFGLEADTIME != null),
			(minimumDRPQuantity: {
				value: $.MINDRPQTY
			}) if($.MINDRPQTY != null),
			(minimumMPSQuantity: {
				value: $.MINMPSQTY
			}) if($.MINMPSQTY != null),
			(orderingCost: {
				currencyCode: "USD",
				value: $.ORDERINGCOST
			}) if($.ORDERINGCOST != null),
			(shippingHandlingCost: {
				currencyCode: "USD",
				value: $.OUTHANDLINGCOST
			}) if($.OUTHANDLINGCOST != null),
			(shrinkageFactor: $.SHRINKAGEFACTOR) if($.SHRINKAGEFACTOR != null),
			useWorkInProgressQuantity: if($.USEWIPSW == 0) false else true,
		}) if($.BUFFERLEADTIME != null or $.DRPCOVDUR != null or $.MPSCOVDUR != null or $.DRPFRZDUR != null or $.PLANPARAM_HOLDINGCOST != null or 
		$.INCDRPQTY != null or $.INCMPSQTY != null or $.INHorLINGCOST != null or $.PLANPARAM_MAXOH != null or 	$.MFGFRZDUR != null or $.MFGLEADTIME != null or
		$.MINDRPQTY != null or $.MINMPSQTY != null or $.ORDERINGCOST != null or $.OUTHorLINGCOST != null or $.SHRINKAGEFACTOR != null),
		(safetyStockParameters: {
			(safetyStockRuleCode: $.SSRULE as String) if($.SSRULE != null),
			(accumulationDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.ACCUMDUR
			}) if($.ACCUMDUR != null),
			(averageReplenishmentLeadDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.AVGLEADTIME
			}) if($.AVGLEADTIME != null),
			(maximumSafetyStock: {
				measurementUnitCode: "EA",
				value: $.SSPARAM_MAXSS
			}) if($.SSPARAM_MAXSS != null),
			(minimumSafetyStock: {
				measurementUnitCode: "EA",
				value: $.MINSS
			}) if($.MINSS != null),
			(safetyStockCoverageDuration: {
				timeMeasurementUnitCode: "MIN",
				value: $.SSCOV
			}) if($.SSCOV != null),
			(safetyStockCustomerServiceLevel: $.STATSSCSL) if($.STATSSCSL != null)
		}) if($.SSRULE != null or $.ACCUMDUR != null or $.AVGLEADTIME != null or $.SSPARAM_MAXSS != null or $.MINSS != null or $.SSCOV != null or $.STATSSCSL != null),
		(safetyStockPresentation: [{
			actionCode: "ADD",
			(effectiveFromDateTime: $.SSPR_EFF as DateTime) if($.SSPR_EFF != null),
			(effectiveUpToDateTime: $.DISC as DateTime) if($.DISC != null),
			(displayQuantity: {
				measurementUnitCode: "EA",
				value: $.DISPLAYQTY
			}) if($.DISPLAYQTY != null),
			(presentationQuantity: {
				measurementUnitCode: "EA",
				value: $.PRESENTATIONQTY
			}) if($.PRESENTATIONQTY != null),
			(maximumOnHandQuantity: {
				measurementUnitCode: "EA",
				value: $.SSPR_MAXOH
			}) if($.SSPR_MAXOH != null),
			(maximumSafetyStock: {
				measurementUnitCode: "EA",
				value: $.SSPR_MAXSS
			}) if($.SSPR_MAXSS != null),
		}]) if($.SSPR_EFF != null or $.DISC != null or $.DISPLAYQTY != null or $.PRESENTATIONQTY != null or $.SSPR_MAXOH != null or $.SSPR_MAXSS != null)
	})
}
