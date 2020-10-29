from pathlib import Path
import subprocess
import logging
import time

sqlBin = "sqlite3"

def run(db: Path, sqlFile: Path) -> subprocess.CompletedProcess:
    elapsedTime = time.perf_counter()
    command = [sqlBin, db]
    commandStringList = [str(c) for c in command]

    with open(sqlFile) as file:
        result = subprocess.run(commandStringList, stdin=file, shell=False)

    elapsedTime = time.perf_counter() - elapsedTime
    logging.info("finish: " + " ".join(commandStringList) + " < "+str(sqlFile))
    logging.info("elapsed time: %.1fmin" % (elapsedTime/60))
    return result
