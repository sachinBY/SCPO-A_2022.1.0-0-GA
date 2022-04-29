%dw 2.0
output application/java
---
 (flatten(payload) map (sku, indexOfsku) -> {
 	MS_BULK_REF: sku.MS_BULK_REF,
	MS_REF: sku.MS_REF,
 	INTEGRATION_STAMP: sku.INTEGRATION_STAMP,
 	MESSAGE_TYPE: sku.MESSAGE_TYPE,
  	MESSAGE_ID: sku.MESSAGE_ID,
  	SENDER: sku.SENDER,
    (ITEM: sku.ITEM) if not sku.ITEM == null,
    (SKULOC: sku.SKULOC) if not sku.SKULOC == null,
	(DMDGROUP: sku.DMDGROUP) if not sku.DMDGROUP == null,
	(vars.deleteudc): 'Y'
  })