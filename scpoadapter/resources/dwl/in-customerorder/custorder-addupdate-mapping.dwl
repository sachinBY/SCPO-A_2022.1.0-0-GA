%dw 2.0
output application/java
var default_value = "###JDA_DEFAULT_VALUE###"

---
(payload map (customerOrder, indexOfCustomerOrder) -> {
	            MS_BULK_REF: customerOrder.MS_BULK_REF,
			 	MS_REF: customerOrder.MS_REF,
				INTEGRATION_STAMP: customerOrder.INTEGRATION_STAMP,
				MESSAGE_TYPE: customerOrder.MESSAGE_TYPE,
				MESSAGE_ID: customerOrder.MESSAGE_ID,
				SENDER: customerOrder.SENDER,
		  		CUST: customerOrder.CUST,
				DELIVERYDATE: customerOrder.DELIVERYDATE,
				DEST: customerOrder.DEST,
		  		DFULOC: customerOrder.DFULOC,
				DMDGROUP: customerOrder.DMDGROUP,
				DMDUNIT: customerOrder.DMDUNIT,
				FCSTSW: customerOrder.FCSTSW,
				FCSTTYPE: customerOrder.FCSTTYPE,
				HEADEREXTREF: customerOrder.HEADEREXTREF,
				ITEM: customerOrder.ITEM,
				LINEITEMEXTREF: customerOrder.LINEITEMEXTREF,
				LOC: customerOrder.LOC,
				MAXEARLYDUR: customerOrder.MAXEARLYDUR,
				MAXLATEDUR: customerOrder.MAXLATEDUR,
				ORDERID: customerOrder.ORDERID,
				//ORDERSEQNUM: customerOrder.CO_ORDERSEQNUM,
				PRIORITY: customerOrder.PRIORITY,
				QTY: customerOrder.QTY,
				RESERVATION: customerOrder.RESERVATION,
				RESEXP: customerOrder.RESEXP,
				SHIPDATE: customerOrder.SHIPDATE,
				STATUS: customerOrder.STATUS,
				SUPERSEDESW: customerOrder.SUPERSEDESW,
				UNITPRICE: customerOrder.UNITPRICE,
				(customerOrder.udcs map {
				(($.scpoColumnName): if ($.scpoColumnValue == null or $.scpoColumnValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.scpoColumnValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.scpoColumnValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.scpoColumnValue as Number
								else $.scpoColumnValue) if($ != null and $.scpoColumnName != null)
				}),
				(customerOrder.avplistUDCS default [] map {
	      		(($.UDCName): if ($.UDCValue == null or $.UDCValue == default_value) default_value
								else if ($.dataType != null and $.dataType == "DATETIME") $.UDCValue as DateTime as String
								else if ($.dataType != null and $.dataType == "DATE") $.UDCValue as Date {format: "yyyy-MM-dd", class : "java.sql.Date"}
								else if ($.dataType != null and ($.dataType == "NUMBER" or $.dataType == "FLOAT" or $.dataType == "INTEGER")) $.UDCValue as Number
								else $.UDCValue) if($ != null and $.UDCName != null)
	    		})
		    
 	 	})