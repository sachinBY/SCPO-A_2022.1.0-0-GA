%dw 2.0
output application/java 
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
---
(payload map (purchMethod, indexOfPurchMethod) -> {
			MS_BULK_REF: purchMethod.MS_BULK_REF,
			MS_REF: purchMethod.MS_REF,	
	   
		    INTEGRATION_STAMP: purchMethod.INTEGRATION_STAMP,
		    MESSAGE_TYPE: purchMethod.MESSAGE_TYPE,
  			MESSAGE_ID: purchMethod.MESSAGE_ID,
  			SENDER: purchMethod.SENDER,
		    INCORDERQTY: if (purchMethod.INCORDERQTY != null) purchMethod.INCORDERQTY else default_value,
			ITEM: if (purchMethod.ITEM != null) purchMethod.ITEM else default_value,
			LEADTIME: if (purchMethod.LEADTIME != null) purchMethod.LEADTIME else default_value,
			MAXORDERQTY: if (purchMethod.MAXORDERQTY != null) purchMethod.MAXORDERQTY else default_value,
			MINORDERQTY: if (purchMethod.MINORDERQTY != null) purchMethod.MINORDERQTY else default_value,
			PURCHMETHOD: if (purchMethod.PURCHMETHOD != null) purchMethod.PURCHMETHOD else default_value,
			ABBR: if (purchMethod.ABBR != null) purchMethod.ABBR else default_value,
			LOC: if (purchMethod.LOC != null) purchMethod.LOC else default_value,
			EFF: if (purchMethod.EFF != null and funCaller.formatGS1ToSCPO(purchMethod.EFF) != default_value) purchMethod.EFF as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
			DISC: if (purchMethod.DISC != null and funCaller.formatGS1ToSCPO(purchMethod.DISC) != default_value) purchMethod.DISC as Date {format: "yyyy-MM-dd", class : "java.sql.Date"} else default_value,
			PRIORITY: if (purchMethod.PRIORITY != null) purchMethod.PRIORITY else default_value,
			FACTOR: if (purchMethod.FACTOR != null) purchMethod.FACTOR else default_value,
			PURCHCOST: if (purchMethod.PURCHCOST != null) purchMethod.PURCHCOST else default_value,
			EXPEDITECOST: if (purchMethod.EXPEDITECOST != null) purchMethod.EXPEDITECOST else default_value,
			AVGCOST: if (purchMethod.AVGCOST != null) purchMethod.AVGCOST else default_value,
			PURCHGROUP: if (purchMethod.PURCHGROUP != null) purchMethod.PURCHGROUP else default_value,
			AVAILQTY: if (purchMethod.AVAILQTY != null) purchMethod.AVAILQTY else default_value,
			NONEWSUPPLYDATE: if (purchMethod.NONEWSUPPLYDATE != null) purchMethod.NONEWSUPPLYDATE else default_value,
			(purchMethod.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
			(purchMethod.PurchMethodUDC default [] map {
		      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
									else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
									else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
									else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
									else $.UDCValue) if ($ != null and $.UDCName != null)
		    	})
		   
})