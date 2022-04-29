%dw 2.0
output application/csv deferred=true
var udcs = vars.outboundUDCs.fcst[0].dfutoskufcstwide[0]
import * from dw::core::Strings
var buckets = p('scpo.outbound.dfutoskufcstwide.buckets')
---
flatten(payload map (element, eleIndex) -> {
	array:((arr: (element filterObject ((value, key) ->  upper(key) contains 'PERIOD') pluck (value, key, index) -> {
		(key): (value),
		startdate: if ( lower(buckets) == 'monthly' ) substringBefore(element.STARTDATE + 'P$(key replace "PERIOD" with "")M' as Period,"T") else if ( lower(buckets) == 'weekly' ) substringBefore(element.STARTDATE + 'P$(key replace "PERIOD" with "")W' as Period,"T") else if ( lower(buckets) == 'yearly' ) substringBefore(element.STARTDATE + 'P$(key replace "PERIOD" with "")Y' as Period,"T") else substringBefore(element.STARTDATE + 'P$(key replace "PERIOD" with "")D' as Period,"T")
	})).arr orderBy ($.startdate) map (period, ind) -> {
		itemId: element.ITEM,
		locationId: element.SKULOC,
		demandChannel: element.DMDGROUP,
		forecastTypeCode: element.TYPE as String,
		'measure.forecastStartDate': period.startdate,
		'measure.quantityvalue': if ( period.'PERIOD$(ind+1)' == null ) '' else period.'PERIOD$(ind+1)'
	})
}.array)
