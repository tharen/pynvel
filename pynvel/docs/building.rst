===============
Building PyNVEL
===============

PyNVEL consists of two parts

1. A compiled NVEL library, `vollib`, that provides the volume estimation routines.
2. Python modules containing helper functions and classes, as well as the
   Cython wrappers that link to vollib.

This page describes the dependencies and methods known to work for building the 
PyNVEL package on Windows.

Requirements
------------
    * MinGW-w64: gfortran, gcc, make
    * Python 2.7, or 3.4; 64 bit
    * Numpy >= 1.9
    * Cython
    * CMake

To run the tests and examples you may need to install

    * Nose2
    * Pandas
    
To rebuild the documentation you will also need

    * Sphinx_
    * `Napoleon Extension`_
    * `Bootstrap Theme`_

To ease Python environment management

    * pip_ - pip is included with Python 2.7.9+, and 3.4+
    * setuptools
    * virtualenv
    * Optionally Miniconda_ includes it's own package manager, conda_.

.. _pip: https://docs.python.org/2.7/installing/index.html
.. _Miniconda: http://conda.pydata.org/miniconda.html
.. _conda: http://conda.pydata.org/docs/
.. _Bootstrap Theme: https://ryan-roemer.github.io/sphinx-bootstrap-theme/
.. _Napoleon Extension: http://sphinxcontrib-napoleon.readthedocs.org/en/latest/
.. _Sphinx: http://www.sphinx-doc.org/en/stable/index.html

Install MinGW-w64
+++++++++++++++++

Download the latest release of the MinGW-w64 toolchain for Windows, 
x86_64-5.3.0-release-win32-seh-rt_v4-rev0_ as of this writting. While 
other threading and exception models may work it is recommended to start with
win32 (vs. posix) and SEH (vs. sjlj). Extract the downloaded file to a convenient
location, e.g. `c:\\progs\\mingw64`.

.. _x86_64-5.3.0-release-win32-seh-rt_v4-rev0: https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/5.3.0/threads-win32/seh/

Python Environment
++++++++++++++++++

#. Install target Python version.
#. Use and configure a virtual environment
#. Install Numpy - Numpy binaries can be hard to come by. One good source is 
   `Christoph Gohlke's page`_ at UC Irvine. This page provides unofficial 'wheels' 
   for many Python packages for the scientific community. Since these packages
   are typically very fresh you may choose to used them for all required 
   packages.
#. Install additional dependencies

.. _Christoph Gohlke's page: http://www.lfd.uci.edu/~gohlke/pythonlibs/

It is advisable to utilize virtual environments with Python in order to isolate
potential conflicting dependencies among projects.  This can be handled using
either the default virtualenv package or the alternative conda_ system. 

.. _conda: http://conda.pydata.org/docs/

From a Windows command prompt type:

.. code-block:: bat
    
    >cd c:\workspace\pynvel
    >pip install virtualenv --upgrade
    >virtualenv .\py34_env
    >.\py34_env\scripts\activate
    >python -m pip install pip --upgrade
    >pip install c:\path\to\downloaded\numpy.whl
    >pip install cython

Alternatively using Conda, assuming Miniconda has been installed:

.. code-block:: bat

    >cd c:\workspace\pynvel
    >conda create -p %cd%\py34_conda python=3.4
    >activate .\py34_conda
    >conda install numpy cython
    
Compiling NVEL
++++++++++++++

NVEL is a library of Fortran routines maintained and supported by the United
States Forest Service, Forest Management Service Center, FMSC_. A current copy
of the source code may be obtained by contacting FMSC directly.  The copy 
included here may be out of date.

.. _FMSC: http://www.fs.fed.us/fmsc/measure/volume/nvel/

A CMakelists.txt file has been provided to enable building NVEL from source
using CMake. This configuration will produce both a linked library (.dll|.so) as 
well as an object archive (.a) for static linking.

Configure CMake
~~~~~~~~~~~~~~~

.. code-block:: bat

    >cd c:\path\to\NVEL
    >mkdir build
    >cd build
    >cmake -G "MinGW makefiles" .. -DCMAKE_INSTALL_PREFIX=c:\path\to\pynvel\root ^
        -DTARGET_32BIT=No -DTARGET_NATIVE=yes -DCMAKE_BUILD_TYPE=Release

        
-DCMAKE_INSTALL_PREFIX=<path> determines the location the compiled libraries 
will be installed to.

-DTARGET_32BIT=No sets the -m64 compiler flag for MinGW (-m32 if Yes) to
ensure gcc and gfortran produce 64 bit binaries.

-DTARGET_NATIVE=Yes is used to set certain architecture 
specific compiler flags (math subroutines, etc.)

-DCMAKE_BUILD_TYPE=Release sets compiler optimization flags.
    
Compile and Install
~~~~~~~~~~~~~~~~~~~

.. code-block:: bat
    
    >cmake --build . --target install -- -j4

If this completes successfully you will now have a compiled library in 
`c:\\path\\to\\pynvel\\root` called `libvollib64.dll` (.so on *nix) in addition 
to a static library called `libvollib64_static.a`.

Compile PyNVEL
++++++++++++++

PyNVEL follows standard Python packaging semantics.

#. Build, compile, link the Cython extension::
    
   >cd c:\path\to\pynvel\root
   >python setup.py build_ext

#. Build the documentation::
  
   >pushd pynvel\docs
   >make html
   >popd
   
#. Generate the wheel package::

   >python setup.py bdist_wheel
    