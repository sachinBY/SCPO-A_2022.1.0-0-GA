%dw 2.0
type jdadate = LocalDateTime {format: "yyyy-MM-dd HH:mm:ss.S"}
type jdadatestring = String {format: "yyyy-MM-dd"}
var default_value = "###JDA_DEFAULT_VALUE###"
fun checkLeapYear(payload) = isLeapYear((payload as Date).year)
fun getDay(payload) = (payload as Date).day
fun getMonth(payload) = (payload as Date).month
fun formatSCPOToGS1(payload) =   
	if (payload as jdadate as jdadatestring == '1970-01-01') '1900-01-01' else payload as jdadate as jdadatestring
fun formatGS1ToSCPO(payload) = 	if (payload != null and (payload contains '1900-01-01')) default_value else payload
fun calculateDays(payload) = if(checkLeapYear == true)
								29 + payload
							else
								28 + payload
fun calculateNumericalDayOfYear(payload) = 	if (getMonth(payload) == 1) 
												getDay(payload) 
											else if (getMonth(payload) == 2)
												31 + getDay(payload)
											else if (getMonth(payload) == 3)
												calculateDays(31 + getDay(payload))
											else if (getMonth(payload) == 4)
												calculateDays(62 + getDay(payload))
											else if (getMonth(payload) == 5)
												calculateDays(92 + getDay(payload))
											else if (getMonth(payload) == 6)
												calculateDays(123 + getDay(payload))
											else if (getMonth(payload) == 7)
												calculateDays(153 + getDay(payload))
											else if (getMonth(payload) == 8)
												calculateDays(184 + getDay(payload))
											else if (getMonth(payload) == 9)
												calculateDays(214 + getDay(payload))
											else if (getMonth(payload) == 10)
												calculateDays(245 + getDay(payload))
											else if (getMonth(payload) == 11)
												calculateDays(275 + getDay(payload))
											else 
												calculateDays(306 + getDay(payload))
fun utcToSeconds(payload) = if(sizeOf(payload) > 10 and (payload[10 to 15] contains("-"))) (((payload[0 to 9] ++ "T00:00:00") as DateTime as Number {unit :"seconds"}) - ((payload[11 to 12] as Number)*60*60 + (payload[14 to 15] as Number)*60))
							else if (payload contains("+")) (((payload[0 to 9] ++ "T00:00:00") as DateTime as Number {unit :"seconds"}) + ((payload[11 to 12] as Number)*60*60 + (payload[14 to 15] as Number)*60))
							else (payload ++ "T00:00:00") as DateTime as Number {unit: "seconds"}
											
---
{
	formatSCPOToGS1: formatSCPOToGS1,
	formatGS1ToSCPO: formatGS1ToSCPO,
	calculateNumericalDayOfYear: calculateNumericalDayOfYear,
	utcToSeconds: utcToSeconds
}