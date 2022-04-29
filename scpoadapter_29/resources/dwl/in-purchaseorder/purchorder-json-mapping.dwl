%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var purchorderEntity = vars.entityMap.purchorder[0].purchorder[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
flatten(flatten(flatten(flatten((payload.purchaseOrder map (order,orderIndex)-> {
	lineItem: (order.lineItem filter(lower($.lineStatus) != 'deleted' and lower($.lineStatus) != 'inactive') map(orderLineItem,orderLineItemIndex)->{
		(if ( orderLineItem.lineItemDetail != null ) {
			(lineItemDetail: (orderLineItem.lineItemDetail map(lineItemDetail,indexDetail)->{
				(if ( orderLineItem.transactionalTradeItem.transactionalItemData != null ) {
					(transItemData: (orderLineItem.transactionalTradeItem.transactionalItemData map(transItemData,indexDetail)->{
						 MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	  					 MS_REF: vars.storeMsgReference.messageReference,	
						(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((orderIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
						MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  						MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  						SENDER: vars.bulkNotificationHeaders.sender,
						PROJECT: if ( orderLineItem.project != null ) orderLineItem.project else if ( order.project != null ) order.project else  default_value,
						PURCHMETHOD: if ( orderLineItem.purchaseMethod != null ) orderLineItem.purchaseMethod else if ( order.purchaseMethod != null ) order.purchaseMethod else default_value,
						ORDERNUM: if ( order.orderId != null ) order.orderId 
					  else default_value,
						ITEM: if ( orderLineItem.transactionalTradeItem.primaryId != null ) orderLineItem.transactionalTradeItem.primaryId 
				  else default_value,
						LINENUM: if ( orderLineItem.lineItemNumber != null ) (orderLineItem.lineItemNumber ++ "_" ++ orderLineItemIndex) 
					 else default_value,
						DUEDATE: if ( lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateTime.date != null ) lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateTime.date 
					 else default_value,
						LOC: if ( lineItemDetail.orderLogisticalInformation.shipTo.primaryId != null ) lineItemDetail.orderLogisticalInformation.shipTo.primaryId 
				 else default_value,
						QTY: if ( lineItemDetail.requestedQuantity.value != null ) lineItemDetail.requestedQuantity.value 
				 else default_value,
						EXPDATE: if ( transItemData.itemExpirationDate != null ) transItemData.itemExpirationDate 
					 else default_value,
						avplistUDCS: (flatten([(lib.getUdcNameAndValue(purchorderEntity, order.avpList, lib.getAvpListMap(order.avpList))[0]) if (order.avpList != null and (order.documentActionCode == "ADD" or order.documentActionCode == "CHANGE_BY_REFRESH") and purchorderEntity != null),
		(lib.getUdcNameAndValue(purchorderEntity, orderLineItem.avpList, lib.getAvpListMap(orderLineItem.avpList))[0]) if (orderLineItem.avpList != null and (order.documentActionCode == "ADD" or order.documentActionCode == "CHANGE_BY_REFRESH") and purchorderEntity != null),
		(lib.getUdcNameAndValue(purchorderEntity, lineItemDetail.avpList, lib.getAvpListMap(lineItemDetail.avpList))[0]) if (lineItemDetail.avpList != null and (order.documentActionCode == "ADD" or order.documentActionCode == "CHANGE_BY_REFRESH") and purchorderEntity != null)])),
						ACTIONCODE: order.documentActionCode
					}))
				} else {
					(transItemData: {
						 MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	  					MS_REF: vars.storeMsgReference.messageReference,	
						(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((orderIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
						MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  						MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  						SENDER: vars.bulkNotificationHeaders.sender,
						PROJECT: if ( orderLineItem.project != null ) orderLineItem.project else if ( order.project != null ) order.project else  default_value,
						PURCHMETHOD: if ( orderLineItem.purchaseMethod != null ) orderLineItem.purchaseMethod else if ( order.purchaseMethod != null ) order.purchaseMethod else default_value,
						ORDERNUM: if ( order.orderId != null ) order.orderId 
					  else default_value,
						ITEM: if ( orderLineItem.transactionalTradeItem.primaryId != null ) orderLineItem.transactionalTradeItem.primaryId 
				  else default_value,
						LINENUM: if ( orderLineItem.lineItemNumber != null ) (orderLineItem.lineItemNumber ++ "_" ++ orderLineItemIndex) 
					 else default_value,
						DUEDATE: if ( lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateTime.date != null ) lineItemDetail.orderLogisticalInformation.orderLogisticalDateInformation.requestedDeliveryDateTime.date 
					 else default_value,
						LOC: if ( lineItemDetail.orderLogisticalInformation.shipTo.primaryId != null ) lineItemDetail.orderLogisticalInformation.shipTo.primaryId 
				 else default_value,
						QTY: if ( lineItemDetail.requestedQuantity.value != null ) lineItemDetail.requestedQuantity.value 
				 else default_value,
						EXPDATE: default_value,
						avplistUDCS: (flatten([(lib.getUdcNameAndValue(purchorderEntity, order.avpList, lib.getAvpListMap(order.avpList))[0]) if (order.avpList != null and (order.documentActionCode == "ADD" or order.documentActionCode == "CHANGE_BY_REFRESH") and purchorderEntity != null),
		(lib.getUdcNameAndValue(purchorderEntity, orderLineItem.avpList, lib.getAvpListMap(orderLineItem.avpList))[0]) if (orderLineItem.avpList != null and (order.documentActionCode == "ADD" or order.documentActionCode == "CHANGE_BY_REFRESH") and purchorderEntity != null),
		(lib.getUdcNameAndValue(purchorderEntity, lineItemDetail.avpList, lib.getAvpListMap(lineItemDetail.avpList))[0]) if (lineItemDetail.avpList != null and (order.documentActionCode == "ADD" or order.documentActionCode == "CHANGE_BY_REFRESH") and purchorderEntity != null)])),
						ACTIONCODE: order.documentActionCode
					})
				})
			}.transItemData))
		} else {
			(lineItemDetail: {
				(if ( orderLineItem.transactionalTradeItem.transactionalItemData != null ) {
					(transItemData: (orderLineItem.transactionalTradeItem.transactionalItemData map(transItemData,indexDetail)->{
						 MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	  					MS_REF: vars.storeMsgReference.messageReference,	
						(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((orderIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
						MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  						MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  						SENDER: vars.bulkNotificationHeaders.sender,
						PROJECT: if ( orderLineItem.project != null ) orderLineItem.project else if ( order.project != null ) order.project else  default_value,
						PURCHMETHOD: if ( orderLineItem.purchaseMethod != null ) orderLineItem.purchaseMethod else if ( order.purchaseMethod != null ) order.purchaseMethod else default_value,
						ORDERNUM: if ( order.orderId != null ) order.orderId 
					  else default_value,
						ITEM: if ( orderLineItem.transactionalTradeItem.primaryId != null ) orderLineItem.transactionalTradeItem.primaryId 
				  else default_value,
						LINENUM: if ( orderLineItem.lineItemNumber != null ) (orderLineItem.lineItemNumber ++ "_" ++ orderLineItemIndex) 
					 else default_value,
						DUEDATE: default_value,
						LOC: default_value,
						QTY: default_value,
						EXPDATE: if ( transItemData.itemExpirationDate != null ) transItemData.itemExpirationDate 
					 else default_value,
						avplistUDCS: (flatten([(lib.getUdcNameAndValue(purchorderEntity, order.avpList, lib.getAvpListMap(order.avpList))[0]) if (order.avpList != null and (order.documentActionCode == "ADD" or order.documentActionCode == "CHANGE_BY_REFRESH") and purchorderEntity != null),
		(lib.getUdcNameAndValue(purchorderEntity, orderLineItem.avpList, lib.getAvpListMap(orderLineItem.avpList))[0]) if (orderLineItem.avpList != null and (order.documentActionCode == "ADD" or order.documentActionCode == "CHANGE_BY_REFRESH") and purchorderEntity != null)])),
						ACTIONCODE: order.documentActionCode
					}))
				} else {
					(transItemData: {
						 MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	  						MS_REF: vars.storeMsgReference.messageReference,	
	  						(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((orderIndex))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
						MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  						MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  						SENDER: vars.bulkNotificationHeaders.sender,
						PROJECT: if ( orderLineItem.project != null ) orderLineItem.project else if ( order.project != null ) order.project else  default_value,
						PURCHMETHOD: if ( orderLineItem.purchaseMethod != null ) orderLineItem.purchaseMethod else if ( order.purchaseMethod != null ) order.purchaseMethod else default_value,
						ORDERNUM: if ( order.orderId != null ) order.orderId 
					  else default_value,
						ITEM: if ( orderLineItem.transactionalTradeItem.primaryId != null ) orderLineItem.transactionalTradeItem.primaryId 
				  else default_value,
						LINENUM: if ( orderLineItem.lineItemNumber != null ) (orderLineItem.lineItemNumber ++ "_" ++ orderLineItemIndex) 
					 else default_value,
						DUEDATE: default_value,
						LOC: default_value,
						QTY: default_value,
						EXPDATE: default_value,
						avplistUDCS: (flatten([(lib.getUdcNameAndValue(purchorderEntity, order.avpList, lib.getAvpListMap(order.avpList))[0]) if (order.avpList != null and (order.documentActionCode == "ADD" or order.documentActionCode == "CHANGE_BY_REFRESH") and purchorderEntity != null),
		(lib.getUdcNameAndValue(purchorderEntity, orderLineItem.avpList, lib.getAvpListMap(orderLineItem.avpList))[0]) if (orderLineItem.avpList != null and (order.documentActionCode == "ADD" or order.documentActionCode == "CHANGE_BY_REFRESH") and purchorderEntity != null)])),
						ACTIONCODE: order.documentActionCode
					})
				})
			}.transItemData)
		})
	}.lineItemDetail)
}.lineItem)))))
