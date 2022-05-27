%dw 2.0
output application/json
---
using (
    sql = "SELECT * FROM DFUTOSKUFCSTWIDE"
)
if (vars.filterCondition != null)
   sql ++ " WHERE " ++ vars.filterCondition ++ " order by ITEM,SKULOC,DMDUNIT,DMDGROUP,DFULOC,STARTDATE,TYPE,SUPERSEDESW offset " ++ vars.offset ++ " rows fetch next " ++ vars.next ++ " rows only"
  else 
  	sql ++ " order by ITEM,SKULOC,DMDUNIT,DMDGROUP,DFULOC,STARTDATE,TYPE,SUPERSEDESW offset " ++ vars.offset ++ " rows fetch next " ++ vars.next ++ " rows only"