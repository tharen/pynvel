"""
PyNVEL command line application
"""

import os
import sys
import json

import click

import pynvel

def warn(x): print(x)

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

# Shared options
# Ref: https://github.com/pallets/click/issues/108#issuecomment-194465429

_shared_options = [
    click.option('-s', '--species', default='', type=str
            , help='Tree species, common abbv. or FIA number, e.g. DF or 202')
    , click.option('-d', '--dbh', required=True, type=float
            , help='Tree diameter at breast height (DBH) in inches.')
    , click.option('-t', '--height', default=None, type=float
            , help='Tree total height in feet from ground to tip.')
    , click.option('-e', '--equation', type=str, default=None
            , help=(
                    'NVEL volume equation identifier. If not provided the '
                    'default for the species and location will '
                    'be used. Pass "FIA" to use the FIA default equation.')
            )
    , click.option('-f', '--form_class', type=int, default=80
            , help='Girard Form Class.')
    ]

def shared_options(func):
    for option in reversed(_shared_options):
        func = option(func)
    return func

@click.group(context_settings={'help_option_names':['-h', '--help']}
        , epilog=(
                'Global configuration variables can be set by editing '
                'pynvel.cfg within the installed package folder.')
        )
@click.version_option(message=str(pynvel.version()))
def cli():
    'PyNVEL command line interface.'
    pass

@click.command()
@click.pass_context
@shared_options
def volume(ctx, species='', dbh=None, height=None, equation=None, form_class=80):
    """
    Report the volume and log attributes of a single tree.
    """
# FIXME: Handle basic strings instead of unicode so Python 2 & 3 don't collide
#        http://docs.cython.org/src/tutorial/strings.html
# TODO: Add option to export in json format
# TODO: Add option to iterate through a file, database table, etc.

    cfg = pynvel.get_config()
    mrule = pynvel.init_merchrule(**cfg['merch_rule'])
    
    if not dbh:
        print('Missing DBH.')
        return False
    
    w = False
    if not species:
        w = True
        species = cfg.get('default_species', 'OT')
    
    if not equation:
        w = True
        equation = cfg['default_equations'].get(species, '632TRFW202')
        
    else:
        w = False
        
    if w:
        print('Default species equation will be used - {}: {}'.format(species, equation))
        
    # Convert the species code
    try:
        spp_code = int(species)
        spp_abbv = pynvel.fia_spp[spp_code]
        
    except:
        spp_code = pynvel.get_spp_code(species.upper())
        spp_abbv = species.upper()

    # Get a default eqution if none provided
    if not equation:
        vol_eq = pynvel.get_equation(spp_code,
                cfg['variant'].encode(), cfg['region'],
                cfg['forest'].encode(), cfg['district'].encode(),
                cfg['product'].encode()
                )

    elif equation.upper() == 'FIA':
        vol_eq = pynvel.get_equation(spp_code, cfg['variant'].encode(),
                cfg['region'], cfg['forest'].encode(), cfg['district'].encode()
                , fia=True)

    else:
        vol_eq = equation.upper()

    # FIXME: Lengths specified in default equations conflict with maxlen mrule
    #        This should be reported to FMSC
    if 'BEH' in vol_eq:
        ml = float(vol_eq[1:3])
        if ml != 0.0:
            warn('Overiding user log length with the equation default: '
                    '{:.1f}->{:.1f}'.format(mrule['maxlen'], ml))
            mrule['maxlen'] = ml

    # TODO: Implement height curves
    if not height:
        raise NotImplementedError('Height estimation is not implemented.')
        tot_ht = 0.0

    else:
        tot_ht = height

    # TODO: Implement user assigned log lengths, cruise type='V'
    ve = vol_eq.encode()
    volcalc = pynvel.VolumeCalculator(
            volume_eq=vol_eq.encode()
            , merch_rule=mrule
            , cruise_type=b'C'
            , calc_products=True
            )
    
    error = volcalc.calc(
            dbh_ob=dbh
            , total_ht=tot_ht
            , form_class=form_class
#             , log_len=np.array([40, 30, 20, 10])
            )

    print_report(volcalc, spp_abbv, spp_code, vol_eq, form_class)
#     print(error)

@click.command(name='stem-ht')
@click.option('-u', '--stem-dib', required=True, type=float, help='Upper stem diameter.')
@click.pass_context
@shared_options
def stem_height(ctx, species='', dbh=None, height=None, equation=None, form_class=80, stem_dib=0.0):
    """
    Calculate the height to specified upper stem diameter (inside bark).
    """

    if not (species or equation) or not dbh:
        print('Missing required parameters.')
        print(ctx.get_help())
        return False

    # TODO: Implement height curves
    if not height:
        # raise NotImplementedError('Height estimation is not implemented.')
        raise click.BadParameter('Height estimation is not implemented.')

    cfg = pynvel.get_config()

    # Convert the species code
    try:
        spp_code = int(species)
        spp_abbv = pynvel.fia_spp[spp_code]
    except:
        spp_code = pynvel.get_spp_code(species.upper())
        spp_abbv = species.upper()

    # Get a default eqution if none provided
    if not equation:
        vol_eq = pynvel.get_equation(spp_code,
                cfg['variant'].encode(), cfg['region'],
                cfg['forest'].encode(), cfg['district'].encode(),
                cfg['product'].encode()
                )

    elif equation.upper() == 'FIA':
        vol_eq = pynvel.get_equation(spp_code, cfg['variant'].encode(),
                cfg['region'], cfg['forest'].encode(), cfg['district'].encode()
                , fia=True)

    else:
        vol_eq = equation.upper()

    stem_ht = pynvel.calc_height(volume_eq=vol_eq.encode(), dbh_ob=dbh, total_ht=height, stem_dib=stem_dib)

    rel_ht = (stem_ht - 4.5) / (height - 4.5) * 100

    msg = 'Stem height to {:.1f}" = {:.2f} ({:.1f}%)'.format(stem_dib, stem_ht, rel_ht)
    print(msg)

@click.command(name='run-tests')
def run_tests():
    print('Run pynvel tests')
    
    # import os
    # print(os.environ['PYTHONPATH'])
    import encodings
    
    import subprocess
    os.chdir(os.path.join(os.path.dirname(__file__), 'test'))
    subprocess.call('pytest')
    sys.exit()

@click.command(name='config')
def print_config():
    'Print the contents of the configuration file and exit.'
    print(json.dumps(pynvel.get_config(), indent=4, sort_keys=True))
    sys.exit(0)

@click.command(name='treelist')
@click.option('-l', '--treelist', help='CSV file of trees')
def calc_table(treelist=None):
    'Calculate volume for a treelist in a csv file.'
    print('Calculate table not implemented.')
    sys.exit(0)

@click.command(name='install_arcgis')
def install_arcgis(args):
    'Install the ArcGIS toolboxes in the user profile.'
    # TODO: Install ArcGIS tbx and pyt
    print('Install ArcGIS is not implemented.')

cli.add_command(volume)
cli.add_command(stem_height)
cli.add_command(run_tests)
cli.add_command(print_config)
cli.add_command(calc_table)
cli.add_command(install_arcgis)

if __name__ == '__main__':
    cli()
