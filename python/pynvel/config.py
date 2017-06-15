
import os
import sys
import json

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
