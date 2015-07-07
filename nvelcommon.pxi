"""
Look up functions and tables used to support the NVEL calls

Author: Tod Haren, tharen@odf.state.or.us
Date: 2012/1/18
"""

def debug(msg): print(msg)
def info(msg): print(msg)
def warn(msg): print(msg)

spp_codes = {
    'SF': (11, 'Pacific silver fir', 'Abies amabilis')
    , 'WF': (15, 'white fir', 'Abies concolor')
    , 'GF': (17, 'grand fir', 'Abies grandis')
    , 'AF': (19, 'subalpine fir', 'Abies lasiocarpa')
    , 'RF': (20, 'California red fir / Shasta red fir', 'Abies magnifica')
    , 'SS': (98, 'Sitka spruce', 'Picea sitchensis')
    , 'NF': (22, 'noble fir', 'Abies procera')
    , 'YC': (42, 'Alaska cedar / western larch', 'Chamaecyparis nootkatensis')
    , 'IC': (81, 'incense-cedar', 'Libocedrus decurrens')
    , 'ES': (93, 'Engelmann spruce', 'Picea engelmannii')
    , 'LP': (108, 'lodgepole pine', 'Pinus contorta')
    , 'JP': (116, 'Jeffrey pine', 'Pinus jeffreyi')
    , 'SP': (117, 'sugar pine', 'Pinus lambertiana')
    , 'WP': (119, 'western white pine', 'Pinus monticola')
    , 'PP': (122, 'ponderosa pine', 'Pinus ponderosa')
    , 'DF': (202, 'Douglas-fir', 'Pseudotsuga menziesii')
    , 'RW': (211, 'coast redwood', 'Sequoia sempervirens')
    , 'RC': (242, 'western redcedar', 'Thuja plicata')
    , 'WH': (263, 'western hemlock', 'Tsuga heterophylla')
    , 'MH': (264, 'mountain hemlock', 'Tsuga mertensiana')
    , 'BM': (312, 'bigleaf maple', 'Acer macrophyllum')
    , 'RA': (351, 'red alder', 'Alnus rubra')
    , 'WA': (352, 'white alder / Pacific madrone', 'Alnus rhombifolia')
    , 'PB': (375, 'paper birch', 'Betula papyrifera var. commutata')
    , 'GC': (431, 'giant chinkapin / tanoak', 'Castanopsis chrysophylla')
    , 'AS': (746, 'quaking aspen', 'Populus tremuloides')
    , 'CW': (747, 'black cottonwood', 'Populus trichocarpa')
    , 'WO': (815, 'Oregon white oak / California black oak', 'Quercus garryana')
    , 'WJ': (064, 'western juniper', 'Juniperus occidentalis')
    , 'LL': (072, 'subalpine larch', 'Larix lyallii')
    , 'WB': (101, 'whitebark pine', 'Pinus albicaulis')
    , 'KP': (103, 'knobcone pine', 'Pinus attenuata')
    , 'PY': (231, 'Pacific yew', 'Taxus brevifolia')
    , 'DG': (492, 'Pacific dogwood', 'Cornus nuttallii')
    , 'HT': (500, 'hawthorn species', 'Crataegus spp.')
    , 'CH': (768, 'bitter cherry', 'Prunus emarginata')
    , 'WI': (920, 'willow species', 'Salix spp.')
    , 'OT': (999, 'other species', 'other spp.')
    , 'CX': (202, 'other conifer', 'conifer spp.')
    , 'HX': (351, 'other hardwood', 'hardwood spp.')
    }

volume_idx = {
        1:'Total Cubic Volume from ground to tip'
        , 2:'Gross Scribner board foot volume'
        , 3:'Net Scribner board foot volume'
        , 4:'Gross merchantable cubic foot volume'
        , 5:'Net merchantable cubic foot volume'
        , 6:'Merchantable cordwood volume'
        , 7:'Gross secondary product volume in cubic feet'
        , 8:'Net secondary product volume in cubic feet'
        , 9:'Secondary product in cordwood'
        , 10:'Gross International 1/4 board foot volume'
        , 11:'Net International 1/4 board foot volume'
        , 12:'Gross secondary product in Scribner board feet'
        , 13:'Net secondary product in Scribner board feet'
        , 14:'Stump volume'
        , 15:'Tip volume'
        }

