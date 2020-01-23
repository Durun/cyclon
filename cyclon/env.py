from pathlib import Path
from .ChangeExtractor import ChangeExtractor
from .AstImporter import AstImporter
from .PatternMaker import PatternMaker

_binPath = Path("bin").resolve().absolute()

repoPoolPath = Path("repositories").resolve()
outPath = Path("db").resolve()
nitronConfigDir = Path("config").resolve()


cpanalyzerPath = _binPath / "nitron-CPAnalyzer.jar"
originalCpanalyzerPath = _binPath / "CPAnalyzer.jar"
nitronPath = _binPath / "nitron.jar"
estimaterPath = _binPath / "CPAnalyzer-cost-estimate.jar"

defaultThread = 8

extractor = ChangeExtractor(
    jarPath=cpanalyzerPath,
    configPath=nitronConfigDir,
    heap_GB=14,
    threadNum=defaultThread
)

importer = AstImporter(
    nitronJarPath=nitronPath,
    nitronHeap_GB=4
)

patternMaker = PatternMaker(
    jarPath=cpanalyzerPath,
    heap_GB=4
)

estimater = ChangeExtractor(
    jarPath=estimaterPath,
    configPath=nitronConfigDir,
    heap_GB=32,
    threadNum=1
)

originalExtractor = ChangeExtractor(
    jarPath=originalCpanalyzerPath,
    configPath=nitronConfigDir,
    heap_GB=8,
    threadNum=defaultThread
)

originalPatternMaker = PatternMaker(
    jarPath=originalCpanalyzerPath,
    heap_GB=4
)
