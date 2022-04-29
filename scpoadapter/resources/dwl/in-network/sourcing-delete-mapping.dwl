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
		DISC: sourcing.DISC,
		EFF: sourcing.EFF,
		FACTOR: sourcing.FACTOR,
		ITEM: sourcing.ITEM,
		MAJORSHIPQTY: sourcing.MAJORSHIPQTY,
		MAXSHIPQTY: sourcing.MAXSHIPQTY,
		MINORSHIPQTY: sourcing.MINORSHIPQTY,
		NONEWSUPPLYDATE: sourcing.NONEWSUPPLYDATE,
		PRIORITY: sourcing.PRIORITY,
		SHRINKAGEFACTOR: sourcing.SHRINKAGEFACTOR,
		SOURCE: sourcing.SOURCE,
		SOURCING: sourcing.SOURCING,
		SOURCINGCOST: sourcing.SOURCINGCOST,
		TRANSMODE: sourcing.TRANSMODE,
		(vars.deleteudc): 'Y'
 	 })