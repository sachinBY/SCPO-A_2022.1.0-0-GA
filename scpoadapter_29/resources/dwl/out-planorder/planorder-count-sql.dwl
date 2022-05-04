%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"select COUNT(*) from PLANORDER" ++ " WHERE " ++ vars.filterCondition
else	
	"select COUNT(*) from PLANORDER"
