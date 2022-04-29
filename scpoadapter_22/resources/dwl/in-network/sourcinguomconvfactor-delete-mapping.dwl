%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
(payload map (sourcingconv, indexOfsourcingconv) -> {
		MS_BULK_REF: sourcingconv.MS_BULK_REF,
		MS_REF: sourcingconv.MS_REF,
		INTEGRATION_STAMP: sourcingconv.INTEGRATION_STAMP,
		MESSAGE_TYPE: sourcingconv.MESSAGE_TYPE,
  		MESSAGE_ID: sourcingconv.MESSAGE_ID,
  		SENDER: sourcingconv.SENDER,
		DEST: sourcingconv.DEST,
		ITEM: sourcingconv.ITEM,
		RATIO: sourcingconv.RATIO,
		SOURCE: sourcingconv.SOURCE,
		SOURCECATEGORY: sourcingconv.SOURCECATEGORY,
		SOURCEUOM: sourcingconv.SOURCEUOM,
		TARGETCATEGORY: sourcingconv.TARGETCATEGORY,
		TARGETUOM: sourcingconv.TARGETUOM,
		TRANSMODE: sourcingconv.TRANSMODE,
		(vars.deleteudc): 'Y'
  })