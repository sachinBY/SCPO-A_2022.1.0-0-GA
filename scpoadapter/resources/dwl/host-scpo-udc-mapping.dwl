%dw 2.0
var default_value = "###JDA_DEFAULT_VALUE###"
fun mapHostToSCPO(packet, pathArray, index) =
  if ((sizeOf(pathArray)) == (index + 1))
    packet."$(pathArray[index])"
  else
    mapHostToSCPO(packet."$(pathArray[index])", pathArray, (index + 1))

//fun getAvpListMap(avpList) = {(avpList.*eComStringAttributeValuePairList map {
//	($.@attributeName) : $
//})}
fun getAvpListMap(avpList) = {(avpList map {
    (($.name) : $.value) if (!isEmpty($))
})}

fun getUdcNameAndValue(entityList, avpList, avpMap) = ([
	entityList map (value , index) -> {
  	    UDCName : value.scpoColumnName,
  	    UDCValue: avpMap[value.hostColumnName],
  	    isPK: value.isPK,
		dataType: value.dataType  	    
  	 }	
])

fun getDefaultNameAndValue(entityList) = ([
	entityList map (value , index) -> {
  	    UDCName : value.scpoColumnName,
  	    UDCValue: null,
  	    isPK: value.isPK,
		dataType: value.dataType  	    
  	 }	
])
fun getUdcMap(udcList) = {(udcList map {
	($.UDCName) : $
})}
fun getUdcList(udcList, udcMap) = ([
	udcList map (value , index) -> {
  	    UDCName : value.UDCName,
  	    UDCValue: if(value.UDCValue == null) udcMap[value.UDCName].UDCValue else value.UDCValue,
  	    isPK: value.isPK,
		dataType: value.dataType  	    
  	 }	
])
fun transformAvpListToUdcs(entityList, avpList, avpMap) = (
	entityList map ({
  	    UDCName : $.scpoColumnName,
  	    UDCValue: avpMap[$.hostColumnName],
  	    isPK: $.isPK,
		dataType: $.dataType  	    
  	 }) map ({
		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
						else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
						else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
						else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
						else $.UDCValue) if ($ != null and $.UDCName != null)
	})
)
fun eval(value , dataType) = if(value == null) ''
							else if(dataType == 'DATE') value as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
							else if(dataType == 'DATETIME') value as DateTime as String
							else if(dataType == 'NUMBER' or dataType == 'FLOAT' or dataType == 'INTEGER') value as Number
							else value
---
{
  mapHostToSCPO: mapHostToSCPO,
  getUdcNameAndValue:getUdcNameAndValue,
  getAvpListMap:getAvpListMap,
  getUdcMap:getUdcMap,
  getUdcList:getUdcList,
  getDefaultNameAndValue:getDefaultNameAndValue,
  transformAvpListToUdcs: transformAvpListToUdcs,
  eval: eval
}