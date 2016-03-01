"""
Setuptools configuration to build the NVEL cython module.

Created on Jun 24, 2015

@author: THAREN
"""

import sys
import shutil
from glob import glob

from setuptools import setup
from Cython.Distutils.extension import Extension
from Cython.Build import cythonize
import numpy
# import numpy.distutils.misc_util

version = '0.1'

description = open('./readme.rst').readline().strip()
long_desc = open('./readme.rst').read().strip()
shutil.copyfile('./readme.rst', 'pynvel/readme.rst')
shutil.copyfile('./readme.rst', 'pynvel/docs/readme.rst')

static = True
debug = False
_is_64bit = (getattr(sys, 'maxsize', None) or getattr(sys, 'maxint')) > 2 ** 32

lib_dirs = ['./pynvel', ]
if _is_64bit:
    print('**Link to vollib64')
    vollib = 'vollib64'
    # MinGW-w64 does not include this definition
    link_args = ['-DMS_WIN64', ]
    compile_args = ['-DMS_WIN64', ]
else:
    vollib = 'vollib'
    link_args = []
    compile_args = []

inc_dirs = [numpy.get_include()]

if static:
    vollib = vollib + '_static'
    libs = [vollib, ]
    # Link to gfortran and quadmath since vollibxx_static does not include
    #   the necessary references
    libs.extend(['gfortran', 'quadmath'])
    link_args.extend(['-static', '-Wno-format'])
    compile_args.extend(['-static', '-Wno-format'])

else:
    libs = [vollib, ]
    link_args = []
    compile_args = []

if debug:
    link_args = ['-g', ] + link_args
    compile_args = ['-g', ] + compile_args

extensions = [
        Extension(
                'pynvel._pynvel'
                , sources=['pynvel/_pynvel.pyx', ]
                , libraries=libs
                , library_dirs=lib_dirs
                , include_dirs=inc_dirs
                , extra_link_args=link_args
                , extra_compile_args=compile_args
                ),
#         Extension(
#                 'pynvel._volinit2'
#                 , sources=['pynvel/_volinit2.pyx', ]
#                 , libraries=libs
#                 , library_dirs=lib_dirs
#                 , include_dirs=inc_dirs
#                 ),
        ]

setup(
    name='pynvel'
    , version=version
    , description=description
    , long_description=long_desc
    , url=''
    , author="Tod Haren"
    , author_email="tod.haren@gmail.com"
    , setup_requires=['cython', 'numpy>=1.9', ]
    , tests_require=['nose2', ]
    , install_requires=['numpy>=1.9', ]
    , ext_modules=cythonize(extensions, gdb_debug=True,)
    , packages=['pynvel', ]
    , include_package_data=True  # package the files listed in MANIFEST.in
    # , data_files=[('arcgis',glob('arcgis/*.pyt')),]
    # , package_data={'pynvel':glob('arcgis/*.pyt')}
    , entry_points={
            'console_scripts': [
            'pynvel=pynvel.__main__:main'
            ]
        }
    , test_suite='nose2.collector.collector'
    )

# Build Command
# >python setup.py build_ext; cp build/lib.win32-2.7/*.pyd .
