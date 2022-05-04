%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"  
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var retailplanEntity = vars.entityMap.retailplan2[0].'udt_ep_forecast'[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
payload map (retailplan2,retailplan2index) -> {
		udcs: (retailplanEntity map (value, index) -> {
			scpoColumnName: value.scpoColumnName,
			scpoColumnValue: if ( not isEmpty(lib.mapHostToSCPO(retailplan2, (value.hostColumnName splitBy "/"), 0)) ) (lib.mapHostToSCPO(retailplan2, (value.hostColumnName splitBy "/"), 0)) else default_value,
			(dataType: value.dataType) if ((lib.mapHostToSCPO(retailplan2, (value.hostColumnName splitBy "/"), 0)) != null),
			}),
		 CHANNEL: if(not isEmpty(retailplan2.locationId)) retailplan2.locationId else default_value,
		 DMDGROUP: "LDE",
		 DUR : default_value,
		 MEASURE: if(not isEmpty(retailplan2.'measure.name')) retailplan2.'measure.name' else null,
		 QTY: if(not isEmpty(retailplan2.'measure.value')) retailplan2.'measure.value' else default_value,
		 STARTDATE: retailplan2.timeId as LocalDateTime as Date {format: "yyyy-MM-dd", class : "java.sql.Date"},
		 SUBCAT:  if(not isEmpty(retailplan2.itemId)) retailplan2.itemId else default_value,
		 ACTIONCODE: if (not isEmpty(retailplan2.documentActionCode)) retailplan2.documentActionCode else if (vars.bulknotificationHeaders.documentActionCode != null) vars.bulknotificationHeaders.documentActionCode else "CHANGE_BY_REFRESH"
}