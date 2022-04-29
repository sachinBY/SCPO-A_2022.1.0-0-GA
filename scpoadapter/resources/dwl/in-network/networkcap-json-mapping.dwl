%dw 2.0
import * from dw::Runtime
output application/java
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
ns ns0 urn:jda:master:network:xsd:3
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var UOMIsoConversion = vars.codeMap.UOMIsoConversion
var UOMConversion = vars.codeMap.UOMConversion
var networkCapEntity = vars.entityMap.networkmap[0].networkcap[0]
---
flatten(flatten(payload.network map (network, networkIndex) -> {
	netCap: (network.networkCapacity map(networkCapacity, networkCapcityIndex) -> {
		//udcs: ((networkCapEntity map(value, index) -> {
		//	(scpoColumnName: value.scpoColumnName) if ((lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0)) != null),
		//	(scpoColumnValue: (lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0))) if ((lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0)) != null),
		//	(dataType: value.dataType) if ((lib.mapHostToSCPO(network, (value.hostColumnName splitBy "/"), 0)) != null)
		//})) filter sizeOf($) > 0,
		UOM: if(vars.uomShortLabels[networkCapacity.minimumCapacity.measurementUnitCode][0] != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH"))
			    vars.uomShortLabels[networkCapacity.minimumCapacity.measurementUnitCode][0]
			 else vars.uomShortLabels[p("bydm.network.default.uom")][0] as Number,
		MINCAP: if(networkCapacity.minimumCapacity.value != null)
			networkCapacity.minimumCapacity.value
			else default_value,
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((networkCapcityIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		SOURCE: if(network.pickUpLocation.locationId != null) network.pickUpLocation.locationId
				else default_value,
		TRANSMODE: if (network.transportEquipmentTypeCode.value == "*UNKNOWN") 
					p("bydm.network.default.transmode")
			   else if(network.transportEquipmentTypeCode.value != null)
					network.transportEquipmentTypeCode.value
			   else default_value,
		DEST: if(network.dropOffLocation.locationId != null) network.dropOffLocation.locationId
				else default_value,
		(networkCapUDC: (lib.getUdcNameAndValue(networkCapEntity, network.avpList, lib.getAvpListMap(network.avpList))[0])) 
	if (network.avpList != null and (network.documentActionCode == "ADD" or network.documentActionCode == "CHANGE_BY_REFRESH") and networkCapEntity != null),
		ACTIONCODE: network.documentActionCode
	})
} pluck ($)))