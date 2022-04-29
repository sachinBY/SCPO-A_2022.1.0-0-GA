%dw 2.0
output application/java 
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")

---
(payload map (firmPlanPurch, indexOfFirmPlanPurch) -> {
		MS_BULK_REF: firmPlanPurch.MS_BULK_REF,
	  	MS_REF: firmPlanPurch.MS_REF,
	    INTEGRATION_STAMP: firmPlanPurch.INTEGRATION_STAMP,
	    MESSAGE_TYPE: firmPlanPurch.MESSAGE_TYPE,
  		MESSAGE_ID: firmPlanPurch.MESSAGE_ID,
  		SENDER: firmPlanPurch.SENDER,
	    SEQNUM: firmPlanPurch.SEQNUM,
		ITEM: if (firmPlanPurch.ITEM != null) firmPlanPurch.ITEM else default_value,
		LOC: if (firmPlanPurch.LOC != null) firmPlanPurch.LOC else default_value,
		QTY: if (firmPlanPurch.QTY != null) firmPlanPurch.QTY else default_value,
		NEEDDATE: if (firmPlanPurch.NEEDDATE != null and funCaller.formatGS1ToSCPO(firmPlanPurch.NEEDDATE) != default_value) firmPlanPurch.NEEDDATE as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
		FIRMPLANSW: if (firmPlanPurch.FIRMPLANSW != null) firmPlanPurch.FIRMPLANSW else default_value,
	    (firmPlanPurch.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(firmPlanPurch.PlanPurchUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
   
})