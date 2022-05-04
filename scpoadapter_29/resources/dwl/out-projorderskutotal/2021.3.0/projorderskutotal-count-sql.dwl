%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"select COUNT(*) from PROJORDERSKUTOTAL" ++ " where " ++ vars.filterCondition
else	
	"select COUNT(*) from PROJORDERSKUTOTAL"
