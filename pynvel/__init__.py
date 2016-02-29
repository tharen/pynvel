

__author__ = 'Tod Haren, tod.haren@gm....com'
__version__ = '0.1'

from . import _pynvel

class version:
    api = __version__
    vollib = _pynvel.vernum()

    def __str__(self):
        vs = str({'api':self.api, 'vollib':self.vollib})
        return vs
