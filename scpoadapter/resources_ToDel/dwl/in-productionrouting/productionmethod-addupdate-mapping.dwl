%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var productionMethodEntity = vars.entityMap.productionrouting[0].productionmethod[0]
---
(payload map (productionMethod,indexofproductionMethod) -> {
		MS_BULK_REF: productionMethod.MS_BULK_REF,
		MS_REF: productionMethod.MS_REF,
	    INTEGRATION_STAMP: productionMethod.INTEGRATION_STAMP,
	    MESSAGE_TYPE: productionMethod.MESSAGE_TYPE,
  		MESSAGE_ID: productionMethod.MESSAGE_ID,
  		SENDER: productionMethod.SENDER,
		PRODUCTIONMETHOD :   productionMethod.PRODUCTIONMETHOD ,
		ITEM:  productionMethod.ITEM ,
		LOC: productionMethod.LOC , 
		BOMNUM:  productionMethod.BOMNUM ,
		INCQTY :  productionMethod.INCQTY ,
		MAXQTY:   productionMethod.MAXQTY ,
		MINQTY :   productionMethod.MINQTY ,
		NONEWSUPPLYDATE:  productionMethod.NONEWSUPPLYDATE,
		PRIORITY:   productionMethod.PRIORITY,
		SPLITFACTOR:   productionMethod.SPLITFACTOR ,
		DISC:   productionMethod.DISC,
		EFF:   productionMethod.EFF,
		EXPEDITECOST:   productionMethod.EXPEDITECOST ,
		CAMPAIGNMINQTY:  productionMethod.CAMPAIGNMINQTY ,
		CAMPAIGNPRIORITY:  productionMethod.CAMPAIGNPRIORITY ,
		DESCR:  productionMethod.DESCR ,
		FINISHCAL:  productionMethod.FINISHCAL ,
		LEADTIME:  productionMethod.LEADTIME ,
		LEADTIMEEFFCNCYCAL:   productionMethod.LEADTIMEEFFCNCYCAL ,
		OFFSETTYPE:  productionMethod.OFFSETTYPE ,
		PRODCOST:   productionMethod.PRODCOST ,
		PRODFAMILY:   productionMethod.PRODFAMILY,
		(productionMethod.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") ($.scpoColumnValue replace 'Z' with ('')) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(productionMethod.ProductionMethodUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") ($.UDCValue replace 'Z' with ('')) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})	    
   
})