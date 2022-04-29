%dw 2.0
output application/java 
var default_value = "###JDA_DEFAULT_VALUE###" 
var funCaller = readUrl("classpath://config-repo/scpoadapter/resources/dwl/date-util.dwl") 
var locEntity = vars.entityMap.loc[0].loc[0]
---
 (payload map (loc, indexOfLoc) -> {
		MS_BULK_REF: loc.MS_BULK_REF,
		MS_REF: loc.MS_REF,
  		INTEGRATION_STAMP: loc.INTEGRATION_STAMP,
  		MESSAGE_TYPE: loc.MESSAGE_TYPE,
		MESSAGE_ID: loc.MESSAGE_ID,
		SENDER: loc.SENDER,
  		BORROWINGPCT: if (loc.BORROWINGPCT != null) loc.BORROWINGPCT else default_value,
	    CURRENCY: if (loc.CURRENCY != null) loc.CURRENCY else default_value,
	    COUNTRY: if (loc.COUNTRY != null) loc.COUNTRY else default_value,
	    DESCR: if (loc.DESCR != null) loc.DESCR else default_value,
	    FRZSTART: if (loc.FRZSTART != null and funCaller.formatGS1ToSCPO(loc.FRZSTART) != default_value) loc.FRZSTART else default_value,
	    LAT: if (loc.LAT != null) loc.LAT else default_value,
	    LOC: if (loc.LOC != null) loc.LOC else default_value,
	    "LOC_TYPE": if (loc."LOC_TYPE" != null) loc."LOC_TYPE" else default_value,
	    LON: if (loc.LON != null) loc.LON else default_value,
	    OHPOST: if (loc.OHPOST != null and funCaller.formatGS1ToSCPO(loc.OHPOST) != default_value) loc.OHPOST else default_value,
	    POSTALCODE: if (loc.POSTALCODE != null) loc.POSTALCODE else default_value,
	    WDDAREA: if (loc.WDDAREA != null) loc.WDDAREA else default_value,
	    WorkingCal: if (loc.WorkingCal != null) loc.WorkingCal else default_value,
	    (loc.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(loc.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
    
  })