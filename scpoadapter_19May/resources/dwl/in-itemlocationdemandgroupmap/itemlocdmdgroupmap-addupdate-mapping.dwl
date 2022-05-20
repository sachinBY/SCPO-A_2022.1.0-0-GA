%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"
---
 (payload map (itemlocdmdgroup, indexOfItemlocdmdgroup) -> {
 		MS_BULK_REF: itemlocdmdgroup.MS_BULK_REF,
        MS_REF: itemlocdmdgroup.MS_REF,
		INTEGRATION_STAMP: itemlocdmdgroup.INTEGRATION_STAMP,
		MESSAGE_TYPE: itemlocdmdgroup.MESSAGE_TYPE,
  	 	MESSAGE_ID: itemlocdmdgroup.MESSAGE_ID,
  	 	SENDER: itemlocdmdgroup.SENDER,
	  	DMDGROUP: if (itemlocdmdgroup.DMDGROUP != null) itemlocdmdgroup.DMDGROUP else default_value,
	    EFF: if (itemlocdmdgroup.EFF != null) itemlocdmdgroup.EFF else default_value,
	    ITEM : if (itemlocdmdgroup.ITEM != null) itemlocdmdgroup.ITEM else default_value,
	    LOC : if (itemlocdmdgroup.LOC != null) itemlocdmdgroup.LOC else default_value,
	    OPPLANPARAM : if (itemlocdmdgroup.OPPLANPARAM != null) itemlocdmdgroup.OPPLANPARAM else default_value,
	    ROOTSW : if (itemlocdmdgroup.ROOTSW != null) itemlocdmdgroup.ROOTSW else default_value,
	    (itemlocdmdgroup.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(itemlocdmdgroup.ItemLocDemandGroupMapUDC default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
    
 })