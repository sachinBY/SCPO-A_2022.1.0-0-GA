%dw 2.0
output application/java 
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var retailplanEntity = vars.entityMap.retailplan2[0].'udt_ep_forecast'[0]
---
(payload map (retailplan2, indexOfRetailPlan2) -> {

		MEASURE: retailplan2.MEASURE,
		SUBCAT: retailplan2.SUBCAT,
		CHANNEL: retailplan2.CHANNEL,
		DMDGROUP: retailplan2.DMDGROUP,
		STARTDATE: retailplan2.STARTDATE,
		(vars.deleteudc): 'Y'
})