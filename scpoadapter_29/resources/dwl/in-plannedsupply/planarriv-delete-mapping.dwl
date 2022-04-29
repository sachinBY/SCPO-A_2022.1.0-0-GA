%dw 2.0
output application/java
---
payload map (planArriv, indexOfplanArriv) -> {
		MS_BULK_REF: planArriv.MS_BULK_REF,
		MS_REF: planArriv.MS_REF,
	    INTEGRATION_STAMP: planArriv.INTEGRATION_STAMP,
	    MESSAGE_TYPE: firmPlanPurch.MESSAGE_TYPE,
  		MESSAGE_ID: firmPlanPurch.MESSAGE_ID,
  		SENDER: firmPlanPurch.SENDER,
		ITEM: planArriv.ITEM,
		DEST: planArriv.DEST,
		(vars.deleteudc): 'Y'   
}