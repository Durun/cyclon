SELECT
	info,
	Sum(support) AS support,
	Sum(support) / Sum(support/confidence) AS confidence,
	Min(firstdate) AS firstdate,
	Max(lastdate) AS lastdate
FROM patterns_with_info
GROUP BY
	info like "%-foreach%",
	info like "%-for%",
	info like "%foreach-%",
	info like "%for-%"
	;
