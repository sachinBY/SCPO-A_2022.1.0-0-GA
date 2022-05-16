%dw 2.0
output application/json encoding = "UTF-8"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var udcs = vars.outboundUDCs.item[0].item[0]
var reverseUOMMap = vars.codeMap.UOMConversion map {
	($ pluck (value,key) -> {(value):key})
}
var isoCodesMap = vars.codeMap.UOMIsoConversion map {
	($ pluck(value, key, index) -> {(value):key})
}
---
{
	header: {
		sender: p('scpo.outbound.sender'),
		receiver: (splitBy(p("scpo.outbound.item.receivers"), ",") map {
			(receiver: $) if (!isEmpty($))
		}).receiver,
		messageVersion: "BYDM 2021.9.0",
		messageId: uuid(),
		"type": p("scpo.outbound.item.messagetype"),
		creationDateAndTime: now()
	},
	item: (payload map (ele, index ) -> {	
		creationDateTime: now(),
		documentStatusCode: "ORIGINAL",
		documentActionCode: "CHANGE_BY_REFRESH",
		lastUpdateDateTime: now(),
		itemId: {
			primaryId: (ele pluck($$))[0]
		},
		description: [{
			value: (flatten(ele pluck($)).DESCR)[0],
			languageCode: "en"
		}],
		tradeItemBaseUnitOfMeasure: if ( (flatten(ele pluck($)).UOM)[0] != null ) reverseUOMMap[(flatten(ele pluck($)).UOM)[0]] else reverseUOMMap[(flatten(ele pluck($)).DEFAULTUOM)[0]],
		priority: (flatten(ele pluck($)).PRIORITY)[0],
		classifications: {
			itemType: (flatten(ele pluck($)).ITEMCLASS)[0],
			itemClass: (flatten(ele pluck($)).ITEMCLASS)[0],
			itemFamilyGroup: (flatten(ele pluck($)).STORAGEGROUP)[0],
			handlingInstruction: [{
				handlingInstructionCode: (flatten(ele pluck($)).PERISHABLESW)[0] as String
			}]
		},
		operationalRules: {
			isDiscrete: if ( (flatten(ele pluck($)).DISCRETESW)[0] == 1 ) true else false
		},
		(measurementTypeConversion: (flatten(ele pluck($)) map {
			(sourceMeasurementUnitCode: {
				measurementUnitCode: isoCodesMap[reverseUOMMap[$.SOURCEUOM]] as String 
			}) if (!isEmpty($.SOURCEUOM)),
			(targetMeasurementUnitCode: {
				measurementUnitCode: isoCodesMap[reverseUOMMap[$.TARGETUOM]] as String
			}) if (!isEmpty($.TARGETUOM)),
			(ratioOfTargetPerSource: $.RATIO) if (!isEmpty($.RATIO))
		})) if (sizeOf(flatten(ele pluck($)) filter ($.SOURCEUOM != null and $.TARGETUOM != null)) > 0)
	})
}
