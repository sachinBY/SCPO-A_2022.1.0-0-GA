%dw 2.0
output application/java
---
 (payload map (suppOrder, indexOfsku) -> {
 	MS_BULK_REF: suppOrder.MS_BULK_REF,
	MS_REF: suppOrder.MS_REF,
 	INTEGRATION_STAMP: suppOrder.INTEGRATION_STAMP,
 	MESSAGE_TYPE: suppOrder.MESSAGE_TYPE,
    MESSAGE_ID: suppOrder.MESSAGE_ID,
  	SENDER: suppOrder.SENDER,
    (ITEM: suppOrder.ITEM) if not suppOrder.ITEM == null,
    (LOC: suppOrder.LOC) if not suppOrder.LOC == null,
    (vars.deleteudc): 'Y'
  })