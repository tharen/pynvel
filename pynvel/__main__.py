"""
PyNVEL command line application
"""

import sys
import argparse

import pynvel

# TODO: Read/write config file for defaults
region = 6
forest = '04'
district = '12'
product = '01'
mrule = pynvel.init_merchrule(
        evod=1, opt=23, maxlen=40, minlen=12
        , cor='Y')

def main():
    args = handle_args()
    print(args)

    # Convert the species code
    try:
        spp_code = int(args.species)
    except:
        spp_code = pynvel.get_spp_code(args.species)

    # Get a default eqution if none provided
    if not args.equation:
        vol_eq = pynvel.getvoleq(
                region, forest, district
                , spp_code, product
                )

    elif args.equation.lower() == 'fia':
        vol_eq = pynvel.getfiavoleq(
                region, forest, district
                , spp_code)

    else:
        vol_eq = args.equation

    # TODO: Implement height curves
    if not args.height:
        raise NotImplementedError('Height must be supplied.')
        tot_ht = 0.0

    else:
        tot_ht = args.height

    # TODO: Implement user assigned log lengths, cruise type='V'
    volcalc = pynvel.VolumeCalculator(
            volume_eq=vol_eq
            , merch_rule=mrule
            , cruise_type='C'
            )

    volcalc.calc(
            dbh_ob=args.dbh
            , total_ht=tot_ht
            , form_class=args.form_class
#             , log_len=np.array([40, 30, 20, 10])
            )

    r = volcalc.volume

    print('Volume Report')
    print('-------------')
    print('Species: {species}, DBH: {dbh}, Ht: {height}'.format(**vars(args)))
    print('Equation: {}, Form: {}'.format(vol_eq, args.form_class))
    print('CuFt Tot.:   {:>8.2f}'.format(r['cuft_total']))
    print('CuFt Merch.: {:>8.2f}'.format(r['cuft_gross_prim']))
    print('BdFt Merch.: {:>8.2f}'.format(r['bdft_gross_prim']))
    print('CuFt Top:    {:>8.2f}'.format(r['cuft_gross_sec']))
    print('CuFt Stump:  {:>8.2f}'.format(r['cuft_stump']))
    print('CuFt Tip:    {:>8.2f}'.format(r['cuft_tip']))

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
            '-f', '--form_class', metavar='', type=float, default=80
            , help='Girard Form Class.')

    parser.add_argument(
            '-e', '--equation', metavar='', type=str
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
