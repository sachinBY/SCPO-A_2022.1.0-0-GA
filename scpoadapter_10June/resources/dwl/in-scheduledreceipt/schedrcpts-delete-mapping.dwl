%dw 2.0
output application/json
---
 (payload map (schedReceipt, index) -> {
 	MS_BULK_REF: schedReceipt.MS_BULK_REF,
	MS_REF: schedReceipt.MS_REF,
 	INTEGRATION_STAMP: schedReceipt.INTEGRATION_STAMP,
	MESSAGE_TYPE: schedReceipt.MESSAGE_TYPE,
  	MESSAGE_ID: schedReceipt.MESSAGE_ID,
  	SENDER: schedReceipt.SENDER,
  	EXPDATE: schedReceipt.EXPDATE,
	ITEM: schedReceipt.ITEM,
	LOC: schedReceipt.LOC,
	SCHEDDATE: schedReceipt.SCHEDDATE,
	SEQNUM: schedReceipt.SEQNUM,
	STARTDATE: schedReceipt.STARTDATE,
	(vars.deleteudc): 'Y'
  })