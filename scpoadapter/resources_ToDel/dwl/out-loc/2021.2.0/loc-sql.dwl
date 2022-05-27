%dw 2.0
output application/json
---
using (
    sql = "SELECT * FROM LOC"
)
if (vars.filterCondition != null)
   sql ++ " WHERE " ++ vars.filterCondition ++ " ORDER BY LOC offset " ++ vars.offset ++ " rows fetch next " ++ vars.next ++ " rows only"
  else 
  	sql ++ " ORDER BY LOC offset " ++ vars.offset ++ " rows fetch next " ++ vars.next ++ " rows only"