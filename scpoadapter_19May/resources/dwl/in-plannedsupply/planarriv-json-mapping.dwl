%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
var planarrivEntity = vars.entityMap.planarriv[0].planarriv[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
flatten(flatten(payload.plannedSupply filter ($."type" == "PLAN_ARRIVAL") map (plannedSupply,indexOfplannedSupply) -> { 
    conversion: plannedSupply.plannedSupplyDetail map(plannedSupplyDetail,indexOfplannedSupplyDetail) ->
    {
    	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((indexOfplannedSupply))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),	
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		(ITEM: plannedSupply.plannedSupplyId.item.primaryId) 
				if plannedSupply.plannedSupplyId.item.primaryId != null,
				
		(DEST: plannedSupply.plannedSupplyId.shipTo.primaryId)
				if plannedSupply.plannedSupplyId.shipTo.primaryId != null,
		(SEQNUM:indexOfplannedSupply as Number),		
		(NEEDARRIVDATE:plannedSupplyDetail.availableForSaleDate) if (plannedSupplyDetail.availableForSaleDate != null),	
		(SCHEDARRIVDATE:plannedSupplyDetail.availableForSaleDate) if (plannedSupplyDetail.availableForSaleDate != null),
		(NEEDSHIPDATE:plannedSupplyDetail.orderCutoffDateTime) if (plannedSupplyDetail.orderCutoffDateTime != null),	
		(SCHEDSHIPDATE:plannedSupplyDetail.orderCutoffDateTime) if (plannedSupplyDetail.orderCutoffDateTime != null),
		(SOURCE: plannedSupply.plannedSupplyId.shipFrom.primaryId)
				if plannedSupply.plannedSupplyId.shipFrom.primaryId != null,
		(QTY: plannedSupplyDetail.requestedQuantity.value as Number) 
			if plannedSupplyDetail.requestedQuantity.value != null, 
		(vars.matchedsourcingdata map(value,index)->{
     
        (SOURCING:     (value.SOURCING default default_value))if(value.ITEM == plannedSupply.plannedSupplyId.item.primaryId),
        (TRANSMODE:    (value.TRANSMODE default default_value))if(value.ITEM == plannedSupply.plannedSupplyId.item.primaryId)
                   
     }),	

		(PlanArrivUDC: (flatten([(lib.getUdcNameAndValue(planarrivEntity, plannedSupply.avpList, lib.getAvpListMap(plannedSupply.avpList))[0]) if (plannedSupply.avpList != null 
		and (plannedSupply.documentActionCode == "ADD" or plannedSupply.documentActionCode == "CHANGE_BY_REFRESH")
		and planarrivEntity != null
		),
		(lib.getUdcNameAndValue(planarrivEntity, plannedSupplyDetail.avpList, lib.getAvpListMap(plannedSupplyDetail.avpList))[0]) if (plannedSupplyDetail.avpList != null 
  			and (plannedSupply.documentActionCode == "ADD" or plannedSupply.documentActionCode == "CHANGE_BY_REFRESH")
			and planarrivEntity != null
		)
		]))),
		ACTIONCODE: plannedSupply.documentActionCode
    }
}pluck($)))