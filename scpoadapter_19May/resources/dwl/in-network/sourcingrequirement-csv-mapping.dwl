%dw 2.0
output application/java
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
ns ns0 urn:jda:master:network:xsd:3
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var sourcingReqEntity = vars.entityMap.networkmap[0].sourcingrequirement[0]
---
(payload map (network, networkIndex) -> {
	
		udcs: ((sourcingReqEntity map (value, index) -> {
			(scpoColumnName: value.scpoColumnName) if ((lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0)) != null),
			(scpoColumnValue: (lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0))) if ((lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0)) != null),
			(dataType: value.dataType) if ((lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0)) != null)
		})) filter sizeOf($) > 0,
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((networkIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		DEST: if(network.'dropOffLocation.locationId' != null) network.'dropOffLocation.locationId'
				else default_value,
		EFF: if(network.'sourcingInformation.sourcingDetails.effectiveFromDate' != null)
				(network.'sourcingInformation.sourcingDetails.effectiveFromDate' replace 'Z' with('')) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
				else default_value,
		ITEM:  if(network.'sourcingInformation.sourcingItem.itemId' != null) network.'sourcingInformation.sourcingItem.itemId'
				else default_value,
		RATE: if(network.'sourcingInformation.sourcingDetails.resourceRequirement.resourceItemCapacity.value' != null)
				network.'sourcingInformation.sourcingDetails.resourceRequirement.resourceItemCapacity.value'
				else default_value,
		RES: if(network.'sourcingInformation.sourcingDetails.resourceRequirement.resourceId' != null)
				network.'sourcingInformation.sourcingDetails.resourceRequirement.resourceId'
				else default_value,
		SOURCE: if(network.'pickUpLocation.locationId' != null) network.'pickUpLocation.locationId'
				else default_value,
		SOURCING:  if(network.'sourcingInformation.sourcingMethod' != null)
					network.'sourcingInformation.sourcingMethod'
					else default_value,
		STEPNUM: if(network.'sourcingInformation.sourcingDetails.resourceRequirement.sourcingStep' != null)
					network.'sourcingInformation.sourcingDetails.resourceRequirement.sourcingStep'
					else default_value,
   	ACTIONCODE: if (network.documentActionCode != null and !isEmpty(network.documentActionCode)) network.documentActionCode else (vars.bulknotificationHeaders.documentActionCode)

})