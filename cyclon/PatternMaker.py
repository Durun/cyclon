from . import runjar
from subprocess import CompletedProcess
import logging


class PatternMaker(object):
    def __init__(self, jarPath: str, heap_GB: int):
        self.jarPath = jarPath
        self.heap_GB = heap_GB

    def run(self,
            dbPath: str,
            ) -> CompletedProcess:

        logging.debug("start PatternMake: {}".format(dbPath))

        result = runjar.run(heap_GB=self.heap_GB, jar=self.jarPath,
                            args=[
                                "patterns",
                                "-db", dbPath,
                                "-a", "-q"
                            ])

        if (result.returncode == 0):
            logging.debug("finish PatternMake: {}".format(dbPath))
        else:
            logging.error("failed PatternMake: {}".format(dbPath))

        return result
