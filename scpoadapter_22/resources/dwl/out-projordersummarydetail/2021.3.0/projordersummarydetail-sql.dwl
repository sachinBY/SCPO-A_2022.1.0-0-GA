%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"select * from PROJORDERSUMMARYDETAIL" ++ " where " ++ vars.filterCondition ++ " ORDER BY ORDERID OFFSET " ++ vars.offset ++ " ROWS FETCH NEXT " ++ vars.next ++ " ROWS ONLY"
else	
	"select * from PROJORDERSUMMARYDETAIL" ++ " ORDER BY ORDERID OFFSET " ++ vars.offset ++ " ROWS FETCH NEXT " ++ vars.next ++ " ROWS ONLY"
