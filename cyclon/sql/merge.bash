SCRIPT_DIR=`dirname $0`

LANG=$1

echo "create: ${LANG}.db"
sqlite3 $LANG.db < $SCRIPT_DIR/nitron-init.sql
for DB in `ls $LANG/*.db` ; do
    echo "merging: ${LANG}.db <- ${DB}"
    echo "DROP VIEW IF EXISTS view_join_rText;" | sqlite3 $DB
    echo "DROP VIEW IF EXISTS view_join_nText;" | sqlite3 $DB
    echo "DROP VIEW IF EXISTS view_join_changes;" | sqlite3 $DB
    echo "DROP VIEW IF EXISTS view_join_patterns;" | sqlite3 $DB
    echo "DROP VIEW IF EXISTS view_FP_rText;" | sqlite3 $DB
    echo "DROP VIEW IF EXISTS view_FP_nText;" | sqlite3 $DB
    echo "DROP VIEW IF EXISTS view_FP_changes;" | sqlite3 $DB
    echo "DROP VIEW IF EXISTS view_FP_patterns;" | sqlite3 $DB
    (
        echo "ATTACH DATABASE \"${DB}\" AS guest;"
        cat $SCRIPT_DIR/nitron-merge.sql
    ) | sqlite3 $LANG.db
done
