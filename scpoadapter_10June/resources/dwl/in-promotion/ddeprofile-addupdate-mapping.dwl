%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"

---
(payload map (promotion, promotionIndex) -> {
			MS_BULK_REF: promotion.MS_BULK_REF,
			MS_REF: promotion.MS_REF,		
		    INTEGRATION_STAMP: promotion.INTEGRATION_STAMP,
		    MESSAGE_TYPE: promotion.MESSAGE_TYPE,
  			MESSAGE_ID: promotion.MESSAGE_ID,
  			SENDER: promotion.SENDER,
			DESCR:  promotion.DESCR,
			DMDCAL:  promotion.DMDCAL,
			DMDGROUP:  promotion.DMDGROUP,
			DMDUNIT:  promotion.DMDUNIT,				  		
			LOC: promotion.LOC,
			MODEL:  promotion.MODEL,	
			STARTDATE:  promotion.STARTDATE,
		    (promotion.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
			(promotion.PromotionUDC default [] map {
		      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
									else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
									else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
									else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
									else $.UDCValue) if ($ != null and $.UDCName != null)
		    })
	   
})
