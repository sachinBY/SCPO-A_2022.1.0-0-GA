%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")

---
 (payload map (order, indexOfOrder) -> {
 		MS_BULK_REF: order.MS_BULK_REF,
	  	MS_REF: order.MS_REF,				
		INTEGRATION_STAMP: order.INTEGRATION_STAMP,
		MESSAGE_TYPE: order.MESSAGE_TYPE,
  		MESSAGE_ID: order.MESSAGE_ID,
  		SENDER: order.SENDER,
	  	ORDERNUM: if (order.ORDERNUM !=null) order.ORDERNUM else default_value,
	    LINENUM: if (order.LINENUM !=null) order.LINENUM else default_value,
	    DUEDATE: if (order.DUEDATE !=null and order.DUEDATE != default_value and funCaller.formatGS1ToSCPO(order.DUEDATE[0 to 9]) != default_value) order.DUEDATE[0 to 9] as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
	    EXPDATE: if (order.EXPDATE !=null and order.EXPDATE != default_value and funCaller.formatGS1ToSCPO(order.EXPDATE[0 to 9]) != default_value) order.EXPDATE[0 to 9] as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
	    ITEM: if (order.ITEM !=null) order.ITEM else default_value,
	    LOC: if (order.LOC !=null) order.LOC else default_value,
	    QTY: if (order.QTY !=null) order.QTY else default_value,
	    PROJECT: if (order.PROJECT !=null) order.PROJECT else default_value,
	    PURCHMETHOD: if (order.PURCHMETHOD !=null) order.PURCHMETHOD else default_value,
	    
		(order.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if($ != null and $.scpoColumnName != null)
			}),
		(order.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if($ != null and $.UDCName != null)
	    	})
	
})