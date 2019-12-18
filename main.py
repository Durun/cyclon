"""
Usage: main.py JOBFILE

JOBFILE:
lang1 repo1
lang2 repo2
...   ...

"""

from cyclon.job import Job
import logging
from typing import List
from pathlib import Path
import sys
from cyclon.env import repoPoolPath, outPath, cpanalyzerPath, nitronPath, defaultThread


def readJobList(filename: str) -> List[Job]:
    with open(filename, "r") as file:
        # remove linebreak
        lines = [line.replace("\n", "") for line in file]
        parsedList = [line.split(" ") for line in lines]
        # remove invalid row
        parsedList = list(filter(lambda t: len(t) >= 2, parsedList))

        jobs = [Job.fromUrl(
            lang=args[0],
            repoUrl=args[1],
            thread=args[2] if len(args) > 2 else defaultThread
        ) for args in parsedList]
    for job in jobs:
        logging.info("queued : {}".format(job))
    return jobs


def process(jobs: List[Job]):
    for job in jobs:
        job.cleanDB().cleanStructure().fetchRepository().runChanges().runImport(
        ).cleanStructure().runPatterns().cleanRepository()
    return


def checkPath(paths: List[Path]):
    notExists = list(filter(lambda p: not p.exists(), paths))
    for path in notExists:
        print("Not exists: {}".format(path.absolute()))
    if 0 < len(notExists):
        exit(-1)


def main():
    args = sys.argv
    if (len(args) != 2):
        print("Usage: main.py JOBFILE\n")
        return
    jobFile = Path(args[1])

    checkPath([jobFile, repoPoolPath, outPath, cpanalyzerPath, nitronPath])

    logging.basicConfig(level=logging.INFO)

    jobs = readJobList(jobFile)
    process(jobs)


if __name__ == '__main__':
    main()
