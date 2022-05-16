%dw 2.0
output application/java 
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var retailplanEntity = vars.entityMap.retailplan2[0].'udt_ep_forecast'[0]
---
(payload map (retailplan2, indexOfRetailPlan2) -> {
		MS_BULK_REF: retailplan2.MS_BULK_REF,
		MS_REF: retailplan2.MS_REF,
		INTEGRATION_STAMP: retailplan2.INTEGRATION_STAMP,
		MESSAGE_TYPE: retailplan2.MESSAGE_TYPE,
  		MESSAGE_ID: retailplan2.MESSAGE_ID,
  		SENDER: retailplan2.SENDER,
		MEASURE: retailplan2.MEASURE,
		SUBCAT: retailplan2.SUBCAT,
		CHANNEL: retailplan2.CHANNEL,
		DMDGROUP: retailplan2.DMDGROUP,
		STARTDATE: retailplan2.STARTDATE,
		(vars.deleteudc): 'Y'
})