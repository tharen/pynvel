"""
Test volume calculation against an independent version of NVEL.

Validation data come from the published NVEL Excel libraries. Defaults are
used according to Excel library documentation and as indicated in Mrules.f:153

    Excel Volume Functions:
    https://www.fs.fed.us/fmsc/measure/volume/nvel/

    Example Excel functions:
        bdft_gross: =getBdftAdv(6,12,"F01FW2W202",A2,B2,0,5,"F",0,0,0,0,0,0,1,0,0,0,0,0)
        cuft_gross: =getTotCubicAdv(6,12,"F01FW2W202",A2,B2,0,5,"F",0,0,0,0,0,1,0,0,0,0)

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

        pynvel.config = pynvel.get_config()

        # TODO: Test multiple equations using nose-parameterized
        self.vol_eq = 'F01FW2W202'
        self.log_len = 16

        d, f = os.path.split(__file__)
        self.test_data = pd.read_csv('{}/data/{}_{}ft.csv'.format(d, self.vol_eq, self.log_len))

        self.test_data['bdft_test'] = 0.0
        self.test_data['cuft_test'] = 0.0

        # Default region 6 merchandizing; mrules.f:153
        self.mrule = pynvel.init_merchrule(evod=2, opt=23,
                maxlen=self.log_len, minlen=2.0, minlent=2.0,
                merchl=8.0, mtopp=5, mtops=2, trim=0.5, stump=0.0,
                cor='Y', minbfd=8)

    def test_calc(self):
        """
        Test volume calculation against an independent version of NVEL.

        Douglas-fir, Region 6, Siuslaw, 5" min top

        """

        vc = pynvel.VolumeCalculator(
                region=6, forest='12',
                volume_eq=self.vol_eq, merch_rule=self.mrule
                )

        for i, row in self.test_data.iterrows():
            r = vc.calc(dbh_ob=row['dbh_ob'], total_ht=row['total_ht'])

            if r != 0:
                print('error code: {}'.format(r))
                print(row)

            self.test_data.loc[i, 'bdft_test'] = vc.volume['bdft_gross_prim']
            self.test_data.loc[i, 'cuft_test'] = vc.volume['cuft_total']

        # print(self.test_data)
        self.test_data['bdft_diff'] = self.test_data['bdft_gross'] - self.test_data['bdft_test']
        self.test_data['cuft_diff'] = self.test_data['cuft_gross'] - self.test_data['cuft_test']

        d,f = os.path.split(__file__)
        self.test_data.to_csv('{}/data/{}_test.csv'.format(d,self.vol_eq), ',')

        self.assertLessEqual(self.test_data['bdft_diff'].sum(), 1)
        self.assertLessEqual(self.test_data['cuft_diff'].sum(), 1)

    def test_calc_fast(self):
        """
        Test volume calculation against an independent version of NVEL.

        Douglas-fir, Region 6, Siuslaw, 5" min top

        """

        # Ensure the correct data types are represented
        self.test_data[['dbh_ob', 'total_ht']] = self.test_data[['dbh_ob', 'total_ht']].astype('float64')

        vc = pynvel.VolumeCalculator(
                region=6, forest='12',
                volume_eq=self.vol_eq, merch_rule=self.mrule)

        # Calculate volume using the fast Loop
        vol = vc.calc_array(
                self.test_data['dbh_ob'].values,
                self.test_data['total_ht'].values)

        # Ensure VolumeLibrary has not modified the merch rule attributes
        assert vc.merch_rule == self.mrule

        self.test_data['cuft_test'] = vol[:, 0]
        self.test_data['bdft_test'] = vol[:, 2]

        self.test_data['bdft_diff'] = self.test_data['bdft_gross'] - self.test_data['bdft_test']
        self.test_data['cuft_diff'] = self.test_data['cuft_gross'] - self.test_data['cuft_test']

        # self.assertLessEqual(self.test_data['bdft_diff'].sum(), 1)
        self.assertLessEqual(self.test_data['cuft_diff'].sum(), 1)

        assert np.all(vol[:, 3] < self.test_data['total_ht'])  # merch ht. < total ht
        assert np.all(vol[:, 4] > 0)  # Num logs > 0
        assert np.all(vol[:, 5] == 0)  # No NVEL errors

#         test_data.to_csv('data/{}_test.csv'.format(vol_eq), ',')

    def test_calc_products(self):
        """
        Test the product classification.

        Douglas-fir, Region 6, Siuslaw, 5" min top

        """

        # Ensure the correct data types are represented
        self.test_data[['dbh_ob', 'total_ht']] = self.test_data[['dbh_ob', 'total_ht']].astype('float64')

        vc = pynvel.VolumeCalculator(
                region=6, forest='12',
                volume_eq=self.vol_eq, merch_rule=self.mrule
                , calc_products=True)

        # Verify the product classification methods work on arrays
        vol = vc.calc_array(
                self.test_data['dbh_ob'].values,
                self.test_data['total_ht'].values)

        # Ensure VolumeLibrary has not modified the merch rule attributes
        assert vc.merch_rule == self.mrule

        self.test_data['cuft_test'] = vol[:, 0]
        self.test_data['bdft_test'] = vol[:, 2]

        self.test_data['bdft_diff'] = self.test_data['bdft_gross'] - self.test_data['bdft_test']
        self.test_data['cuft_diff'] = self.test_data['cuft_gross'] - self.test_data['cuft_test']

        # self.assertLessEqual(self.test_data['bdft_diff'].sum(), 1)
        self.assertLessEqual(self.test_data['cuft_diff'].sum(), 1)

        assert np.all(vol[:, 3] < self.test_data['total_ht'])  # merch ht. < total ht
        assert np.all(vol[:, 4] > 0)  # Num logs > 0
        assert np.all(vol[:, 5] == 0)  # No NVEL errors

        # Ensure there is data in the product arrays
        assert np.sum(vc.trees_product_cuft) > 0
        assert np.sum(vc.trees_product_bdft) > 0
#         assert np.sum(vc.trees_product_diam) > 0
#         assert np.sum(vc.trees_product_len) > 0
#         assert np.sum(vc.trees_product_count) > 0

        # TODO: Add checks on product volume, diam, etc.

        print('\nTrees')
        print(self.test_data.loc[400:406])
        print('\nProduct CuFt')
        print(np.asarray(vc.trees_product_cuft[400:406, :5]))
        print('\nProduct BdFt')
        print(np.asarray(vc.trees_product_bdft[400:406, :5]))
        print('\nProduct Diam.')
        print(np.asarray(vc.trees_product_diam[400:406, :5]))
        print('\nProduct Length')
        print(np.asarray(vc.trees_product_len[400:406, :5]))
        print('\nProduct Count')
        print(np.asarray(vc.trees_product_count[400:406, :5]))

#         test_data.to_csv('data/{}_test.csv'.format(vol_eq), ',')
if __name__ == "__main__":
    # import sys;sys.argv = ['', 'Test.test_FW01FW2W202']
    unittest.main()
