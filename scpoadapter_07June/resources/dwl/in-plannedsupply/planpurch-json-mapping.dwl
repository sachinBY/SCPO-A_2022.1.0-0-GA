%dw 2.0
output application/java  
var planPurchEntity = vars.entityMap.firmplanpurch[0].planpurch[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
flatten(flatten(payload.plannedSupply filter ($."type" == "PLAN_PURCHASE") map (plannedSupply,indexOfplannedSupply) -> { 
    conversion: plannedSupply.plannedSupplyDetail map(plannedSupplyDetail,indexOfplannedSupplyDetail) ->
    {
		udcs: ((planPurchEntity map (value, index) -> {
			(scpoColumnName: value.scpoColumnName) if ((lib.mapHostToSCPO(plannedSupply, (value.hostColumnName splitBy "/"), 0)) != null),
			(scpoColumnValue: (lib.mapHostToSCPO(plannedSupply, (value.hostColumnName splitBy "/"), 0))) if ((lib.mapHostToSCPO(plannedSupply, (value.hostColumnName splitBy "/"), 0)) != null),
			(dataType: value.dataType) if ((lib.mapHostToSCPO(plannedSupply, (value.hostColumnName splitBy "/"), 0)) != null)
		})) filter sizeOf($) > 0,
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	  	MS_REF: vars.storeMsgReference.messageReference,	
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((indexOfplannedSupply))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		SEQNUM: (indexOfplannedSupply*100 + indexOfplannedSupplyDetail),
		(ITEM: plannedSupply.plannedSupplyId.item.primaryId) 
				if plannedSupply.plannedSupplyId.item.primaryId != null,
		(LOC: plannedSupply.plannedSupplyId.shipTo.primaryId)
				if plannedSupply.plannedSupplyId.shipTo.primaryId != null,
		(QTY: plannedSupplyDetail.requestedQuantity.value as Number) 
			if plannedSupplyDetail.requestedQuantity.value != null, 
		(NEEDDATE: plannedSupplyDetail.requestedDeliveryDate replace 'Z' with(''))  
				if plannedSupplyDetail.requestedDeliveryDate != null,
		(FIRMPLANSW: if(plannedSupplyDetail.isFirmPlannedSupply == "true") 1 else 0) 
					if plannedSupplyDetail.isFirmPlannedSupply != null,
		(PlanPurchUDC: (lib.getUdcNameAndValue(planPurchEntity, plannedSupply.avpList, lib.getAvpListMap(plannedSupply.avpList))[0])
 	) 
  			if (plannedSupply.avpList != null 
  			and (plannedSupply.documentActionCode == "ADD" or plannedSupply.documentActionCode == "CHANGE_BY_REFRESH")
  			and planPurchEntity != null),
		ACTIONCODE: plannedSupply.documentActionCode
    }
}pluck($)))