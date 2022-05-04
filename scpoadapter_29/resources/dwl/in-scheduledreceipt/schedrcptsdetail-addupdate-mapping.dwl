%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"  
var scheduledReceiptDetailEntity = vars.entityMap.schedrcpts[0].schedrcptsdetail[0]	
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
		QTYINMOVE: schedReceiptDetail.QTYINMOVE,
		QTYINQUEUE: schedReceiptDetail.QTYINQUEUE,
		QTYINRUN: schedReceiptDetail.QTYINRUN,
		SCHEDDATE: schedReceiptDetail.SCHEDDATE,
		SEQNUM: schedReceiptDetail.SEQNUM,
		STARTDATE: schedReceiptDetail.STARTDATE,
		STEPNUM: schedReceiptDetail.STEPNUM,
		STEPSCHEDDATE: schedReceiptDetail.STEPSCHEDDATE,
		STEPSTARTDATE: schedReceiptDetail.STEPSTARTDATE,
	    (schedReceiptDetail.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(schedReceiptDetail.ScheduledReceiptDetailUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
   
  })