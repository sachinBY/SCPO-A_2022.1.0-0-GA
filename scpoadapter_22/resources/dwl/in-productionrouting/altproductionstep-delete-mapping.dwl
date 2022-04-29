%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
(payload map(productionStep, indexofproductionStep) -> {
	MS_BULK_REF: productionStep.MS_BULK_REF,
	MS_REF: productionStep.MS_REF,
	INTEGRATION_STAMP: productionStep.INTEGRATION_STAMP,
	MESSAGE_TYPE: productionStep.MESSAGE_TYPE,
  	MESSAGE_ID: productionStep.MESSAGE_ID,
  	SENDER: productionStep.SENDER,
	ITEM: productionStep.ITEM,
	LOC: productionStep.LOC,
	PRODUCTIONMETHOD: productionStep.PRODUCTIONMETHOD,
	PRIMARYSTEPNUM: productionStep.PRIMARYSTEPNUM,
	ALTRES: productionStep.ALTRES,
	EFF: default_value,
	ALTRESGROUP: productionStep.ALTRESGROUP,
	(vars.deleteudc): 'Y'
})