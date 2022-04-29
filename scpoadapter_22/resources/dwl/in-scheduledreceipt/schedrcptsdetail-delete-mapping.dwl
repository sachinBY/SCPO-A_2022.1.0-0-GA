%dw 2.0
output application/json
---
 (payload map (schedReceiptDetail, index) -> {
 	MS_BULK_REF: schedReceiptDetail.MS_BULK_REF,
	MS_REF: schedReceiptDetail.MS_REF,
	INTEGRATION_STAMP: schedReceiptDetail.INTEGRATION_STAMP,
	MESSAGE_TYPE: schedReceiptDetail.MESSAGE_TYPE,
  	MESSAGE_ID: schedReceiptDetail.MESSAGE_ID,
  	SENDER: schedReceiptDetail.SENDER,
  	EXPDATE: schedReceiptDetail.EXPDATE,
	ITEM: schedReceiptDetail.ITEM,
	LOC: schedReceiptDetail.LOC,
	SCHEDDATE: schedReceiptDetail.SCHEDDATE,
	SEQNUM: schedReceiptDetail.SEQNUM,
	STARTDATE: schedReceiptDetail.STARTDATE,
	STEPNUM: schedReceiptDetail.STEPNUM,
	(vars.deleteudc): 'Y'
  })