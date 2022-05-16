%dw 2.0
output application/java
---
payload map (planArriv, indexOfplanArriv) -> {
		MS_BULK_REF: planArriv.MS_BULK_REF,
		MS_REF: planArriv.MS_REF,
	    INTEGRATION_STAMP: planArriv.INTEGRATION_STAMP,
	    MESSAGE_TYPE: planArriv.MESSAGE_TYPE,
  		MESSAGE_ID: planArriv.MESSAGE_ID,
  		SENDER: planArriv.SENDER,
		ITEM: planArriv.ITEM,
		DEST: planArriv.DEST,
		(vars.deleteudc): 'Y'   
}