ATTACH "patterns-original.db" AS NH3;
/* codes */
DROP TABLE IF EXISTS temp.nh3;
DROP TABLE IF EXISTS temp.nitron;
DROP TABLE IF EXISTS join_rText;
DROP TABLE IF EXISTS join_nText;

CREATE TEMP TABLE nitron AS
SELECT id, rText, nText, start, end
FROM main.codes
WHERE (end != 0)
;
CREATE TEMP TABLE nh3 AS
SELECT id, rText, nText, start, end
FROM NH3.codes
WHERE (end != 0)
;

CREATE TABLE join_rText AS
SELECT
    nh3.id AS nh3_id,
    nitron.id AS nitron_id
FROM temp.nh3
JOIN temp.nitron
	ON  (nh3.end != 0)
    AND	(nitron.end != 0)
    AND	(nh3.start = nitron.start)
    AND	(nh3.rText = nitron.rText)
;

CREATE TABLE join_nText AS
SELECT
    nh3.id AS nh3_id,
    nitron.id AS nitron_id
FROM temp.nh3
JOIN temp.nitron
	ON
		(nh3.end != 0)
    AND	(nitron.end != 0)
    AND	(nh3.start = nitron.start)
    AND	(nh3.nText = nitron.nText)
;

/*  changes  */
DROP TABLE IF EXISTS temp.nh3;
DROP TABLE IF EXISTS temp.nitron;
DROP TABLE IF EXISTS join_changes;

CREATE TEMP TABLE nitron AS
SELECT id, beforeHash, afterHash
FROM main.changes
;
CREATE TEMP TABLE nh3 AS
SELECT id, beforeHash, afterHash
FROM NH3.changes
;

CREATE TABLE join_changes AS
SELECT
    nh3.id AS nh3_id,
    nitron.id AS nitron_id
FROM temp.nh3
JOIN temp.nitron
	ON  (nh3.beforeHash == nitron.beforeHash)
    AND (nh3.afterHash == nitron.afterHash)
;

/*  patterns  */
DROP TABLE IF EXISTS temp.nh3;
DROP TABLE IF EXISTS temp.nitron;
DROP TABLE IF EXISTS join_patterns;

CREATE TEMP TABLE nitron AS
SELECT id, beforeHash, afterHash
FROM main.patterns
;
CREATE TEMP TABLE nh3 AS
SELECT id, beforeHash, afterHash
FROM NH3.patterns
;

CREATE TABLE join_patterns AS
SELECT
    nh3.id AS nh3_id,
    nitron.id AS nitron_id
FROM temp.nh3
JOIN temp.nitron
	ON  (nh3.beforeHash == nitron.beforeHash)
    AND (nh3.afterHash == nitron.afterHash)
;

/* fails */
DROP TABLE IF EXISTS FP_rText;
CREATE TABLE FP_rText AS
SELECT id AS nitron_id FROM main.codes WHERE (end != 0)
EXCEPT
SELECT nitron_id FROM join_rText
;
DROP TABLE IF EXISTS FN_rText;
CREATE TABLE FN_rText AS
SELECT id AS nh3_id FROM nh3.codes WHERE (end != 0)
EXCEPT
SELECT nitron_id FROM join_rText
;

DROP TABLE IF EXISTS FP_nText;
CREATE TABLE FP_nText AS
SELECT id AS nitron_id FROM main.codes WHERE (end != 0)
EXCEPT
SELECT nitron_id FROM join_nText
EXCEPT
SELECT * FROM FP_rText
;
DROP TABLE IF EXISTS FN_nText;
CREATE TABLE FN_nText AS
SELECT id AS nh3_id FROM nh3.codes WHERE (end != 0)
EXCEPT
SELECT nitron_id FROM join_nText
;

DROP TABLE IF EXISTS FP_changes;
CREATE TABLE FP_changes AS
SELECT id AS nitron_id FROM main.changes
EXCEPT
SELECT nitron_id FROM join_changes
;
DROP TABLE IF EXISTS FN_changes;
CREATE TABLE FN_changes AS
SELECT id AS nitron_id FROM nh3.changes
EXCEPT
SELECT nitron_id FROM join_changes
;

