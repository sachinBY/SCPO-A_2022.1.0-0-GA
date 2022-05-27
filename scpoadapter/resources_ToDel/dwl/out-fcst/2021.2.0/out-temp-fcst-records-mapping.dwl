%dw 2.0
output application/java
---
vars.temp.tmpFcstRecords map (record, index) -> {
	DMDUNIT: record.DMDUNIT,
	DMDGROUP: record.DMDGROUP,
	LOC: record.LOC,
	STARTDATE: (record.'FN_STARTDATE' as Date) as Date {format: "yyyy-mm-dd", class : "java.sql.Date"},
	TYPE: record.TYPE,
	QTY: ((record.QTY as Number default 0) + (record[('PERIOD') ++ ((record.'FN_STARTDATE' as Date - record.STARTDATE as Date).days + (vars.temp.noOfDays as Number default 1) as String)] as Number default 0)),
	MODEL: record.MODEL,
	DUR: record.DUR,
	FCSTID: record.FCSTID
}