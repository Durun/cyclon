JOBFILE=$1
python3 estimate.py ${JOBFILE}
COSTS=estimated-costs

cat $COSTS >> costs && sort -n -k 3 -t \t costs | uniq > /tmp/costs && mv /tmp/costs costs && rm $COSTS
sort -n -k 3 -t \t costs | uniq > /tmp/costs && mv /tmp/costs costs
