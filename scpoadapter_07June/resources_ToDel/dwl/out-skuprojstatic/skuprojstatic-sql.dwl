%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"SELECT * FROM SKUPROJSTATIC" ++ " where " ++ vars.filterCondition ++ " ORDER BY ITEM,LOC,STARTDATE,OPTIONSET OFFSET " ++ vars.offset ++ " ROWS FETCH NEXT " ++ vars.next ++ " ROWS ONLY"
else	
	"SELECT * FROM SKUPROJSTATIC" ++ " ORDER BY ITEM,LOC,STARTDATE,OPTIONSET OFFSET " ++ vars.offset ++ " ROWS FETCH NEXT " ++ vars.next ++ " ROWS ONLY"
