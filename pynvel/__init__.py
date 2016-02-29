

__author__ = 'Tod Haren, tod.haren@gm....com'
__version__ = '0.1'

from ._pynvel import *

class version:
    api = __version__
    vollib = vernum()

    def __str__(self):
        vs = str({'api':self.api, 'vollib':self.vollib})
        return vs
