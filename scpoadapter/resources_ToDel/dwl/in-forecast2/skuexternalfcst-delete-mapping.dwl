%dw 2.0
output application/java
---
payload map (forecast, indexOfForecast) -> {
	MS_BULK_REF: forecast.MS_BULK_REF,
	MS_REF: forecast.MS_REF,
	INTEGRATION_STAMP: forecast.INTEGRATION_STAMP,
	MESSAGE_TYPE: forecast.MESSAGE_TYPE,
  	MESSAGE_ID: forecast.MESSAGE_ID,
  	SENDER: forecast.SENDER,
	(ITEM: forecast.ITEM),
	(LOC: forecast.LOC) ,
	(STARTDATE: forecast.STARTDATE),
	(PROJECT: forecast.PROJECT),
	(vars.deleteudc): 'Y' 
}