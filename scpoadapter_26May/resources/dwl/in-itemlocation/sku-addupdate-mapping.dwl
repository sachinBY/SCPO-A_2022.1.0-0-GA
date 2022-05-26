%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var skuEntity = vars.entityMap.sku[0].sku[0]
---
 (payload map (sku, indexOfsku) -> {
 		MS_BULK_REF: sku.MS_BULK_REF,
		MS_REF: sku.MS_REF,	
		INTEGRATION_STAMP: sku.INTEGRATION_STAMP,
		MESSAGE_TYPE: sku.MESSAGE_TYPE,
  		MESSAGE_ID: sku.MESSAGE_ID,
  		SENDER: sku.SENDER,
	  	CREATIONDATE: if (sku.CREATIONDATE != null and funCaller.formatGS1ToSCPO(sku.CREATIONDATE) != default_value) sku.CREATIONDATE else default_value,
	  	ENABLEOPT: if(sku.ENABLEOPT != null) sku.ENABLEOPT else default_value,
		INFINITESUPPLYSW: if(sku.INFINITESUPPLYSW != null) sku.INFINITESUPPLYSW else default_value,
		REPLENMETHOD: if(sku.REPLENMETHOD != null) sku.REPLENMETHOD else default_value,
		REPLENTYPE: if(sku.REPLENTYPE != null) sku.REPLENTYPE else default_value,
	    ITEM: if (sku.ITEM != null) sku.ITEM else default_value,
	    LOC: if (sku.LOC != null) sku.LOC else default_value,
	    OH: if (sku.OH != null) sku.OH else default_value,
	    OHPOST: if (sku.OHPOST != null and funCaller.formatGS1ToSCPO(sku.OHPOST) != default_value) sku.OHPOST else default_value,
		(sku.udcs map {
			(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(sku.SkuUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    })
   
  })