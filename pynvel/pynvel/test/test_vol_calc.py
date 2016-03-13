'''
Created on Sep 16, 2015

@author: THAREN
'''

import pynvel

vol_eq = pynvel.get_volume_eq('DF')
# vol_eq = '632BEHW202'
mrule = pynvel.init_merchrule()
v = pynvel.get_volume(
        6, 4, volume_eq=vol_eq, dbh_ob=18.0, total_ht=120.0
        , form_class=82
        , ht_ref=33.0
        , merch_rule=mrule
        , cruise_type='F'
        , cubic_total_flag=0
        , bdft_prim_flag=0
        , cubic_prim_flag=0)

print(v['bdft_gross_prim'])

# vc = pynvel.VolumeCalculator(volume_eq=vol_eq)
#
# print vc.volume_eq
# v = vc.calc(dbh_ob=18.0, total_ht=120.0, form_class=82)
# print pynvel.error_codes[v]
# print vc.volume['bdft_gross_prim']
# print vc.merch_height
# print vc.log_vol
# print vc.logs
