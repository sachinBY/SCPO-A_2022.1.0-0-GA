%dw 2.0
output application/java
---
(payload map (uomCategory, indexOfUomCategory) -> {
	MS_BULK_REF: uomCategory.MS_BULK_REF,
	MS_REF: uomCategory.MS_REF,
	INTEGRATION_STAMP: uomCategory.INTEGRATION_STAMP,
	MESSAGE_TYPE: uomCategory.MESSAGE_TYPE,
  	MESSAGE_ID: uomCategory.MESSAGE_ID,
  	SENDER: uomCategory.SENDER,
	CATEGORY: uomCategory.CATEGORY,
	(vars.deleteudc): 'Y' 
})
