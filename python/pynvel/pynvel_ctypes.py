from ctypes import byref, cdll, c_int, c_float,c_char_p

nvel = cdll.LoadLibrary(r'C:\workspace\pyforestsim\pyforestsim\nvel\pynvel\pynvel\libvollib64.dll')

variant = c_char_p('PN')
region = c_int(6)
forest = c_char_p('01')
district = c_char_p('01')
species = c_int(202)
product = c_char_p('01')
voleq = c_char_p('          ')
err = c_int(0)


nvel.voleqdef_(variant, byref(region), forest, district, byref(species), product, voleq, byref(err)
        ,variant,2,2,2,2,10)
print(voleq.value)

#s = c_char_p()
#s.value = 'aaa'
#nvel.foo_(s)
#print(s)