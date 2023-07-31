"""
PyNVEL - A Python interface for the National Volume Estimator Library (NVEL).
"""

# NOTE: This file contains automated build-time configuration values.
#       The configuration step runs during the CMake configuration.

import os
import sys

import toml
import numpy as np

from pynvel._version import __version__,__version_tuple__
from pynvel.volume_height import calc_volume_height

def warn(x):
    print(x)
# warn = lambda x: print(x)

__author__ = 'Tod Haren, tod.haren@gm....com'

try:
    from ._pynvel import *
except:
    print(sys.executable)
    print(sys.version)
    raise

# from ._pynvel import *

if getattr(sys, 'frozen', False):
    exe_folder = os.path.dirname(sys.executable)
    config_path = os.path.join(exe_folder, 'pynvel.toml')
else:
    pkg_path = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.join(pkg_path, 'pynvel.toml')

# print(__file__)
# print(config_path)

default_config = """
[pynvel]
  district = "01"
  forest = "12"
  product = "01"
  region = 6
  variant = "PN"
  default_species = "DF"

  log_products = [
    [24.0,17.0],
    [8.0,12.0],
    [5.0,12.0],
    [2.0,12.0],
    [0.0,0.0],
    ]

  [pynvel.merch_rule]
    btr = 0.0
    cor = "Y"
    dbtbh = 0.0
    evod = 1
    maxlen = 32.0
    minbfd = 8.0
    minlen = 12.0
    minlent = 12.0
    mtopp = 5.0
    mtops = 2.0
    opt = 23
    stump = 1.0
    trim = 1.0

  [pynvel.equations]
    SS = "632TRFW098"
    LP = "632TRFW108"
    PP = "632TRFW122"
    DF = "632TRFW202"
    RC = "632TRFW242"
    WH = "632TRFW263"
    RA = "616TRFW351"
    OH = "616TRFW998"
    OC = "632TRFW202"
    OT = "632TRFW202"
"""

def get_config():
    """
    Return a dict representing the contents of *config_path*.
    """
    # TODO: Create a user config in my documents or appdata, .pynvel/pynvel.cfg
    # TODO: Overlay the user config with the global config.
    cfg = toml.loads(default_config)

    try:
        with open(config_path) as f:
            _cfg = toml.load(f)

        cfg.update(_cfg)

    except:
        raise
        warn(('PyNVEL config does not exist. Writing defaults to {}.'
                ).format(config_path))
        with open(config_path, 'w') as f:
            f.write(toml.dumps(cfg))

    return cfg

class version:
    """Report the version numbers of the API and NVEL(vollib)."""

    api = __version__
    vollib = vollib_version()

    def __call__(self):
        return {'api':self.api, 'vollib':self.vollib}

    def __str__(self):
        vs = str({'api':self.api, 'vollib':self.vollib})
        return vs

config = get_config()

class VolumeCalculator(Cython_VolumeCalculator):
    """
    Subclass the Cython VolumeCalculator cdef class.
    """
    def __init__(self
            , merch_rule=None
            , log_prod_lims=None
            , *args, **kargs):
        """
        Initialize the VolumeCalculator

        Args
        ----
        merch_rule:
        log_prod_lims:
        """
        super(VolumeCalculator, self).__init__(*args, **kargs)

        if merch_rule is None:
            merch_rule = init_merchrule(**config.get('pynvel')['merch_rule'])
        self.merch_rule = merch_rule

        if log_prod_lims is None:
            log_prod_lims = np.array(config.get('pynvel')['log_products'], dtype=np.float32)
        self.log_prod_lims = log_prod_lims

        # ## TODO: Search VolumeLibrary for known equations
        # if len(self.volume_eq.strip)<10
        #     msg = 'Volume equation ID is not valid: "' + self.volume_eq.decode() + '"'
        #     raise ValueError(msg)
