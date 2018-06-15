# PyNVEL

A Python package for the National Volume Estimator library.

[National Volume Estimator Library][1]
[NVEL source code][2]

[1]: http://www.fs.fed.us/fmsc/measure/volume/nvel/
[2]: https://github.com/FMSC-Measurements/VolumeLibrary

## Getting Started

### Clone the repository

The NVEL code is included as a Git submodule. 

    git clone --recurse-submodules https://github.com/tharen/pynvel

or for older version of Git.

    git clone https://github.com/tharen/pynvel
    cd pynel
    git submodule update --init --recursive

### Setup the Python Environment

Conda is not specifically required, but is known to work as advertised. Note
that the `conda-forge` channel is prioritized in the environment.yml file.

    conda env create -f python\environment.yml
    
### Install Additional Requirements

* [CMake][https://cmake.org/]
* [MinGW-w64][https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/]

  MinGW32 or other MinGW providers will likely work, but have not been tested
  with recent revisions.

### To Build

See [build_notes.txt]
