%dw 2.0
output application/java
---
 (payload map (vehicleLoadLine, indexOfVehicleLoadLineData) -> {
 	MS_BULK_REF: vehicleLoadLine.MS_BULK_REF,
	MS_REF: vehicleLoadLine.MS_REF,
	INTEGRATION_STAMP: vehicleLoadLine.INTEGRATION_STAMP,
	MESSAGE_TYPE: vehicleLoadLine.MESSAGE_TYPE,
  	MESSAGE_ID: vehicleLoadLine.MESSAGE_ID,
  	SENDER: vehicleLoadLine.SENDER,
 	LOADID: vehicleLoadLine.LOADID,
 	PRIMARYITEM: vehicleLoadLine.PRIMARYITEM,
 	EXPDATE: vehicleLoadLine.EXPDATE,
 	EXPDATE: vehicleLoadLine.EXPDATE,
 	DEST: vehicleLoadLine.DEST,
 	(vars.deleteudc): 'Y'
  })