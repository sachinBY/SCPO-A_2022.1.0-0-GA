%dw 2.0
output application/java  
---
 (payload map (dfuTosku, indexOfdfuTosku) -> {
 		MS_BULK_REF: dfuTosku.MS_BULK_REF,
    	MS_REF: dfuTosku.MS_REF,    
 		INTEGRATION_STAMP: dfuTosku.INTEGRATION_STAMP,
 		MESSAGE_TYPE: dfuTosku.MESSAGE_TYPE,
  		MESSAGE_ID: dfuTosku.MESSAGE_ID,
  		SENDER: dfuTosku.SENDER,
    	(DMDUNIT: dfuTosku.DMDUNIT) if (dfuTosku.DMDUNIT != null),
	    (DMDGROUP: dfuTosku.DMDGROUP) if (dfuTosku.DMDGROUP != null),
	    (DFULOC:  dfuTosku.DFULOC) if (dfuTosku.DFULOC != null),
	     MODEL: dfuTosku.MODEL,
	    (DISC: dfuTosku.DISC) if (dfuTosku.DISC != null),
	    (EFF: dfuTosku.EFF) if (dfuTosku.EFF != null),
	    (ITEM: dfuTosku.ITEM) if (dfuTosku.ITEM != null),
	    (SKULOC: dfuTosku.SKULOC) if (dfuTosku.SKULOC != null),
	    (vars.deleteudc): 'Y'
  })