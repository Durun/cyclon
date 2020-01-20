#!/bin/bash

# Usage: COMMAND LANG
# Output: QUERY.response.json QUERY.job

SCRIPT_DIR=`dirname $0`
GETBYURL="python $SCRIPT_DIR/getByUrl.py"
PRINTREPOS="python $SCRIPT_DIR/printRepos.py"

LANG=$1

SORTBY=stars
#QUERY="language:${LANG}+stars:>100"
QUERY="language:${LANG}"
REQUEST="q=${QUERY}&sort=${SORTBY}"

URL="https://api.github.com/search/repositories?${REQUEST}"

$GETBYURL $URL | tee "${QUERY}-${SORTBY}.response.json" | $PRINTREPOS > ${QUERY}.job
