%dw 2.0
output application/java
---
(payload map (uom, indexOfUom) -> {
	MS_BULK_REF: uom.MS_BULK_REF,
	MS_REF: uom.MS_REF,
	INTEGRATION_STAMP: uom.INTEGRATION_STAMP,
	MESSAGE_TYPE: uom.MESSAGE_TYPE,
  	MESSAGE_ID: uom.MESSAGE_ID,
  	SENDER: uom.SENDER,
	UOM: uom.UOM,
	(vars.deleteudc): 'Y' 
})
