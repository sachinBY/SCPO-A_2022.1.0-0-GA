%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
 (payload map (sourcing, indexOfSourcing) -> {
 		MS_BULK_REF: sourcing.MS_BULK_REF,
		MS_REF: sourcing.MS_REF,
 		INTEGRATION_STAMP: sourcing.INTEGRATION_STAMP,
 		MESSAGE_TYPE: sourcing.MESSAGE_TYPE,
  		MESSAGE_ID: sourcing.MESSAGE_ID,
  		SENDER: sourcing.SENDER,
		DEST: sourcing.DEST,
		ITEM: sourcing.ITEM,
		SOURCE: sourcing.SOURCE,
		SOURCING: sourcing.SOURCING,
		(vars.deleteudc): 'Y'
 	 })