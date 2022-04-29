%dw 2.0
import * from dw::core::Objects
output application/json  skipNullOn="everywhere"


var uomShortLabelArray =  (payload filter $.SHORTLABEL != null)  map {
	($.UOM): ($.SHORTLABEL)
}
---
uomShortLabelArray map
($ mapObject 
($) : $$
)