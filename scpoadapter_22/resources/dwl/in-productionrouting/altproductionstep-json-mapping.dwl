%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var altProductionStepEntity = vars.entityMap.productionrouting[0].altproductionstep[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
flatten(flatten(flatten(payload.productionRouting map (productionRouting, productionRoutingIndex) -> {
    steps: (productionRouting.productionRoutingOperation map(productionstep, productionstepIndex) -> {
		val:(productionstep.productionResource map(productionResource,productionResourceIndex)->{
			newval:(productionResource.alternateResource map(alternateResource,alternateResourceIndex)->{
				MS_BULK_REF: vars.storeHeaderReference.bulkReference,
				MS_REF: vars.storeMsgReference.messageReference,
				(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((productionRoutingIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
				MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  				MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  				SENDER: vars.bulkNotificationHeaders.sender,
				ITEM: if (productionRouting.item != null) productionRouting.item else default_value,
				LOC: if (productionRouting.location != null) productionRouting.location else default_value,
				PRODUCTIONMETHOD : if (productionRouting.productionRoutingId != null) productionRouting.productionRoutingId else default_value,
				PRIMARYSTEPNUM: if (productionstep.operationNumber != null) productionstep.operationNumber as Number else default_value,
				ALTRES: if (alternateResource.resourceId != null) alternateResource.resourceId else default_value,
				EFF: if (productionstep.effectiveFromDate != null) (productionstep.effectiveFromDate replace 'Z' with ('')) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
				//PRODDUR:if(productionstep.operationDuration.value != null) productionstep.operationDuration.value else default_value,
				PRODRATE: if (alternateResource.resourceCapacityUsageRate != null) alternateResource.resourceCapacityUsageRate as Number else default_value,
				PRODRATECAL: if (alternateResource.productionRateCalendar != null) alternateResource.productionRateCalendar else default_value,
				USAGESW: if (alternateResource.isUsedForPlanning != null and alternateResource.isUsedForPlanning == true) 1 else if (alternateResource.isUsedForPlanning != null and alternateResource.isUsedForPlanning == false) 0 else default_value,
				PRIORITY: if (alternateResource.priority != null) alternateResource.priority as Number else default_value,
				//ALTRESGROUP is primary key in live table so IGP table has kept not null constraint, but there is no mapping for ALTRESGROUP so adapter is defaulting live table default value here.
				ALTRESGROUP: ' ',
				avplistUDCS:(flatten([(lib.getUdcNameAndValue(altProductionStepEntity, productionRouting.avpList, lib.getAvpListMap(productionRouting.avpList) )[0]) if (productionRouting.avpList != null 
				and (productionRouting.documentActionCode == "ADD" or productionRouting.documentActionCode == "CHANGE_BY_REFRESH")
				and altProductionStepEntity != null),
				(lib.getUdcNameAndValue(altProductionStepEntity, productionstep.avpList, lib.getAvpListMap(productionstep.avpList) )[0]) if (productionstep.avpList != null 
				and (productionRouting.documentActionCode == "ADD" or productionRouting.documentActionCode == "CHANGE_BY_REFRESH")
				and altProductionStepEntity != null
				)])),
				ACTIONCODE: productionRouting.documentActionCode
					})
				}.newval)
			}.val)
}.steps)))
