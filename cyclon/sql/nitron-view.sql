DROP VIEW IF EXISTS nTexts;
CREATE VIEW nTexts AS
SELECT DISTINCT hash, nText FROM codes
;

DROP VIEW IF EXISTS patterns_with_code;
CREATE VIEW patterns_with_code AS
SELECT
	patterns.*,
	c1.nText AS beforeNText,
	c2.nText AS afterNText
FROM patterns
JOIN nTexts AS c1
	ON	patterns.beforeHash = c1.hash
JOIN nTexts AS c2
	ON	patterns.afterHash = c2.hash
;

DROP VIEW IF EXISTS patterns_with_info;
CREATE VIEW patterns_with_info AS
SELECT
    patterns.*,
    pattern_info.info
FROM patterns
JOIN pattern_info
	ON 	patterns.beforeHash = pattern_info.beforeHash
	AND	patterns.afterHash = pattern_info.afterHash
;

DROP VIEW IF EXISTS patterns_with_info_code;
CREATE VIEW patterns_with_info_code AS
SELECT
    patterns_with_info.*,
    c1.nText AS beforeNText,
    c2.nText AS afterNText
FROM patterns_with_info
JOIN nTexts AS c1
	ON 	patterns_with_info.beforeHash = c1.hash
JOIN nTexts AS c2
	ON	patterns_with_info.afterHash = c2.hash
;
