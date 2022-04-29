%dw 2.0
output application/json encoding="UTF-8",deferred=true
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.vehicleloadline[0].vehicleloadline[0]
---
{header:{
    sender: p('scpo.outbound.sender'),
 
	receiver: (splitBy(p("scpo.outbound.vehicleloadline.receivers") , ",") map {
			(receiver: $) if ($ != null and $ != '')
		}).receiver,		
    messageVersion:"BYDM 2021.8.0",
    messageId:uuid(),
    "type":p('scpo.outbound.vehicleloadline.messagetype'),
    creationDateAndTime:now()
},
    plannedSupply:(payload map {
    	creationDateTime:now(),
    	documentStatusCode:"ORIGINAL",
    	documentActionCode:"CHANGE_BY_REFRESH",
	        (avpList: 
					(filter(udcs, (element, index) -> $[upper(element.scpoColumnName)] != null) map (udc , value) -> {
						name: udc.hostColumnName,
						value: $[upper(udc.scpoColumnName)]
					})
				) if (!isEmpty(udcs)),
	         "plannedSupplyId": {
        "item": {
          "primaryId": $.ITEM,
          "additionalTradeItemId": [
            {
              "typeCode": "GTIN-14",
              "value": "00000000000000"
            }
          ]
        },
        "shipTo": {
          "primaryId": $.DEST,
          "additionalPartyId": [
            {
              "typeCode": "GLN",
              "value": "0000000000000"
            }
          ]
        },
        "shipFrom": {
          "primaryId": $.SOURCE,
          "additionalPartyId": [
            {
              "typeCode": "GLN",
              "value": "0000000000000"
            }
          ]
        },
        transportLoadId:$.LOADID
      },
		"type":"VEHICLE_LOAD",
        plannedSupplyDetail:[{
            "requestedQuantity": {
            "value": $.QTY
          },
          "movementInformation": {
            "deliveryDate": $.SCHEDARRIVDATE as DateTime as Date {
					format: "yyyy-MM-dd", class : "java.sql.Date"
				},
          }
        }]
    })}
