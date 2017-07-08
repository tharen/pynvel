
import os
import sys
import json

import numpy as np

def warn(x):
    print(x)
# warn = lambda x: print(x)

__author__ = 'Tod Haren, tod.haren@gm....com'
__version__ = '0.0.6.dev5'

try:
    from ._pynvel import *
except:
    print(sys.executable)
    print(sys.version)
    raise

# from ._pynvel import *

if getattr(sys, 'frozen', False):
    exe_folder = os.path.dirname(sys.executable)
    config_path = os.path.join(exe_folder, 'pynvel.cfg')
else:
    pkg_path = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.join(pkg_path, 'pynvel.cfg')

# print(__file__)
# print(config_path)

default_config = """{
	"variant": "PN",
	"region": 6,
	"forest": "12",
	"district": "01",
	"product": "01",

	"merch_rule": {
		"evod": 1,
		"opt": 23,
		"maxlen": 40.0,
		"minlen": 12.0,
		"minlent": 12.0,
		"mtopp": 5.0,
		"mtops": 2.0,
		"stump": 1.0,
		"trim": 1.0,
		"btr": 0.0,
		"dbtbh": 0.0,
		"minbfd": 8.0,
		"cor": "Y"
	},

	"log_products": [
		[24.0, 17.0],
		[8.0, 12.0],
		[5.0, 12.0],
		[2.0, 12.0],
		[0.0, 0.0]
	]

}"""

def get_config():
    """
    Return a dict representing the contents of *config_path*.
    """
    # TODO: Create a user config in my documents or appdata, .pynvel/pynvel.cfg
    # TODO: Overlay the user config with the global config.
    try:
        cfg = json.load(open(config_path))
    except:
        warn(('PyNVEL config does not exist. Writing defaults to {}.'
                ).format(config_path))
        cfg = json.loads(default_config)
        with open(config_path, 'w') as f:
            f.write(json.dumps(cfg, indent=4, sort_keys=True))
#         raise IOError('Could not load the config file.')

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
        super().__init__(*args, **kargs)
        
        if merch_rule is None:
            merch_rule = init_merchrule(**config['merch_rule'])
        self.merch_rule = merch_rule
        
        if log_prod_lims is None:
            log_prod_lims = np.array(config['log_products'], dtype=np.float32)
        self.log_prod_lims = log_prod_lims
