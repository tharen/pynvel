"""
PyNVEL command line application
"""

import os
import sys
import argparse
import json

import pynvel

def warn(x): print(x)

def main():
    """
    Report the volume and log attributes of a single tree.
    """
# FIXME: Handle basic strings instead of unicode so Python 2 & 3 don't collide
#        http://docs.cython.org/src/tutorial/strings.html
# TODO: Add option to export in json format
# TODO: Add option to iterate through a file, database table, etc.

    cfg = pynvel.get_config()
    args = handle_args()
    mrule = pynvel.init_merchrule(**cfg['merch_rule'])

    # Convert the species code
    try:
        spp_code = int(args.species)
        spp_abbv = pynvel.fia_spp[spp_code]
    except:
        spp_code = pynvel.get_spp_code(args.species.upper())
        spp_abbv = args.species.upper()

    # Get a default eqution if none provided
    if not args.equation:
        vol_eq = pynvel.get_equation(spp_code,
                cfg['variant'].encode(), cfg['region'],
                cfg['forest'].encode(), cfg['district'].encode(),
                cfg['product'].encode()
                )

    elif args.equation.lower() == 'fia':
        vol_eq = pynvel.get_equation(spp_code, cfg['variant'].encode(),
                cfg['region'], cfg['forest'].encode(), cfg['district'].encode()
                , fia=True)

    else:
        vol_eq = args.equation.upper()

    # FIXME: Lengths specified in default equations conflict with maxlen mrule
    #        This should be reported to FMSC
    if 'BEH' in vol_eq:
        ml = float(vol_eq[1:3])
        if ml != 0.0:
            warn('Overiding user log length with the equation default: '
                    '{:.1f}->{:.1f}'.format(mrule['maxlen'], ml))
            mrule['maxlen'] = ml

    # TODO: Implement height curves
    if not args.height:
        raise NotImplementedError('Height estimation is not implemented.')
        tot_ht = 0.0

    else:
        tot_ht = args.height

    # TODO: Implement user assigned log lengths, cruise type='V'
    volcalc = pynvel.VolumeCalculator(
            volume_eq=vol_eq.encode()
            , merch_rule=mrule
            , cruise_type=b'C'
            , calc_products=True
            )

    error = volcalc.calc(
            dbh_ob=args.dbh
            , total_ht=tot_ht
            , form_class=args.form_class
#             , log_len=np.array([40, 30, 20, 10])
            )

    print_report(volcalc, spp_abbv, spp_code, vol_eq, args.form_class)
#     print(error)

def print_report(volcalc, spp_abbv, spp_code, vol_eq, form_class):
    """Print a basic volume report to stdout."""
    r = volcalc.volume

    print('Volume Report (Version: {})'.format(pynvel.version.vollib))
    print('---------------------------------------')
    print('Species: {}({})'.format(spp_abbv, spp_code))
    print('Equation: {}'.format(vol_eq))
    print('DBH:         {:>8.1f}'.format(volcalc.dbh_ob))
    print('Form Class   {:>8.1f}'.format(form_class))
    print('Form Ht:     {:>8.1f}'.format(volcalc.form_height))
    print('Total Ht:    {:>8.1f}'.format(volcalc.total_height))
    print('Merch Ht:    {:>8.1f}'.format(volcalc.merch_height))
    print('CuFt Tot:    {:>8.1f}'.format(r['cuft_total']))
    print('CuFt Merch:  {:>8.1f}'.format(r['cuft_gross_prim']))
    print('BdFt Merch:  {:>8.1f}'.format(r['bdft_gross_prim']))
    print('CuFt Top:    {:>8.1f}'.format(r['cuft_gross_sec']))
    print('CuFt Stump:  {:>8.1f}'.format(r['cuft_stump']))
    print('CuFt Tip:    {:>8.1f}'.format(r['cuft_tip']))

    prod = volcalc.products
    print('')
    if not prod == {}:
        print('Product Summary')
        print('---------------')
        print('Prod Logs CuFt   BdFt    Len   Diam')
        for i in range(volcalc.num_products):
            try:
                p = prod['prod_{}'.format(i + 1)]
                s = (
                    '{:<4d} {count:<4d} {cuft:<6.1f} {bdft:<7.1f} '
                    '{length:<5.1f} {diameter:<6.1f} '
                    ).format(i, **p)
                print(s)

            except:
                pass

        print('')

    else:
        print('* No products')



    if volcalc.num_logs > 0:
        print('Log Detail')
        print('----------')
        logs = volcalc.logs
        flds = ['Bole', 'Len', 'L DOB', 'L DIB', 'S DOB', 'S DIB', 'Scale'
                , 'CuFt', 'BdFt', 'Int 1/4']
        fmt = (
            '{position:<3d} {prod_class:<4d} {bole_height:<7.1f} {length:<7.1f} '
            '{large_dib:<7.1f} {large_dib:<7.1f} '
            '{small_dob:<7.1f} {small_dib:<7.1f} {scale_diam:<7.1f} '
            '{cuft_gross:<7.1f} {bdft_gross:<7.1f} {intl_gross:<7.1f}'
            )
        print('Log Prod ' + ' '.join(['{:<7s}'.format(f) for f in flds]))
        for l, log in enumerate(logs):
            print(fmt.format(**log.as_dict()))

    else:
        print('* No log detail'.format(vol_eq))

    print('\nERROR: {}'.format(volcalc.error_message))

