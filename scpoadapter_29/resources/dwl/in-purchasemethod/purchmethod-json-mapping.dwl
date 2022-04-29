%dw 2.0
output application/java  
import * from dw::Runtime
var UOMIsoConversion = vars.codeMap.UOMIsoConversion
var UOMConversion = vars.codeMap.UOMConversion
var purchMethodEntity = vars.entityMap.purchmethod[0].purchmethod[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var conversionToSeconds=vars.codeMap."time-units-seconds-conversion"
var conversionToMinutes=vars.codeMap."time-units-minutes-conversion"
var conversionToHours=vars.codeMap."time-units-hours-conversion"
var conversionToDays=vars.codeMap."time-units-days-conversion"
var conversionToWeeks=vars.codeMap."time-units-weeks-conversion"
var conversionToMonths=vars.codeMap."time-units-months-conversion"
var conversionToYears=vars.codeMap."time-units-years-conversion"
var default_value = "###JDA_DEFAULT_VALUE###"
---
(payload.purchaseMethod map {
	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference,	
	   
	(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	SENDER: vars.bulkNotificationHeaders.sender,
	(INCORDERQTY: $.incrementalOrderQuantity.value as Number) if ($.incrementalOrderQuantity != null),
	ITEM : if($.purchaseMethodId.item.primaryId != null) 
        		$.purchaseMethodId.item.primaryId
           else fail("Item can't be null"), 
	LEADTIME: 	if($.replenishLeadDuration.value != null) 
					if($.replenishLeadDuration.timeMeasurementUnitCode != null) 		   		   			
				if(lower(p("bydm.inbound.purchmethod.timemeasurementunitcode")) startsWith "sec") 
					
						ceil($.replenishLeadDuration.value * conversionToSeconds[$.replenishLeadDuration.timeMeasurementUnitCode][0] as Number)
				else if(lower(p("bydm.inbound.purchmethod.timemeasurementunitcode")) startsWith "hour") 
					
						ceil($.replenishLeadDuration.value * conversionToHours[$.replenishLeadDuration.timeMeasurementUnitCode][0]  as Number)
				else if(lower(p("bydm.inbound.purchmethod.timemeasurementunitcode")) startsWith "day") 
					
						ceil($.replenishLeadDuration.value * conversionToDays[$.replenishLeadDuration.timeMeasurementUnitCode][0]  as Number) 
				else if(lower(p("bydm.inbound.purchmethod.timemeasurementunitcode")) startsWith "week") 
					
						ceil($.replenishLeadDuration.value * conversionToWeeks[$.replenishLeadDuration.timeMeasurementUnitCode][0]  as Number) 
					
				else if(lower(p("bydm.inbound.purchmethod.timemeasurementunitcode")) startsWith "month") 
					
						ceil($.replenishLeadDuration.value * conversionToMonths[$.replenishLeadDuration.timeMeasurementUnitCode][0]  as Number)
				else if(lower(p("bydm.inbound.purchmethod.timemeasurementunitcode")) startsWith "year") 
					
						ceil($.replenishLeadDuration.value * conversionToYears[$.replenishLeadDuration.timeMeasurementUnitCode][0]  as Number)
				else 
					
						
						ceil($.replenishLeadDuration.value * conversionToMinutes[$.replenishLeadDuration.timeMeasurementUnitCode][0]  as Number)

				else 
					$.replenishLeadDuration.value
			else 
				default_value,
	(MAXORDERQTY: $.maximumOrderQuantity.value as Number) if ($.maximumOrderQuantity.value != null),
	(MINORDERQTY: $.minimumOrderQuantity.value as Number) if ($.minimumOrderQuantity.value != null),
	(PURCHMETHOD: $.purchaseMethodId.purchaseMethod) if ($.purchaseMethodId.purchaseMethod != null),
	(ABBR: $.description.value) if ($.description.value != null),
	LOC : if($.purchaseMethodId.location.primaryId != null) 
        		$.purchaseMethodId.location.primaryId
        		else fail("Location can't be null"), 
	(EFF: $.purchaseMethodPercentage.effectiveFromDate) if ($.purchaseMethodPercentage.effectiveFromDate != null),
	(DISC: $.purchaseMethodPercentage.effectiveUpToDate) if ($.purchaseMethodPercentage.effectiveUpToDate != null),
	(PRIORITY :  $.purchaseMethodPercentage.priority) if ($.purchaseMethodPercentage.priority != null),
	(FACTOR :  $.purchaseMethodPercentage.demandPercentage as Number / 100) if ($.purchaseMethodPercentage.demandPercentage != null),
	(PURCHCOST: $.purchaseCost.value as Number) if ($.purchaseCost != null),
	(EXPEDITECOST: $.expediteCost.value as Number) if ($.expediteCost.value != null),
	(AVGCOST: $.averageCost.value as Number) if ($.averageCost.value != null),
	(PURCHGROUP: $.purchaseGroup ) if ($.purchaseGroup != null),
	(AVAILQTY: $.availableQuantity.value as Number) if ($.availableQuantity.value != null),
	(NONEWSUPPLYDATE: $.noNewSupplyBeforeDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}) if ($.noNewSupplyBeforeDate != null),
	(PurchMethodUDC: (lib.getUdcNameAndValue(purchMethodEntity, $.avpList, lib.getAvpListMap($.avpList))[0])
 	) 
  			if ($.avpList != null 
  			and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
  			and purchMethodEntity != null),
  			
	ACTIONCODE: $.documentActionCode
})