# nvel.py
"""
Classes and functions for using the National Volume Estimation Library.

Author: Tod Haren, tharen@odf.state.or.us
Date: 2012/1/18

Notes:
Tested using the NVEL vollib.dll compiled on 2013/9/23

This work builds on the examples provided with the NVEL binaries. Adding 
convenience wrappers, default values, and the merchandising class.

This is a work in progress with much remaining to do to make it a fully
functional tool.  However, it provides the necessary framework for interacting
with the NVEL. See the TODO comments for hints of possible improvements to be
added.
 
fchar - A ctypes structure subclass to represent a Python string as a Fortran 
        character argument.  Fortran subroutine calls generally include an 
        implied length value with all character arguments.
MerchRule - A ctypes structure to represent the NVEL derived type
_VOLLIBC2 - This is a low level function wraps the primary NVEL subroutine. The
        function accepts the same input arguments as the NVEL subroutine but 
        returns the results as a Python dictionary.

get_merch_ht - This will return an estimated height to a minimum top diameter.
get_total_vol - Returns total, bdft, cubic volumes

get_volume - Returns total volumes, log segment details, and error messages. 
"""

# #TODO: define a Tree class to be passed back and forth rather than measurements, logs, etc.

import os
import ctypes
import numpy as np

from nvelcommon import *

# This assumes the NVEL vollib.dll file is in the same folder as this script
loc = os.path.split(__file__)[0]
libname = 'vollib.dll'
try:
    _nvel = ctypes.windll.LoadLibrary(os.path.join(loc, libname))
except:
    raise ImportError(
            'Can\'t load the NVEL library. Expected to find {} '
            'in the folder {}'.format(libname, loc)
            )

# Alternatively, uncomment this line and change the path to vollib.dll
# _nvel = ctypes.windll.LoadLibrary(r'C:\workspace\projects\ForestInventory\nvel_tools\nvel_tools\vollib.dll')

# Finally, the NVEL installer should register the dll with the Windows registry
#  system.  If this is the case, then it should be possible to simple specify
#  the name of the library directly, but I haven't tested this
# _nvel = ctypes.windll.LoadLibrary('vollib')

class fchar(ctypes.Structure):
    """
    Represent a Python string as a Fortran character argument
    """
    _fields_ = [
            ('str', ctypes.c_char_p),
            ('len', ctypes.c_int),
             ]

class MerchRule(ctypes.Structure):
    """
    User defined merchandizing rules represented as a ctypes struct
    """
    _fields_ = [
        ('evod', ctypes.c_int),
        ('opt', ctypes.c_int),
        ('maxlen', ctypes.c_float),
        ('minlen', ctypes.c_float),
        ('minlent', ctypes.c_float),
        ('merchl', ctypes.c_float),
        ('mtopp', ctypes.c_float),
        ('mtops', ctypes.c_float),
        ('stump', ctypes.c_float),
        ('trim', ctypes.c_float),
        ('btr', ctypes.c_float),
        ('dbtbh', ctypes.c_float),
        ('minbfd', ctypes.c_float),
        ('cor', ctypes.c_char),
        ]

    def __init__(self, evod=1, opt=14, maxlen=40
                 , minlen=10, minlent=10, merchl=10
                 , mtopp=5, mtops=2, stump=1, trim=1
                 , btr=0, dbtbh=0, minbfd=7.0, cor='Y'
                 , *args, **kwargs
                 ):
        """
        Represents a user defined merchandising standard to be used by the 
        NVEL profile models.  See the NVEL documentation for details.
        
        Reference: Mrules.f
        
        Primary Product: BdFt; CuFt; Cord Wood
        Secondary Product: CuFt; Cord Wood
        
        @param evod: 1 - Odd segment lengths allowed; 2 - Even segment lengths only
        @param opt: Bucking option: 11 - 16ft logs; 12 - 20ft logs; 13 - 32ft logs; 14 - 40ft logs
                                    Short Top Log Options
                                    21 - Recombined if <1/2 max len 
                                    22 - Always recombined with lower log 
                                    23 - No recombination
                                    24 - Dropped if <1/4 max len;
                                            Set to 1/2 max len if >1/4 & <3/4 max len;
                                            Set to max len if >3/4 max len
        @param maxlen: Maximum segment length (feet)
        @param minlen: Minimum segment length (feet)
        @param minlent: Minimum top/secondary product segment length (feet)
        @param merchl: Minimum tree merch length to <mtopp> (feet)
        @param mtopp: Minimum diameter of primary product (inches)
        @param mtops: Minimum diameter of secondary product (inches)
        @param stump: Stump height (feet)
        @param trim: Trim length per segment (feet)
        @param btr: Bark thickness ratio
        @param dbtbh: Double bark thickness at breast height
        @param minbfd: Minimum tree DBH for sawlogs (inches)
        @param cor: Scribner BdFt volume source: 'Y'=table; 'N'=factor
        """
        self.evod = evod
        self.opt = opt
        self.maxlen = maxlen
        self.minlen = minlen
        self.minlent = minlent
        self.merchl = merchl
        self.mtopp = mtopp
        self.mtops = mtops
        self.stump = stump
        self.trim = trim
        self.btr = btr
        self.dbtbh = dbtbh
        self.minbfd = minbfd
        self.cor = cor

# define a default merchandizing rule
# default_merch_rule = MerchRule()
#        evod=1, opt=23, maxlen=40, minlen=10, minlent=6
#        , merchl=24, mtopp=5, mtops=2, stump=1
#       , trim=1.0/12.0, btr=0, dbtbh=0, minbfd=6.0, cor="N")

