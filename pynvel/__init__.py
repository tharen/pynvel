
import os
import sys

def warn(x):
    print(x)
# warn = lambda x: print(x)

__author__ = 'Tod Haren, tod.haren@gm....com'
__version__ = '0.1'

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
        'variant':'PN',
        'region':6,
        'forest':'12',
        'district':'01',
        'product':'01',

        'merch_rule':{
            'evod':1, 'opt':23, 'maxlen':40.0, 'minlen':12.0, 'minlent':12.0,
            'mtopp':5.0, 'mtops':2.0, 'stump':1.0, 'trim':1.0,
            'btr':0.0, 'dbtbh':0.0, 'minbfd':8.0, 'cor':'Y'
        }
    }"""

def get_config():
    """
    Return a dict representing the contents of *config_path*.
    """
    # TODO: Create a user config in my documents or appdata, .pynvel/pynvel.cfg
    # TODO: Overlay the user config with the global config.
    try:
        cfg = eval(open(config_path).read())
    except:
        warn(('PyNVEL config does not exist. Writing defaults to {}.'
                ).format(config_path))
        cfg = eval(default_config)
        with open(config_path, 'w') as f:
            f.write(default_config)
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
