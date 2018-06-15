# PyNVEL

A Python package for the National Volume Estimator library.

PyNVEL provides a single class, `VolumeCalculator`, to abstract the interface
with the low level NVEL library functions. PyNVEL uses Cython to accelerate 
bulk processing of tree data and to interface with the NVEL library.

A command line interface is also included for convenient single tree volume
estimation reports and to test various equation and configuration combinations.

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

* [CMake](https://cmake.org/)
* [MinGW-w64](https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/)

  MinGW32 or other MinGW providers will likely work, but have not been tested
  with recent revisions.

### To Build

See [build_notes.txt](./build_notes.txt)

### Usage

Command line interface

    $ pynvel --help
  
Run the unit tests.
  
    $ pynvel run-tests
    
Report the contents of the configuration file. The configuration is stored as
a JSON formatted text file.
  
    $ pynvel configuration>config.json
    
Get a volume report for tree using the default equations. Species, DBH,
and total height are required. Default equations can be changed in the 
configuration file.
    
    $ pynvel volume --help
    $ pynvel volume -sDF -d18 -t120
    
Any valid NVEL equation identifier can be specified.

    $ pynvel volume -eF02FW3W202 -d18 -t120 -f87

Estimate height to specific diameter inside bark along the bole.

    $ pynvel stem-ht --help
    $ pynvel stem-ht -e F02FW3W202 -f 87 -d 18 -t 120 --stem-dib 10.4
    