def get_spp_code(species):
    """
    Return the FIA code for the given species 2 character identifier
    """
    # #TODO: implement region specific lookup, although it should not vary nationwide

    try:
        spp = fvs_pn_spp_codes['species']
    except KeyError:
        spp = fvs_pn_spp_codes['OT']
    except:
        raise

    return spp

def xget_volume_eq(species, region=6, forest=12, district=0, product=1):
    """
    Get the NVEL default volume equation identifier for a species
    """
    # #FIXME:  This currently bombs, complaining about a input conversion error
    regn = ctypes.c_int(region)
    forst = fchar('%-2s' % forest, 2)
    dist = fchar('0%d ' % district, 3)
    spp = ctypes.c_int(get_spp_code(species))
    prod = fchar('0%d ' % product, 3)
    voleq = fchar(' ' * 11, 11)
    errflag = ctypes.c_int()

    _nvel.GETVOLEQ(ctypes.byref(regn)
            , ctypes.byref(forst)
            , ctypes.byref(dist)
            , ctypes.byref(spp)
            , ctypes.byref(prod)
            , ctypes.byref(voleq)
            , ctypes.byref(errflag))

def _VOLLIBC2(
        region=6, forest=12, vol_eq=None
        , top_dib_1=5.0, top_dib_2=2.0, stump_ht=1.0
        , dbh=0.0, dob_root_col=0.0
        , ht_type='F', tot_ht=0.0
        , log_len=16, ht_prod_1=0.0, ht_prod_2=0.0
        , stem_ht_1=0.0, stem_ht_2=0.0
        , stem_dob_1=0.0, stem_dob_2=0.0
        , ref_ht=0, avg_z_1=0.0, avg_z_2=0.0
        , form_class=0, dbl_brk_thick=0.0, btr=0.0
        , len_logs=[]
        , bole_hts=[]
        , product=1, con_spp=''
        , live_stat='L', ht_live_limb=0
        , cruise_type='F', num_logs_1=0
        , num_logs_2=0, merch_rule=None
        , baa=0, site_idx=0
        , debug=0
        ):
    """
    Segments a tree and computes log volume estimates.
    This is a ctypes wrapper to the primary volume calculation routine in NVEL.

    Args
    ----
    @param region: (REGN) Region number used to set Regional Merchandizing Rules
    @param forest: (FORST) Two digit forest number
    @param vol_eq: (VOLEQ) The 10 character volume equation number for this tree
    @param top_dib_1: (MTOPP) Minimum top diameter inside bark for primary product
    @param top_dib_2: (MTOPS) Minimum top diameter inside bark for secondary product
    @param stump_ht: (STUMP) Stump height in feet
    @param dbh: (DBHOB) Diameter Breast Height outside bark
    @param dob_root_col: (DRCOB) Diameter Root Collar outside bark (ground level diameter)
    @param ht_type: (HTTYPE) Height type for ht_prod_1 and ht_prod_2 variables: L - Logs; F - Feet
    @param tot_ht: (HTTOT) Total tree height measured from ground to tip
    @param log_len: (HTLOG) If ht_type is set to L, this is the length of the logs, (8,16, or 32)
    @param ht_prod_1: (HT1PRD) Height to the minimum top diameter inside bark for primary product.
    @param ht_prod_2: (HT2PRD) Height to the minimum top diameter inside bark for secondary product.
    @param stem_ht_1: (UPSHT1) Upper stem height in feet where upper stem diameter was measured or where AVG1 is to be applied.
    @param stem_ht_2: (UPSHT2) Second upper stem height in feet where a second upper stem diameter was measured.
    @param stem_dob_1: (UPSD1) Upper stem diameter measured at stem_ht_1
    @param stem_dob_2: (UPSD2) Second upper stem diameter measured at stem_ht_2
    @param ref_ht: (HTREF) Reference height.  Percent of total height where stem_dob_1 was measured or where AVGZ1 is to be applied.
    @param avg_z_1: (AVGZ1) Flewelling's Average Z-Score value to be applied at either stem_ht_1 or ref_ht
    @param avg_z_2: (AVGZ2) Second average Z-Score value to be applied at stem_ht_2.
    @param form_class: (FCLASS) Girard's form class.  Diameter at the top of the first log given as a percent of DBH.
    @param dbl_brk_thick: (DBTBH) Double bark thickness at breast height in inches
    @param btr: (BTR) Bark thickness ratio given as the percent of diameter inside bark to diameter outside bark.  (dib/dob *100).
    @param con_spp: (CONSPEC) Contract species.  (used by BLM profile models)
    @param ht_live_limb: (HTTFLL) Height to first live limb in feet (used by Region 3 volume equation for ponderosa pine).
    @param live_stat: (LIVE) Tree status used in Region 1 equations
    @param cruise_type: (CTYPE) Cruise Type:  Flag to set some special volume criteria.
                                'C' or blank = Cruise volumes.  Will return zero volumes if required fields are missing.
                                'F' = FVS volumes.  Missing merchantable heights and form class variables will be calculated if they are required.
                                'V' = Variable log length cruise.  Requires the len_logs variable to contain the variable log lengths.
    @param baa: Basal Area of the stand.  Optional variable used when calculating the merchantable heights required with the current Region 8 and Region 9 volume models.
    @param site_idx: Site Index of the stand.  Optional variable used when calculating the merchantable heights required with the current Region 8 and Region 9 volume models.
    @param product: (PROD) Product code: 1 - saw timber; 2 - pulpwood; 6 - roundwood

    @param merch_rule: Instance of a MerchRule for use with profile models

    @param num_logs_1: (NOLOGP) Number of 16 foot logs in the merchantable part of a tree, from stump to minimum top diameter for primary product.
    @param num_logs_2: (NOLOGS) Number of 16 foot logs in the topwood part or the tree, from the minimum top diameter for the primary product to the minimum top diameter for the secondary product.
    @param len_logs: (LOGLEN) Log lengths in feet for up to 20 logs.
    @param bole_hts: (BOLHT) The actual heights up the tree where the corresponding LOGDIA values were predicted.
    """

    # Upper case variable names coincide with the NVEL subroutine arguments
    REGN = ctypes.c_int(region)
    FORST = fchar('%-3s' % forest, 3)

    VOLEQ = fchar('%-11s' % vol_eq, 11)

    MTOPP = ctypes.c_float(top_dib_1)
    MTOPS = ctypes.c_float(top_dib_2)
    STUMP = ctypes.c_float(stump_ht)

    DBHOB = ctypes.c_float(dbh)
    DRCOB = ctypes.c_float(dob_root_col)

    HTTYPE = fchar('%s' % ht_type, 1)

    HTTOT = ctypes.c_float(tot_ht)
    HTLOG = ctypes.c_int(int(log_len))

    HTPRD1 = ctypes.c_float(ht_prod_1)
    HTPRD2 = ctypes.c_float(ht_prod_2)

    UPSHT1 = ctypes.c_float(stem_ht_1)
    UPSHT2 = ctypes.c_float(stem_ht_2)
    UPSD1 = ctypes.c_float(stem_dob_1)
    UPSD2 = ctypes.c_float(stem_dob_2)

    HTREF = ctypes.c_int(int(ref_ht))
    AVGZ1 = ctypes.c_float(avg_z_1)
    AVGZ2 = ctypes.c_float(avg_z_2)
    FCLASS = ctypes.c_int(int(form_class))

    DBTBH = ctypes.c_float(dbl_brk_thick)
    BTR = ctypes.c_float(btr)

    I3 = ctypes.c_int(3)
    I7 = ctypes.c_int(7)
    I15 = ctypes.c_int(15)
    I20 = ctypes.c_int(20)
    I21 = ctypes.c_int(21)

    VOL = (ctypes.c_float * 15)()
    LOGVOL = (ctypes.c_float * 7 * 20)()
    LOGDIA = (ctypes.c_float * 21 * 3)()
    LOGLEN = (ctypes.c_float * 20)()
    BOLHT = (ctypes.c_float * 21)()

