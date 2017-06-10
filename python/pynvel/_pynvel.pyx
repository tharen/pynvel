#cython: c_string_type=str, c_string_encoding=ascii
#xcython: embedsignature=True

from collections import OrderedDict

import numpy as np
cimport numpy as np
cimport cython
from cython.view cimport array as cvarray

from libc.math cimport sqrt

from _vollib cimport *
include 'nvelcommon.pxi'

#--- Compiler directives
DEF _NUM_PROD=10 # Number of possible log product types

# Assign module variables to compiler directives
num_products=_NUM_PROD

cpdef merchrules_ init_merchrule(
        int evod=1, int opt=23, float maxlen=40.0, float minlen=12.0
        , float minlent=12.0, float merchl=12.0, float mtopp=5.0
        , float mtops=2.0, float stump=1.0, float trim=1.0
        , float btr=0.0, float dbtbh=0.0, float minbfd=8.0, str cor='Y'
        ):
    """
    Return a structure defining log merchandizing rules.

    Notes:
        Refer to vollib/segmnt.f for variable definitions
        Type MERCHRULES is implemented in mrules_mod.f

    Args:
        evod (int): Log segmentation rule.

            + 1: Odd number of segments allowed
            + 2: Even segments only

        opt (int): Specified segmentation option codes are as follows.
            **Note:** opt=[11-14] implies evod=1.

            + 11: 16 ft log scale (fsh 2409.11)
            + 12: 20 ft log scale (fsh 2409.11)
            + 13: 32 ft log scale
            + 14: 40 ft log scale
            + 21: Nominal log length (NLL), if top less than half
              of NLL it is combined with next lowest log and
              segmented acording to rules for NLL max length.
              if segment is half or more of NLL then segment
              stands on its' own.
            + 22: Nominal log length, top is placed with next lowest
              log and segmented acording to rules for NLL max
              length.
            + 23: Nominal log length, top segment stands on its' own.
            + 24: Nominal log length, top segment less than 1/4 of
              NLL then segment is droped, if segment is
              1/4 to 3/4 then segment is = 1/2 of NLL,
              if segment is greater than 3/4 of NLL then
              segment is = NLL.

        maxlen (float): Maximum segment length
        minlen (float): Minimum segment length
        minlent (float): Minimum segment length, secondary product
        merchl (float): Minimum tree merch length
        mtopp (float): Minimum top diameter, primary product
        mtops (float): Minimum top diameter, secondary product
        stump (float): Stump height
        trim (float): Segment trim length
        btr (float): Bark thickness ratio (breast height)
        dbtbh (float): Double bark thickness (breast height)
        minbfd (float): Minimum merch. tree diameter
        cor (str): Make corrections to Scribner factor volumes (Y/N)

    Returns:
        struct: A struct representing the defined merchandizing rules.
    """

    # FIXME: This is a hack because I couldn't figure out how to initialize a
    #        compatible character variable as a parameter.
    cdef char cor_
    if cor == 'Y':
        cor_ = 'Y'
    else:
        cor_ = 'N'

    cdef merchrules_ mr = merchrules_(
            evod=evod, opt=opt, maxlen=maxlen, minlen=minlen, minlent=minlent
            , merchl=merchl, mtopp=mtopp, mtops=mtops, stump=stump
            , trim=trim, btr=btr, dbtbh=dbtbh, minbfd=minbfd, cor=cor_
            )

    return mr

def vollib_version():
    """Return the VOLLIB version identifier."""
    cdef int v = 0
    vernum_(&v)

    return v

