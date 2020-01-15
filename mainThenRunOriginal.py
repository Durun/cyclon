"""
Usage: mainThenRunOriginal.py JOBFILE

JOBFILE:
lang1 repo1
lang2 repo2
...   ...

"""
import main as mainFile

from cyclon.job import Job
import logging
from typing import List
from pathlib import Path
import sys
from cyclon.env import repoPoolPath, outPath, originalCpanalyzerPath

def process(jobs: List[Job]):
    for job in jobs:
        job.cleanDB().cleanStructure().fetchRepository().runChangesOriginal().runPatterns()
    return

def main():
    mainFile.main()
    args = sys.argv
    if (len(args) != 2):
        print("Usage: mainThenRunOriginal.py JOBFILE\n")
        return
    jobFile = Path(args[1])

    mainFile.checkPath([jobFile, repoPoolPath, outPath,
               originalCpanalyzerPath])

    logging.basicConfig(level=logging.INFO)
    jobs = mainFile.readJobList(jobFile)
    process(jobs)


if __name__ == '__main__':
    main()
