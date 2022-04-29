%dw 2.0
output application/java
---
payload groupBy ($.ORDERID) pluck(value , key, index ) -> {
	(key): value
}
