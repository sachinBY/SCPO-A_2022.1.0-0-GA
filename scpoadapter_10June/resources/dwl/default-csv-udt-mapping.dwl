%dw 2.0
output application/java
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var udt = vars.udtColumns
---
((vars.payloadCopy) map {
	udcs:(udt map (value, index) -> {
		(scpoColumnName: value.scpoColumnName) if ((lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) != null),
		(scpoColumnValue: (lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0))) if ((lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) != null),
		(dataType: value.dataType) if ((lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) != null),
		(isPK: value.isPK) if ((lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) != null)
	}),
	ACTIONCODE: if (not isEmpty($.documentActionCode)) $.documentActionCode else if (vars.bulknotificationHeaders.documentActionCode != null) vars.bulknotificationHeaders.documentActionCode else "ADD"
})