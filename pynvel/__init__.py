
import sys

__author__ = 'Tod Haren, tod.haren@gm....com'
__version__ = '0.1'

try:
    from ._pynvel import *
except:
    print(sys.executable)
    print(sys.version)
    raise

# from ._pynvel import *

class version:
    api = __version__
    vollib = vollib_version()

    def __str__(self):
        vs = str({'api':self.api, 'vollib':self.vollib})
        return vs
