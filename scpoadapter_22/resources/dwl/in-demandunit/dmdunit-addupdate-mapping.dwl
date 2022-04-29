%dw 2.0
output application/java  
var default_value = "###JDA_DEFAULT_VALUE###"

---
 (payload map (dmdunit, indexOfdmdunit) -> {
 	    MS_BULK_REF: dmdunit.MS_BULK_REF,
	    MS_REF: dmdunit.MS_REF,
		INTEGRATION_STAMP: dmdunit.INTEGRATION_STAMP,
		MESSAGE_TYPE: dmdunit.MESSAGE_TYPE,
  		MESSAGE_ID: dmdunit.MESSAGE_ID,
  		SENDER: dmdunit.SENDER,
  		DMDUNIT: if (dmdunit.DMDUNIT != null) dmdunit.DMDUNIT else default_value,
	    DESCR: if (dmdunit.DESCR != null) dmdunit.DESCR else default_value,
	    HIERARCHYLEVEL: if (dmdunit.HIERARCHYLEVEL != null) dmdunit.HIERARCHYLEVEL else default_value,
	    WDDCATEGORY: if (dmdunit.WDDCATEGORY != null) dmdunit.WDDCATEGORY else default_value,
	    PACKSIZE: if (dmdunit.PACKSIZE != null) dmdunit.PACKSIZE else default_value,
	    UNITSIZE: if (dmdunit.UNITSIZE != null) dmdunit.UNITSIZE else default_value,
	    UOM: if (dmdunit.UOM != null) dmdunit.UOM else default_value,
	    BRAND: if (dmdunit.BRAND != null) dmdunit.BRAND else default_value,
  		COLLECTION: if (dmdunit.COLLECTION != null) dmdunit.COLLECTION else default_value,
  		IGNOREPRICINGLVLSW: if (dmdunit.IGNOREPRICINGLVLSW != null) dmdunit.IGNOREPRICINGLVLSW else default_value,
  		ONORDERQTY: if (dmdunit.ONORDERQTY != null) dmdunit.ONORDERQTY else default_value,
  		//PERISHABLESW: if (dmdunit.PERISHABLESW != null) dmdunit.PERISHABLESW else default_value,
  		PRICELINK: if (dmdunit.PRICELINK != null) dmdunit.PRICELINK else default_value,
	    (dmdunit.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if ($ != null and $.scpoColumnName != null)
			}),
		(dmdunit.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if ($ != null and $.UDCName != null)
	    	})
  })