#     VOL[:] = [0.0, ] * 15
#     LOGVOL[:][:] = [[0.0, ] * 7] * 20
#     LOGDIA[:][:] = [[0.0, ] * 21] * 3
#     LOGLEN[:] = [0.0, ] * 20
#     BOLHT[:] = [0.0, ] * 21

    # process predefined variable log lengths
    if cruise_type.lower() == 'v':
        for i, ll in enumerate(len_logs):
            LOGLEN[i] = ll

        for i, bh in enumerate(bole_hts):
            BOLHT[i + 1] = bole_hts[i]

        # if log lengths are provided and cruise_type=='V' then TLOGS is required
        TLOGS = ctypes.c_int(len(len_logs))

    else:
        TLOGS = ctypes.c_int(0)

    NOLOGP = ctypes.c_int(num_logs_1)
    NOLOGS = ctypes.c_int(num_logs_2)

    # calculation flags
    cubicTotalFlag = ctypes.c_int(1)
    boardFootFlag = ctypes.c_int(1)
    cubicFootFlag = ctypes.c_int(1)
    cordsFlag = ctypes.c_int(1)
    prod2Flag = ctypes.c_int(1)

    CONSPEC = fchar('%-5s' % con_spp.upper(), 5)

    PROD = fchar('00%s' % product, 3)

    HTTFLL = ctypes.c_int(ht_live_limb)

    LIVE = fchar('%-2s' % live_stat.upper(), 2)

    BA = ctypes.c_int(baa)
    SI = ctypes.c_int(site_idx)
    mCTYPE = fchar('%-2s' % cruise_type, 2)
    ERRFLAG = ctypes.c_int(0)

    # added user merch rules 1/23/12 following modifications provided by
    # YingFang Wang at FMSC Fort Collins [yingfangwang@fs.fed.us]
    INDEB = ctypes.c_int(debug)  # Debug flag

    # ensure user merch rules are provided if requested
    if isinstance(merch_rule, (MerchRule, ctypes.Structure)):
        PMTFLG = ctypes.c_int(2)  # profile model flag to use user merch rule
    else:
#        raise TypeError('User merch rule must be a MerchRule instance')
        # If merch_rule is not an instance of MerchRule class, unflag the
        # profile model variable and provide a dummy merch_rule
        PMTFLG = ctypes.c_int(1)
        merch_rule = MerchRule()

