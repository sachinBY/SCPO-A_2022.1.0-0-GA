%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var planarrivEntity = vars.entityMap.planarriv[0].planarriv[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
if (payload."type"[0] == "PLAN_ARRIVAL")
(payload map (plannedsupply, indexofplannedsupply) -> {
 		udcs:(planarrivEntity map (value, index) -> {
			scpoColumnName: value.scpoColumnName,
			scpoColumnValue: if ((lib.mapHostToSCPO(plannedsupply, (value.hostColumnName splitBy "/"), 0)) != null) (lib.mapHostToSCPO(plannedsupply, (value.hostColumnName splitBy "/"), 0)) else default_value,
			(dataType: value.dataType) if ((lib.mapHostToSCPO(plannedsupply, (value.hostColumnName splitBy "/"), 0)) != null),
		}),
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((indexofplannedsupply))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender, 
		ITEM: if (plannedsupply."plannedSupplyId.item.primaryId" != null and plannedsupply."plannedSupplyId.item.primaryId" != "")  
				plannedsupply."plannedSupplyId.item.primaryId"
			 else default_value,
	  	DEST: if (plannedsupply."plannedSupplyId.shipTo.primaryId" != null and plannedsupply."plannedSupplyId.shipTo.primaryId" != "")  
				plannedsupply."plannedSupplyId.shipTo.primaryId"
			 else default_value,
		SEQNUM: indexofplannedsupply,
		NEEDARRIVDATE: if(plannedsupply."plannedSupplyDetail.availableForSaleDate" != null)
			(plannedsupply."plannedSupplyDetail.availableForSaleDate")
			else default_value,
		SCHEDARRIVDATE: if(plannedsupply."plannedSupplyDetail.availableForSaleDate" != null )
			(plannedsupply."plannedSupplyDetail.availableForSaleDate")
			else default_value,
		NEEDSHIPDATE: if(plannedsupply."plannedSupplyDetail.orderCutoffDateTime" != null)
			(plannedsupply."plannedSupplyDetail.orderCutoffDateTime")
			else default_value,
		SCHEDSHIPDATE: if(plannedsupply."plannedSupplyDetail.orderCutoffDateTime" != null)
			(plannedsupply."plannedSupplyDetail.orderCutoffDateTime")
			else default_value,
		QTY: if (plannedsupply."plannedSupplyDetail.requestedQuantity.value" != null and plannedsupply."plannedSupplyDetail.requestedQuantity.value" != "")  
				plannedsupply."plannedSupplyDetail.requestedQuantity.value" as Number
			 else default_value,
		
		SOURCE: if (plannedsupply."plannedSupplyId.shipFrom.primaryId" != null and plannedsupply."plannedSupplyId.shipFrom.primaryId" != "")  
				plannedsupply."plannedSupplyId.shipFrom.primaryId"
			 else default_value,
	(vars.matchedsourcingdata map(value,index)->{
     
        (SOURCING:     (value.SOURCING default default_value))if(value.ITEM == plannedsupply."plannedSupplyId.item.primaryId"),
        (TRANSMODE:    (value.TRANSMODE default default_value))if(value.ITEM == plannedsupply."plannedSupplyId.item.primaryId")
                   
     }),
     	
		ACTIONCODE: if (not isEmpty(plannedsupply.documentActionCode)) plannedsupply.documentActionCode else if (vars.bulknotificationHeaders.documentActionCode != null) vars.bulknotificationHeaders.documentActionCode else "CHANGE_BY_REFRESH"
  	
  })
  
  else []