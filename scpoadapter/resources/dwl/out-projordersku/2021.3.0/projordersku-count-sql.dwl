%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"SELECT COUNT(*) FROM (SELECT PROJORDERSKU.*,ITEM.UOM FROM PROJORDERSKU,ITEM WHERE PROJORDERSKU.ITEM = ITEM.ITEM" ++ " AND " ++ vars.filterCondition ++ ")"
else	
	"SELECT COUNT(*) FROM (SELECT PROJORDERSKU.*,ITEM.UOM FROM PROJORDERSKU,ITEM WHERE PROJORDERSKU.ITEM = ITEM.ITEM)"
