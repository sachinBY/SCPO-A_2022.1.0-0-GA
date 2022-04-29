%dw 2.0
output application/java
---
{
noOfDays:1 default 1,
tmpFcstRecords:payload filter $.'TMP_QTY' == null
}