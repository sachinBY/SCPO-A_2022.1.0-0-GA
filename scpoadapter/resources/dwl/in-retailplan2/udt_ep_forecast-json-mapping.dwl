%dw 2.0
var default_value = "###JDA_DEFAULT_VALUE###"
var retailplanEntity = vars.entityMap.retailplan2[0].'udt_ep_forecast'[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
import * from dw::Runtime
output application/java
---
(flatten(flatten(payload.retailPlan2 map (retailplan2,retailplan2index) -> { 
	
		 measure: if(not isEmpty(retailplan2.measure))
		 retailplan2.measure map(measure,measureindex) ->
    {
	    CHANNEL: if(not isEmpty(retailplan2.locationId)) retailplan2.locationId else default_value,
		DMDGROUP: "LDE",
		DUR : default_value,
		MEASURE: if(not isEmpty(measure.name)) measure.name else null,
		QTY: if(not isEmpty(measure.value)) measure.value as Number else default_value,
		(FORECASTUDC: (lib.getUdcNameAndValue(retailplanEntity, retailplan2.avpList, lib.getAvpListMap(retailplan2.avpList))[0])
	 	)  if (retailplan2.avpList != null and retailplanEntity != null) ,
	 	STARTDATE: retailplan2.timeId as LocalDateTime,
		SUBCAT:  if(not isEmpty(retailplan2.itemId)) retailplan2.itemId else default_value,
		ACTIONCODE: retailplan2.documentActionCode default "CHANGE_BY_REFRESH"
		
	}
	
  else {
  	    CHANNEL: if(not isEmpty(retailplan2.locationId)) retailplan2.locationId else default_value,
		DMDGROUP: "LDE",
		DUR : default_value,
		QTY:  default_value,
		(FORECASTUDC: (lib.getUdcNameAndValue(retailplanEntity, retailplan2.avpList, lib.getAvpListMap(retailplan2.avpList))[0])
	 	)  if (retailplan2.avpList != null and retailplanEntity != null) ,
	 	STARTDATE: retailplan2.timeId as LocalDateTime,
		SUBCAT:  if(not isEmpty(retailplan2.itemId)) retailplan2.itemId else default_value,
		ACTIONCODE: if (not isEmpty(retailplan2.documentActionCode)) retailplan2.documentActionCode else if (vars.bulknotificationHeaders.documentActionCode != null) vars.bulknotificationHeaders.documentActionCode else "CHANGE_BY_REFRESH"
		
  }
    	
}.measure))) default [] 