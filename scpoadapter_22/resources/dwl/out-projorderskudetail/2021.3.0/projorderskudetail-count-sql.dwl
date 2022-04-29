%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"select COUNT(*) FROM (select PROJORDERSKUDETAIL.*,ITEM.UOM from PROJORDERSKUDETAIL,ITEM where PROJORDERSKUDETAIL.ITEM = ITEM.ITEM" ++ " AND " ++ vars.filterCondition ++ ")"
else	
	"SELECT COUNT(*) FROM (select PROJORDERSKUDETAIL.*,ITEM.UOM from PROJORDERSKUDETAIL,ITEM where PROJORDERSKUDETAIL.ITEM = ITEM.ITEM)"