vol_lbl = ('cuft_tot','scrib_gross_p','scrib_net_p'
        ,'cuft_gross_p','cuft_net_p','cords_p','cuft_gross_s','cuft_net_s'
        ,'cords_s','intl_gross','intl_net','scrib_gross_s'
        ,'scrib_net_s','cuft_stump','cuft_tip')

log_volume_idx = {
        1:'Gross Scribner board foot log volume (20 logs)'
        , 2:'Gross removed Scribner board foot log volume (20 logs)'
        , 3:'Net Scribner board foot log volume (20 logs)'
        , 4:'Gross cubic foot log volume (20 logs)'
        , 5:'Gross removed cubic foot log volume (20 logs)'
        , 6:'Net cubic foot log volume (20 logs)'
        , 7:'Gross International 1/4 board foot log volume (20 logs)'
        }

log_vol_lbl = ('scrib_bdft_gross','scrib_bdft_gross_rem','scrib_bdft_net'
        ,'cuft_gross','cuft_gross_rem','cuft_net','intl_bdft')

log_diameter_idx = {
        1:'Scaling diameter inside bark (rounded or truncated value).'
        , 2:'Actual predicted diameter inside bark.'
        , 3:'Actual predicted diameter outside bark.'
        }

error_codes = {
        0:'No errors'
        , 1:'No volume equation match'
        , 2:'No form class'
        , 3:'DBH less than one'
        , 4:'Tree height less than 4.5'
        , 5:'D2H is out of bounds'
        , 6:'No species match'
        , 7:'Illegal primary product log height (Ht1prd)'
        , 8:'Illegal secondary product log height (Ht2prd)'
        , 9:'Upper stem measurements required'
        , 10:'Illegal upper stem height (UPSHT1)'
        , 11:'Unable to fit profile given dbh, merch ht and top dia'
        }

def get_volume_eq(spp):
    """
    Return a volume equation to use for a given species
    """
    # #TODO: Define a more complete lookup table and odd-ball species defaults
    # #TODO: reduce the species list to SLI and PPI species codes

    # FVS PN Species list, not all species are represented directly
    # #TODO: evaluate equations for non-represented spp. eg. SS, RF, WL/YC
    eqs = {
        'SF': 'B00BEHW011'
        , 'WF': 'B00BEHW015'
        , 'GF': 'B00BEHW017'
        , 'AF': 'B00BEHW015'
        , 'RF': 'B00BEHW021'
        , 'SS': 'B00BEHW098'
        , 'NF': 'B00BEHW022'
        , 'YC': 'B00BEHW042'
        , 'WL': 'B00BEHW042'  # coupled with YC in FVS PN
        , 'IC': 'B00BEHW081'  # RC
        , 'ES': 'B00BEHW093'
        , 'LP': 'B00BEHW108'
        , 'JP': 'B00BEHW116'
        , 'SP': 'B00BEHW117'
        , 'WP': 'B00BEHW119'
        , 'PP': 'B00BEHW122'
#         , 'DF': '632BEHW202'
        , 'DF': 'F01FW3W202'
#         , 'DF': 'I00FW3W202'
#         , 'DF': 'B00BEHW202'
        , 'RW': 'B00BEHW211'  # RW Region 5
#         , 'RW': '532TRFW211'  # RW Region 5
#         , 'RC': 'I00FW3W242'
        , 'RC': 'F01FW3W242'
#         , 'WH': '632BEHW000'
#         , 'WH': 'B00BEHW260'
        , 'WH': 'F00FW2W263'
#         , 'WH': 'F00FW3W264'
        , 'MH': 'F00FW3W264'
#         , 'BM': 'B00BEHW312'
        , 'BM': 'B00BEHW998'
        , 'RA': 'B00BEHW351'
#        , 'WA': ''
#        , 'PB': ''
#        , 'GC': ''
#        , 'AS': ''
#        , 'CW': ''
#        , 'WO': ''
#        , 'WJ': ''
#        , 'LL': ''
#        , 'WB': ''
#        , 'KP': ''
#        , 'PY': ''
#        , 'DG': ''
#        , 'HT': ''
#        , 'CH': ''
#        , 'WI': ''
#         , 'OT': 'B00BEHW999'
#         , 'CX': 'B00BEHW999'
#         , 'HX': 'B00BEHW999'
        , 'OT': 'F00FW3W202'
        , 'CX': 'F00FW3W202'
        , 'HX': 'B00BEHW998'
        }
    try:
        eq = eqs[spp.upper()]

    except KeyError:
        # default volume equation for odd-ball species
        eq = 'F03FW2W202'  # DF

    return(eq)
