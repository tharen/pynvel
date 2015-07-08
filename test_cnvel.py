'''
Created on Jun 25, 2015

@author: THAREN
'''

import os
import sys

import pandas as pd
import numpy as np

import pynvel

# print sys.path
# print os.environ['path']

print 'Version:', pynvel.vernum()

region = 6
forest = '04'
district = '12'
species = 202
product = '01'

print pynvel.fia_spp[202]

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
#         , ht_ref=33
#         , upper_ht1=17.5, upper_diam1=18.0 * .80
#         , num_logs=3, log_len=[40, 40, 20]
        , merch_rule=mrule
#         , debug=1
#         , cubic_total_flag=1
#         , bdft_prim_flag=1
        )

volcalc = pynvel.VolumeCalculator(
        volume_eq='F01FW3W202'
        , merch_rule=mrule
        )
volcalc.calc(dbh_ob=20.0, total_ht=150.0, form_class=80)

r = volcalc.volume
print r
print 'CuFt Tot.:  ', r['cuft_tot']
print 'CuFt Merch.:', r['cuft_gross_p']
print 'BdFt Merch.:', r['scrib_gross_p']
print 'CuFt Top:   ', r['cuft_gross_s']
print 'CuFt Stump: ', r['cuft_stump']
print 'CuFt Tip:   ', r['cuft_tip']

# for l in volcalc.log_vol:
#     print l
#
# for l in volcalc.log_diam:
#     print l

for l in volcalc.logs:
    print l.pos, l.bole_ht, l.len, l.large_dib, l.small_dib,
    print l.scale_diam, l.cuft_gross, l.scrib_gross

# print volcalc.volume

# print np.array(volcalc.volume)
# print np.array(volcalc.log_len)


n = 1000
np.random.seed(1234)
dbh = np.random.normal(24.0, 4.0, n)
ht = dbh * 6.3
fc = np.zeros(n, dtype=np.int)
fc[:] = 80
df = pd.DataFrame({'dbh_ob':dbh, 'total_ht':ht, 'form_class':fc})

def volsum(row):
    volcalc.calc(**row)
    vol = volcalc.volume
    cols = ['dbh', 'total_ht', 'form_class', 'volume_eq', 'cuft_tot', 'bdft_gross', 'cuft_gross']
    return pd.Series({
            'cuft_tot':vol['cuft_tot']
            , 'bdft_gross':vol['scrib_gross_p']
            , 'cuft_gross':vol['cuft_gross_p']
            , 'dbh':volcalc.dbh_ob
            , 'total_ht':volcalc.total_ht
            , 'form_class':volcalc.form_class
            , 'volume_eq':volcalc.volume_eq
            }, index=cols)

foo = df.apply(volsum, axis=1)

print foo.head()
