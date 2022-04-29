%dw 2.0
output application/java
---
(payload map (vehicleLoad, indexOfVehicleLoad) -> {
	MS_BULK_REF: vehicleLoad.MS_BULK_REF,
	MS_REF: vehicleLoad.MS_REF,
	INTEGRATION_STAMP: vehicleLoad.INTEGRATION_STAMP,
	MESSAGE_TYPE: vehicleLoad.MESSAGE_TYPE,
  	MESSAGE_ID: vehicleLoad.MESSAGE_ID,
  	SENDER: vehicleLoad.SENDER,
	LOADID: vehicleLoad.LOADID,
	(vars.deleteudc): 'Y'
  })