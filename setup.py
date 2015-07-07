"""
Distutils configuration to build the NVEL cython model.

Created on Jun 24, 2015

@author: THAREN
"""

from distutils.core import setup
from Cython.Distutils.extension import Extension
from Cython.Build import cythonize
import numpy
# import numpy.distutils.misc_util

# include_dirs = numpy.distutils.misc_util.get_numpy_include_dirs()

libs = ['vollib', ]
lib_dirs = [r'C:\Python27\libs', '.' ]
inc_dirs = [numpy.get_include()]
extensions = [Extension(
                    'pynvel'
                    , sources=['pynvel.pyx', ]
                    , libraries=libs
                    , library_dirs=lib_dirs
                    , include_dirs=inc_dirs
                    ), ]

setup(ext_modules=cythonize(extensions,))
