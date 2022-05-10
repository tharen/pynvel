"""
Setuptools configuration to build the NVEL cython module.
"""
# NOTE: This file contains automated build-time configuration values.
#     The configuration step runs during the CMake configuration.

import os
import sys
import time
import shutil
from glob import glob

from setuptools import setup
from Cython.Distutils.extension import Extension
from Cython.Build import cythonize
import numpy

# Get the path of the current python interpreter
PREFIX = os.path.split(os.path.abspath(sys.executable))[0]

# Monkey patch distutils for use with MinGW-w64 compilers
from distutils import cygwinccompiler
cygwinccompiler.get_msvcr = lambda:['vcruntime140']

# TODO: Add Spinx build step as a custom routine
#       http://stackoverflow.com/questions/1710839/custom-distutils-commands/1712544#1712544

# API version
version = '0.0.8'

description = open('./readme.rst').readlines()[3].strip()
long_desc = open('./readme.rst').read().strip()
shutil.copyfile('./readme.rst', 'pynvel/readme.rst')
shutil.copyfile('./readme.rst', 'pynvel/docs/readme.rst')

try:
    # FIXME: I think this can be handled in MANIFEST.in
    # TODO: This should be called after docs are generated
    shutil.rmtree('./pynvel/docs/html', ignore_errors=True)
    time.sleep(0.05)  # Windows takes a bit to catch up on the delete
    shutil.copytree('./pynvel/docs/_build/html', './pynvel/docs/html')
except:
    pass

static = False
if '--static' in sys.argv:
    static = True
    sys.argv.remove('--static')

debug = False
if '--debug' in sys.argv:
    debug = True
    sys.argv.remove('--debug')

_is_windows = sys.platform=='win32'
_is_64bit = (getattr(sys, 'maxsize', None) or getattr(sys, 'maxint')) > 2 ** 32

lib_dirs = [
        './pynvel'
        , 'C:/workspace/pysftools/pynvel/python/pynvel'
        , 'C:/workspace/pysftools/pynvel/python/pynvel'
        , f'{PREFIX}/Library/bin'
        ]
inc_dirs = [numpy.get_include()]

print('**Link to vollib64')
vollib = 'vollib64'
link_args = []
compile_args = []

if _is_64bit:
    if _is_windows:
        # MinGW-w64 does not include this definition
        define_macros = [('MS_WIN64', None), ]
    else:
        define_macros = []
else:
    define_macros = []

if static:
    # For static linking pass the MinGW archive as an object file
    # TODO: Find the static library dynamically
    vollib = 'C:/workspace/pysftools/pynvel/python/pynvel/lib' + vollib + '_static.a'
    extra_objects = [vollib, ]
    # Link to gfortran and quadmath since vollibxx_static does not include
    #   the necessary references
    libs = ['gfortran', 'quadmath']
    if _is_windows:
        link_args.extend(['-static','-Wno-format',])
        compile_args.extend(['-static','-Wno-format',])

    else:
        link_args.extend(['-Wno-format',])
        compile_args.extend(['-Wno-format',])

else:
    libs = [vollib, ]
    link_args = []
    extra_objects = []
    compile_args = []

if debug:
    link_args = ['-g', ] + link_args
    compile_args = ['-g', ] + compile_args

else:
    link_args = ['-O2', '-Wl,--strip-all'] + link_args
    compile_args = ['-O2', ] + compile_args

# If static linking on non Windows, use -fPIC
if not _is_windows: # and static:
    compile_args.extend(['-fPIC',])
    link_args.extend(['-fPIC',])

# # Use a custom GCC specs file to force linking with the appropriate libmsvcr*.a
# #  Ref: http://www.mingw.org/wiki/HOWTO_Use_the_GCC_specs_file
# #       https://wiki.python.org/moin/WindowsCompilers
# # Populate the spec file template with MSVCR version info
# if _is_64bit and _is_windows:
    # spec_file = './mingw-gcc.specs'
    # v = sys.version_info[:2]
    # open(spec_file, 'w')
    # if v >= (3, 3) and v <= (3, 4):
        # d = {'msvcrt':'msvcr100', 'msvcrt_version':'0x1000', 'moldname':'moldname'}
        # with open(spec_file + '.in') as infile:
            # open(spec_file, 'w').write(infile.read().format(**d))

        # link_args.extend(['-specs={}'.format(spec_file), ])
        # compile_args.extend(['-specs={}'.format(spec_file), ])

    # elif v >= (2, 6) and v <= (3, 2):
        # d = {'msvcrt':'msvcr90', 'msvcrt_version':'0x0900', 'moldname':'moldname'}
        # with open(spec_file + '.in') as infile:
            # open(spec_file, 'w').write(infile.read().format(**d))

        # link_args.extend(['-specs={}'.format(spec_file), ])
        # compile_args.extend(['-specs={}'.format(spec_file), ])

link_args.append('-Wl,--allow-multiple-definition')

# TODO: Need to include libvollib only when linking dynamically rather than always through MANIFEST.in.
extensions = [
        Extension(
                'pynvel._pynvel'
                , sources=['pynvel/_pynvel.pyx', ]
                , extra_objects=extra_objects
                , libraries=libs
                , library_dirs=lib_dirs
                , include_dirs=inc_dirs
                , extra_link_args=link_args
                , extra_compile_args=compile_args
                , define_macros=define_macros
                ),
        ]

setup(
    name='pynvel'
    , version=version
    , description=description
    , long_description=long_desc
    , url='TBA'
    , author="Tod Haren"
    , author_email="tod.haren@gmail.com"
    , setup_requires=['cython>=0.28.2', 'numpy>=1.11.3']
    , tests_require=['pytest', 'pandas', 'numpy', 'pytest-runner']
    , install_requires=[
            'cython>=0.28.2', 'numpy>=1.11.3','click>=6.7'
            ,'pandas>=0.22','xlrd','xlwt']
    , ext_modules=cythonize(extensions, gdb_debug=debug, annotate=True)
    , packages=['pynvel', ]
    , package_data={'pynvel':['test/*.txt', 'test/data/*',]}
    , include_package_data=True  # package the files listed in MANIFEST.in
    # , data_files=[('arcgis',glob('arcgis/*.pyt')),]
    # , package_data={'pynvel':glob('arcgis/*.pyt')}
    , entry_points={
            'console_scripts': [
            'pynvel=pynvel.__main__:cli'
            ]
        }
    )

# Build Command
# >python setup.py build_ext; cp build/lib.win32-2.7/*.pyd .
