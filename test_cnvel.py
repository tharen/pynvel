'''
Created on Jun 25, 2015

@author: THAREN
'''

import os
import sys

import numpy as np

import pynvel

# print sys.path
# print os.environ['path']

print 'Version:', pynvel.vernum()

region = 6
forest = '04'
district = '12'
species = 202
product = 1

print pynvel.getvoleq(region, forest, district, species, product)
print pynvel.getfiavoleq(region, forest, district, species)

# mrule = pynvel.merchrules_(evod=1)
mrule = pynvel.init_merchrule(evod=1, opt=23, maxlen=40, minlen=12)

print mrule

r = pynvel.get_volume(
        region=6, forest=12, volume_eq='F01FW3W202'
        , dbh_ob=20.0, total_ht=150
        , cruise_type='C'
        , form_class=80
        , ht_ref=33
#         , upper_ht1=17.5, upper_diam1=18.0 * .80
#         , num_logs=3, log_len=[40, 40, 20]
        , merch_rule=mrule
#         , debug=1
#         , cubic_total_flag=1
#         , bdft_prim_flag=1
        )

print 'CuFt Tot.:  ', r['cuft_tot']
print 'CuFt Merch.:', r['cuft_gross_p']
print 'BdFt Merch.:', r['scrib_gross_p']
print 'CuFt Top:   ', r['cuft_gross_s']
print 'CuFt Stump: ', r['cuft_stump']
print 'CuFt Tip:   ', r['cuft_tip']

volcalc = pynvel.VolumeCalculator(
        volume_eq='F01FW3W202'
        , merch_rule=mrule
        )
volcalc.calc(dbh_ob=20.0, total_ht=150.0, form_class=80)

print np.array(volcalc.volume)
