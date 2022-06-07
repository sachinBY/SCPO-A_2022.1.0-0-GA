%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"select * from PROJORDEREXCEPTION" ++ " where " ++ vars.filterCondition ++ " ORDER BY SOURCE,DEST,TRANSMODE,ORDERGROUP,ORDERGROUPMEMBER,ORDERID,ITEM,EXCEPTION,EXCEPTIONDATE OFFSET " ++ vars.offset ++ " ROWS FETCH NEXT " ++ vars.next ++ " ROWS ONLY"
else	 
	"select * from PROJORDEREXCEPTION" ++ " ORDER BY SOURCE,DEST,TRANSMODE,ORDERGROUP,ORDERGROUPMEMBER,ORDERID,ITEM,EXCEPTION,EXCEPTIONDATE OFFSET " ++ vars.offset ++ " ROWS FETCH NEXT " ++ vars.next ++ " ROWS ONLY"
