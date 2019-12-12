from cyclon.repo import Repository
from cyclon.env import extractor, importer, patternMaker, outPath
from typing import Union
from pathlib import Path
import shutil
import logging
import os


class Job(object):
    @staticmethod
    def fromUrl(repoUrl: str, lang: str):
        return NormalJob(
            repo=Repository.fromUrl(url=repoUrl),
            lang=lang
        )

    def runChanges(self):
        raise NotImplementedError

    def runImport(self):
        raise NotImplementedError

    def runPatterns(self):
        raise NotImplementedError

    def cleanRepository(self):
        raise NotImplementedError

    def cleanStructure(self):
        raise NotImplementedError

    def cleanDB(self):
        raise NotImplementedError


class NormalJob(Job):
    def __init__(self, repo: Repository, lang: str):
        self.repo = repo
        self.dbPath = outPath / (repo.name + ".db")
        self.lang = lang
        logging.info("Instantiated Job: {}".format(self))

    def __str__(self) -> str:
        return "[{}] {}".format(self.lang, self.repo)

    def toFailureIf(self, isFailure: bool) -> Job:
        if (isFailure):
            logging.error("Failed Job: {}".format(self))
            return FailuredJob(self)
        else:
            return self

    def runChanges(self) -> Job:
        self.repo.cloneIfNotExists()
        if (self.dbPath.exists()):
            logging.info(
                "Passed ChangeExtract Job: {} DB exists.".format(self))
            return self
        logging.info("Start ChangeExtract Job: {}".format(self))
        result = extractor.run(
            repoPath=self.repo.dirPath,
            dbPath=self.dbPath,
            langName=self.lang
        )
        return self.toFailureIf(result.returncode != 0)

    def runImport(self) -> Job:
        logging.info("Start AstImport Job: {}".format(self))
        result = importer.run(dbPath=self.dbPath)
        return self.toFailureIf(result.returncode != 0)

    def runPatterns(self) -> Job:
        logging.info("Start Patterns Job: {}".format(self))
        result = patternMaker.run(
            dbPath=self.dbPath
        )
        return self.toFailureIf(result.returncode != 0)

    def _removeOnDemand(self, path: Path) -> Job:
        if (path.exists()):
            try:
                if (path.is_dir()):
                    shutil.rmtree(path)
                else:
                    os.remove(path)
                logging.info("Removed: {}".format(path))
            except OSError as err:
                logging.error(err)
                return self.toFailureIf(True)
        return self

    def cleanRepository(self) -> Job:
        return self._removeOnDemand(path=self.repo.dirPath)

    def cleanStructure(self) -> Job:
        return self._removeOnDemand(path=Path(str(self.dbPath)+".structures"))

    def cleanDB(self) -> Job:
        return self._removeOnDemand(path=self.dbPath)


class FailuredJob(Job):
    def __init__(self, base: NormalJob):
        self.base = base

    def __str__(self) -> str:
        return str(self.base)

    def runChanges(self) -> Job:
        logging.warn("Passed run Changes: {}".format(self))
        return self

    def runImport(self) -> Job:
        logging.warn("Passed run Import: {}".format(self))
        return self

    def runPatterns(self) -> Job:
        logging.warn("Passed run Patterns: {}".format(self))
        return self

    def cleanRepository(self) -> Job:
        logging.warn("Passed clean Repository: {}".format(self))
        return self

    def cleanStructure(self) -> Job:
        logging.warn("Passed clean Structure: {}".format(self))
        return self

    def cleanDB(self) -> Job:
        logging.warn("Passed clean DB: {}".format(self))
        return self
