/* pattern テーブルに連番idを付加 */
DROP TABLE IF EXISTS patterns_id;
CREATE TABLE patterns_id (
	id integer primary key autoincrement, 
	beforeHash blob,
	afterHash blob, 
	changetype integer,
	difftype integer,
	support integer,
	confidence real,
	authors integer,
	files integer,
	nos integer,
	firstdate text,
	lastdate text
);
INSERT INTO patterns_id(
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
	lastdate)
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
		lastdate
	FROM patterns;
DROP TABLE patterns;
ALTER TABLE patterns_id RENAME TO patterns;

/* create bug tables */
DROP TABLE IF EXISTS bugfixpatterns;
DROP TABLE IF EXISTS bugfixchanges;
DROP TABLE IF EXISTS bugfixrevisions;

CREATE TABLE bugfixpatterns AS SELECT * FROM patterns;
CREATE TABLE bugfixchanges AS SELECT * FROM changes;
CREATE TABLE bugfixrevisions AS SELECT * FROM revisions;  

ALTER TABLE bugfixpatterns ADD bugfix INT NOT NULL DEFAULT 0;
ALTER TABLE bugfixchanges ADD bugfix INT NOT NULL DEFAULT 0;
ALTER TABLE bugfixrevisions ADD bugfix INT NOT NULL DEFAULT 0;


/* setup bugfixrevisions table */
/* コミットメッセージにバグ関連の単語が含まれる場合にbugfix=1とする */
UPDATE bugfixrevisions SET bugfix = 1
WHERE
    message GLOB '[eE]rror*' 
OR
    message GLOB '*[^a-zA-Z][eE]rror*' 
OR
    message GLOB '[bB]ug*' 
OR
    message GLOB '*[^a-zA-Z][bB]ug*' 
OR
    message GLOB '[fF]ix*' 
OR
    message GLOB '*[^a-zA-Z][fF]ix*' 
OR
    message GLOB '[fF]ault*' 
OR
    message GLOB '*[^a-zA-Z][fF]ault.*' 
OR
    message LIKE '%issue%' 
OR
    message LIKE '%mistake%' 
OR
    message LIKE '%incorrect%' 
OR
    message LIKE '%defect%' 
OR
    message LIKE '%flaw%' 
;


/* setup bugfixchanges table */
UPDATE bugfixchanges SET bugfix = 1
WHERE revision IN (
	SELECT id FROM bugfixrevisions
	WHERE bugfix > 0
);


/* setup bugfixpatterns table */
/* bugfix値は、そのpatternに該当するchangesの個数とした(暫定)*/
UPDATE bugfixpatterns SET bugfix = 1
WHERE (beforeHash, afterHash) IN (
	SELECT beforeHash, afterHash FROM bugfixchanges
	WHERE bugfix > 0
)
;
DROP TABLE IF EXISTS tmp;
CREATE TEMP TABLE tmp AS
SELECT beforeHash, afterHash, SUM(bugfix) as sumBugfix
FROM bugfixchanges
GROUP BY beforeHash, afterHash
;
DROP TABLE IF EXISTS tmpPatterns;
CREATE TEMP TABLE tmpPatterns AS
SELECT *
FROM bugfixpatterns LEFT OUTER JOIN tmp
ON (
	bugfixpatterns.beforeHash = tmp.beforeHash
	AND
	bugfixpatterns.afterHash = tmp.afterHash
)
;
DROP TABLE bugfixpatterns;
CREATE TABLE bugfixpatterns AS
SELECT 
	id,
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
	sumBugfix AS bugfix
FROM temp.tmpPatterns;

DROP TABLE IF EXISTS tmp;
DROP TABLE IF EXISTS tmpPatterns;
