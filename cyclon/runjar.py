from typing import List, Any
from pathlib import Path
import subprocess
import logging
import time


def run(heap_GB: int, jar: Path, args: List[Any]) -> subprocess.CompletedProcess:
    elapsedTime = time.perf_counter()
    command = [
        "java",
        "-ea", "-Xmx" + str(heap_GB) + "g",
        "-jar", jar] + args
    commandStringList = [str(c) for c in command]
    result = subprocess.run(commandStringList, shell=False)

    elapsedTime = time.perf_counter() - elapsedTime
    logging.info("finish: " + " ".join(commandStringList))
    logging.info("elapsed time: %.1fmin" % (elapsedTime/60))
    return result
