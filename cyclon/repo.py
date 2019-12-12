from pathlib import Path
from typing import Optional
import os
import subprocess
from cyclon.env import repoPoolPath
import logging


def gitClone(url: str, dst: Path):
    command = ["git", "clone", url, str(dst)]
    result = subprocess.run(command)
    return


def _repoName(url: str) -> str:
    elems = url.split("/")
    return "{}.{}".format(elems[-2], Path(elems[-1]).stem)


class Repository(object):
    @staticmethod
    def getOrClone(url: str):
        repoPath = repoPoolPath / _repoName(url)
        optionalRepo = Repository._getOrNone(repoPath)
        if (optionalRepo is None):
            optionalRepo = Repository._clone(url)
        return optionalRepo

    @staticmethod
    def _clone(url: str):
        repoPath = repoPoolPath / _repoName(url)
        gitClone(url, dst=repoPath)
        return Repository(dirPath=repoPath)

    @staticmethod
    def _getOrNone(repoPath: Path):
        return Repository(repoPath) if repoPath.exists() else None

    def __init__(self, dirPath: Path):
        self.dirPath = dirPath
        self.name = dirPath.name
        logging.info("Instantiated Repogitory: {} on {}".format(
            self.name, self.dirPath))

    def __str__(self) -> str:
        return self.name
