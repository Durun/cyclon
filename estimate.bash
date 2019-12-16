JOBFILE=$1
python3 estimate.py ${JOBFILE} &> ${JOBFILE}.log
COSTS=estimated-costs
sort -r -k 4 -t \t $COSTS | uniq > /tmp/$COSTS
mv /tmp/$COSTS $COSTS
