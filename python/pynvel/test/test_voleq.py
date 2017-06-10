"""
Test volume calculation against an independent version of NVEL.

Reference:
    http://www.fs.fed.us/fmsc/measure/volume/tablegenerator/index.php

Created on Mar 4, 2016

@author: Tod Haren
"""

import os
import unittest

import numpy as np
import pandas as pd

import pynvel

class Test(unittest.TestCase):

    def setUp(self):
        """
        Test setup, load datasets
        """

        # TODO: Test multiple equations using nose-parameterized
        self.vol_eq = 'F01FW2W202'
        
        d,f = os.path.split(__file__)
        test_bdft = pd.read_csv('{}/data/{}_bdft.txt'.format(d,self.vol_eq))
        test_bdft.columns = ['dbh_ob', 'total_ht', 'bdft_gross']
        test_cuft = pd.read_csv('{}/data/{}_cuft.txt'.format(d,self.vol_eq))
        test_cuft.columns = ['dbh_ob', 'total_ht', 'cuft_gross']

        self.test_data = test_bdft.merge(test_cuft, on=['dbh_ob', 'total_ht'])
        self.test_data[['dbh_ob', 'total_ht']] = self.test_data[['dbh_ob', 'total_ht']].astype('float64')
        self.test_data['bdft_test'] = 0.0
        self.test_data['cuft_test'] = 0.0

        # Default region 6 merchandizing; mrules.f:142
        self.mrule = pynvel.init_merchrule(evod=2, opt=23,
                maxlen=16.0, minlen=2.0, minlent=2.0, merchl=8.0,
                mtopp=5, mtops=2, trim=0.5, stump=0.0,
                cor='N', minbfd=1)

    def test_calc(self):
        """
        Test volume calculation against an independent version of NVEL.
        
        Douglas-fir, Region 6, Siuslaw, 5" min top
        
        Reference:
            http://www.fs.fed.us/fmsc/measure/volume/tablegenerator/index.php
        """

        vc = pynvel.VolumeCalculator(
                region=6, forest='12',
                volume_eq=self.vol_eq, merch_rule=self.mrule)

        for i, row in self.test_data.iterrows():
            r = vc.calc(dbh_ob=row['dbh_ob'], total_ht=row['total_ht'])

            if r != 0:
                print('error code: {}'.format(r))
                print(row)

            self.test_data.loc[i, 'bdft_test'] = vc.volume['bdft_gross_prim']
            self.test_data.loc[i, 'cuft_test'] = vc.volume['cuft_total']

        print(self.test_data)
        self.test_data['bdft_diff'] = self.test_data['bdft_gross'] - self.test_data['bdft_test']
        self.test_data['cuft_diff'] = self.test_data['cuft_gross'] - self.test_data['cuft_test']

        self.assertLessEqual(self.test_data['bdft_diff'].sum(), 1)
        self.assertLessEqual(self.test_data['cuft_diff'].sum(), 1)

#         test_data.to_csv('data/{}_test.csv'.format(vol_eq), ',')

    def test_calc_fast(self):
        """
        Test volume calculation against an independent version of NVEL.
        
        Douglas-fir, Region 6, Siuslaw, 5" min top
        
        Reference:
            http://www.fs.fed.us/fmsc/measure/volume/tablegenerator/index.php
        """

        vc = pynvel.VolumeCalculator(
                region=6, forest='12',
                volume_eq=self.vol_eq, merch_rule=self.mrule)

        # Calculate volume using the fast Loop
        vol = vc.calc_array(
                self.test_data['dbh_ob'].values,
                self.test_data['total_ht'].values)

        self.test_data['cuft_test'] = vol[:, 0]
        self.test_data['bdft_test'] = vol[:, 2]

        self.test_data['bdft_diff'] = self.test_data['bdft_gross'] - self.test_data['bdft_test']
        self.test_data['cuft_diff'] = self.test_data['cuft_gross'] - self.test_data['cuft_test']

        self.assertLessEqual(self.test_data['bdft_diff'].sum(), 1)
        self.assertLessEqual(self.test_data['cuft_diff'].sum(), 1)
        
        assert np.all(vol[:,3] < self.test_data['total_ht']) # merch ht. < total ht
        assert np.all(vol[:,4] > 0) # Num logs > 0
        assert np.all(vol[:,5] == 0) # No NVEL errors

#         test_data.to_csv('data/{}_test.csv'.format(vol_eq), ',')

if __name__ == "__main__":
    # import sys;sys.argv = ['', 'Test.test_FW01FW2W202']
    unittest.main()
