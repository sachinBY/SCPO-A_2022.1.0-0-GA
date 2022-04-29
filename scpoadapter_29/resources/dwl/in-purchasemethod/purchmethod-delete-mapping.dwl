%dw 2.0
output application/java
---
(payload map (purchMethod, indexOfPurchMethod) -> {
		MS_BULK_REF: purchMethod.MS_BULK_REF,
		MS_REF: purchMethod.MS_REF,	
	    INTEGRATION_STAMP: purchMethod.INTEGRATION_STAMP,
	    MESSAGE_TYPE: purchMethod.MESSAGE_TYPE,
  		MESSAGE_ID: purchMethod.MESSAGE_ID,
  		SENDER: purchMethod.SENDER,
  		(PURCHMETHOD: purchMethod.PURCHMETHOD) if not purchMethod.PURCHMETHOD == null,
		(ITEM: purchMethod.ITEM )if not purchMethod.ITEM == null,
		(LOC: purchMethod.LOC) if not purchMethod.LOC == null,
		(vars.deleteudc): 'Y'
	  })