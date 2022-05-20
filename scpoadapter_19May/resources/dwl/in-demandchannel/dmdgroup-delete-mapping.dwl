%dw 2.0
output application/java  
---
(payload map (dmdgroup, indexOfDmdgroup) -> {
	MS_BULK_REF: dmdgroup.MS_BULK_REF,
	MS_REF: dmdgroup.MS_REF,
	INTEGRATION_STAMP: dmdgroup.INTEGRATION_STAMP,
	MESSAGE_TYPE: dmdgroup.MESSAGE_TYPE,
	MESSAGE_ID: dmdgroup.MESSAGE_ID,
	SENDER: dmdgroup.SENDER,
    DMDGROUP: dmdgroup.DMDGROUP,
    (vars.deleteudc): 'Y'
  })