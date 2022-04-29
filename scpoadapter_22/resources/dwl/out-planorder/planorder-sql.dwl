%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"select * from PLANORDER" ++ " WHERE " ++ vars.filterCondition ++ " ORDER BY ITEM,LOC,SEQNUM OFFSET " ++ vars.offset ++ " ROWS FETCH NEXT " ++ vars.next ++ " ROWS ONLY"
else	
	"select * from PLANORDER ORDER BY ITEM,LOC,SEQNUM OFFSET " ++ vars.offset ++ " ROWS FETCH NEXT " ++ vars.next ++ " ROWS ONLY"
