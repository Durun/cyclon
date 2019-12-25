SELECT 
	info, 
	Sum(support) AS support, 
	Sum(support) / Sum(support/confidence) AS confidence,
	Min(firstdate) AS firstdate,
	Max(lastdate) AS lastdate
FROM patterns_with_info
GROUP BY 
	info like "%-foreach%",
	info like "%-for%"
	;

SELECT *
FROM patterns_with_code
WHERE (NOT beforeNText like "%forEach%")
	AND beforeNText like "%for%"
	AND afterNText like "%forEach%";
