%dw 2.0
output application/java  
---
(payload map (tranmodeeqp, indexOftransmodeeqp) -> {
	MS_BULK_REF: tranmodeeqp.MS_BULK_REF,
	MS_REF: tranmodeeqp.MS_REF,
	INTEGRATION_STAMP: tranmodeeqp.INTEGRATION_STAMP,
	MESSAGE_TYPE: tranmodeeqp.MESSAGE_TYPE,
  	MESSAGE_ID: tranmodeeqp.MESSAGE_ID,
  	SENDER: tranmodeeqp.SENDER,
    (TRANSMODE: tranmodeeqp.TRANSMODE) if not tranmodeeqp.TRANSMODE == null,
    (vars.deleteudc): 'Y'
 })