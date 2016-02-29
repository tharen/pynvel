"""
PyNVEL command line application
"""

import sys
import argparse

import pynvel

def main():
    args = handle_args()


    print(args)

def install_arcgis():
    # TODO: Install ArcGIS tbx and pyt
    print('Install ArcGIS is not implemented.')

def handle_args():
    parser = argparse.ArgumentParser(
            description='Python Wrappers for the National Volume Estimator Library.')

    # Positional arguments for basic variables (optional usage)
    parser.add_argument(
            'species', metavar='species', type=str, nargs='?'
            , help=('Tree species code, common abbv., plants code, '
                    'FIA number.'))

    parser.add_argument(
            'dbh', metavar='dbh', type=float, nargs='?'
            , help='Tree DBH in inches.')

    parser.add_argument(
            'height', metavar='height', type=float, nargs='?'
            , help='Tree total height in feet.')

    parser.add_argument(
            'equation', metavar='equation', type=float, nargs='?'
            , help='NVEL volume equation identifier.')

    # Named arguments
    parser.add_argument(
            '-s', '--species', type=str, metavar=''
            , help=('Tree species code, common abbv., plants code, '
                    'FIA number.'))

    parser.add_argument(
            '-d', '--dbh', metavar='', type=float
            , help='Tree DBH in inches.')

    parser.add_argument(
            '-t', '--height', metavar='', type=float
            , help='Tree total height in feet.')

    parser.add_argument(
            '-e', '--equation', metavar='', type=float
            , help='NVEL volume equation identifier.')

    parser.add_argument(
            '-v', '--version', dest='version', action='store_true'
            , help='Report the installed version of PyNVEL and exit.')

    parser.add_argument(
            '--install_arcgis', dest='install_arcgis', action='store_true'
            , help='Install the ArcGIS toolboxes in the user profile.')

    args = parser.parse_args()

    if args.version:
        print(pynvel.version())
        sys.exit(0)

    if args.install_arcgis:
        install_arcgis()
        sys.exit(0)

    return args

if __name__ == '__main__':
    main()
