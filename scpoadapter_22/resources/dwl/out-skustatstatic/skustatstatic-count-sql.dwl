%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"select COUNT(*) from SKUSTATSTATIC" ++ " where " ++ vars.filterCondition
else	
	"select COUNT(*) from SKUSTATSTATIC"
