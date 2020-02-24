--ATTACH DATABASE "changes.db" AS guest;

INSERT INTO main.changes SELECT * FROM guest.changes;
INSERT INTO main.codes SELECT * FROM guest.codes;
INSERT INTO main.revisions SELECT * FROM guest.revisions;

INSERT OR IGNORE INTO main.node_type_sets
SELECT g.*
FROM guest.node_type_sets AS g
LEFT JOIN main.node_type_sets AS m
	ON	m.tokenTypes = g.tokenTypes
	AND	m.ruleNames = g.ruleNames
;

REPLACE INTO main.patterns (beforeHash, afterHash, changetype, difftype, support, confidence, authors, files, nos, firstdate, lastdate, projects)
SELECT
	m.beforeHash,
	m.afterHash,
	m.changetype,
	m.difftype,
	m.support + g.support,
	(m.support + g.support) / ((m.support / m.confidence) + (g.support / g.confidence)),
	max(m.authors, g.authors),
	m.files + g.files,
	max(m.nos, g.nos),
	min(m.firstdate, g.firstdate),
	max(m.lastdate,  g.lastdate),
	m.projects + 1
FROM main.patterns AS m
JOIN guest.patterns AS g
	ON	m.beforeHash = g.beforeHash
	AND	m.afterHash = g.afterHash
;
INSERT OR IGNORE INTO main.patterns (beforeHash, afterHash, changetype, difftype, support, confidence, authors, files, nos, firstdate, lastdate, projects)
SELECT
	beforeHash,
	afterHash,
	changetype,
	difftype,
	support,
	confidence,
	authors,
	files,
	nos,
	firstdate,
	lastdate,
	1
FROM guest.patterns
;
INSERT OR IGNORE INTO main.structures SELECT * FROM guest.structures;

DETACH guest;
