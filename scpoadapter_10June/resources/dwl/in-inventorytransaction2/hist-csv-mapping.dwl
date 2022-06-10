%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl")
var histStreams = vars.codeMap.histStreamConversion
var histEntity = vars.entityMap.hist[0].hist[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload map {
	
		udcs: (histEntity map (value, index) -> {
			(scpoColumnName: value.scpoColumnName) if ((lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) != null),
			(scpoColumnValue: (lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0))) if ((lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) != null),
			(dataType: value.dataType) if ((lib.mapHostToSCPO($, (value.hostColumnName splitBy "/"), 0)) != null),
		}),
		MS_BULK_REF: vars.storeHeaderReference.bulkReference,
		MS_REF: vars.storeMsgReference.messageReference,
		(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
		MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  		MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  		SENDER: vars.bulkNotificationHeaders.sender,
	  	TYPE: "1",
	    EVENT: " ",
	    DMDUNIT: if ($.itemId != null) $.itemId
		  	else default_value,
	    DMDGROUP: if ($.demandChannel != null and $.demandChannel != "") $.demandChannel
		   else default_value,
	    LOC: if ($.locationId != null and $.locationId != "") $.locationId
		  	else default_value,
	  	STARTDATE: if ($.startDate != null and $.startDate != "" and funCaller.formatGS1ToSCPO($.startDate) != default_value) $.startDate as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
		  	else default_value,
	  	HISTSTREAM: if ($.transactionCode != null and $.transactionCode != "" and histStreams."$($.transactionCode)"[0] != null) histStreams."$($.transactionCode)"[0]
	  		else default_value,
	  	QTY: if ($."quantity.value" != null and $."quantity.value" != "") $."quantity.value" 
			else default_value,
		DUR: if($.durationInMinutes != null and $.durationInMinutes != "") 
					$.durationInMinutes as Number 
			  else default_value,
		ACTIONCODE: "ADD"
	
  })
