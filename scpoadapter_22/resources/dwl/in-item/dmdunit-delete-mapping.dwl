%dw 2.0
output application/java  
ns ns0 urn:jda:master:demand_unit:xsd:3
---
 (payload map (dmdunit, indexOfdmdunit) -> {
 	MS_BULK_REF: dmdunit.MS_BULK_REF,
	MS_REF: dmdunit.MS_REF,
	INTEGRATION_STAMP: dmdunit.INTEGRATION_STAMP,
	MESSAGE_TYPE: dmdunit.MESSAGE_TYPE,
	MESSAGE_ID: dmdunit.MESSAGE_ID,
	SENDER: dmdunit.SENDER,
    (DMDUNIT: dmdunit.DMDUNIT) if not dmdunit.DMDUNIT == null,
    (vars.deleteudc): 'Y'
  })