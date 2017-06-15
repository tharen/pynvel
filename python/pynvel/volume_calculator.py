
import numpy as np

from . import *
from ._pynvel import Cython_VolumeCalculator

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
        config = get_config()
        super().__init__(*args, **kargs)
        
        if merch_rule is None:
            merch_rule = init_merchrule(**config['merch_rule'])
        self.merch_rule = merch_rule
        
        if log_prod_lims is None:
            log_prod_lims = np.array(config['log_products'], dtype=np.float32)
        self.log_prod_lims = log_prod_lims