# FORTRAN subroutine call
#      SUBROUTINE VOLLIBC2(REGN,FORSTI,VOLEQI,MTOPP,MTOPS,STUMP,
#     +    DBHOB,
#     &    DRCOB,HTTYPEI,HTTOT,HTLOG,HT1PRD,HT2PRD,UPSHT1,UPSHT2,UPSD1,
#     &    UPSD2,HTREF,AVGZ1,AVGZ2,FCLASS,DBTBH,BTR,I3,I7,I15,I20,I21,
#     &    VOL,LOGVOLI,LOGDIAI,LOGLEN,BOLHT,TLOGS,NOLOGP,NOLOGS,CUTFLG,
#     &    BFPFLG,CUPFLG,CDPFLG,SPFLG,CONSPECI,PRODI,HTTFLL,LIVEI,
#     &    BA,SI,CTYPEI,ERRFLAG, INDEB, PMTFLG, MERRULES)

    # Call the FORTRAN volume library subroutine
    _nvel.VOLLIBC2(
            ctypes.byref(REGN)
            , FORST
            , VOLEQ
            , ctypes.byref(MTOPP)
            , ctypes.byref(MTOPS)
            , ctypes.byref(STUMP)
            , ctypes.byref(DBHOB)
            , ctypes.byref(DRCOB)
            , HTTYPE
            , ctypes.byref(HTTOT)
            , ctypes.byref(HTLOG)
            , ctypes.byref(HTPRD1)
            , ctypes.byref(HTPRD2)
            , ctypes.byref(UPSHT1)
            , ctypes.byref(UPSHT2)
            , ctypes.byref(UPSD1)
            , ctypes.byref(UPSD2)
            , ctypes.byref(HTREF)
            , ctypes.byref(AVGZ1)
            , ctypes.byref(AVGZ2)
            , ctypes.byref(FCLASS)
            , ctypes.byref(DBTBH)
            , ctypes.byref(BTR)

            , ctypes.byref(I3)
            , ctypes.byref(I7)
            , ctypes.byref(I15)
            , ctypes.byref(I20)
            , ctypes.byref(I21)

            , ctypes.byref(VOL)  # out
            , ctypes.byref(LOGVOL)  # out
            , ctypes.byref(LOGDIA)  # out
            , ctypes.byref(LOGLEN)  # in/out
            # #TODO: check the I/O status of BOLHT, I think it is only output
            , ctypes.byref(BOLHT)  # in/out

            , ctypes.byref(TLOGS)  # in/out
            , ctypes.byref(NOLOGP)  # out
            , ctypes.byref(NOLOGS)  # out

            , ctypes.byref(cubicTotalFlag)
            , ctypes.byref(boardFootFlag)
            , ctypes.byref(cubicFootFlag)
            , ctypes.byref(cordsFlag)
            , ctypes.byref(prod2Flag)

            , CONSPEC
            , PROD
            , ctypes.byref(HTTFLL)
            , LIVE
            , ctypes.byref(BA)
            , ctypes.byref(SI)
            , mCTYPE
            , ctypes.byref(ERRFLAG)

            , ctypes.byref(INDEB)
            , ctypes.byref(PMTFLG)
            , ctypes.byref(merch_rule)
            )

    # process the output variables in to Python lists and data types
    result = {}
    result['VOL'] = [v for v in VOL]
    result['LOGVOL'] = [v for v in [log[:] for log in LOGVOL]]
    result['LOGDIA'] = [d for d in [log[:] for log in LOGDIA]]
    result['BOLHT'] = [ht for ht in BOLHT]
    result['TLOGS'] = TLOGS.value
    result['HTPRD1'] = HTPRD1.value
    result['UPSHT1'] = UPSHT1.value
    result['UPSD1'] = UPSD1.value
    result['HTPRD2'] = HTPRD2.value
    result['UPSHT2'] = UPSHT2.value
    result['UPSD2'] = UPSD2.value
    result['LOGLEN'] = [l for l in LOGLEN]
    result['NOLOGP'] = NOLOGP.value
    result['NOLOGS'] = NOLOGS.value
    result['ERRFLAG'] = ERRFLAG.value
    result['VOLEQ'] = VOLEQ.str

    return result