DROP TABLE IF EXISTS FP_patterns;
CREATE TABLE FP_patterns AS
SELECT id AS nitron_id FROM main.patterns
EXCEPT
SELECT nitron_id FROM join_patterns
;
DROP TABLE IF EXISTS FN_patterns;
CREATE TABLE FN_patterns AS
SELECT id AS nitron_id FROM nh3.patterns
EXCEPT
SELECT nitron_id FROM join_patterns
;
/* summary */
DROP TABLE IF EXISTS nitron_result;
CREATE TABLE nitron_result AS
SELECT *
FROM
	(	SELECT 'nitron_all' AS data ),
	(
		SELECT count(*) AS rText
		FROM (SELECT DISTINCT id FROM main.codes)
	),(
		SELECT count(*) AS nText
		FROM (SELECT DISTINCT id FROM main.codes)
	),(
		SELECT count(*) AS changes
		FROM (SELECT DISTINCT id FROM main.changes)
	),(
		SELECT count(*) AS patterns
		FROM (SELECT DISTINCT id FROM main.patterns)
	)
;
INSERT INTO nitron_result
SELECT *
FROM
	(	SELECT 'nh3_all' AS data ),
	(
		SELECT count(*) AS rText
		FROM (SELECT DISTINCT id FROM nh3.codes)
	),(
		SELECT count(*) AS nText
		FROM (SELECT DISTINCT id FROM nh3.codes)
	),(
		SELECT count(*) AS changes
		FROM (SELECT DISTINCT id FROM nh3.changes)
	),(
		SELECT count(*) AS patterns
		FROM (SELECT DISTINCT id FROM nh3.patterns)
	)
;
INSERT INTO nitron_result
SELECT *
FROM
	(	SELECT 'nitron_no_blank' AS data ),
	(
		SELECT count(*) AS rText
		FROM (SELECT DISTINCT id FROM main.codes WHERE end != 0)
	),(
		SELECT count(*) AS nText
		FROM (SELECT DISTINCT id FROM main.codes WHERE end != 0)
	),(
		SELECT count(*) AS changes
		FROM (SELECT DISTINCT id FROM main.changes)
	),(
		SELECT count(*) AS patterns
		FROM (SELECT DISTINCT id FROM main.patterns)
	)
;
INSERT INTO nitron_result
SELECT *
FROM
	(	SELECT 'nh3_no_blank' AS data ),
	(
		SELECT count(*) AS rText
		FROM (SELECT DISTINCT id FROM nh3.codes WHERE end != 0)
	),(
		SELECT count(*) AS nText
		FROM (SELECT DISTINCT id FROM nh3.codes WHERE end != 0)
	),(
		SELECT count(*) AS changes
		FROM (SELECT DISTINCT id FROM nh3.changes)
	),(
		SELECT count(*) AS patterns
		FROM (SELECT DISTINCT id FROM nh3.patterns)
	)
;
INSERT INTO nitron_result
SELECT *
FROM
	(	SELECT '(nh3_correct)' AS data ),
	(
		SELECT count(*) AS rText
		FROM (SELECT DISTINCT nh3_id FROM join_rText)
	),(
		SELECT count(*) AS nText
		FROM (SELECT DISTINCT nh3_id FROM join_nText)
	),(
		SELECT count(*) AS changes
		FROM (SELECT DISTINCT nh3_id FROM join_changes)
	),(
		SELECT count(*) AS patterns
		FROM (SELECT DISTINCT nh3_id FROM join_patterns)
	)
;
INSERT INTO nitron_result
SELECT *
FROM
	(	SELECT 'nitron_correct' AS data ),
	(
		SELECT count(*) AS rText
		FROM (SELECT DISTINCT nitron_id FROM join_rText)
	),(
		SELECT count(*) AS nText
		FROM (SELECT DISTINCT nitron_id FROM join_nText)
	),(
		SELECT count(*) AS changes
		FROM (SELECT DISTINCT nitron_id FROM join_changes)
	),(
		SELECT count(*) AS patterns
		FROM (SELECT DISTINCT nitron_id FROM join_patterns)
	)
;
INSERT INTO nitron_result
SELECT *
FROM
	(	SELECT 'Precision' AS data ),
	(
		SELECT
			(SELECT cast(rText as real) FROM nitron_result WHERE data='nitron_correct')
			/
			(SELECT rText FROM nitron_result WHERE data='nitron_no_blank')
	),(
		SELECT
			(SELECT cast(nText as real) FROM nitron_result WHERE data='nitron_correct')
			/
			(SELECT nText FROM nitron_result WHERE data='nitron_no_blank')
	),(
		SELECT
			(SELECT cast(changes as real) FROM nitron_result WHERE data='nitron_correct')
			/
			(SELECT changes FROM nitron_result WHERE data='nitron_no_blank')
	),(
		SELECT
			(SELECT cast(patterns as real) FROM nitron_result WHERE data='nitron_correct')
			/
			(SELECT patterns FROM nitron_result WHERE data='nitron_no_blank')
	)
