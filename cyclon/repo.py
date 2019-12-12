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
    def fromUrl(url: str):
        return Repository(url)

    def __init__(self, url: str):
        self.url = url
        self.dirPath = repoPoolPath / _repoName(url)
        self.name = self.dirPath.name
        logging.info("Instantiated Repogitory: {} on {}".format(
            self.name, self.dirPath))

    def __str__(self) -> str:
        return self.name

    def _clone(self):
        gitClone(url=self.url, dst=self.dirPath)
        return self

    def cloneIfNotExists(self):
        return self if self.dirPath.exists() else self._clone()