# FIXME: Handle basic strings instead of unicode so Python 2 & 3 don't collide
#        http://docs.cython.org/src/tutorial/strings.html
cpdef char* get_equation(
        int species, char * fvs_variant='', int region=0, char * forest=''
        , char * district='01', char * product='01', bint fia=False):
    """
    Return the default equation ID for a species in a geographic location.

    If fvs_variant is not provided the region and forest codes are used to
    lookup a default.

    See Volume_Equation_Table.doc :download:`download
    <./Volume_Equation_Table.doc>`, section 9, for region and forest codes.

    Args:
        fvs_variant (str): FVS variant abbreviation, eg. PN for the
            Pacific Northcoast variant
        region (int): USFS region number, eg. 6 for PNW.
        forest (str): USFS forest number, e.g. '04'.
        district (str): USFS district number, (default='01').
        species (int): FIA species number.
        product (str): Product type code, '01': saw timber; '02': pulp
        fia (bool): If True, return the default FIA equation. (default=False)

    Returns:
        str: Default volume equation ID.
    """

    cdef char* vol_eq = ''
    cdef int err_flag = 0
    
    # FIXME: This may be unnecessary
    vartmp = fvs_variant.encode('UTF-8')
    cdef char* _fvs_variant = vartmp
    fortmp = forest.encode('UTF-8')
    cdef char* forest_ = fortmp
    distmp = district.encode('UTF-8')
    cdef char* district_ = distmp
    prodtmp = product.encode('UTF-8')
    cdef char* product_ = prodtmp
    
    if not fia:
        voleqdef_(_fvs_variant, &region, forest_, district_
                , &species, product_, vol_eq, &err_flag
                ,2,2,2,2,10)

    else:
        fiavoleqdef_(fvs_variant, &region, forest, district
                , &species, vol_eq, &err_flag
                ,2,2,2,10)

    return vol_eq[:10]
    
cdef class Log:
    """
    Represents a single merchandized log segment.
    """
    cdef public int position
    cdef public float bole_height
    cdef public float length
    cdef public float large_dib
    cdef public float large_dob
    cdef public float small_dib
    cdef public float small_dob
    cdef public float scale_diam
    cdef public float cuft_gross
    cdef public float bdft_gross
    cdef public float intl_gross
    cdef public int prod_class

    def __cinit__(self
            , int pos, float bole_ht, float length
            , float large_dib, float large_dob
            , float small_dib, float small_dob, float scale_diam
            , float cuft_gross, float bdft_gross, float intl_gross
            , int prod_class=0):
        self.position = pos
        self.bole_height = bole_ht
        self.length = length
        self.large_dib = large_dib
        self.large_dob = large_dob
        self.small_dib = small_dib
        self.small_dob = small_dob
        self.scale_diam = scale_diam
        self.cuft_gross = cuft_gross
        self.bdft_gross = bdft_gross
        self.intl_gross = intl_gross
        self.prod_class = prod_class

    def __getitem__(self,item):
        return getattr(self,item)

    def as_dict(self):
        """Return the log segment attributes as a dictionary."""
        d = OrderedDict()
        d['position'] = self.position
        d['bole_height'] = self.bole_height
        d['length'] = self.length
        d['large_dib'] = self.large_dib
        d['large_dob'] = self.large_dob
        d['small_dib'] = self.small_dib
        d['small_dob'] = self.small_dob
        d['scale_diam'] = self.scale_diam
        d['cuft_gross'] = self.cuft_gross
        d['bdft_gross'] = self.bdft_gross
        d['intl_gross'] = self.intl_gross
        d['prod_class'] = self.prod_class

        return d

    def __repr__(self):
        d = self.as_dict()
        return str(d)

#     def __str__(self):
#         return self.__repr__()

cpdef float scribner_volume(float diam, float length, bint cor=True):
    cdef char*  _cor
    cdef float vol

    if cor:
        _cor='Y'
    else:
        _cor='N'

    scrib_(&diam,&length,_cor,&vol,1)

    return vol

