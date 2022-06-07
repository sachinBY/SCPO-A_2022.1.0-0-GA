%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
---
 (payload map (histTrans, indexOfHistTrans) -> {
 		MS_BULK_REF: histTrans.MS_BULK_REF,
		MS_REF: histTrans.MS_REF,
		INTEGRATION_STAMP: histTrans.INTEGRATION_STAMP,
		MESSAGE_TYPE: histTrans.MESSAGE_TYPE,
  		MESSAGE_ID: histTrans.MESSAGE_ID,
  		SENDER: histTrans.SENDER,
		ACTUALARRIVDATE: if(histTrans.ACTUALARRIVDATE != null or histTrans.ACTUALARRIVDATE != "") histTrans.ACTUALARRIVDATE else default_value,
		
		DEST: if(histTrans.DEST != null or histTrans.DEST != "") histTrans.DEST else default_value,

		ITEM: if(histTrans.ITEM != null or histTrans.ITEM != "") histTrans.ITEM else default_value,

		
		SOURCE:	if(histTrans.SOURCE != null or histTrans.SOURCE != "") histTrans.SOURCE else default_value,

		TRANSMODE: 	if(histTrans.TRANSMODE != null or histTrans.TRANSMODE != "") histTrans.TRANSMODE else default_value,
		ORDERID: if(histTrans.ORDERID != null or histTrans.ORDERID != "") histTrans.ORDERID else default_value,
		(vars.deleteudc): 'Y'
 	 })