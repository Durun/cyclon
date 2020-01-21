JOBFILE=$1
bash logMemoryUsage.bash > ${JOBFILE}.memory.log &
python3 runOriginal.py ${JOBFILE} &> ${JOBFILE}.log
