from pathlib import Path
from .ChangeExtractor import ChangeExtractor
from .AstImporter import AstImporter
from .PatternMaker import PatternMaker

_binPath = Path("bin").resolve().absolute()

repoPoolPath = Path("repositories").resolve()
outPath = Path("db").resolve()
nitronConfigDir = Path("config").resolve()


cpanalyzerPath = _binPath / "nitron-CPAnalyzer.jar"
nitronPath = _binPath / "nitron.jar"
estimaterPath = _binPath / "CPAnalyzer-cost-estimate.jar"

defaultThread = 20

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
