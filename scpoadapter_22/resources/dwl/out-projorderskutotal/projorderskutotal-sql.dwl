%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"select * from PROJORDERSKUTOTAL" ++ " where " ++ vars.filterCondition ++ " ORDER BY ORDERID,ITEM,DEST,UOM OFFSET " ++ vars.offset ++ " ROWS FETCH NEXT " ++ vars.next ++ " ROWS ONLY"
else	
	"select * from PROJORDERSKUTOTAL" ++ " ORDER BY ORDERID,ITEM,DEST,UOM OFFSET " ++ vars.offset ++ " ROWS FETCH NEXT " ++ vars.next ++ " ROWS ONLY"
