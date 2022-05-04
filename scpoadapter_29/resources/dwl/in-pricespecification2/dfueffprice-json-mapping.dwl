%dw 2.0
output application/java
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
fun calculateDur(startDate, endDate) = (((endDate++"T00:00:00Z") as DateTime as Number {unit: "seconds"}))/60 - (((startDate++"T00:00:00Z") as DateTime as Number {unit: "seconds"})/60)
var default_value = "###JDA_DEFAULT_VALUE###"
var dfueffpriceEntity = vars.entityMap.dfuprice[0].dfueffprice[0]
---
(payload.priceSpecification2 filter ($.priceType == "REDUCED") map {
	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference, 
	(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	SENDER: vars.bulkNotificationHeaders.sender,
	DMDGROUP: if (!isEmpty($.demandChannel)) $.demandChannel
		else default_value,
	DMDUNIT: if (!isEmpty($.itemId)) $.itemId
		else default_value,
	DUR: if (!isEmpty($.priceEffectiveFromDate) and !isEmpty($.priceEffectiveUpToDate)) calculateDur($.priceEffectiveFromDate, $.priceEffectiveUpToDate)
		else default_value,
	EFFPRICE: if (!isEmpty($.retailPrice) and !isEmpty($.retailPrice.value)) $.retailPrice.value
	  	else default_value,
	LOC: if (!isEmpty($.locationId)) $.locationId
		else default_value,
	STARTDATE: if (!isEmpty($.priceEffectiveFromDate)) $.priceEffectiveFromDate as Date {format:"yyyy-MM-dd",class:"java.sql.Date"}
		else default_value,
	(if ($.avpList != null  and dfueffpriceEntity != null) 
		lib.transformAvpListToUdcs(dfueffpriceEntity, $.avpList, lib.getAvpListMap($.avpList)) else null),
	ACTIONCODE: $.documentActionCode default "CHANGE_BY_REFRESH"
})