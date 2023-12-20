class_name Price

var resource: String = ""
var amount: float = -1


static func with(res: String, n: float) -> Price:
	var p: Price = Price.new()
	p.resource = res
	p.amount = n
	return p
