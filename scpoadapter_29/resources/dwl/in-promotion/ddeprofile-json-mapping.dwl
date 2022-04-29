%dw 2.0
output application/java

var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var promotionDDeProfileEntity = vars.entityMap.promotion[0].ddeprofile[0]
var default_value = "###JDA_DEFAULT_VALUE###"
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload.promotion  map (promotion, promotionIndex) -> {
	promotions: (promotion.eligibilityInformation map (promotioneligibilityInf, promotioneligibilityInfIndex) -> {
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,	
	    (INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((promotionIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		DESCR:  if (promotion.promotionId != null) 
					promotion.promotionId
				else 
					default_value,
		DMDCAL:  if (promotioneligibilityInf.demandCalendar != null) 
					promotioneligibilityInf.demandCalendar
				 else 
					default_value,
		DMDGROUP:  if (promotioneligibilityInf.demandChannel != null) 
						promotioneligibilityInf.demandChannel
				   else 
						default_value,
		DMDUNIT:  if (promotioneligibilityInf.item.itemId != null) 
					promotioneligibilityInf.item.itemId
				  else 
				   	default_value,				  		
		LOC: if(promotioneligibilityInf.location.locationId !=null) 
				promotioneligibilityInf.location.locationId	
		     else  
		     	default_value,
		MODEL:  if (promotioneligibilityInf.modelId != null) 
					upper(promotioneligibilityInf.modelId)
				else 
					"LEWANDOWSKI",	
		STARTDATE: if (promotion.effectiveFromDate != null and funCaller.formatGS1ToSCPO(promotion.effectiveFromDate) != default_value) 
						promotion.effectiveFromDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
				   else 
				   		default_value,
		(PromotionUDC: (lib.getUdcNameAndValue(promotionDDeProfileEntity, promotion.avpList, lib.getAvpListMap(promotion.avpList))[0])) 
  		if (promotion.avpList != null 
  			and (promotion.documentActionCode == "ADD" or promotion.documentActionCode == "CHANGE_BY_REFRESH")
  			and promotionDDeProfileEntity != null
  		),
		ACTIONCODE: promotion.documentActionCode
	})  
}).promotions reduce ($ ++ $$)