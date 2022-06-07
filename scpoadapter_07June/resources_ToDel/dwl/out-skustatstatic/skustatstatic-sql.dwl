%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"select * from SKUSTATSTATIC" ++ " where " ++ vars.filterCondition ++ " ORDER BY ITEM,LOC OFFSET " ++ vars.offset ++ " ROWS FETCH NEXT " ++ vars.next ++ " ROWS ONLY"
else	
	"select * from SKUSTATSTATIC" ++ " ORDER BY ITEM,LOC OFFSET " ++ vars.offset ++ " ROWS FETCH NEXT " ++ vars.next ++ " ROWS ONLY"
