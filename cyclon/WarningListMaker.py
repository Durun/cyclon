from . import runjar, runsql
from subprocess import CompletedProcess
import logging
import subprocess
from typing import Union


class WarningListMaker(object):
    """
    jarPath: str
        Specify the path to Ammonia.jar
    """
    def __init__(self, jarPath: str, setupBugTablesSql: str, heap_GB: int):
        self.jarPath = jarPath
        self.setupBugTablesSql = setupBugTablesSql
        self.heap_GB = heap_GB

    def run(self,
            dbPath: str,
            warningDbPath: str,
            lang: str,
            gitRepoPath: str
            ) -> CompletedProcess:
        logging.debug("start WarningList: {}".format(warningDbPath))

        setupResult = self.__setupDatabase(dbPath)
        if (setupResult.returncode != 0):
            logging.error("failed WarningList: Can't apply SQL > {}".format(dbPath))
            return setupResult

        commitID = self.__getCommitID(gitRepoPath)

        result = runjar.run(heap_GB=self.heap_GB, jar=self.jarPath,
                            args=[
                                "-db", dbPath,
                                "-lang", lang,
                                "-gitrepo", gitRepoPath,
                                "-gitcommit", commitID,
                                "-wldb", warningDbPath
                            ])

        if (result.returncode == 0):
            logging.debug("finish WarningList: {}".format(warningDbPath))
        else:
            logging.error("failed WarningList: {}".format(warningDbPath))

        return result

    def __setupDatabase(self, dbPath: str) -> CompletedProcess:
        result = runsql.run(
            db=dbPath,
            sqlFile=self.setupBugTablesSql
        )
        return result

    def __getCommitID(self, repoPath: str, branch: Union[str, None] = None) -> str:
        command = [
            "git", "log",
            "--format=format:\"%H\""
        ]
        if branch is not None: command.append(branch)
        result = subprocess.run(command, cwd=repoPath, shell=False, stdout=subprocess.PIPE)
        ids = result.stdout.decode().split("\n")
        id = ids[0].replace("\"", "")
        return id
