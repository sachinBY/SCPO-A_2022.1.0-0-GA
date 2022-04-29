%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var vehicleLoadEntity = vars.entityMap.vehicleloadline[0].vehicleload[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
flatten(flatten(payload.transportLoad filter()->($.loadStatusCode=="PLANNED" or $.loadStatusCode=="IN_TRANSIT")) map(transportLoad, transportLoadIndex) -> {
	stop:(transportLoad.stop map(stop,stopIndex)->{
	ARRIVDATE: if ((stop.stopLogisticEvent filter ($.logisticEventTypeCode == 'TERMINAL_ARRIVAL'))[0].logisticEventDateTime.date != null 
					
				) 
					(stop.stopLogisticEvent filter ($.logisticEventTypeCode == 'TERMINAL_ARRIVAL'))[0].logisticEventDateTime.date as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} 
			   else 
					default_value,
	DESCR: if (transportLoad.note.value != null) transportLoad.note.value 
		   else default_value,
    MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference,
	(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((transportLoadIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	SENDER: vars.bulkNotificationHeaders.sender,
	DESTSTATUS: default_value,
	EXPORTED: default_value,
	LBSOURCE: default_value,
	LOADID: if (transportLoad.transportLoadId != null) 
				transportLoad.transportLoadId 
			else 
				default_value,
	SHIPDATE: if ((stop.stopLogisticEvent filter ($.logisticEventTypeCode == 'TERMINAL_DEPARTURE'))[0].logisticEventDateTime.date != null 
				
				) 
				(stop.stopLogisticEvent filter ($.logisticEventTypeCode == 'TERMINAL_DEPARTURE'))[0].logisticEventDateTime.date as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
			  else 
				default_value,
	LOADSW: "0",
	SOURCESTATUS: if (transportLoad.loadStatusCode != null) 
					if(transportLoad.loadStatusCode == "PLANNED") "1"
					else if (transportLoad.loadStatusCode == "IN_TRANSIT") "3"
					else default_value
				  else default_value,
	TRANSMODE: if (transportLoad.transportEquipment.transportEquipmentTypeCode.value != null) 					
					transportLoad.transportEquipment.transportEquipmentTypeCode.value 
				else "*UNKNOWN",
	(VehicleLoadUDC: (lib.getUdcNameAndValue(vehicleLoadEntity, transportLoad.avpList, lib.getAvpListMap(transportLoad.avpList))[0])) 
  		if (transportLoad.avpList != null 
  			and (transportLoad.documentActionCode == "ADD" or transportLoad.documentActionCode == "CHANGE_BY_REFRESH")
  			and vehicleLoadEntity != null
  		),
	ACTIONCODE: transportLoad.documentActionCode	
	})
}.stop)