%dw 2.0
output application/java
---
(payload map ($ - "ACTIONCODE" - "EFFPRICE" - "DUR" ++ (vars.deleteudc): 'Y'))