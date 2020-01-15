JOBFILE=$1
bash logMemoryUsage.bash > ${JOBFILE}.memory.log &
python3 mainThenRunOriginal.py ${JOBFILE} &> ${JOBFILE}.log
