%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")

---
(payload map (productionStep, indexofproductionStep) -> {
	    MS_BULK_REF: productionStep.MS_BULK_REF,
		MS_REF: productionStep.MS_REF,
        INTEGRATION_STAMP: productionStep.INTEGRATION_STAMP,
        MESSAGE_TYPE: productionStep.MESSAGE_TYPE,
  		MESSAGE_ID: productionStep.MESSAGE_ID,
  		SENDER: productionStep.SENDER,
		STEPNUM:  productionStep.STEPNUM,
		RES:  productionStep.RES, 
		EFF:  productionStep.EFF,
		PRODRATE:  productionStep.PRODRATE ,
		FIXEDRESREQ: productionStep.FIXEDRESREQ , 
		DESCR:  productionStep.DESCR ,
		NEXTSTEPTIMING: productionStep.NEXTSTEPTIMING , 
		PRODCOST:  productionStep.PRODCOST ,
		PRODDUR: productionStep.PRODDUR , 
		LOADOFFSETDUR: productionStep.LOADOFFSETDUR, 
		PRODRATECAL:   productionStep.PRODRATECAL ,
		PRODFAMILY:  productionStep.PRODFAMILY , 
		PRODUCTIONMETHOD:  productionStep.PRODUCTIONMETHOD , 
		ITEM:  productionStep.ITEM ,
		LOC:  productionStep.LOC ,
		PRODOFFSET: productionStep.PRODOFFSET,
		(productionStep.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if($ != null and $.scpoColumnName != null)
			}),
		(productionStep.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})    
   
})