from cyclon.repo import Repository
from cyclon.env import extractor, originalExtractor, importer, patternMaker, estimater, outPath, defaultThread
from typing import Union
from pathlib import Path
import shutil
import logging
import os
import subprocess


class Job(object):
    @staticmethod
    def fromUrl(repoUrl: str, lang: str, thread: int = defaultThread):
        return NormalJob(
            repo=Repository.fromUrl(url=repoUrl),
            lang=lang,
            thread=thread
        )

    def fetchRepository(self):
        raise NotImplementedError

    def runEstimate(self):
        raise NotImplementedError

    def runChanges(self):
        raise NotImplementedError

    def runChangesOriginal(self):
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
    def __init__(self, repo: Repository, lang: str, thread: int = defaultThread):
        self.repo = repo
        self.dbPath = outPath / lang / (repo.name + ".db")
        self.lang = lang
        self.thread = thread
        os.makedirs(self.dbPath.parent, exist_ok=True)
        logging.info("Instantiated Job: {}".format(self))

    def __str__(self) -> str:
        return "[{}] {}".format(self.lang, self.repo)

    def toFailureIf(self, isFailure: bool) -> Job:
        if (isFailure):
            logging.error("Failed Job: {}".format(self))
            return FailuredJob(self)
        else:
            return self

    def fetchRepository(self) -> Job:
        self.repo.cloneIfNotExists()
        return self.toFailureIf(not self.repo.dirPath.exists())

    def runEstimate(self) -> Job:
        if (not self.repo.dirPath.exists()):
            logging.warn(
                "Passed Estimate Job: {} Repo not exists.".format(self))
            return self.toFailureIf(True)

        logging.info("Start Estimate Job: {}".format(self))
        result = estimater.run(
            repoPath=self.repo.dirPath,
            dbPath=self.dbPath,
            langName=self.lang
        )
        try:
            with open("{}.cost".format(self.dbPath.absolute())) as input:
                lines = input.read().splitlines()
            entry = lines[0] + "\n" + lines[1] + "\t" + \
                self.lang + " " + self.repo.url + "\n"
            with open("estimated-costs", "a") as output:
                output.write(entry)
        except FileNotFoundError as err:
            logging.error(err)
            return self.toFailureIf(True)
        return self.toFailureIf(result.returncode != 0)

    def runChanges(self) -> Job:
        if (not self.repo.dirPath.exists()):
            logging.warn(
                "Passed ChangeExtract Job: {} Repo not exists.".format(self))
            return self.toFailureIf(True)

        if (self.dbPath.exists()):
            logging.info(
                "Passed ChangeExtract Job: {} DB exists.".format(self))
            return self

        logging.info("Start ChangeExtract Job: {}".format(self))
        result = extractor.run(
            repoPath=self.repo.dirPath,
            dbPath=self.dbPath,
            langName=self.lang,
            thread=self.thread
        )
        return self.toFailureIf(result.returncode != 0)

    def runChangesOriginal(self) -> Job:
        if (not self.repo.dirPath.exists()):
            logging.warn(
                "Passed ChangeExtractOriginal Job: {} Repo not exists.".format(self))
            return self.toFailureIf(True)

        if (self.dbPath.exists()):
            logging.info(
                "Passed ChangeExtractOriginal Job: {} DB exists.".format(self))
            return self

        logging.info("Start ChangeExtractOriginal Job: {}".format(self))
        result = originalExtractor.run(
            repoPath=self.repo.dirPath,
            dbPath=self.dbPath,
            langName=self.lang,
            thread=self.thread
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

    def fetchRepository(self) -> Job:
        logging.warn("Passed run Fetch: {}".format(self))
        return self

    def runEstimate(self) -> Job:
        logging.warn("Passed run Estimate: {}".format(self))
        return self

    def runChanges(self) -> Job:
        logging.warn("Passed run Changes: {}".format(self))
        return self

    def runChangesOriginal(self) -> Job:
        logging.warn("Passed run ChangesOriginal: {}".format(self))
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
