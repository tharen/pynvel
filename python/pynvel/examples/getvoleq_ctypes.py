'''
Created on Jun 26, 2015

@author: THAREN
'''

import ctypes

_nvel = ctypes.windll.LoadLibrary('./vollib.dll')

class fchar(ctypes.Structure):
    """
    Represent a Python string as a Fortran character argument
    """
    _fields_ = [
            ('str', ctypes.c_char_p),
            ('len', ctypes.c_int),
             ]


regn = ctypes.c_int(6)
forst = fchar('%-3s' % '04', 3)
dist = fchar('%-3s' % '12', 3)
voleq = fchar('%-11s' % '', 11)
spec = ctypes.c_int(202)
err = ctypes.c_int(0)

_nvel._vernum_(ctypes.byref(err))
print err.value

_nvel._getfiavoleq_(ctypes.byref(regn), forst, dist, ctypes.byref(spec), voleq, ctypes.byref(err))

print voleq.str
print err.value
