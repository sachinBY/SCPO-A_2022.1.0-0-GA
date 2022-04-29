%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"select * from ORDERLINK" ++ " where " ++ vars.filterCondition ++ " ORDER BY ITEM,LOC,DMDTYPE,DMDSEQNUM,ORDERID,SHIPDATE,SUPPLYTYPE,SUPPLYSEQNUM,PARENTLOC,PARENTITEM,SUPPLYSUBSEQNUM,SCHEDSEQNUM offset " ++ vars.offset ++ " rows fetch next " ++ vars.next ++ " rows only"
else	
	"select * from ORDERLINK" ++ " ORDER BY ITEM,LOC,DMDTYPE,DMDSEQNUM,ORDERID,SHIPDATE,SUPPLYTYPE,SUPPLYSEQNUM,PARENTLOC,PARENTITEM,SUPPLYSUBSEQNUM,SCHEDSEQNUM offset " ++ vars.offset ++ " rows fetch next " ++ vars.next ++ " rows only"
