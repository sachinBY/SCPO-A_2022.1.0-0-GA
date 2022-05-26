%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
---
 (flatten(payload) map (skuDmdGroup, indexOfsku) -> {
 		MS_BULK_REF: skuDmdGroup.MS_BULK_REF,
		MS_REF: skuDmdGroup.MS_REF,
 		INTEGRATION_STAMP: skuDmdGroup.INTEGRATION_STAMP,
 		MESSAGE_TYPE: skuDmdGroup.MESSAGE_TYPE,
  		MESSAGE_ID: skuDmdGroup.MESSAGE_ID,
  		SENDER: skuDmdGroup.SENDER,
	  	DMDCAL: skuDmdGroup.DMDCAL ,
		DMDGROUP: skuDmdGroup.DMDGROUP ,
		DMDPOSTDATE: skuDmdGroup.DMDPOSTDATE ,
		ERRORPERIOD: skuDmdGroup.ERRORPERIOD ,
	    ITEM: skuDmdGroup.ITEM ,
	    SKULOC:skuDmdGroup.SKULOC ,
	    FCSTLAG: skuDmdGroup.FCSTLAG ,
	    GROUPNAME: skuDmdGroup.GROUPNAME ,
	   
	    
	    HIGHERBUCKETDMDCAL: skuDmdGroup.HIGHERBUCKETDMDCAL ,
		MINOLTDUR:skuDmdGroup.MINOLTDUR as Number ,
		MAXOLTDUR:skuDmdGroup.MAXOLTDUR as Number ,
		OLTPROFILEID:skuDmdGroup.OLTPROFILEID,
	    
	    
		(skuDmdGroup.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(skuDmdGroup.SkuDmdParamUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    })
   
  })