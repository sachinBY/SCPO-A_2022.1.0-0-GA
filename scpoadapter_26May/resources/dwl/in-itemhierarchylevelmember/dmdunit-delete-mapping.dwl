%dw 2.0
output application/java  
---
 (payload map (dmdunit, indexOfdmdunit) -> {
 	MS_BULK_REF: dmdunit.MS_BULK_REF,
	MS_REF: dmdunit.MS_REF,
	INTEGRATION_STAMP: dmdunit.INTEGRATION_STAMP,
	MESSAGE_TYPE: dmdunit.MESSAGE_TYPE,
  	MESSAGE_ID: dmdunit.MESSAGE_ID,
  	SENDER: dmdunit.SENDER,
    (DMDUNIT: dmdunit.DMDUNIT) if not dmdunit.DMDUNIT == null,
    (DESCR: dmdunit.DESCR) if not dmdunit.DESCR == null,
    (HIERARCHYLEVEL: dmdunit.HIERARCHYLEVEL) if not dmdunit.HIERARCHYLEVEL == null,
    (vars.deleteudc): 'Y'
  })