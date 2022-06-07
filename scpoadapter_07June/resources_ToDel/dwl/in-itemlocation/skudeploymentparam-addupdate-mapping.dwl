%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var skuDeploymentParamEntity = vars.entityMap.sku[0].skudeploymentparam[0]
---
(payload map (sdp, indexOfsdp) -> {
		MS_BULK_REF: sdp.MS_BULK_REF,
		MS_REF: sdp.MS_REF,	
		INTEGRATION_STAMP: sdp.INTEGRATION_STAMP,
		MESSAGE_TYPE: sdp.MESSAGE_TYPE,
  		MESSAGE_ID: sdp.MESSAGE_ID,
  		SENDER: sdp.SENDER,
	    ITEM: if (sdp.ITEM != null) sdp.ITEM else default_value,
	    LOC: if (sdp.LOC != null) sdp.LOC else default_value,
	    INITSTKOUTCOST: if (sdp.INITSTKOUTCOST != null) sdp.INITSTKOUTCOST else default_value,
	    SURPLUSRESTOCKCOST: if (sdp.SURPLUSRESTOCKCOST != null) sdp.SURPLUSRESTOCKCOST else default_value,
	    (sdp.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(sdp.SkuDeploymentParamUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    })
   
  })