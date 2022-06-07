%dw 2.0
output application/java
---
payload groupBy ($.PRIMEKEY) pluck(value , key, index ) -> {
	(key): value
}
