%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
---
 (payload map (supporder, indexOfSuppOrder) -> {
 		MS_BULK_REF: supporder.MS_BULK_REF,
		MS_REF: supporder.MS_REF,
 		INTEGRATION_STAMP: supporder.INTEGRATION_STAMP,
 		MESSAGE_TYPE: supporder.MESSAGE_TYPE,
    	MESSAGE_ID: supporder.MESSAGE_ID,
  		SENDER: supporder.SENDER,
	  	ITEM: if(supporder.ITEM != null) supporder.ITEM else default_value,
		LOC: if(supporder.LOC != null) supporder.LOC else default_value,
		SUPPORDERID: if(supporder.SUPPORDERID != null) supporder.SUPPORDERID else default_value,
		NEEDARRIVDATE: if (supporder.NEEDARRIVDATE != null and funCaller.formatGS1ToSCPO(supporder.NEEDARRIVDATE) != default_value) supporder.NEEDARRIVDATE else default_value,
		NEEDQTY: if(supporder.NEEDQTY != null) supporder.NEEDQTY else default_value,
		HOLDOUTRELEASESTART: if (supporder.HOLDOUTRELEASESTART != null and funCaller.formatGS1ToSCPO(supporder.HOLDOUTRELEASESTART) != default_value) supporder.HOLDOUTRELEASESTART else default_value,
		GROUPTYPE: if (supporder.GROUPTYPE != null) supporder.GROUPTYPE else default_value,
	    TYPE: if (supporder.TYPE != null) supporder.TYPE else default_value,
	    STATUS: if (supporder.STATUS != null) supporder.STATUS else default_value,
	    PRIORITY: if (supporder.PRIORITY != null) supporder.PRIORITY else default_value,
		EXTRALOADDUR: if (supporder.EXTRALOADDUR != null) supporder.EXTRALOADDUR else default_value,
		(supporder.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(supporder.SuppOrderUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    })
   
  })