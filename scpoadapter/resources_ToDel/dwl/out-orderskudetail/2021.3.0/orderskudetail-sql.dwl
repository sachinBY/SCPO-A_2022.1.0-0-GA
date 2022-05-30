%dw 2.0
output application/java
---
if(vars.filterCondition != null)
	"SELECT * FROM ORDERSKUDETAIL" ++ " WHERE " ++ vars.filterCondition
else	
	"SELECT * FROM ORDERSKUDETAIL"
