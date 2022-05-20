%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var custOrderHeaderEntity = vars.entityMap.custorder[0].custorderheader[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
((payload.customerOrder filter (order, idx) -> (not isEmpty(order.lineItem filter (lineItem, idx2) -> (lower(lineItem.lineStatus) == 'open')))) map (order, orderIndex) -> {
		//udcs: ((custOrderHeaderEntity map (value, index) -> {
		//	(scpoColumnName: value.scpoColumnName) if ((lib.mapHostToSCPO(order, (value.hostColumnName splitBy "/"), 0)) != null),
		//	(scpoColumnValue: (lib.mapHostToSCPO(order, (value.hostColumnName splitBy "/"), 0))) if ((lib.mapHostToSCPO(order, (value.hostColumnName splitBy "/"), 0)) != null),
		//	(dataType: value.dataType) if ((lib.mapHostToSCPO(order, (value.hostColumnName splitBy "/"), 0)) != null)
		//})) filter sizeOf($) > 0,
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	    MS_REF: vars.storeMsgReference.messageReference,
		INTEGRATION_STAMP: ((vars.creationDateAndTime as DateTime + ('PT' ++ orderIndex ++ 'S') as Period) replace 'T' with '') [0 to 17],
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
	 	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
	 	SENDER: vars.bulkNotificationHeaders.sender,
		CUST: if (order.buyer.primaryId != null) 
					order.buyer.primaryId 
					else default_value,
		EXTREF: if (order.orderId != null) 
				   		order.orderId 
				   else default_value,
		CREATIONDATE: if (order.creationDateTime != null) 
							order.creationDateTime 
						 else default_value,
		DMDGROUP: if (order.demandChannel != null) 
						order.demandChannel 
					 else default_value,
		PRIORITY: if (order.orderPriority != null) 
					  	order.orderPriority 
					 else default_value,
   		(CustOrderHeaderUDC: (lib.getUdcNameAndValue(custOrderHeaderEntity, order.avpList, lib.getAvpListMap(order.avpList))[0])) 
  		if (order.avpList != null 
  			and (order.documentActionCode == "ADD" or order.documentActionCode == "CHANGE_BY_REFRESH")
  			and custOrderHeaderEntity != null
  		),
		ACTIONCODE: order.documentActionCode
})