# #FIXME: Need an alternative form to use with gfortran DLL
def _VOLLIBC2_foo(
        region=6, forest=12, vol_eq=None
        , top_dib_1=5.0, top_dib_2=2.0, stump_ht=1.0
        , dbh=0.0, dob_root_col=0.0
        , ht_type='F', tot_ht=0.0
        , log_len=16, ht_prod_1=0.0, ht_prod_2=0.0
        , stem_ht_1=0.0, stem_ht_2=0.0
        , stem_dob_1=0.0, stem_dob_2=0.0
        , ref_ht=0, avg_z_1=0.0, avg_z_2=0.0
        , form_class=0, dbl_brk_thick=0.0, btr=0.0
        , len_logs=[]
        , bole_hts=[]
        , product=1, con_spp=''
        , live_stat='L', ht_live_limb=0
        , cruise_type='F', num_logs_1=0
        , num_logs_2=0, merch_rule=None
        , baa=0, site_idx=0
        , debug=0
        ):
    """
    Segments a tree and computes log volume estimates.
    This is a ctypes wrapper to the primary volume calculation routine in NVEL.
    
    Args
    ----
    @param region: (REGN) Region number used to set Regional Merchandizing Rules
    @param forest: (FORST) Two digit forest number
    @param vol_eq: (VOLEQ) The 10 character volume equation number for this tree
    @param top_dib_1: (MTOPP) Minimum top diameter inside bark for primary product
    @param top_dib_2: (MTOPS) Minimum top diameter inside bark for secondary product
    @param stump_ht: (STUMP) Stump height in feet
    @param dbh: (DBHOB) Diameter Breast Height outside bark
    @param dob_root_col: (DRCOB) Diameter Root Collar outside bark (ground level diameter)
    @param ht_type: (HTTYPE) Height type for ht_prod_1 and ht_prod_2 variables: L - Logs; F - Feet
    @param tot_ht: (HTTOT) Total tree height measured from ground to tip
    @param log_len: (HTLOG) If ht_type is set to L, this is the length of the logs, (8,16, or 32) 
    @param ht_prod_1: (HT1PRD) Height to the minimum top diameter inside bark for primary product.
    @param ht_prod_2: (HT2PRD) Height to the minimum top diameter inside bark for secondary product.
    @param stem_ht_1: (UPSHT1) Upper stem height in feet where upper stem diameter was measured or where AVG1 is to be applied.
    @param stem_ht_2: (UPSHT2) Second upper stem height in feet where a second upper stem diameter was measured.
    @param stem_dob_1: (UPSD1) Upper stem diameter measured at stem_ht_1
    @param stem_dob_2: (UPSD2) Second upper stem diameter measured at stem_ht_2
    @param ref_ht: (HTREF) Reference height.  Percent of total height where stem_dob_1 was measured or where AVGZ1 is to be applied.
    @param avg_z_1: (AVGZ1) Flewelling's Average Z-Score value to be applied at either stem_ht_1 or ref_ht
    @param avg_z_2: (AVGZ2) Second average Z-Score value to be applied at stem_ht_2.
    @param form_class: (FCLASS) Girard's form class.  Diameter at the top of the first log given as a percent of DBH.
    @param dbl_brk_thick: (DBTBH) Double bark thickness at breast height in inches
    @param btr: (BTR) Bark thickness ratio given as the percent of diameter inside bark to diameter outside bark.  (dib/dob *100).
    @param con_spp: (CONSPEC) Contract species.  (used by BLM profile models)
    @param ht_live_limb: (HTTFLL) Height to first live limb in feet (used by Region 3 volume equation for ponderosa pine).
    @param live_stat: (LIVE) Tree status used in Region 1 equations
    @param cruise_type: (CTYPE) Cruise Type:  Flag to set some special volume criteria.
                                'C' or blank = Cruise volumes.  Will return zero volumes if required fields are missing.
                                'F' = FVS volumes.  Missing merchantable heights and form class variables will be calculated if they are required.
                                'V' = Variable log length cruise.  Requires the len_logs variable to contain the variable log lengths.
    @param baa: Basal Area of the stand.  Optional variable used when calculating the merchantable heights required with the current Region 8 and Region 9 volume models.
    @param site_idx: Site Index of the stand.  Optional variable used when calculating the merchantable heights required with the current Region 8 and Region 9 volume models.
    @param product: (PROD) Product code: 1 - saw timber; 2 - pulpwood; 6 - roundwood
    
    @param merch_rule: Instance of a MerchRule for use with profile models
    
    @param num_logs_1: (NOLOGP) Number of 16 foot logs in the merchantable part of a tree, from stump to minimum top diameter for primary product.
    @param num_logs_2: (NOLOGS) Number of 16 foot logs in the topwood part or the tree, from the minimum top diameter for the primary product to the minimum top diameter for the secondary product.
    @param len_logs: (LOGLEN) Log lengths in feet for up to 20 logs.
    @param bole_hts: (BOLHT) The actual heights up the tree where the corresponding LOGDIA values were predicted.
    """

    # Upper case variable names coincide with the NVEL subroutine arguments
    REGN = ctypes.c_int(region)
    FORST = ctypes.c_char_p(forest)

    VOLEQ = ctypes.c_char_p(vol_eq)

    MTOPP = ctypes.c_float(top_dib_1)
    MTOPS = ctypes.c_float(top_dib_2)
    STUMP = ctypes.c_float(stump_ht)

    DBHOB = ctypes.c_float(dbh)
    DRCOB = ctypes.c_float(dob_root_col)

    HTTYPE = ctypes.c_char_p(ht_type)

    HTTOT = ctypes.c_float(tot_ht)
    HTLOG = ctypes.c_int(int(log_len))

    HTPRD1 = ctypes.c_float(ht_prod_1)
    HTPRD2 = ctypes.c_float(ht_prod_2)

    UPSHT1 = ctypes.c_float(stem_ht_1)
    UPSHT2 = ctypes.c_float(stem_ht_2)
    UPSD1 = ctypes.c_float(stem_dob_1)
    UPSD2 = ctypes.c_float(stem_dob_2)

    HTREF = ctypes.c_int(int(ref_ht))
    AVGZ1 = ctypes.c_float(avg_z_1)
    AVGZ2 = ctypes.c_float(avg_z_2)
    FCLASS = ctypes.c_int(int(form_class))

    DBTBH = ctypes.c_float(dbl_brk_thick)
    BTR = ctypes.c_float(btr)

    I3 = ctypes.c_int(3)
    I7 = ctypes.c_int(7)
    I15 = ctypes.c_int(15)
    I20 = ctypes.c_int(20)
    I21 = ctypes.c_int(21)

    VOL = (ctypes.c_float * 15)()
    LOGVOL = (ctypes.c_float * 7 * 20)()
    LOGDIA = (ctypes.c_float * 21 * 3)()
    LOGLEN = (ctypes.c_float * 20)()
    BOLHT = (ctypes.c_float * 21)()

#     VOL[:] = [0.0, ] * 15
#     LOGVOL[:][:] = [[0.0, ] * 7] * 20
#     LOGDIA[:][:] = [[0.0, ] * 21] * 3
#     LOGLEN[:] = [0.0, ] * 20
#     BOLHT[:] = [0.0, ] * 21

    # process predefined variable log lengths
    if cruise_type.lower() == 'v':
        for i, ll in enumerate(len_logs):
            LOGLEN[i] = ll

        for i, bh in enumerate(bole_hts):
            BOLHT[i + 1] = bole_hts[i]

        # if log lengths are provided and cruise_type=='V' then TLOGS is required
        TLOGS = ctypes.c_int(len(len_logs))

    else:
        TLOGS = ctypes.c_int(0)

    NOLOGP = ctypes.c_int(num_logs_1)
    NOLOGS = ctypes.c_int(num_logs_2)

    # calculation flags
    cubicTotalFlag = ctypes.c_int(1)
    boardFootFlag = ctypes.c_int(1)
    cubicFootFlag = ctypes.c_int(1)
    cordsFlag = ctypes.c_int(1)
    prod2Flag = ctypes.c_int(1)

    CONSPEC = ctypes.c_char_p(con_spp)

    PROD = ctypes.c_char_p(product)

    HTTFLL = ctypes.c_int(ht_live_limb)

    LIVE = ctypes.c_char_p(live_stat)

    BA = ctypes.c_int(baa)
    SI = ctypes.c_int(site_idx)
    mCTYPE = ctypes.c_char_p(cruise_type)
    ERRFLAG = ctypes.c_int(0)

    # added user merch rules 1/23/12 following modifications provided by
    # YingFang Wang at FMSC Fort Collins [yingfangwang@fs.fed.us]
    INDEB = ctypes.c_int(debug)  # Debug flag

    # ensure user merch rules are provided if requested
    if isinstance(merch_rule, (MerchRule, ctypes.Structure)):
        PMTFLG = ctypes.c_int(2)  # profile model flag to use user merch rule
    else:
#        raise TypeError('User merch rule must be a MerchRule instance')
        # If merch_rule is not an instance of MerchRule class, unflag the
        # profile model variable and provide a dummy merch_rule
        PMTFLG = ctypes.c_int(1)
        merch_rule = MerchRule()

# FORTRAN subroutine call
#      SUBROUTINE VOLLIBC2(REGN,FORSTI,VOLEQI,MTOPP,MTOPS,STUMP,
#     +    DBHOB,
#     &    DRCOB,HTTYPEI,HTTOT,HTLOG,HT1PRD,HT2PRD,UPSHT1,UPSHT2,UPSD1,
#     &    UPSD2,HTREF,AVGZ1,AVGZ2,FCLASS,DBTBH,BTR,I3,I7,I15,I20,I21,
#     &    VOL,LOGVOLI,LOGDIAI,LOGLEN,BOLHT,TLOGS,NOLOGP,NOLOGS,CUTFLG,
#     &    BFPFLG,CUPFLG,CDPFLG,SPFLG,CONSPECI,PRODI,HTTFLL,LIVEI,
#     &    BA,SI,CTYPEI,ERRFLAG, INDEB, PMTFLG, MERRULES)

    # Call the FORTRAN volume library subroutine
    _nvel.vollibc2_(
            ctypes.byref(REGN)
            , FORST
            , VOLEQ
            , ctypes.byref(MTOPP)
            , ctypes.byref(MTOPS)
            , ctypes.byref(STUMP)
            , ctypes.byref(DBHOB)
            , ctypes.byref(DRCOB)
            , HTTYPE
            , ctypes.byref(HTTOT)
            , ctypes.byref(HTLOG)
            , ctypes.byref(HTPRD1)
            , ctypes.byref(HTPRD2)
            , ctypes.byref(UPSHT1)
            , ctypes.byref(UPSHT2)
            , ctypes.byref(UPSD1)
            , ctypes.byref(UPSD2)
            , ctypes.byref(HTREF)
            , ctypes.byref(AVGZ1)
            , ctypes.byref(AVGZ2)
            , ctypes.byref(FCLASS)
            , ctypes.byref(DBTBH)
            , ctypes.byref(BTR)

            , ctypes.byref(I3)
            , ctypes.byref(I7)
            , ctypes.byref(I15)
            , ctypes.byref(I20)
            , ctypes.byref(I21)

            , ctypes.byref(VOL)  # out
            , ctypes.byref(LOGVOL)  # out
            , ctypes.byref(LOGDIA)  # out
            , ctypes.byref(LOGLEN)  # in/out
            # #TODO: check the I/O status of BOLHT, I think it is only output
            , ctypes.byref(BOLHT)  # in/out

            , ctypes.byref(TLOGS)  # in/out
            , ctypes.byref(NOLOGP)  # out
            , ctypes.byref(NOLOGS)  # out

            , ctypes.byref(cubicTotalFlag)
            , ctypes.byref(boardFootFlag)
            , ctypes.byref(cubicFootFlag)
            , ctypes.byref(cordsFlag)
            , ctypes.byref(prod2Flag)

            , CONSPEC
            , PROD
            , ctypes.byref(HTTFLL)
            , LIVE
            , ctypes.byref(BA)
            , ctypes.byref(SI)
            , mCTYPE
            , ctypes.byref(ERRFLAG)

            , ctypes.byref(INDEB)
            , ctypes.byref(PMTFLG)
            , ctypes.byref(merch_rule)
            , 2, 10, 1, 4, 2, 1, 1
            )

    # process the output variables in to Python lists and data types
    result = {}
    result['VOL'] = [v for v in VOL]
    result['LOGVOL'] = [v for v in [log[:] for log in LOGVOL]]
    result['LOGDIA'] = [d for d in [log[:] for log in LOGDIA]]
    result['BOLHT'] = [ht for ht in BOLHT]
    result['TLOGS'] = TLOGS.value
    result['HTPRD1'] = HTPRD1.value
    result['UPSHT1'] = UPSHT1.value
    result['UPSD1'] = UPSD1.value
    result['HTPRD2'] = HTPRD2.value
    result['UPSHT2'] = UPSHT2.value
    result['UPSD2'] = UPSD2.value
    result['LOGLEN'] = [l for l in LOGLEN]
    result['NOLOGP'] = NOLOGP.value
    result['NOLOGS'] = NOLOGS.value
    result['ERRFLAG'] = ERRFLAG.value
    result['VOLEQ'] = VOLEQ.str

    return result

