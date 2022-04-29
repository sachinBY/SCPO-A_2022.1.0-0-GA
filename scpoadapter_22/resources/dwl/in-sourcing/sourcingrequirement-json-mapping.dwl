%dw 2.0
output application/java
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var sourcingReqEntity = vars.entityMap.sourcing[0].sourcingrequirement[0]

---

flatten((payload.sourcing map (sourcing, sourcingIndex) -> {
	(val:sourcing.sourcingDetails.resourceRequirement map()-> {
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((sourcingIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		DEST: if(sourcing.sourcingId.dropOffLocation.locationId != null) sourcing.sourcingId.dropOffLocation.locationId
				else default_value,
		EFF: if(sourcing.sourcingDetails.effectiveFromDate != null and funCaller.formatGS1ToSCPO(sourcing.sourcingDetails.effectiveFromDate replace 'Z' with('')) != default_value)
			    (sourcing.sourcingDetails.effectiveFromDate replace 'Z' with('')) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
				else default_value,
		ITEM: if(sourcing.sourcingId.item.itemId != null) sourcing.sourcingId.item.itemId
				else default_value,
		RATE: if($.resourceItemCapacity.value != null) $.resourceItemCapacity.value
				else default_value,
		RES:  if($.resourceId != null) $.resourceId
				else default_value,
		SOURCE: if(sourcing.sourcingId.pickUpLocation.locationId != null) sourcing.sourcingId.pickUpLocation.locationId
				else default_value,
		SOURCING: if(sourcing.sourcingId.sourcingMethod != null) sourcing.sourcingId.sourcingMethod
				else default_value,
		STEPNUM: if($.sourcingStep != null) $.sourcingStep
				else default_value,
	    avplistUDCS:(flatten([(lib.getUdcNameAndValue(sourcingReqEntity, sourcing.avpList, lib.getAvpListMap(sourcing.avpList))[0]) if (sourcing.avpList != null 
		and (sourcing.documentActionCode == "ADD" or sourcing.documentActionCode == "CHANGE_BY_REFRESH")
		and sourcingReqEntity != null
		),
		(lib.getUdcNameAndValue(sourcingReqEntity, sourcing.sourcingDetails.avpList, lib.getAvpListMap(sourcing.sourcingDetails.avpList))[0]) if (sourcing.sourcingDetails.avpList != null 
			and (sourcing.sourcingDetails.documentActionCode == "ADD" or sourcing.sourcingDetails.documentActionCode == "CHANGE_BY_REFRESH")
			and sourcingReqEntity != null
		)
		])),
		
		ACTIONCODE: sourcing.documentActionCode,
		
		})
	}).val)