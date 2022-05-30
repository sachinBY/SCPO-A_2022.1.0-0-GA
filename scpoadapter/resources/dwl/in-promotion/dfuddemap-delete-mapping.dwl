%dw 2.0
output application/java
---
(payload map (promotion, promotionIndex) -> {
		MS_BULK_REF: promotion.MS_BULK_REF,
		MS_REF: promotion.MS_REF,	
	    INTEGRATION_STAMP: promotion.INTEGRATION_STAMP,
	    MESSAGE_TYPE: promotion.MESSAGE_TYPE,
  		MESSAGE_ID: promotion.MESSAGE_ID,
  		SENDER: promotion.SENDER,
		DMDUNIT:  promotion.DMDUNIT,
		DMDGROUP:  promotion.DMDGROUP,			  		
		LOC: promotion.LOC,
		MODEL:  promotion.MODEL,
		PROMOTION: promotion.PROMOTION,
		(vars.deleteudc): 'Y'
})
