%dw 2.0
output application/java  
---
 (payload map (order, orderseqNum) -> {
 	MS_BULK_REF: order.MS_BULK_REF,
	MS_REF: order.MS_REF,	
 	INTEGRATION_STAMP: order.INTEGRATION_STAMP,
 	MESSAGE_TYPE: order.MESSAGE_TYPE,
  	MESSAGE_ID: order.MESSAGE_ID,
  	SENDER: order.SENDER,
    ORDERNUM: order.ORDERNUM,
    LINENUM: order.LINENUM,
    (vars.deleteudc): 'Y'
  })