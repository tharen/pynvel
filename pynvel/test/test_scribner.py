"""
Created 2016

@author: Tod Haren, tod.haren@gmail.com
"""
import unittest

import numpy as np
import pynvel

class Test(unittest.TestCase):


    def setUp(self):
        pass


    def tearDown(self):
        pass


    def test_scribner(self):
        diams = np.arange(4,24,2)
        lens = np.arange(4,44,4)
        vols = np.zeros((diams.shape[0],lens.shape[0]))
        v = np.zeros((lens.shape[0]))
        f = np.vectorize(pynvel.scribner_volume)
        for i,d in enumerate(diams):
            v=f(d,lens,False)
            vols[i]=v

        print(vols)


if __name__ == "__main__":
    # import sys;sys.argv = ['', 'Test.testName']
    unittest.main()
