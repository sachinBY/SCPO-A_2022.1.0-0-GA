%dw 2.0
output application/json encoding = "UTF-8",deferred=true
var udcs = vars.outboundUDCs.depdmdstatic[0].depdmdstatic[0]
import * from dw::core::Strings
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.depdmdstatic.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: "BYDM 2021.5.0",
		messageId: uuid(),
		"type": p("scpo.outbound.depdmdstatic.messagetype"),
		creationDateAndTime: now()
		},
		
		dependentDemand:(payload map {
				creationDateTime: now(),
				documentStatusCode: "ORIGINAL",
				documentActionCode: "CHANGE_BY_REFRESH",
		(avpList: (filter(udcs, (element, index) -> $[upper(element.scpoColumnName)] != null) map (udc , value) -> {
			name: udc.hostColumnName,
			value: $[upper(udc.scpoColumnName)]
		})) if (!isEmpty(udcs)),
			dependentDemandId:{
				itemId: $.ITEM,
				locationId: $.LOC,
				parentItemId: $.PARENT,
				needDate: substringBefore($.STARTDATE,"T"),
				isFirmPlannedOrder: if($.FIRMSW == 1) true
									else false,
				billOfMaterialNumber: $.BOMNUM,
				parentSequence: $.PARENTSEQNUM,
				parentScheduleDate: substringBefore($.PARENTSCHEDDATE,"T"),
				parentExpirationDate: substringBefore($.PARENTEXPDATE,"T"),
				parentOrderTypeCode: $.PARENTORDERTYPE,
				canBeSuperseded: if($.SUPERSEDESW == 1) true
								 else false,
				parentStartDate: substringBefore($.PARENTSTARTDATE,"T"),
				sequenceNumber: $.SEQNUM					
			},
			calculatedPriority: $.CALCPRIORITY,
			demandQuantity: $.QTY,
			earliestNeedDate: substringBefore($.EARLIESTNEEDDATE,"T"),
			expirationDate: substringBefore($.EXPDATE,"T"),
			scheduleQuantity: $.SCHEDQTY,
			scheduleDate: substringBefore($.SCHEDDATE,"T"),
			scheduleStatusTypeCode: $.SCHEDSTATUS
		})	
		
}