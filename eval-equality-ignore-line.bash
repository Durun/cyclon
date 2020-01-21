#!/bin/bash
SCRIPT_DIR=`dirname $0`

SQL=$SCRIPT_DIR/cyclon/sql/equality-result-ignore-line.sql

ORIGINAL_DB=$1
NITRON_DB=$2

echo "Original=$ORIGINAL_DB"
echo "Nitron=$NITRON_DB"

echo "Processing..."
cat $SQL | sed -e "s#patterns-original.db#${ORIGINAL_DB}#" | sqlite3 $NITRON_DB
echo "Done. -> $NITRON_DB"