cdef class Cython_VolumeCalculator:
    """
    Initialize volume calculation for a single species.

    Attributes:
        volume_eq (str): NVEL volume equation identifier
        dbh_ob (float): Diameter at breast height, outside bark
        drc_ob (float): Diameter at root collar, outside bark
        form_class (int): Girard form class, e.g. DIB at 17.3'/DBH
        num_logs (int): Number of logs estimated for the tree
        num_logs_prim (float): Number of primary product logs
        num_logs_sec (float): Number of secondary product logs
    """
    cdef int region
    cdef char* forest
    cdef public char* volume_eq
    cdef float min_top_prim
    cdef float min_top_sec
    cdef float stump_ht
    cdef public float dbh_ob
    cdef public float drc_ob
    cdef char* ht_type
    cdef float total_ht
    cdef int ht_log
    cdef float ht_prim
    cdef float ht_sec
    cdef float upper_ht1
    cdef float upper_ht2
    cdef float upper_diam1
    cdef float upper_diam2
    cdef int ht_ref
    cdef float avg_z1
    cdef float avg_z2
    cdef public int form_class
    cdef float bark_thick
    cdef float bark_ratio
    cdef public int num_logs
    cdef public float num_logs_prim
    cdef public float num_logs_sec
    cdef int cubic_total_flag
    cdef int bdft_prim_flag
    cdef int cubic_prim_flag
    cdef int cord_prim_flag
    cdef int sec_vol_flag
    cdef char* con_spp
    cdef char* prod_code
    cdef int ht_1st_limb
    cdef char* live
    cdef int basal_area
    cdef int site_index
    cdef char* cruise_type
    cdef int _error_flag
    cdef public merchrules_ merch_rule
    cdef list sorts

    cdef np.float32_t[:] volume_wk
    cdef np.float32_t[:,:] log_vol_wk
    cdef np.float32_t[:,:] log_diam_wk
    cdef np.float32_t[:] log_len_wk
    cdef np.float32_t[:] bole_ht_wk
    
    cdef np.int_t[:] log_prod_wk
    cdef public np.float32_t[:,:] log_prod_lims
    
    cdef float log_prod_cuft[_NUM_PROD]
    cdef float log_prod_bdft[_NUM_PROD]
    cdef float log_prod_len[_NUM_PROD]
    cdef float log_prod_diam[_NUM_PROD]
    cdef long log_prod_count[_NUM_PROD]

    def __cinit__(self
            , merchrules_ merch_rule=init_merchrule()
            , np.ndarray log_prod_lims=np.zeros((5,2), dtype=np.float32)
            , *args, **kargs):
        
        self.merch_rule = merch_rule
        self.log_prod_lims = log_prod_lims
        
        self.volume_wk = np.zeros((15, ), dtype=np.float32, order='F')
        self.log_vol_wk = np.zeros((7, 20), dtype=np.float32, order='F')
        self.log_diam_wk = np.zeros((21, 3), dtype=np.float32, order='F')
        self.log_len_wk = np.zeros((20, ), dtype=np.float32, order='F')
        self.bole_ht_wk = np.zeros((21, ), dtype=np.float32, order='F')
        
        self.log_prod_wk = np.zeros((20, ), dtype=np.int)
        
        self.log_prod_cuft[:] = [0.0,]*_NUM_PROD
        self.log_prod_bdft[:] = [0.0,]*_NUM_PROD
        self.log_prod_len[:] = [0.0,]*_NUM_PROD
        self.log_prod_diam[:] = [0.0,]*_NUM_PROD
        self.log_prod_count[:] = [0,]*_NUM_PROD
        

    def __init__(self, int region=6, char* forest='12', char* volume_eq=''
            , float min_top_prim=5.0, float min_top_sec=2.0, float stump_ht=1.0
            , int cubic_total_flag=1, int bdft_prim_flag=1, int cubic_prim_flag=1
            , int cord_prim_flag=1, int sec_vol_flag=1
            , char* con_spp='', char* prod_code='01'
            , int basal_area=0, int site_index=0
            , char* cruise_type='C'
            , *args, **kargs
            ):
        """
        Initialize common volume calculation attributes.

        Args:
            region (int): USFS region number
            forest (str): USFS forest number, e.g. '04'
            volume_eq (str): Volume equation Identifier
            min_top_prim (float): Primary product minimum top diameter
            min_top_sec (float): Secondary product minimum top diameter
            stump_ht (float): Stump height
            cubic_total_flag (int): Tota cubic foot calculation flag
            bdft_prim_flag (int): Board foot calculation flag
            cubic_prim_flag (int): Primary product cubic foot calculation flag
            cord_prim_flag (int): Secondary product cubic foot calculation flag
            sec_vol_flag (int): Secondary volume calculation flag
            con_spp (str): Contract species
            prod_code (int): Product code- 1: Sawtimber; 2: Pulpwood; 3: Roundwood
            basal_area (int): Basal area per acre
            site_index (int): Site index
            cruise_type (str): Volume calculation method

                + (C)ruise method requires all necessary fields.
                + (F)VS method will impute missing heights and form_class.
                + (V)ariable method requires num_logs and log_len.

            merch_rule (merchrules_): User defined merchandizing rules.
            log_prod_lims (ndarray): Array of log product class limits, e.g. [(min_diam, min_len),]
        """
        self.region = region
        self.forest = forest
        self.volume_eq = volume_eq
        self.min_top_prim = min_top_prim
        self.min_top_sec = min_top_sec
        self.stump_ht = stump_ht

        self.cubic_total_flag = cubic_total_flag
        self.bdft_prim_flag = bdft_prim_flag
        self.cubic_prim_flag = cubic_prim_flag
        self.cord_prim_flag = cord_prim_flag
        self.sec_vol_flag = sec_vol_flag

        self.con_spp = con_spp
        self.prod_code = prod_code
        self.basal_area = basal_area
        self.site_index = site_index
        self.cruise_type = cruise_type
        
    property total_height:
        """Return the total height of the tree."""
        def __get__(self):
            return self.total_ht

    property merch_height:
        """Return the height to the top of the primary product."""
        def __get__(self):
            return self.ht_prim

    property form_height:
        """Return the reference height used in bole form estimation."""
        def __get__(self):
            return self.ht_ref

    property volume:
        """Return a dict of tree volumes."""
        def __get__(self):
            # zip vol_lbl from nvelcommon.pxi with the volume array
            return dict(zip(vol_lbl, self.volume_wk))
    
    property products:
        """Return a dict of log product summaries."""
        def __get__(self):
            cdef int i
            d = OrderedDict()
            for i in range(_NUM_PROD):
                # print(i)
                if self.log_prod_cuft[i]<=0.0:
                    # print('skip')
                    continue
                
                l = 'prod_{}'.format(i+1)
                d[l] = {}
                d[l]['cuft'] = self.log_prod_cuft[i]
                d[l]['bdft'] = self.log_prod_bdft[i]
                d[l]['length'] = self.log_prod_len[i]
                d[l]['count'] = self.log_prod_count[i]
                d[l]['diameter'] = self.log_prod_diam[i]
            
            return d
            
    property log_vol:
        """Return a list of log segment volumes."""
        def __get__(self):
            # zip log_vol_lbl from nvelcommon.pxi with the log volume array
            #return [dict(zip(log_vol_lbl, v)) for v in self.log_vol_wk[:self.num_logs]]

            cdef int i

            vols = []
            lbls = [v[0] for k,v in sorted(log_volume_idx.items())]
            for i in range(self.num_logs):
                vols.append(dict(zip(lbls, self.log_vol_wk[:,i])))

            return vols

    property log_diam:
        """Return a list a estimated log diameters."""
        def __get__(self):

            cdef int i

            diams = []
            for i in range(self.num_logs+1):
                l = np.array(self.log_diam_wk[i])
                s = np.array(self.log_diam_wk[i+1])

                d = {   'large_ob':l[2]
                        ,'small_ob':s[2]
                        ,'large_ib':l[1]
                        ,'small_ib':s[1]
                        ,'scale':s[0]
                        }
                diams.append(d)

            return diams

    property logs:
        """Return a list of log objects."""
        def __get__(self):
            cdef int i
            # TODO: Make logs a C array of Log objects
            logs = []

            for i in range(1,self.num_logs+1):
                large = np.array(self.log_diam_wk[i-1])
                small = np.array(self.log_diam_wk[i])
                vol = np.array(self.log_vol_wk[:,i-1])
                len = self.log_len_wk[i-1]
                bole = self.bole_ht_wk[i]
                prod = self.log_prod_wk[i-1]
                
                logs.append(Log(i,bole,len
                        ,large[1],large[2]
                        ,small[1],small[2],small[0]
                        ,vol[3],vol[0],vol[6],prod
                        ))

            return logs

    property error_flag:
        """Return the volume calculation error code."""
        def __get__(self):
            return error_codes[self._error_flag]

    cdef int classify_log_product(self, float diam, float len):
        """Determine the product class of a log based on diameter and length."""
        cdef int i
        for i in range(_NUM_PROD):
            if ((diam >= self.log_prod_lims[i][0]) 
                    and (len >= self.log_prod_lims[i][1])):
                return i+1
            
    @cython.boundscheck(False)
    @cython.wraparound(False)
    def calc_array(self,
            np.ndarray[np.float64_t, ndim=1] dbh,
            np.ndarray[np.float64_t, ndim=1] total_ht,
            np.ndarray[np.float64_t, ndim=1] form_class=None):
        """
        Return an array of volume attributes for an array of trees.

        Args:
            dbh (float64): Array of tree DBHs
            total_ht (float64): Array of tree heights
            form_class (float64): Array of form class values

        Returns:
            float64: Array of tree volume attributes
        """

        #TODO: need to type the I/O arrays or use Cython views
        # http://docs.cython.org/src/tutorial/numpy.html
        # http://stackoverflow.com/questions/22118772/correct-way-to-return-numpy-friendly-arrays-using-typed-memoryviews-in-cython
        cdef size_t i
        cdef size_t n = dbh.shape[0]
        cdef np.ndarray[np.float64_t, ndim=2] v = \
                np.zeros((n,6), dtype=np.float64)
        
        cdef np.ndarray[np.float64_t, ndim=2] logs = \
                np.zeros((n,6), dtype=np.float64)

        if form_class is None:
            form_class = np.zeros((n,), dtype=np.float64)

        for i in range(n):
            err = self.calc(dbh_ob=dbh[i],total_ht=total_ht[i],form_class=form_class[i])
            if err!=0:
                v[i,0] = 0.0
                v[i,1] = 0.0
                v[i,2] = 0.0
                v[i,3] = 0.0
                v[i,4] = 0.0
                v[i,5] = 0.0

            else:
                v[i,0] = self.volume_wk[0] # Total CuFt
                v[i,1] = self.volume_wk[3] # Merch CuFt
                v[i,2] = self.volume_wk[1] # Scribner BdFt
                v[i,3] = self.merch_height # Merch Height
                v[i,4] = float(self.num_logs) # Num Logs
                v[i,5] = float(err) # Error Flag

        return v

    @cython.cdivision(True)
    cpdef int calc(self
            , float dbh_ob=0.0, float drc_ob=0.0, float total_ht=0.0, int ht_log=0
            , char* ht_type='F', float ht_prim=0.0, float ht_sec=0.0
            , float upper_ht1=0.0, float upper_ht2=0.0, float upper_diam1=0.0, float upper_diam2=0.0
            , int ht_ref=0, float avg_z1=0.0, float avg_z2=0.0, int form_class=0
            , float bark_thick=0.0, float bark_ratio=0.0, int ht_1st_limb=0, char* live='L'
            , np.ndarray log_len=np.zeros((20,),dtype=np.float32)
            ):
        """
        Estimate the volume of a tree.

        Tree volume will be estimated using the volume equation, merch. rules,
        etc. defined by the attributes of the current instance of
        VolumeCalculator.

        Args:
            dbh_ob (float):
            drc_ob (float):
            total_ht (float):

            ht_type (str):
            ht_log (int):
            ht_prim (float):
            ht_sec (float):

            upper_ht1 (float):
            upper_ht2 (float):
            upper_diam1 (float):
            upper_diam2 (float):
            ht_ref (int):
            avg_z1 (float):
            avg_z2 (float):
            form_class (int):

            bark_thick (float):
            bark_ratio (float):
            ht_1st_limb (int):
            live (str):

        """
        
        cdef float check_vol
        cdef float cone_vol
        
        self.dbh_ob = dbh_ob
        self.drc_ob = drc_ob
        self.total_ht = total_ht

        self.ht_type = ht_type
        self.ht_log = ht_log
        self.ht_prim = ht_prim
        self.ht_sec = ht_sec

        self.upper_ht1 = upper_ht1
        self.upper_ht2 = upper_ht2
        self.upper_diam1 = upper_diam1
        self.upper_diam2 = upper_diam2
        self.ht_ref = ht_ref
        self.avg_z1 = avg_z1
        self.avg_z2 = avg_z2
        self.form_class = form_class

        self.bark_thick = bark_thick
        self.bark_ratio = bark_ratio
        self.ht_1st_limb = ht_1st_limb
        self.live = live

        cdef int i3=3
        cdef int i7=7
        cdef int i15=15
        cdef int i20=20
        cdef int i21=21

        self.num_logs_prim = 0.0
        self.num_logs_sec = 0.0

        cdef int error_flag = 0
        cdef int idist = 0

        cdef int fl = 2
        cdef int vl = 10
        cdef int hl = 1
        cdef int csl = 4
        cdef int pl = 2
        cdef int ll = 1
        cdef int ctl = 1
        
        cdef int p
        
        # Ensure the result arrays are zero'd
        self.volume_wk[:] = 0.0
        self.log_vol_wk[:,:] = 0.0
        self.log_len_wk[:] = 0.0
        self.log_diam_wk[:,:] = 0.0
        self.bole_ht_wk[:] = 0.0
        
        # Zero the log product tallys
        self.log_prod_cuft[:] = [0.0,]*_NUM_PROD
        self.log_prod_bdft[:] = [0.0,]*_NUM_PROD
        self.log_prod_len[:] = [0.0,]*_NUM_PROD
        self.log_prod_diam[:] = [0.0,]*_NUM_PROD
        self.log_prod_count[:] = [0,]*_NUM_PROD

        # Populate log_len_wk if log lengths are provided
        self.num_logs = 0
        cdef int i
        if self.cruise_type==b'V':
            if log_len.any():
                for i in xrange(log_len.shape[0]):
                    if log_len[i]<=0.0: break
                    self.num_logs += 1
                    self.log_len_wk[i] = log_len[i]

            else:
                raise AttributeError('cruise_type==\'V\', but log_len is empty')
        
        # Zero the log product class
        self.log_prod_wk[:] = 0
        
        volinit2_(
                &self.region
                , self.forest
                , self.volume_eq
                , &self.min_top_prim
                , &self.min_top_sec
                , &self.stump_ht
                , &self.dbh_ob
                , &self.drc_ob
                , self.ht_type
                , &self.total_ht
                , &self.ht_log
                , &self.ht_prim
                , &self.ht_sec
                , &self.upper_ht1
                , &self.upper_ht2
                , &self.upper_diam1
                , &self.upper_diam2
                , &self.ht_ref
                , &self.avg_z1
                , &self.avg_z2
                , &self.form_class
                , &self.bark_thick
                , &self.bark_ratio
                , &i3
                , &i7
                , &i15
                , &i20
                , &i21
                , &self.volume_wk[0]
                , &self.log_vol_wk[0,0]
                , &self.log_diam_wk[0,0]
                , &self.log_len_wk[0]
                , &self.bole_ht_wk[0]
                , &self.num_logs
                , &self.num_logs_prim
                , &self.num_logs_sec
                , &self.cubic_total_flag
                , &self.bdft_prim_flag
                , &self.cubic_prim_flag
                , &self.cord_prim_flag
                , &self.sec_vol_flag
                , self.con_spp
                , self.prod_code
                , &self.ht_1st_limb
                , self.live
                , &self.basal_area
                , &self.site_index
                , self.cruise_type
                , &error_flag
                , &self.merch_rule
                , &idist

                # Lengths of char* arguments
                # TODO: This is the gfortran way, but perhaps not Intel, etc.
                , fl, vl, hl, csl
                , pl, ll, ctl
                )
        
        # Some equation and tree combinations will overflow/underflow
        # This is a blunt check to make sure the total volume is reasonable
        cone_vol = ((dbh_ob*0.92)**2.0 * 0.005454154 * total_ht) / 3.0
        cyl_vol = ((dbh_ob*0.92)**2.0 * 0.005454154 * total_ht)
         
        for i in range(15):
            if self.volume_wk[i]<0.0:
                self.volume_wk[i] = 0.0
        
        if dbh_ob<1.0:
            for i in range(15):
                self.volume_wk[i] = 0.0
            
            self.volume_wk[0] = cone_vol
            
        if self.volume_wk[14]>cone_vol*2:
            self.volume_wk[14] = 0.0
            # TODO: Log this as an error or raise a warning/exception
             
        check_vol = (
                self.volume_wk[3] + self.volume_wk[6]
                + self.volume_wk[13] + self.volume_wk[14])
         
        if self.volume_wk[0]>check_vol*2:
            self.volume_wk[0] = check_vol
        
        # Classify the log product as populate the product tallys
        for i in range(self.num_logs):
            p = self.classify_log_product(
                    self.log_diam_wk[i+1,0]
                    ,self.log_len_wk[i]
                    )
            self.log_prod_wk[i] = p
            self.log_prod_cuft[p] += self.log_vol_wk[3,i]
            self.log_prod_bdft[p] += self.log_vol_wk[0,i]
            self.log_prod_len[p] += self.log_len_wk[i]
            # Sum the squared diameters to get a quadratic mean
            self.log_prod_diam[p] += self.log_diam_wk[i+1,1]**2.0
            self.log_prod_count[p] += 1
        
        # Compute quadratic mean log diameter
        for i in range(_NUM_PROD):
            self.log_prod_diam[i] = sqrt(self.log_prod_diam[i]/self.log_prod_count[i])
            
        # TODO: raise an error or recalculate with a default equation
            
#         if error_flag!=0:
#             print('Error Code {}: {}'.format(error_flag,error_codes[error_flag]))
        #TODO: raise an exception for critical error flags
        self._error_flag = error_flag
        return error_flag
