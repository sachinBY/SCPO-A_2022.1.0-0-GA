%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"SELECT COUNT(*) FROM SKUPROJSTATIC" ++ " where " ++ vars.filterCondition
else	
	"SELECT COUNT(*) FROM SKUPROJSTATIC"
