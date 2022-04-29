%dw 2.0
output application/json encoding = "UTF-8",deferred=true
var udcs = vars.outboundUDCs.fcst[0].fcst[0]
import * from dw::core::Strings
var buckets = p('scpo.outbound.dfutoskufcstwide.buckets')
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.dfutoskufcstwide.receivers") , ",") map {
			(receiver: $) if ($ != null and $ != '')
		}).receiver,
		messageVersion: "BYDM 2021.5.0",
		messageId: uuid(),
		"type": p('scpo.outbound.dfutoskufcstwide.messagetype'),
		creationDateAndTime: now()
	},
	forecast2: (payload map (element, eleIndex) -> {
		itemId: element.ITEM,
		locationId: element.SKULOC,
		demandChannel: element.DMDGROUP,
		forecastTypeCode: element.TYPE as String,
		measure: ((arr:(element filterObject ((value, key) ->  upper(key) contains 'PERIOD') pluck (value, key, index) -> {
			(key): (value),
			startdate: if ( lower(buckets) == 'monthly' ) substringBefore(element.STARTDATE + 'P$(key replace "PERIOD" with "")M' as Period,"T") else if ( lower(buckets) == 'weekly' ) substringBefore(element.STARTDATE + 'P$(key replace "PERIOD" with "")W' as Period,"T") else if ( lower(buckets) == 'yearly' ) substringBefore(element.STARTDATE + 'P$(key replace "PERIOD" with "")Y' as Period,"T") else substringBefore(element.STARTDATE + 'P$(key replace "PERIOD" with "")D' as Period,"T")
		})).arr orderBy ($.startdate) map (period, ind) -> {
			forecastStartDate: period.startdate,
			("quantity": {
				"value": period.'PERIOD$(ind+1)'
			})
		}) filter ($.quantity.value != null)
	})
}