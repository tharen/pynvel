'''
Created on Jun 25, 2015

@author: THAREN
'''

import os
import sys

import pandas as pd
import numpy as np

import pynvel

# print(sys.path)
# print(os.environ['path'])

print('Version:'.format(pynvel.version()))

variant = ''
region = 6
forest = '12'
district = '01'
species = 202
product = '01'

print(pynvel.fia_spp[202])

print(pynvel.get_equation(species, variant, region, forest, district, product))
print(pynvel.get_equation(species, variant, region, forest, district, fia=True))

# mrule = pynvel.merchrules_(evod=1)
mrule = pynvel.init_merchrule(
        evod=1, opt=23, maxlen=39, minlen=12
        , cor='Y')

print('**', mrule)

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
        , cruise_type='V'
        )
volcalc.calc(dbh_ob=20.0, total_ht=150.0, form_class=82
        , log_len=np.array([40, 30, 20, 10]))

r = volcalc.volume
print(r)
print('CuFt Tot.:  ', r['cuft_total'])
print('CuFt Merch.:', r['cuft_gross_prim'])
print('BdFt Merch.:', r['bdft_gross_prim'])
print('CuFt Top:   ', r['cuft_gross_sec'])
print('CuFt Stump: ', r['cuft_stump'])
print('CuFt Tip:   ', r['cuft_tip'])

# for l in volcalc.log_vol:
#     print(l)
#
# for l in volcalc.log_diam:
#     print(l)

for l in volcalc.logs:
    print(l.pos, l.bole_ht, l.length, l.large_dib, l.small_dib,)
    print(l.scale_diam, l.cuft_gross, l.bdft_gross)

# print(volcalc.volume)

# print(np.array(volcalc.volume))
# print(np.array(volcalc.log_len))


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
            'cuft_total':vol['cuft_total']
            , 'bdft_gross':vol['bdft_gross_prim']
            , 'cuft_gross':vol['cuft_gross_prim']
            , 'dbh':volcalc.dbh_ob
            , 'total_ht':volcalc.total_ht
            , 'form_class':volcalc.form_class
            , 'volume_eq':volcalc.volume_eq
            }, index=cols)

volcalc = pynvel.VolumeCalculator(
        volume_eq='F01FW3W202'
        , merch_rule=mrule
        )

foo = df.apply(volsum, axis=1)

print(foo.head())

# print(sys.executable)
# raw_input('WTF')
