%dw 2.0
output application/java 
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")

---
(payload map (planArriv, indexOfplanArriv) -> {
		MS_BULK_REF: planArriv.MS_BULK_REF,
		MS_REF: planArriv.MS_REF,
        INTEGRATION_STAMP: planArriv.INTEGRATION_STAMP,
        MESSAGE_TYPE: planArriv.MESSAGE_TYPE,
  		MESSAGE_ID: planArriv.MESSAGE_ID,
  		SENDER: planArriv.SENDER,
		ITEM: planArriv.ITEM,
		DEST: planArriv.DEST,
		SEQNUM: planArriv.SEQNUM,
		NEEDARRIVDATE: if (planArriv.NEEDARRIVDATE != null and funCaller.formatGS1ToSCPO(planArriv.NEEDARRIVDATE) != default_value) planArriv.NEEDARRIVDATE as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
		SCHEDARRIVDATE: if (planArriv.SCHEDARRIVDATE != null and funCaller.formatGS1ToSCPO(planArriv.SCHEDARRIVDATE) != default_value) planArriv.SCHEDARRIVDATE as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
		NEEDSHIPDATE: if (planArriv.NEEDSHIPDATE != null and funCaller.formatGS1ToSCPO(planArriv.NEEDSHIPDATE) != default_value) planArriv.NEEDSHIPDATE as Date {class : "java.sql.Date"} else default_value,
		SCHEDSHIPDATE: if (planArriv.SCHEDSHIPDATE != null and funCaller.formatGS1ToSCPO(planArriv.SCHEDSHIPDATE) != default_value) planArriv.SCHEDSHIPDATE as Date {class : "java.sql.Date"} else default_value,
		
		QTY: if (planArriv.QTY != null) planArriv.QTY else default_value,
		SOURCE: if (planArriv.SOURCE != null) planArriv.SOURCE else default_value,
		SOURCING: if (planArriv.SOURCING != null) planArriv.SOURCING else default_value,
		TRANSMODE: if (planArriv.TRANSMODE != null) planArriv.TRANSMODE else default_value,
		
	    (planArriv.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(planArriv.PlanArrivUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
   
})