%dw 2.0
output application/java  

var itemHierarchyLevelMemberEntity = vars.entityMap.itemhierarchylevelmember[0].dmdunit[0]
var hierarchyLevelConvers = vars.codeMap.hierarchyLevelConversion
var lib = readUrl("classpath://config-repo/scpoadapter/resources/dwl/host-scpo-udc-mapping.dwl")
var ancestryTables = p('bydm.dmdunit.ancestry.hierarchies') splitBy(',')
var default_value = "###JDA_DEFAULT_VALUE###"
fun ancestryMap(ancestry) = (ancestry map {
	($.hierarchyLevelId): ($.memberId)
})
fun ancestryUDCs(data , ancestryTables) = (
	ancestryTables map {
		UDCName: ('UDC_'++$++'_ID'),
		UDCValue: data[$][0]
	}
) 
---
(payload.itemHierarchyLevelMember map {
	 (MS_BULK_REF: vars.storeHeaderReference.bulkReference),
	 (MS_REF: vars.storeMsgReference.messageReference),
	 (INTEGRATION_STAMP:((vars.creationDateAndTime as DateTime) + ("PT$(($$))S" as Period)) as String{format:"yyyy-MM-dd HH:mm:ss"}),
	 MESSAGE_TYPE: vars.bulkNotificationHeaders.bulkType,
  	 MESSAGE_ID: vars.bulkNotificationHeaders.bulkMessageSourceId,
  	 SENDER: vars.bulkNotificationHeaders.sender,
     (DESCR: $.itemHierarchyInformation.memberName) if not $.itemHierarchyInformation.memberName == null,
     (DMDUNIT: $.itemHierarchyLevelMemberId) 
  			if not $.itemHierarchyLevelMemberId == null,
     (HIERARCHYLEVEL: hierarchyLevelConvers[$.itemHierarchyInformation.hierarchyLevelId][0]) 
  				if ($.itemHierarchyInformation.hierarchyLevelId != null 
  					and ($.documentActionCode == "ADD" 
  						or $.documentActionCode == "CHANGE_BY_REFRESH"
  					)
  				),
  	avplistUDCS:(flatten([(lib.getUdcNameAndValue(itemHierarchyLevelMemberEntity, $.avpList, lib.getAvpListMap($.avpList))[0]) if ($.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and itemHierarchyLevelMemberEntity != null
	),
	(lib.getUdcNameAndValue(itemHierarchyLevelMemberEntity, $.levelSpecificAttributes, lib.getAvpListMap($.levelSpecificAttributes))[0]) if ($.levelSpecificAttributes.avpList != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH")
		and itemHierarchyLevelMemberEntity != null
	),
	(ancestryUDCs(ancestryMap($.itemHierarchyInformation.ancestry) , ancestryTables)) if ($.itemHierarchyInformation != null 
		and ($.documentActionCode == "ADD" or $.documentActionCode == "CHANGE_BY_REFRESH") and (p('bydm.dmdunit.process.ancestry') as Boolean default false) == true)	
	])),			
     ACTIONCODE: $.documentActionCode
})