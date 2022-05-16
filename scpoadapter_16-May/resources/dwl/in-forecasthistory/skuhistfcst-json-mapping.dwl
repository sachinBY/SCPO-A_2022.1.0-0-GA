%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var fcsthistEntity = vars.entityMap.skuhistfcst[0].skuhistfcst[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload.forecastHistory map(fcstHist,indexfsct) -> {
	data: (fcstHist.measure map(measure,indexMeasure) -> {
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$((indexfsct))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
		BASEFCST: measure.baseForecastQuantity.value,
		DUR: measure.durationInMinutes,
		(FCSTDATE: (fcstHist.forecastDate replace "Z" with ("")) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}) if not fcstHist.forecastDate==null,
		ITEM: fcstHist.itemId,
		LAG: measure.lag,
		LOC: fcstHist.locationId,
		NONBASEFCST: measure.nonBaseForecastQuantity.value,
		(STARTDATE: (measure.forecastStartDate replace "Z" with ("")) as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}) if not measure.forecastStartDate==null,
		(fcstUDC: (lib.getUdcNameAndValue(fcsthistEntity, fcstHist.avpList, lib.getAvpListMap(fcstHist.avpList))[0])) 
  			if (fcstHist.avpList != null and fcsthistEntity != null),
		}),
		ACTIONCODE: if(fcstHist.documentActionCode == null) "ADD" else fcstHist.documentActionCode})