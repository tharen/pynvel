======
PyNVEL
======

Command Line
------------

PyNVEL provides a command line interface for estimating the volume of individual
trees and access to automation features.

.. code-block:: bash

    $pynvel -h
    usage: pynvel-script.py [-h] [-s] [-d] [-t] [-f] [-e] [-v] [--install_arcgis]
                            [species] [dbh] [height] [equation]

    Python Wrappers for the National Volume Estimator Library.

    positional arguments:
      species             Tree species code, common abbv. or FIA number.
      dbh                 Tree DBH in inches.
      height              Tree total height in feet.
      equation            NVEL volume equation identifier. If not provided the
                          default for the species and configured location will be
                          used. Pass "FIA" to use the FIA default equation.

    optional arguments:
      -h, --help          show this help message and exit
      -s , --species      Tree species code, common abbv. or FIA number.
      -d , --dbh          Tree DBH in inches.
      -t , --height       Tree total height in feet.
      -f , --form_class   Girard Form Class.
      -e , --equation     NVEL volume equation identifier.
      -v, --version       Report the installed version of PyNVEL and exit.
      --install_arcgis    Install the ArcGIS toolboxes in the user profile.

Individual Tree Volume
^^^^^^^^^^^^^^^^^^^^^^

Species, DBH, height, and volume equation id can be provided as positional or 
named arguments. If an equation identifier is not provide PyNVEL will lookup a 
default according to the species and location specified in the configuration 
file.

.. code-block:: bash

    $pynvel DF 18 120 F02FW2W202
    Volume Report
    -------------
    Species: DF(202),
    Equation: F02FW2W202
    DBH:             18.0
    Form:            80.0
    Total Ht:         120
    Merch Ht:          99
    CuFt Tot:       82.40
    CuFt Merch:     75.40
    BdFt Merch:    350.00
    CuFt Top:        0.00
    CuFt Stump:      2.78
    CuFt Tip:        4.22

    Log Detail
    ----------
    log bole_height length large_dib large_dob small_dib small_dob scale_diam cuft_gross bdft_gross
    1   42.0        40.0   16.2      18.0      13.0      14.0      13.0       46.4       240.0
    2   83.0        40.0   13.0      14.0      8.2       8.8       8.0        25.4       90.0
    3   99.0        15.0   8.2       8.8       5.0       5.4       5.0        3.6        20.0
