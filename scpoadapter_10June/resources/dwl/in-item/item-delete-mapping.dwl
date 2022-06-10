%dw 2.0
output application/java  
---
(payload map (item, indexOfItem) -> {
	MS_BULK_REF: item.MS_BULK_REF,
	MS_REF: item.MS_REF, 
	INTEGRATION_STAMP: item.INTEGRATION_STAMP,
	MESSAGE_TYPE: item.MESSAGE_TYPE,
 	MESSAGE_ID: item.MESSAGE_ID,
 	SENDER: item.SENDER,
    (DEFAULTUOM: item.DEFAULTUOM) if not item.DEFAULTUOM == null,
    (DESCR: item.DESCR) if not item.DESCR == null,
    (DISCRETESW: item.DISCRETESW) if not item.DISCRETESW == null,
    (ITEM: item.ITEM) if not item.ITEM == null,
    (ITEMCLASS: item.ITEMCLASS) if not item.ITEMCLASS == null,
    (PERISHABLESW: item.PERISHABLESW) if not item.PERISHABLESW == null,
    (PRIORITY: item.PRIORITY) if not item.PRIORITY == null,
    (STORAGEGROUP: item.STORAGEGROUP) if not item.STORAGEGROUP == null,
    (UNITSPERPALLET: item.UNITSPERPALLET) if not item.UNITSPERPALLET == null,
    (UOM: item.UOM) if not item.UOM == null,
    (VOL: item.VOL) if not item.VOL == null,
    (item.ItemUDC default [] map {
      (($.UDCName)) : $.UDCValue
    }),
    (vars.deleteudc): 'Y'
  })