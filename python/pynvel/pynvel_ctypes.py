"""
Demonstrate calling the nvel library using ctypes.
"""

from ctypes import byref, cdll, c_int, c_float,c_char,c_char_p,Structure

nvel = cdll.LoadLibrary(r'.\libvollib64.dll')

dbh = 18.0
height = 120.0
fc = 80

variant = c_char_p(b'PN')
district = c_char_p(b'01')
species = c_int(202)
product = c_char_p(b'01')

region = c_int(6)
forest = c_char_p(b'01')
voleq = c_char_p(b'          ')
min_top_prim = c_float(5.0)
min_top_sec = c_float(2.0)
stump_ht = c_float(1.0)
dbh_ob = c_float(dbh)
drc_ob = c_float(0.0)
ht_type = c_char_p(b'F')
total_ht = c_float(height)
ht_log = c_int()
ht_prim = c_float(0)
ht_sec = c_float(0)
upper_ht1 = c_float(0)
upper_ht2 = c_float(0)
upper_diam1 = c_float(0)
upper_diam2 = c_float(0)
ht_ref = c_int(0)
avg_z1 = c_float(0)
avg_z2 = c_float(0)
form_class = c_int(fc)
bark_thick = c_float(0)
bark_ratio = c_float(0)
i3 = c_int(3)
i7 = c_int(7)
i15 = c_int(15)
i20 = c_int(20)
i21 = c_int(21)

volume_wk = (c_float*15)()
log_vol_wk = ((c_float*7)*20)()
log_diam_wk = ((c_float*21)*3)()
log_len_wk = (c_float*20)()
bole_ht_wk = (c_float*21)()

num_logs = c_int(0)
num_logs_prim = c_int(0)
num_logs_sec = c_int(0)
cubic_total_flag = c_int(1)
bdft_prim_flag = c_int(1)
cubic_prim_flag = c_int(1)
cord_prim_flag = c_int(1)
sec_vol_flag = c_int(1)
con_spp = c_char_p(b'')
prod_code = c_char_p(b'01')
ht_1st_limb = c_int(0)
live = c_char_p(b'L')
basal_area = c_int(0)
site_index = c_int(0)
cruise_type = c_char_p(b'C')
error_flag = c_int(0)
idist = c_int(0)

class MerchRule(Structure):
    _fields_ = [
        ('evod', c_int),
        ('opt', c_int),
        ('maxlen', c_float),
        ('minlen', c_float),
        ('minlent', c_float),
        ('merchl', c_float),
        ('mtopp', c_float),
        ('mtops', c_float),
        ('stump', c_float),
        ('trim', c_float),
        ('btr', c_float),
        ('dbtbh', c_float),
        ('minbfd', c_float),
        #NOTE: **Must be single char, not pointer. Unsure how to pass a len arg in a struct
        ('cor', c_char)
        ]

mrule = MerchRule()
mrule.evod = 1
mrule.opt = 23
mrule.maxlen = 40.0
mrule.minlen = 12.0
mrule.minlent = 12.0
mrule.merchl = 12.0
mrule.mtopp = 5.0
mrule.mtops = 2.0
mrule.stump = 1.0
mrule.trim = 1.0
mrule.btr = 0.0
mrule.dbtbh = 0.0
mrule.minbfd = 8.0
mrule.cor = b'N'

# Get the default equation
nvel.voleqdef_(variant, byref(region), forest, district, byref(species)
        , product, voleq, byref(error_flag),2,2,2,2,10)

voleq = c_char_p(b'F02FW2W202')
print(voleq.value)


r = nvel.volinit2_(
        byref(region)
        , forest
        , voleq
        , byref(min_top_prim)
        , byref(min_top_sec)
        , byref(stump_ht)
        , byref(dbh_ob)
        , byref(drc_ob)
        , ht_type
        , byref(total_ht)
        , byref(ht_log)
        , byref(ht_prim)
        , byref(ht_sec)
        , byref(upper_ht1)
        , byref(upper_ht2)
        , byref(upper_diam1)
        , byref(upper_diam2)
        , byref(ht_ref)
        , byref(avg_z1)
        , byref(avg_z2)
        , byref(form_class)
        , byref(bark_thick)
        , byref(bark_ratio)
        , byref(i3)
        , byref(i7)
        , byref(i15)
        , byref(i20)
        , byref(i21)
        , byref(volume_wk)
        , byref(log_vol_wk)
        , byref(log_diam_wk)
        , byref(log_len_wk)
        , byref(bole_ht_wk)
        , byref(num_logs)
        , byref(num_logs_prim)
        , byref(num_logs_sec)
        , byref(cubic_total_flag)
        , byref(bdft_prim_flag)
        , byref(cubic_prim_flag)
        , byref(cord_prim_flag)
        , byref(sec_vol_flag)
        , con_spp
        , prod_code
        , byref(ht_1st_limb)
        , live
        , byref(basal_area)
        , byref(site_index)
        , cruise_type
        , byref(error_flag)
        , byref(mrule)
        , byref(idist)

        ,2,10,1,2,2,1,1
    )

print('Error:', error_flag.value)
print('Num Logs:', num_logs.value)
print('Tot CuFt:', volume_wk[0])
print('Net BdFt:', volume_wk[1])
print('Net CuFt:', volume_wk[3])
print('Top CuFt:', volume_wk[6])
print('Stump CuFt:', volume_wk[13])
print('Tip CuFt:', volume_wk[14])
print(volume_wk[14]+volume_wk[13]+volume_wk[6]+volume_wk[3])

print('')
for i,l in enumerate(log_len_wk):
    print(log_len_wk[i])