def buck_logs(merch_ht, log_len=40.0, trim=1.0
        , min_log_len=12.0, log_increment=2.0, stump_ht=1.0):
    """
    Rudimentary log segmentation for testing len_logs feature of profile models
    """
    # #TODO: find out how to adjust trim in NVEL
    lc = int((merch_ht - stump_ht) / (log_len + trim))
    len_logs = [log_len, ] * lc

    residual = merch_ht - lc * (log_len + trim) - trim
    if not residual < min_log_len:
        topLog = int(residual / log_increment) * log_increment
        len_logs.append(topLog)

    bole_hts = [0, ] * len(len_logs)
    bh = stump_ht
    for i, log in enumerate(len_logs):
        bh += len_logs[i] + trim
        bole_hts[i] = bh

    print bole_hts
    return (len_logs, bole_hts)

def get_merch_ht(spp, dbh, dib, total_ht=None, stump_ht=1.0, vol_eq=None, *args, **kargs):
    """
    Call NVEL and get back the estimated height to the minimum DIB
    """
    # get default profile vol_eq for spp
    if not vol_eq:
        vol_eq = get_volume_eq(spp)

    result = _VOLLIBC2(dbh=dbh
        , tot_ht=total_ht
        , vol_eq=vol_eq
        , top_dib_1=dib
        , stump_ht=stump_ht
        , *args, **kargs
        )

    return result['HTPRD1']

def get_total_vol(dbh, tot_ht=None, spp=None, vol_eq=None, *args, **kargs):
    """
    Return a dict of total cubic, and merch volumes for a tree
    """

    if not spp:
        spp = 'OT'

    if not vol_eq:
        vol_eq = get_volume_eq(spp)

    result = _VOLLIBC2(dbh=dbh
            , tot_ht=tot_ht
            , vol_eq=vol_eq
            , *args, **kargs
            )
    vol = {
            'merch_bdft':max(0.0, result['VOL'][1])  # + result['VOL'][11])
            , 'merch_cuft':max(0.0, result['VOL'][3])
            , 'total_cuft':max(0.0, result['VOL'][0])
            , 'int4_bdft':max(0.0, result['VOL'][9])
            }

    return(vol)

def get_volume(dbh, tot_ht=None, spp=None, vol_eq=None, *args, **kargs):
    """
    Return tree and log volume estimates using NVEL.
    
    See _VOLLIBC2 for additional parameters that can be passed to specify 
    merchadizing rules, merch height, etc.
    
    Args
    ----
    @param spp: Species character identifier. Used to lookup a volume equation.
    @param dbh: Diameter at breast height, outside bark.
    @param tot_ht: Total height from ground to tip.
    @param vol_eq: User provided volume equation identifier to use.
    
    *args - Additional positional arguments passed to _VOLLIBC2
    **kargs - Additional named arguments passed to _VOLLIBC2
    """
    # #TODO: NVEL can estimate height, test this feature
    if not tot_ht:
        raise ValueError('Height dubbing is not implemented')
        # #TODO: define a HeightDiameter class that will impute missing heights
        #           using spp,height,dbh samples, or regional coefficients
#        tot_ht = estimateHeight(spp,dbh)

    if not spp:
        spp = 'OT'

    if not vol_eq:
        vol_eq = get_volume_eq(spp)

    # Pass the tree attributes to the NVEL wrapper
    result = _VOLLIBC2(
            dbh=dbh
            , tot_ht=tot_ht
            , vol_eq=vol_eq
            , *args, **kargs
            )

    nl = result['TLOGS']
#     logs = {}
#     logs['length'] = [max(0.0, l) for l in result['LOGLEN'][:nl + 1]]
#     logs['bole_height'] = [max(0.0, l) for l in result['BOLHT'][:nl + 1]]
#     logs['scale_diam'] = [max(0.0, l) for l in result['LOGDIA'][0][:nl + 1]]
#     # large end of 2nd log == small end of first log
#     logs['large_dib'] = [max(0.0, l) for l in result['LOGDIA'][1][:nl]]
#     logs['small_dib'] = [max(0.0, l) for l in result['LOGDIA'][1][1:nl + 1]]
#     logs['merch_bdft'] = [max(0.0, l[0]) for l in result['LOGVOL'][:nl + 1]]
#     logs['merch_cuft'] = [max(0.0, l[3]) for l in result['LOGVOL'][:nl + 1]]
#     logs['int4_bdft'] = [max(0.0, l[6]) for l in result['LOGVOL'][:nl + 1]]

#     logs_dtype = numpy.dtype({
#             'names':('length', 'bole_height', 'scale_diam', 'large_dib', 'small_dib', 'merch_bdft', 'merch_cuft', 'int4_bdft')
#             , 'formats':('f4', 'f4', 'f4', 'f4', 'f4', 'f4', 'f4', 'f4',)
#             })
#     logs = numpy.recarray((nl,), dtype=logs_dtype)
    logs = [{}, ] * nl
    for l in xrange(nl):
        log = {}
        log['length'] = max(0.0, result['LOGLEN'][l])
        # BOLHT and LOGDIA begin with the large end of the the butt log
        log['bole_height'] = max(0.0, result['BOLHT'][l + 1])
        log['scale_diam'] = max(0.0, result['LOGDIA'][0][l + 1])
        # large end of 2nd log == small end of first log
        log['large_dib'] = max(0.0, result['LOGDIA'][1][l])
        log['small_dib'] = max(0.0, result['LOGDIA'][1][l + 1])
        log['merch_bdft'] = max(0.0, result['LOGVOL'][l][0])
        log['merch_cuft'] = max(0.0, result['LOGVOL'][l][3])
        log['int4_bdft'] = max(0.0, result['LOGVOL'][l][6])
        logs[l] = log

    return {
            'merch_bdft':max(0.0, result['VOL'][1])  # + result['VOL'][11])
            , 'merch_cuft':max(0.0, result['VOL'][3])
            , 'total_cuft':max(0.0, result['VOL'][0])
            , 'int4_bdft':max(0.0, result['VOL'][9])
            , 'merch_ht':result['HTPRD1']
            , 'logs':logs
            , 'num_logs':result['TLOGS']
            , 'vol_eq':result['VOLEQ']
            , 'error_flag':errCodes[result['ERRFLAG']]
            }

