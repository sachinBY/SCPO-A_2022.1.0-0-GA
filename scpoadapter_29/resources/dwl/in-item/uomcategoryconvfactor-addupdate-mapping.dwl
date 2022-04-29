%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var itemUomCatConvFactorEntity = vars.entityMap.item[0].uomcategoryconvfactor[0]
var itemUomCatConvFactorCol = vars.entityMap.item[0].uomcategoryconvfactor[0] groupBy $.scpoColumnName orderBy ($$) pluck ($$)
var entityMap = if (itemUomCatConvFactorEntity != null) unzip((itemUomCatConvFactorEntity map (v,k)->{(payload.data map {((v.scpoColumnName) : if ($[v.scpoColumnName] !=null) true else false)})})) else []
---
 payload map {
 			MS_BULK_REF: $.MS_BULK_REF,
			MS_REF: $.MS_REF, 
 			INTEGRATION_STAMP: $.INTEGRATION_STAMP,
 			MESSAGE_TYPE: $.MESSAGE_TYPE,
 			MESSAGE_ID: $.MESSAGE_ID,
 			SENDER: $.SENDER,
			ITEM: $.ITEM,
			RATIO: $.RATIO,
			SOURCECATEGORY: $.SOURCECATEGORY,
			SOURCEUOM: $.SOURCEUOM,
			TARGETCATEGORY: $.TARGETCATEGORY,
			TARGETUOM: $.TARGETUOM,
			//($ mapObject (value, key)->{
				//((key) :  value) if (itemUomCatConvFactorEntity[(key)][0] !=null)
			//}),
			//(entityMap[$$] map(v,k)-> {
				//((itemUomCatConvFactorCol[(k)]) : default_value) if (v ~= false)
			//})	
			($.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})	
}