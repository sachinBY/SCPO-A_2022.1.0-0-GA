%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
 (payload map (repnet, indexOfRepnet) -> {
 	MS_BULK_REF: repnet.MS_BULK_REF,
	MS_REF: repnet.MS_REF,
	INTEGRATION_STAMP: repnet.INTEGRATION_STAMP,
	MESSAGE_TYPE: repnet.MESSAGE_TYPE,
  	MESSAGE_ID: repnet.MESSAGE_ID,
  	SENDER: repnet.SENDER,
	TRANSMODE: repnet.TRANSMODE,
	SOURCE: repnet.SOURCE,
	DEST: repnet.DEST,
	TRANSLEADTIME: repnet.TRANSLEADTIME,
	LOADTIME: repnet.LOADTIME,
	RANK: repnet.RANK,
	RATEPERCWT: repnet.RATEPERCWT,
	UNLOADTIME: repnet.UNLOADTIME,
	ORDERCOST: repnet.ORDERCOST,
	SHIPCAL: repnet.SHIPCAL,
	ARRIVCAL: repnet.ARRIVCAL,
	ORDERREVIEWCAL: repnet.ORDERREVIEWCAL,
	LEADTIMEEFFCNCYCAL: repnet.LEADTIMEEFFCNCYCAL,
	(vars.deleteudc): 'Y'
 	 })