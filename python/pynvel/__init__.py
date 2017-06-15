
import os
import sys
import json

import numpy as np

def warn(x):
    print(x)
# warn = lambda x: print(x)

__author__ = 'Tod Haren, tod.haren@gm....com'
__version__ = '0.0.6.dev0'

try:
    from ._pynvel import *
except:
    print(sys.executable)
    print(sys.version)
    raise

from .config import *
from .volume_calculator import VolumeCalculator

class version:
    """Report the version numbers of the API and NVEL(vollib)."""

    api = __version__
    vollib = vollib_version()

    def __call__(self):
        return {'api':self.api, 'vollib':self.vollib}

    def __str__(self):
        vs = str({'api':self.api, 'vollib':self.vollib})
        return vs
