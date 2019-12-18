from cyclon import runjar
from os import path
import os
from pathlib import Path
from subprocess import CompletedProcess
import logging


class ChangeExtractor(object):

    """
    call after all jobs.
    """
    @staticmethod
    def cleanLink():
        link = Path("config")
        if (link.is_symlink()):
            os.remove(link)
            logging.info(
                "Removed symbolic link: {}".format(link))

    def __init__(self, jarPath: Path, configPath: Path, heap_GB: int, threadNum: int):
        self.jarPath = jarPath
        self.configPath = configPath
        self.threadNum = threadNum
        self.heap_GB = heap_GB

    def _linkConfigIfNotExist(self):
        tmpConfig = Path("config").absolute()
        if (not tmpConfig.exists()):
            os.symlink(src=self.configPath, dst=tmpConfig,
                       target_is_directory=True)
            logging.info(
                "Created symbolic link: {} -> {}".format(tmpConfig, self.configPath))

    def run(self,
            repoPath: Path,
            dbPath: Path,
            langName: str,
            thread: int = None
            ) -> CompletedProcess:
        softwareName = repoPath.name

        logging.debug("start ChangeExtract: [{}] {} -> {}".format(
            langName, repoPath, dbPath))

        self._linkConfigIfNotExist()

        result = runjar.run(heap_GB=self.heap_GB, jar=self.jarPath,
                            args=[
                                "changes",
                                "-gitrepo", repoPath,
                                "-db", dbPath,
                                "-lang", langName,
                                "-soft", softwareName,
                                "-thd", thread or self.threadNum,
                                "-n", "-q"
                            ])

        if (result.returncode == 0):
            logging.debug("finish ChangeExtract: {}".format(dbPath))
        else:
            logging.error("failed ChangeExtract: {}".format(dbPath))

        return result
