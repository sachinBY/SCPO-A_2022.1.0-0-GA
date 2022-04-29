%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
 (payload map (customerOrder, indexOfCustomerOrder) -> {
 	    MS_BULK_REF: customerOrder.MS_BULK_REF,
	    MS_REF: customerOrder.MS_REF,
 		INTEGRATION_STAMP: customerOrder.INTEGRATION_STAMP,
 		MESSAGE_TYPE: customerOrder.MESSAGE_TYPE,
		MESSAGE_ID: customerOrder.MESSAGE_ID,
		SENDER: customerOrder.SENDER,
		ITEM: customerOrder.ITEM,
		LOC: customerOrder.LOC,
		ORDERID: customerOrder.ORDERID,
		SHIPDATE: customerOrder.SHIPDATE,
		(vars.deleteudc): 'Y'
 	 })