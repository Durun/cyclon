import os
from subprocess import CompletedProcess
from cyclon import runjar
import logging


class AstImporter(object):
    def __init__(self, nitronJarPath: str, nitronHeap_GB: int):
        self.nitronJarPath = nitronJarPath
        self.nitronHeap_GB = nitronHeap_GB

    def run(self, dbPath: str) -> CompletedProcess:
        structurePath = "{}.structures".format(dbPath)

        logging.debug("start import: {} -> {}".format(structurePath, dbPath))

        nitronResult = runjar.run(self.nitronHeap_GB, self.nitronJarPath, [
                                  "importAst", structurePath, dbPath])

        if (nitronResult.returncode == 0):
            logging.debug("finish import: {}".format(dbPath))
        else:
            logging.error("failed import: {}".format(dbPath))

        return nitronResult
