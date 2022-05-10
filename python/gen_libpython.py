"""
Rebuild libpython MinGW import library
"""

import os
import sys
import subprocess

if not sys.platform=='win32':
    print('Not a Windows platform. Skipping libpython generation.')
    sys.exit()
    
py_ver = ''.join(str(v) for v in sys.version_info[:2])
pfx = sys.exec_prefix

# Find the python DLL
o = subprocess.check_output('where python{}.dll'.format(py_ver))
try:
    py_dll = o.decode().split('\r\n')[0]
except:
    print('Error locating Python DLL. Make sure it is available in the search path.')
    sys.exit(1)

# Find the vcruntime DLL
vc_ver = 140
o = subprocess.check_output('where vcruntime{}.dll'.format(vc_ver))
try:
    vc_dll = o.decode().split('\r\n')[0]
except:
    print('Error locating vcruntime DLL. Make sure it is available in the search path.')
    sys.exit(1)
    
print('Build libpython MinGW import libraris')
print('Python version: {}'.format(sys.version_info[:2]))
print('Python DLL: {}'.format(py_dll))
print('VC Runtime DLL: {}:'.format(vc_dll))
print('')

# pwd = os.path.abspath(os.curdir)
# os.chdir(os.path.join(pfx,'libs'))

cmd = ['gendef',py_dll] #os.path.join(pfx,dll)]
print('CMD: ' + ' '.join(cmd))
subprocess.call(cmd)

cmd = ['dlltool','--dllname',py_dll,'--def','python{}.def'.format(py_ver)
    ,'--output-lib','libpython{}.a'.format(py_ver)]

print('CMD: ' + ' '.join(cmd))
subprocess.call(cmd)

# Repeat for VC Runtime
cmd = ['gendef',vc_dll]
print('CMD: ' + ' '.join(cmd))
subprocess.call(cmd)

cmd = ['dlltool','--dllname',vc_dll,'--def','vcruntime{}.def'.format(vc_ver)
    ,'--output-lib','libvcruntime{}.a'.format(vc_ver)]

print('CMD: ' + ' '.join(cmd))
subprocess.call(cmd)
    
# os.chdir(pwd)