def install_arcgis(args):
    # TODO: Install ArcGIS tbx and pyt
    print('Install ArcGIS is not implemented.')

def calc_table(args):
    print(args.treelist)
    print('Calculate table not implemented.')

def handle_args():
    parser = argparse.ArgumentParser(
            description=('PyNVEL command line interface.'),
            epilog=(
                    'Global configuration variables can be set by editing '
                    'pynvel.cfg within the installed package folder.'))

    # Positional arguments for basic variables (optional usage)
    parser.add_argument(
            'species', metavar='species', type=str, nargs='?'
            , help=('Tree species, common abbv. or '
                    'FIA number, e.g. DF or 202'))

    parser.add_argument(
            'dbh', metavar='dbh', type=float, nargs='?'
            , help='Tree diameter at breast height (DBH) in inches.')

    parser.add_argument(
            'height', metavar='height', type=float, nargs='?'
            , help='Tree total height in feet from ground to tip.')

    parser.add_argument(
            'equation', metavar='equation', type=str, nargs='?', default=''
            , help=('NVEL volume equation identifier. If not provided the '
                    'default for the species and location will '
                    'be used. Pass "FIA" to use the FIA default equation.'))

    # Named arguments
    parser.add_argument(
            '-s', '--species', type=str, metavar=''
            , help=('Tree species code or FIA number.'))

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
            '-e', '--equation', metavar='', type=str, default=''
            , help='NVEL volume equation identifier.')

    parser.add_argument(
            '-v', '--version', dest='version', action='store_true'
            , help='Print the installed version of PyNVEL and exit.')

    parser.add_argument(
            '--config', dest='config', action='store_true'
            , help='Print the contents of the configuration file and exit.')

    parser.add_argument(
            '--install_arcgis', dest='install_arcgis', action='store_true'
            , help='Install the ArcGIS toolboxes in the user profile.')

    parser.add_argument(
            '--treelist', dest='treelist', metavar='', default=''
            , help='Calculate volume for a treelist in a csv file.')

    parser.add_argument('--run-tests', action='store_true', default=False
            , help='Run test scripts and exit.')

    args = parser.parse_args()

    if args.version:
        print(pynvel.version())
        sys.exit(0)

    if args.config:
        # Pretty print the configuration contents
        print(json.dumps(pynvel.get_config(), indent=4, sort_keys=True))
        sys.exit(0)

    if args.install_arcgis:
        install_arcgis(args)
        sys.exit(0)

    if args.treelist:
        calc_table(args)
        sys.exit(0)

    if args.run_tests:
        print('Run pynvel tests')
        import subprocess
        os.chdir(os.path.join(os.path.dirname(__file__), 'test'))
        subprocess.call('pytest')
        sys.exit()

    # No special flags present, run main.
    if not args.species or not args.dbh:
        print('ERROR: Incorrect number of arguments. Species and DBH are ')
        print('       required for single tree usage.')
        parser.print_help()
        sys.exit(1)

    return args

if __name__ == '__main__':
    main()
