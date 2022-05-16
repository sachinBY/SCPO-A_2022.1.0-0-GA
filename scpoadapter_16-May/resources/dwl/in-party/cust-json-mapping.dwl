%dw 2.0
output application/java
var custEntity = vars.entityMap.cust[0].cust[0]
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
---
(payload.party map {
	MS_BULK_REF: vars.storeHeaderReference.bulkReference,
	MS_REF: vars.storeMsgReference.messageReference,
	(INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"} 
    ),
    MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	SENDER: vars.bulkNotificationHeaders.sender,
	CUST:$.partyId,
    CUSTCLASS:$.customerDetails.customerClass,
    DESCR:$.basicParty.partyName,
    PRIORITY:$.customerDetails.priority,
    //UDC_Street_Address:$.basicParty.partyAddress.streetAddressOne,
    //UDC_City:$.basicParty.partyAddress.city,
    //UDC_District:$.basicParty.partyAddress.addressDistrict,
    //UDC_Postal:$.basicParty.partyAddress.postalCode,
    //UDC_POBox:$.basicParty.partyAddress.pOBoxNumber,
    //UDC_Region:$.basicParty.partyAddress.addressRegion,
    //UDC_CountryCode:$.basicParty.partyAddress.countryCode,
    //UDC_Telephone:$.basicParty.partyContact.communicationChannel.communicationValue,
    //UDC_SalesOrg:$.customerDetails.organisationalInformation.salesOrganisation,
    //UDC_Channel:$.customerDetails.organisationalInformation.channel,
    //UDC_Division:$.customerDetails.organisationalInformation.division,
    //UDC_CustomerGroup:$.customerDetails.organisationalInformation.customerGroup,
    //UDC_AccountGroup:$.customerDetails.organisationalInformation.accountGroup,
    //UDC_SalesOffice:$.customerDetails.organisationalInformation.salesOffice,
    //UDC_DeliveringPlant:$.customerDetails.organisationalInformation.preferredWarehouse.primaryId,
	(CustUDC: (lib.getUdcNameAndValue(custEntity, $.avpList, lib.getAvpListMap($.avpList))[0])) 
	if ($.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and custEntity != null
	),
	ACTIONCODE: $.documentActionCode
})