def test():
    """
    Demonstrates a basic call to the NVEL routine
    """
    spp = ['WH', 'RW', 'CX', 'DF', 'RA', 'SS', 'RC']
    dbh = [45.0] * len(spp)
    ht = [200.0] * len(spp)
    min_top_dib = 5.0

    for s, sp in enumerate(spp):
        # get_volume returns a dict with 'bdft' and 'cuft' volume
        vol = get_volume(dbh[s], tot_ht=ht[s], spp=sp, top_dib_1=min_top_dib)

        print('SPP: {:s}, CuFt: {:>6.1f}, BdFt: {:>6.1f}, Eq. No.: {}'.format(
                sp, vol['merch_cuft'], vol['merch_bdft'], vol['vol_eq']))

def test2():
    """
    Demonstrate and test the convenience functions and NVEL return values
    """
    spp = 'WH'
    dbh = 17
    min_top_dib = 5.0
    ht = 114
    form_class = 70

    kargs = {
#             'vol_eq':'632BEHW000'
#             'vol_eq':'B00BEHW260'  # 'B00BEHW999'
#             'vol_eq':'I00FW3W260'
#             'vol_eq':'I00FW3W017'
#             'vol_eq': 'B32BEHW263'
#             'vol_eq':'I11FW2W263'
            'vol_eq':'F01FW3W263'
            , 'stem_ht_1':17.0
            , 'stem_dob_1':dbh * float(form_class) * 0.01
            , 'region':6
            , 'form_class':form_class
            }

    # define merchandization specs to be enforced for profile models
    merch_rule = MerchRule(
            evod=2
            , opt=23
            , maxlen=40
            , minlen=12
            , minlent=12
            , merchl=12
            , mtopp=min_top_dib
            , mtops=2.0
            , stump=1.0
            , trim=1.0
            , btr=0
            , dbtbh=0
            , minbfd=8.0
            , cor="Y")

    print('spp: %s, dbh: %.1f, ht: %.1f, min dib: %.1f' % (spp, dbh, ht, min_top_dib))
    merch_ht = get_merch_ht(spp, dbh, min_top_dib, ht
            , merch_rule=merch_rule
            , **kargs
            )
    print('merch bole length : %.2f' % merch_ht)

    vol = get_total_vol(spp, dbh, tot_ht=ht
            , merch_rule=merch_rule
            , **kargs
            )
    print('')
    print('Total Volume:')
    print('%d\' logs:' % merch_rule.maxlen)
    print('total cuft: %.1f, gross cuft: %.1f, gross bdft: %.1f, intl. 1/4 bdft: %.1f' %
            (vol['tot_cuft'], vol['merch_cuft'], vol['merch_bdft'], vol['int4_bdft']))

    # predetermine the lengths of the first logs, if specified then cruise_type must be 'V'
    # if bole length exceeds the sum of predefined log lengths, then it appears
    # the remainder is processed following the default NVEL rules.
#     len_logs = [100, 40]
#     cruise_type = 'V'
    len_logs = []
    cruise_type = 'C'

    # get_volume collects all the NVEL outputs into a dictionary
    out = get_volume(dbh, spp=spp, tot_ht=ht, merch_rule=merch_rule
            , len_logs=len_logs, cruise_type=cruise_type
            , **kargs
            )
    logs = out['logs']

    print('')
    print('Error Status: %s' % out['error_flag'])
    print('Volume Equation: %s' % out['vol_eq'])
    print('Merchandized Logs:')
    keys = ('length', 'bole_height', 'scale_diam', 'large_dib', 'small_dib', 'merch_bdft', 'merch_cuft', 'int4_bdft')
    fmt = '    {:d}: ' + ','.join('{{{}:12.1f}}'.format(k) for k in keys)

    print '       ' + ','.join('{:>12s}'.format(k) for k in keys)
    for l, log in enumerate(logs):
        print fmt.format(l, **log)

def test3():
    import numexpr
    import pandas as pd
    def nwoa_ht_range(dbh):
        """
        Return a minimum and maximum height range tuple for a given DBH
        
        The low and high curves were fit to the extremes of 5 inch DBH classes
        (0-50") for all spp height samples in SLI for NW districts.
        """
        max_curve = '4.5 + 1287.8861 * exp(-4.2799 * dbh**-0.2604)'
        mean_curve = '4.5 + 1519.9448 * exp(-6.4349 * dbh**-0.2929)'
        min_curve = '4.5 + 243.7127 * exp(-7.6165 * dbh**-0.5255)'

        max_ht = numexpr.evaluate(max_curve)
        mean_ht = numexpr.evaluate(mean_curve)
        min_ht = numexpr.evaluate(min_curve)

        return (min_ht, mean_ht, max_ht)

    trees = [(d, nwoa_ht_range(d)[1]) for d in xrange(1, 121)]

    trees = pd.DataFrame.from_records(trees, columns=('dbh', 'total_ht'))

    def gv(x, spp):
        attrs = ['merch_ht', 'merch_bdft', 'total_cuft', 'merch_cuft']
        vol = get_volume(x['dbh'], x['total_ht'], spp)
        return pd.Series({v:vol.get(v) for v in attrs})

    vols = trees.apply(gv, axis=1, args=['DF', ])
    for k in vols.keys():
        trees[k] = vols[k]

#     print trees.head(10)
#     print trees.tail(10)
    print trees.ix[9:19]
    trees.to_clipboard(index=False)

if __name__ == '__main__':
    test2()
#     test3()
#     test()

