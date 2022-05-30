%dw 2.0
output application/json
---
using (
    sql = "SELECT * FROM RECSHIP"
)

if (vars.filterCondition != null)
   sql ++ " WHERE " ++ vars.filterCondition ++ " order by item, source, dest, type, seqnum offset " ++ vars.offset ++ " rows fetch next " ++ vars.next ++ " rows only"
  else 
  	sql ++ " order by item, source, dest, type, seqnum offset " ++ vars.offset ++ " rows fetch next " ++ vars.next ++ " rows only"