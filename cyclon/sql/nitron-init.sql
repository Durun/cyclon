CREATE TABLE changes (software string, id integer, filepath string, author string, beforeID integer, beforeHash blob, afterID integer, afterHash blob, revision string, date string, changetype integer, difftype integer, primary key(software, id));
CREATE TABLE codes (software string, id integer, rText string, nText string, hash blob, start int, end int, primary key(software, id));
CREATE TABLE node_type_sets (id INTEGER PRIMARY KEY, grammar TEXT NOT NULL, tokenTypes TEXT NOT NULL, ruleNames TEXT NOT NULL);
CREATE TABLE patterns (beforeHash blob, afterHash blob, changetype integer, difftype integer, support integer, confidence real, authors integer, files integer, nos integer, firstdate string, lastdate string, projects integer, primary key(beforeHash, afterHash));
CREATE TABLE revisions (software string, id string, date string, message string, author string, primary key(software, id));
CREATE TABLE structures (hash BLOB PRIMARY KEY, json TEXT NOT NULL, nodeTypeSet INT NOT NULL, CONSTRAINT fk_structures_nodeTypeSet_id FOREIGN KEY (nodeTypeSet) REFERENCES node_type_sets(id) ON DELETE RESTRICT ON UPDATE RESTRICT);

CREATE INDEX index_patterns_beforeHash on patterns(beforeHash);
CREATE INDEX index_patterns_afterHash on patterns(afterHash);
CREATE INDEX index_patterns_beforeHash_afterHash on patterns(beforeHash, afterHash);
CREATE INDEX index_codes_hash on codes(hash);
