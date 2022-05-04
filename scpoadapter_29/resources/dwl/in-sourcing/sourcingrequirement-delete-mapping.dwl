%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
 (payload map (sourcingreq, indexOfSourcingReq) -> {
 			MS_BULK_REF: sourcingreq.MS_BULK_REF,
			MS_REF: sourcingreq.MS_REF,
			INTEGRATION_STAMP: sourcingreq.INTEGRATION_STAMP,
			MESSAGE_TYPE: sourcingreq.MESSAGE_TYPE,
  			MESSAGE_ID: sourcingreq.MESSAGE_ID,
  			SENDER: sourcingreq.SENDER,
			DEST: sourcingreq.DEST,
			EFF: sourcingreq.EFF,
			ITEM: sourcingreq.ITEM,
			SOURCE: sourcingreq.SOURCE,
			SOURCING: sourcingreq.SOURCING,
			STEPNUM: sourcingreq.STEPNUM,
			(vars.deleteudc): 'Y'
 	 })