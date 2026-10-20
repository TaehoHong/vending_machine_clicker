extends RefCounted


static func format_amount(amount: int) -> String:
	var digits: String = str(amount)
	var formatted: String = ""
	for i in range(digits.length()):
		if i > 0 and (digits.length() - i) % 3 == 0:
			formatted += ","
		formatted += digits[i]
	return formatted


static func format_gold(amount: int) -> String:
	if amount < 10000:
		return format_amount(amount)
	var divisor: int = 1000
	var suffix: String = "K"
	if amount >= 1000000000:
		divisor = 1000000000
		suffix = "B"
	elif amount >= 1000000:
		divisor = 1000000
		suffix = "M"
	# 표시만 줄이고 잔액은 그대로 둔다. 반올림으로 잔액을 높여 보이지 않는다.
	var tenths: int = amount / (divisor / 10)
	return "%d.%d%s" % [tenths / 10, tenths % 10, suffix]
