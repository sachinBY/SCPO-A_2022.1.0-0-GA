%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"select * from PLANARRIV" ++ " where " ++ vars.filterCondition ++ " ORDER BY ITEM,DEST,SEQNUM OFFSET " ++ vars.offset ++ " ROWS FETCH NEXT " ++ vars.next ++ " ROWS ONLY"
else	
	"select * from PLANARRIV ORDER BY ITEM,DEST,SEQNUM OFFSET " ++ vars.offset ++ " ROWS FETCH NEXT " ++ vars.next ++ " ROWS ONLY"
