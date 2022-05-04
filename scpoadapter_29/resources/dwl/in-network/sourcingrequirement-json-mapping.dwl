%dw 2.0
output application/java
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
ns ns0 urn:jda:master:network:xsd:3
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var sourcingReqEntity = vars.entityMap.networkmap[0].sourcingrequirement[0]
---
flatten(flatten(flatten(flatten(payload.network map (network, networkIndex) -> {
	sourcing: (network.sourcingInformation map(sourcingInformation, sourcingInformationIndex) -> {
		requirement: (sourcingInformation.sourcingDetails.resourceRequirement map(resourceRequirement, resourceRequirementIndex) -> {
		//udcs: ((sourcingReqEntity map (value, index) -> {
		//	(scpoColumnName: value.scpoColumnName) if ((lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0)) != null),
		//	(scpoColumnValue: (lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0))) if ((lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0)) != null),
		//	(dataType: value.dataType) if ((lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0)) != null)
		//})) filter sizeOf($) > 0,
		DEST: if(network.dropOffLocation.locationId != null) network.dropOffLocation.locationId
				else default_value,
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((resourceRequirementIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		EFF: if(sourcingInformation.sourcingDetails.effectiveFromDate != null)
				(sourcingInformation.sourcingDetails.effectiveFromDate replace 'Z' with('')) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
				else default_value,
		ITEM:  if(sourcingInformation.sourcingItem.itemId != null) sourcingInformation.sourcingItem.itemId
				else default_value,
		RATE: if(resourceRequirement.resourceItemCapacity.value != null)
				resourceRequirement.resourceItemCapacity.value
				else default_value,
		RES: if(resourceRequirement.resourceId != null)
				resourceRequirement.resourceId
				else default_value,
		SOURCE: if(network.pickUpLocation.locationId != null) network.pickUpLocation.locationId
				else default_value,
		SOURCING:  if(sourcingInformation.sourcingMethod != null)
					sourcingInformation.sourcingMethod
					else default_value,
		STEPNUM: if(resourceRequirement.sourcingStep != null)
					resourceRequirement.sourcingStep
					else default_value,

			sourcingrequirementUDC:flatten([(lib.getUdcNameAndValue(sourcingReqEntity, network.avpList, lib.getAvpListMap(network.avpList))[0]) 
	if (not isEmpty(network.avpList) and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH") and sourcingReqEntity != null),
	(lib.getUdcNameAndValue(sourcingReqEntity, sourcingInformation.sourcingDetails.avpList, lib.getAvpListMap(sourcingInformation.sourcingDetails.avpList))[0]) 
	if (not isEmpty(sourcingInformation.sourcingDetails.avpList) and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH") and sourcingReqEntity != null),
	(lib.getUdcNameAndValue(sourcingReqEntity, resourceRequirement.avpList, lib.getAvpListMap(resourceRequirement.avpList))[0]) 
	if (not isEmpty(resourceRequirement.avpList) and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH") and sourcingReqEntity != null)
	]),
   	ACTIONCODE: network.documentActionCode
})
	}  pluck ($))
} pluck($)))))
