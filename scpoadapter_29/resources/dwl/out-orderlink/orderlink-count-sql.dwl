%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"select COUNT(*) from ORDERLINK" ++ " where " ++ vars.filterCondition
else	
	"select COUNT(*) from ORDERLINK"
