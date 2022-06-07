%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var vehicleLoadLineEntity = vars.entityMap.vehicleloadline[0].vehicleloadline[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
flatten(flatten((payload.transportLoad filter()->($.loadStatusCode=="PLANNED" or $.loadStatusCode=="IN_TRANSIT")) map (transportLoad, transportLoadIndex) -> {
	vehicleloadlines: flatten(transportLoad.shipment map (transportLoadShipment, transportLoadShipmentIndex) -> {
		val: flatten(transportLoadShipment.shipmentItem map (shipmentItem, shipmentItemIndex) -> {
			tradeItems: (shipmentItem.transactionalTradeItem map (transactionalTradeItem, transactionalTradeItemIndex) -> {
				(if(transactionalTradeItem.transactionalItemData != null){
				transItemData: (transactionalTradeItem.transactionalItemData map(transactionalItemData,transactionalItemDataIndex)-> {
					MS_BULK_REF: vars.storeHeaderReference.bulkReference,
					MS_REF: vars.storeMsgReference.messageReference,
					(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((transactionalItemDataIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
					MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  					MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  					SENDER: vars.bulkNotificationHeaders.sender,
					DEST: if ( transportLoadShipment.shipTo.primaryId != null ) transportLoadShipment.shipTo.primaryId else default_value,
					EXPDATE: if ( transactionalItemData.itemExpirationDate != null ) transactionalItemData.itemExpirationDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
					ITEM: transactionalTradeItem.primaryId,
					LOADID: transportLoad.transportLoadId,
					LOADLINEID: if ( shipmentItem.lineItemNumber != null ) shipmentItem.lineItemNumber else default_value,
					PRIMARYITEM: shipmentItem.requestedTradeItem.primaryId,
					QTY: if ( transactionalTradeItem.tradeItemQuantity.value != null ) transactionalTradeItem.tradeItemQuantity.value else default_value,
					SCHEDARRIVDATE: if ( transportLoadShipment.plannedDelivery.logisticEventDateTime.date != null ) transportLoadShipment.plannedDelivery.logisticEventDateTime.date as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
					SCHEDSHIPDATE: if ( transportLoadShipment.plannedDespatch.logisticEventDateTime.date != null ) transportLoadShipment.plannedDespatch.logisticEventDateTime.date as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
					SEQNUM: default_value,
					SOURCE: if ( transportLoadShipment.shipFrom.primaryId !=null ) transportLoadShipment.shipFrom.primaryId else default_value,
					SOURCING: if ( shipmentItem.sourcingMethod != null ) shipmentItem.sourcingMethod else default_value,
					avplistUDCS: (flatten([(lib.getUdcNameAndValue(vehicleLoadLineEntity, transportLoad.avpList, lib.getAvpListMap(transportLoad.avpList))[0]) if (transportLoad.avpList != null and (transportLoad.documentActionCode == "ADD" or transportLoad.documentActionCode == "CHANGE_BY_REFRESH") and vehicleLoadLineEntity != null),
		(lib.getUdcNameAndValue(vehicleLoadLineEntity, transportLoadShipment.avpList, lib.getAvpListMap(transportLoadShipment.avpList))[0]) if (transportLoadShipment.avpList != null and (transportLoad.documentActionCode == "ADD" or transportLoad.documentActionCode == "CHANGE_BY_REFRESH") and vehicleLoadLineEntity != null)])),
					ACTIONCODE: transportLoad.documentActionCode
				})}
				else {
				transItemData: ({
					MS_BULK_REF: vars.storeHeaderReference.bulkReference,
					MS_REF: vars.storeMsgReference.messageReference,
					(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT0S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
					MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  					MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  					SENDER: vars.bulkNotificationHeaders.sender,
					DEST: if ( transportLoadShipment.shipTo.primaryId != null ) transportLoadShipment.shipTo.primaryId else default_value,
					EXPDATE: default_value,
					ITEM: transactionalTradeItem.primaryId,
					LOADID: transportLoad.transportLoadId,
					LOADLINEID: if ( shipmentItem.lineItemNumber != null ) shipmentItem.lineItemNumber else default_value,
					PRIMARYITEM: shipmentItem.requestedTradeItem.primaryId,
					QTY: if ( transactionalTradeItem.tradeItemQuantity.value != null ) transactionalTradeItem.tradeItemQuantity.value else default_value,
					SCHEDARRIVDATE: if ( transportLoadShipment.plannedDelivery.logisticEventDateTime.date != null ) transportLoadShipment.plannedDelivery.logisticEventDateTime.date as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
					SCHEDSHIPDATE: if ( transportLoadShipment.plannedDespatch.logisticEventDateTime.date != null ) transportLoadShipment.plannedDespatch.logisticEventDateTime.date as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
					SEQNUM: default_value,
					SOURCE: if ( transportLoadShipment.shipFrom.primaryId !=null ) transportLoadShipment.shipFrom.primaryId else default_value,
					SOURCING: if ( shipmentItem.sourcingMethod != null ) shipmentItem.sourcingMethod else default_value,
					avplistUDCS: (flatten([(lib.getUdcNameAndValue(vehicleLoadLineEntity, transportLoad.avpList, lib.getAvpListMap(transportLoad.avpList))[0]) if (transportLoad.avpList != null and (transportLoad.documentActionCode == "ADD" or transportLoad.documentActionCode == "CHANGE_BY_REFRESH") and vehicleLoadLineEntity != null),
		(lib.getUdcNameAndValue(vehicleLoadLineEntity, transportLoadShipment.avpList, lib.getAvpListMap(transportLoadShipment.avpList))[0]) if (transportLoadShipment.avpList != null and (transportLoad.documentActionCode == "ADD" or transportLoad.documentActionCode == "CHANGE_BY_REFRESH") and vehicleLoadLineEntity != null),
		(lib.getUdcNameAndValue(vehicleLoadLineEntity, shipmentItem.avpList, lib.getAvpListMap(shipmentItem.avpList))[0]) if (shipmentItem.avpList != null and (transportLoad.documentActionCode == "ADD" or transportLoad.documentActionCode == "CHANGE_BY_REFRESH") and vehicleLoadLineEntity != null)])),
					ACTIONCODE: transportLoad.documentActionCode
				})})
			}.transItemData)
		}.tradeItems)
	}.val)
}.vehicleloadlines)) filter (value,index) -> (value != null)
