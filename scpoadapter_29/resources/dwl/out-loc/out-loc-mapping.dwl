%dw 2.0
output application/json encoding = "UTF-8",deferred=true
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.loc[0].loc[0]
import * from dw::core::Strings
---
{
	header: {
	sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.loc.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: "BYDM 2021.10.0",
		messageId: uuid(),
		"type": p("scpo.outbound.loc.messagetype"),
		creationDateAndTime: now()
		
		
	},
	location:(payload map {
		
			creationDateTime: now(),
			documentStatusCode: "ORIGINAL",
			documentActionCode: "CHANGE_BY_REFRESH",
			
	 (avpList: 
					(filter(udcs, (element, index) -> $[upper(element.scpoColumnName)] != null) map (udc , value) -> {
						name: udc.hostColumnName,
						value: $[upper(udc.scpoColumnName)]
					})
				) if (!isEmpty(udcs)),
			
			locationId: $.LOC,
			basicLocation: {
				locationName: $.DESCR,
				address: {
					countryCode: $.COUNTRY,
					currencyOfPartyCode: $.CURRENCY,
					postalCode: $.POSTALCODE,
					geographicalCoordinates: {
						latitude: $.LAT as String,
						longitude: $.LON as String,
						
					}
				},
				(locationTypeCode: if ( $.LOC_TYPE == 1 ) "SUPPLIER" 
					        	              else if ( $.LOC_TYPE == 5 ) "CUSTOMER"
					        	              else if ( $.LOC_TYPE == 2 ) "MANUFACTURING_PLANT"
					        	              else if ( $.LOC_TYPE == 6 ) "STORE"
					        	              else if ( $.LOC_TYPE == 3 ) "WAREHOUSE_AND_OR_DEPOT"
					        	              else ""),
			},
			planningDetails: {
				calendarId: $.WORKINGCAL,
				borrowingPercentage: $.BORROWINGPCT,
				beginFreezeDate: $.FRZSTART as DateTime,
				lastOnHandPostDate: $.OHPOST as DateTime,
				weatherArea: $.WDDAREA
			}
		}
	)
}
   	   
