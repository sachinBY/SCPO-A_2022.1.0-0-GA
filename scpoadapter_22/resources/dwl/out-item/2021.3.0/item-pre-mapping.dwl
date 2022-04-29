%dw 2.0
output application/java
---
payload groupBy ($.ITEM) pluck(value , key, index ) -> {
	(key): value
}
