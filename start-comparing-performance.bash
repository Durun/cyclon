JOBFILE=$1
bash logMemoryUsage.bash > ${JOBFILE}.memory.log &
python3 main.py ${JOBFILE} &> ${JOBFILE}.log
