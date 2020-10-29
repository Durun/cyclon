from pathlib import Path
import subprocess
import logging
import time

sqlBin = "sqlite3"

def run(db: Path, sqlFile: Path) -> subprocess.CompletedProcess:
    elapsedTime = time.perf_counter()
    command = ["bash", "-c", "{} {} < {}".format(sqlBin, db, sqlFile)]

    result = subprocess.run(command)

    elapsedTime = time.perf_counter() - elapsedTime
    logging.info("finish: " + " ".join(command))
    logging.info("elapsed time: %.1fmin" % (elapsedTime/60))
    return result
