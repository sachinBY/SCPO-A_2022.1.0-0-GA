%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"  
var scheduledReceiptEntity = vars.entityMap.schedrcpts[0].schedrcpts[0]	
---
 (payload map (schedReceipt, index) -> {
 		MS_BULK_REF: schedReceipt.MS_BULK_REF,
		MS_REF: schedReceipt.MS_REF,	
		
 		INTEGRATION_STAMP: schedReceipt.INTEGRATION_STAMP,
 		MESSAGE_TYPE: schedReceipt.MESSAGE_TYPE,
  		MESSAGE_ID: schedReceipt.MESSAGE_ID,
  		SENDER: schedReceipt.SENDER,
		ACTIONALLOWEDSW:schedReceipt.ACTIONALLOWEDSW,
	  	EXPDATE: schedReceipt.EXPDATE,
		EXPLODESW: if(schedReceipt.EXPLODESW == "true") 1 else if (schedReceipt.EXPLODESW == "false") 0 else schedReceipt.EXPLODESW,
		ITEM: schedReceipt.ITEM,
		LASTCOMPLETEDSTEP: schedReceipt.LASTCOMPLETEDSTEP,
		LOC: schedReceipt.LOC,
		PCTCOMPLETE: schedReceipt.PCTCOMPLETE,
		PRIORITY: schedReceipt.PRIORITY,
		PRODUCTIONMETHOD: schedReceipt.PRODUCTIONMETHOD,
		PROJECT: schedReceipt.PROJECT,
		QTY: schedReceipt.QTY,
		QTYRECEIVED: schedReceipt.QTYRECEIVED,
		SCHEDDATE: schedReceipt.SCHEDDATE,
		SEQNUM: schedReceipt.SEQNUM,
		STARTDATE: schedReceipt.STARTDATE,
	    (schedReceipt.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(schedReceipt.ScheduledReceiptUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
   
  })