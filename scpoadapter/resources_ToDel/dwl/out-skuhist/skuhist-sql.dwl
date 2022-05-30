%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"SELECT * FROM SKUHIST" ++ " where " ++ vars.filterCondition ++ " ORDER BY STARTDATE,TYPE,DUR,ITEM,LOC OFFSET " ++ vars.offset ++ " ROWS FETCH NEXT " ++ vars.next ++ " ROWS ONLY"
else	
	"SELECT * FROM SKUHIST" ++ " ORDER BY STARTDATE,TYPE,DUR,ITEM,LOC OFFSET " ++ vars.offset ++ " ROWS FETCH NEXT " ++ vars.next ++ " ROWS ONLY"