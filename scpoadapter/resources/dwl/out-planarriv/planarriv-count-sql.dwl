%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"select COUNT(*) from PLANARRIV" ++ " where " ++ vars.filterCondition
else	
	"select COUNT(*) from PLANARRIV"