;
INSERT INTO nitron_result
SELECT *
FROM
	(	SELECT 'Recall' AS data ),
	(
		SELECT
			(SELECT cast(rText as real) FROM nitron_result WHERE data='nitron_correct')
			/
			(SELECT rText FROM nitron_result WHERE data='nh3_no_blank')
	),(
		SELECT
			(SELECT cast(nText as real) FROM nitron_result WHERE data='nitron_correct')
			/
			(SELECT nText FROM nitron_result WHERE data='nh3_no_blank')
	),(
		SELECT
			(SELECT cast(changes as real) FROM nitron_result WHERE data='nitron_correct')
			/
			(SELECT changes FROM nitron_result WHERE data='nh3_no_blank')
	),(
		SELECT
			(SELECT cast(patterns as real) FROM nitron_result WHERE data='nitron_correct')
			/
			(SELECT patterns FROM nitron_result WHERE data='nh3_no_blank')
	)
;

INSERT INTO nitron_result
SELECT *
FROM
	(	SELECT 'F value' AS data ),
	(
		SELECT
			(SELECT rText FROM nitron_result WHERE data='Precision') * (SELECT rText FROM nitron_result WHERE data='Recall') * 2
			/
			((SELECT rText FROM nitron_result WHERE data='Precision') + (SELECT rText FROM nitron_result WHERE data='Recall'))
	),(
		SELECT
			(SELECT nText FROM nitron_result WHERE data='Precision') * (SELECT rText FROM nitron_result WHERE data='Recall') * 2
			/
			((SELECT nText FROM nitron_result WHERE data='Precision') + (SELECT rText FROM nitron_result WHERE data='Recall'))
	),(
		SELECT
			(SELECT changes FROM nitron_result WHERE data='Precision') * (SELECT rText FROM nitron_result WHERE data='Recall') * 2
			/
			((SELECT changes FROM nitron_result WHERE data='Precision') + (SELECT rText FROM nitron_result WHERE data='Recall'))
	),(
		SELECT
			(SELECT patterns FROM nitron_result WHERE data='Precision') * (SELECT rText FROM nitron_result WHERE data='Recall') * 2
			/
			((SELECT patterns FROM nitron_result WHERE data='Precision') + (SELECT rText FROM nitron_result WHERE data='Recall'))
	)
;

/* views */
DROP VIEW IF EXISTS view_join_rText;
CREATE VIEW view_join_rText AS
SELECT codes.* FROM join_rText
JOIN main.codes ON nitron_id=id
;
DROP VIEW IF EXISTS view_join_nText;
CREATE VIEW view_join_nText AS
SELECT codes.* FROM join_nText
JOIN main.codes ON nitron_id=id
;
DROP VIEW IF EXISTS view_join_changes;
CREATE VIEW view_join_changes AS
SELECT changes.* FROM join_changes
JOIN main.changes ON nitron_id=id
;
DROP VIEW IF EXISTS view_join_patterns;
CREATE VIEW view_join_patterns AS
SELECT patterns.* FROM join_patterns
JOIN main.patterns ON nitron_id=id
;


DROP VIEW IF EXISTS view_FP_rText;
CREATE VIEW view_FP_rText AS
SELECT codes.* FROM FP_rText
JOIN main.codes ON nitron_id=id
;
DROP VIEW IF EXISTS view_FP_nText;
CREATE VIEW view_FP_nText AS
SELECT codes.* FROM FP_nText
JOIN main.codes ON nitron_id=id
;
DROP VIEW IF EXISTS view_FP_changes;
CREATE VIEW view_FP_changes AS
SELECT changes.* FROM FP_changes
JOIN main.changes ON nitron_id=id
;
DROP VIEW IF EXISTS view_FP_patterns;
CREATE VIEW view_FP_patterns AS
SELECT patterns.* FROM FP_patterns
JOIN main.patterns ON nitron_id=id
;

/*
DROP VIEW IF EXISTS view_FN_rText;
CREATE VIEW view_FN_rText AS
SELECT codes.* FROM FN_rText
JOIN NH3.codes ON nh3_id=id
;
DROP VIEW IF EXISTS view_FN_nText;
CREATE VIEW view_FN_nText AS
SELECT codes.* FROM FN_nText
JOIN NH3.codes ON nh3_id=id
;
DROP VIEW IF EXISTS view_FN_changes;
CREATE VIEW view_FN_changes AS
SELECT changes.* FROM FN_changes
JOIN NH3.changes ON nh3_id=id
;
DROP VIEW IF EXISTS view_FN_patterns;
CREATE VIEW view_FN_patterns AS
SELECT patterns.* FROM FN_patterns
JOIN NH3.patterns ON nh3_id=id
;
*/

SELECT * FROM nitron_result WHERE data='Precision' OR data='Recall';
