# cython: c_string_type=str, c_string_encoding=ascii
#xcython: embedsignature=True

from collections import OrderedDict

import numpy as np
cimport numpy as np
cimport cython
from cython.view cimport array as cvarray

from libc.math cimport sqrt
# from libcpp cimport bool # Boolean type has to be imported
# from cpython cimport bool

from _vollib cimport *
include 'nvelcommon.pxi'

#--- Compiler directives
DEF _NUM_PROD=10 # Number of possible log product types
DEF _MAX_LOGS=20 # NVEL tree logs array size
DEF _TREE_N_VOLS=15 # NVEL volume summary array length
DEF _LOG_N_DIAMS=3 # NVEL log diameters
DEF _LOG_N_VOLS=7 # NVEL log volume summaries

cpdef merchrules_ init_merchrule(
        int evod=1, int opt=23, float maxlen=40.0, float minlen=12.0
        , float minlent=12.0, float merchl=12.0, float mtopp=5.0
        , float mtops=2.0, float stump=1.0, float trim=1.0
        , float btr=0.0, float dbtbh=0.0, float minbfd=8.0
        , str cor='Y'
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
        cor (str): Use table Scribner values (Y) or factor volumes (N)

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
#        Not sure if <unicode> string coersion is portable
cpdef char* get_equation(
        int species, char * fvs_variant=<unicode>'PN', int region=0
        , char * forest=<unicode>'01', char * district=<unicode>'01'
        , char * product=<unicode>'01', bint fia=False):
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
    eq = <unicode>'          '
    cdef char* vol_eq = eq
    cdef int err_flag = 0
    
    # FIXME: This may be unnecessary
    vartmp = <unicode>fvs_variant
    cdef char* fvs_variant_ = vartmp
    fortmp = <unicode>forest
    cdef char* forest_ = fortmp
    distmp = <unicode>district
    cdef char* district_ = distmp
    prodtmp = <unicode>product
    cdef char* product_ = prodtmp
    
    if not fia:
        voleqdef_(fvs_variant_, &region, forest_, district_
                , &species, product_, vol_eq, &err_flag
                ,2,2,2,2,10)

    else:
        fiavoleqdef_(fvs_variant_, &region, forest_, district_
                , &species, vol_eq, &err_flag
                ,2,2,2,10)
    
    return vol_eq[:10]

cpdef float calc_height(
            int region=0, char * forest=<unicode>'01', char * volume_eq=<unicode>' '*10
            , float dbh_ob=0.0, float total_ht=0.0, float ht_prim=0.0, float ht_sec=0.0
            , float upper_ht1=0.0, float upper_ht2=0.0, float upper_diam1=0.0, float upper_diam2=0.0
            , float avg_z1=0.0, float avg_z2=0.0, int ht_ref=0, float bark_thick=0.0, float bark_ratio=0.0
            , int form_class=0, float stem_dib=0.0):
    """
    Return the bole height to a given diameter inside bark for profile models.
    
    Notes:
        Refer to vollib/ht2opd.f.
    
    Args:
        region (int): USFS region identifier.
        forest (str): USFS forest code.
        volume_eq (str): Volume equation identifier.
        dbh_ob (float): DBH outside bark (inches).
        total_ht (float): Total tree height (feet).
        
        stem_dib (float): Stem inside bark diameter to estimate height for (inches).
    
    Returns:
        Height above ground to the target stem DIB.
    """
    
    cdef float stem_height = 0.0
    cdef int err_flag = 0
    
    ht2topd_(
            &region, forest, volume_eq
            , &dbh_ob, &total_ht, &ht_prim, &ht_sec
            , &upper_ht1, &upper_ht2, &upper_diam1, &upper_diam2
            , &avg_z1, &avg_z2, &ht_ref, &bark_thick, &bark_ratio
            , &form_class, &stem_dib, &stem_height, &err_flag)
    
    if not err_flag==0:
        err_msg = error_codes[err_flag]
        raise ValueError('ht2topd returned error {}: {}'.format(err_flag,err_msg))
    
    return stem_height

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
    """
    Return Scribner board foot volume computed using factors.
    
    Args:
        diam: Log scale diameter (in).
        length: Log scale length (feet).
        cor: Return volume as Scribner decimal C if True.    
    """
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
    Initialize volume calculation for a volume equation.

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
    cdef public float bark_thick
    cdef public float bark_ratio
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
    
    cdef public int num_products
    cdef float log_prod_cuft[_NUM_PROD]
    cdef float log_prod_bdft[_NUM_PROD]
    cdef float log_prod_len[_NUM_PROD]
    cdef float log_prod_diam[_NUM_PROD]
    cdef long log_prod_count[_NUM_PROD]
    
    cdef public int num_trees
    cdef public np.int32_t[:,:] trees_volume
    cdef public np.float32_t[:,:] trees_product_cuft
    cdef public np.float32_t[:,:] trees_product_bdft    
    cdef public np.float32_t[:,:] trees_product_diam
    cdef public np.float32_t[:,:] trees_product_len
    cdef public np.int32_t[:,:] trees_product_count

    def __cinit__(self
            , merchrules_ merch_rule=init_merchrule()
            , np.ndarray log_prod_lims=np.zeros((_NUM_PROD,2), dtype=np.float32)
            , *args, **kargs):
        
        self.merch_rule = merch_rule
        self.log_prod_lims = log_prod_lims
        
        self.volume_wk = np.zeros((_TREE_N_VOLS, ), dtype=np.float32, order='F')
        self.log_vol_wk = np.zeros((_LOG_N_VOLS, _MAX_LOGS), dtype=np.float32, order='F')
        self.log_diam_wk = np.zeros((_MAX_LOGS+1, _LOG_N_DIAMS), dtype=np.float32, order='F')
        self.log_len_wk = np.zeros((_MAX_LOGS, ), dtype=np.float32, order='F')
        self.bole_ht_wk = np.zeros((_MAX_LOGS+1, ), dtype=np.float32, order='F')
        
        self.log_prod_wk = np.zeros((_MAX_LOGS, ), dtype=np.int)
        
        self.log_prod_cuft[:] = [0.0,]*_NUM_PROD
        self.log_prod_bdft[:] = [0.0,]*_NUM_PROD
        self.log_prod_len[:] = [0.0,]*_NUM_PROD
        self.log_prod_diam[:] = [0.0,]*_NUM_PROD
        self.log_prod_count[:] = [0,]*_NUM_PROD
        
        self.num_trees = 0
        self.num_products = self.log_prod_lims.shape[0]

    def __init__(self
            
            # NVEL parameters
            , int region=6, char* forest=<unicode>'12', char* volume_eq=<unicode>' '*10
            , int cubic_total_flag=1, int bdft_prim_flag=1, int cubic_prim_flag=1
            , int cord_prim_flag=1, int sec_vol_flag=1
            , char* con_spp=<unicode>' ', char* prod_code=<unicode>'01'
            , int basal_area=0, int site_index=0
            , char* cruise_type=<unicode>'C'
            
            # PyNVEL arguments
            , bint calc_products=False
            , *args, **kwargs
            ):
        """
        Initialize common volume calculation attributes.

        Args:
            region (int): USFS region number
            forest (str): USFS forest number, e.g. '04'
            volume_eq (str): Volume equation Identifier
            cubic_total_flag (int): Total cubic foot calculation flag
            bdft_prim_flag (int): Board foot calculation flag
            cubic_prim_flag (int): Primary product cubic foot calculation flag
            cord_prim_flag (int): Secondary product cubic foot calculation flag
            sec_vol_flag (int): Secondary volume calculation flag
            con_spp (str): Contract species
            prod_code (str): Product code- '01': Sawtimber; '02': Pulpwood; '03': Roundwood
            basal_area (int): Basal area per acre
            site_index (int): Site index
            cruise_type (str): Volume calculation method

                + (C)ruise method requires all necessary fields.
                + (F)VS method will impute missing heights and form_class.
                + (V)ariable method requires num_logs and log_len.
            
            calc_products (bool): If True log product classes will be summarized. 
            merch_rule (merchrules_): User defined merchandizing rules.
            log_prod_lims (ndarray): Array of log product class limits, e.g. [(min_diam, min_len),]
            *args: Arbitrary positional arguments.
            **kwargs: Arbitrary keyword arguments.
        """
        self.region = region
        self.forest = forest
        self.volume_eq = volume_eq

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
        
        self.calc_products = calc_products
        
        # Labels for the array returned by calc_array
    
    property volume_labels:
        """List of labels for the array returned by calc_array"""
        def __get__(self):
                return [
                    'total_cuft','merch_cuft'
                    ,'merch_bdft','merch_ht'
                    ,'num_logs','err_flag']
        
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
            
            if not self.calc_products:
                return None
            
            d = OrderedDict()
            for i in range(self.num_products):
                if self.log_prod_cuft[i]<=0.0:
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

    property error_message:
        """Return the volume calculation error message."""
        def __get__(self):
            return error_codes[self._error_flag]
    
    property error_flag:
        """Deprecated, use error_message or error_code."""
        def __get__(self):
            return self.error_message
        
    property error_code:
        """Return the volume calculation error code."""
        def __get__(self):
            return self._error_flag

    cdef int classify_log_product(self, float diam, float len):
        """Determine the product class of a log based on diameter and length."""
        cdef int i
        for i in range(self.num_products):
            if ((diam >= self.log_prod_lims[i][0]) 
                    and (len >= self.log_prod_lims[i][1])):
                return i
            
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
            with_prod: If True, populate the product class arrays

        Returns:
            float64: Array of tree volume attributes
        """

        #TODO: need to type the I/O arrays or use Cython views
        # http://docs.cython.org/src/tutorial/numpy.html
        # http://stackoverflow.com/questions/22118772/correct-way-to-return-numpy-friendly-arrays-using-typed-memoryviews-in-cython
        cdef size_t i
        cdef size_t n = dbh.shape[0]
#         cdef np.ndarray[np.float64_t, ndim=2] v = \
#                 np.zeros((n,6), dtype=np.float64)
        
        # Tree volume array
        self.tree_volume = np.zeros((n,6), dtype=np.float64)
        
        # Product class arrays
        self.trees_product_cuft = np.zeros((n,_NUM_PROD), dtype=np.float32)
        self.trees_product_bdft = np.zeros((n,_NUM_PROD), dtype=np.float32)
        self.trees_product_diam = np.zeros((n,_NUM_PROD), dtype=np.float32)
        self.trees_product_len = np.zeros((n,_NUM_PROD), dtype=np.float32)
        self.trees_product_count = np.zeros((n,_NUM_PROD), dtype=np.int32)
                
        if form_class is None:
            form_class = np.zeros((n,), dtype=np.float64)

        for i in range(n):
            err = self.calc(dbh_ob=dbh[i],total_ht=total_ht[i],form_class=form_class[i])
            if err!=0:
                self.tree_volume[i,0] = 0.0
                self.tree_volume[i,1] = 0.0
                self.tree_volume[i,2] = 0.0
                self.tree_volume[i,3] = 0.0
                self.tree_volume[i,4] = 0.0
                self.tree_volume[i,5] = 0.0

            else:
                self.tree_volume[i,0] = self.volume_wk[0] # Total CuFt
                self.tree_volume[i,1] = self.volume_wk[3] # Merch CuFt
                self.tree_volume[i,2] = self.volume_wk[1] # Scribner BdFt
                self.tree_volume[i,3] = self.merch_height # Merch Height
                self.tree_volume[i,4] = float(self.num_logs) # Num Logs
                self.tree_volume[i,5] = float(err) # Error Flag
            
            if self.calc_products:
                for j in range(self.num_products):
                    self.trees_product_cuft[i,j] = self.log_prod_cuft[j]
                    self.trees_product_bdft[i,j] = self.log_prod_bdft[j]
                    self.trees_product_diam[i,j] = self.log_prod_diam[j]
                    self.trees_product_len[i,j] = self.log_prod_len[j]
                    self.trees_product_count[i,j] = self.log_prod_count[j]
        
        self.num_trees = n
        
        return np.asarray(self.tree_volume)

    @cython.cdivision(True)
    cpdef int calc(self
            , float dbh_ob=0.0, float drc_ob=0.0, float total_ht=0.0, int ht_log=0
            , char* ht_type=<unicode>'F', float ht_prim=0.0, float ht_sec=0.0
            , float upper_ht1=0.0, float upper_ht2=0.0
            , float upper_diam1=0.0, float upper_diam2=0.0
            , int ht_ref=0, float avg_z1=0.0, float avg_z2=0.0, int form_class=0
            , float bark_thick=0.0, float bark_ratio=0.0, int ht_1st_limb=0
            , char* live=<unicode>'L'
            , np.ndarray log_len=np.zeros((_MAX_LOGS,),dtype=np.float32)
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
        
        # TODO: Should these merchandizing parameters be variable or static.
        #   If greater than zero they override the user values merch rule
        #   values in Mrules.f. I suspect this will change in the future.
        self.min_top_prim = self.merch_rule.mtopp
        self.min_top_sec = self.merch_rule.mtops
        self.stump_ht = self.merch_rule.stump

        cdef int i3=_LOG_N_DIAMS
        cdef int i7=_LOG_N_VOLS
        cdef int i15=_TREE_N_VOLS
        cdef int i20=_MAX_LOGS
        cdef int i21=_MAX_LOGS + 1

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
        if self.cruise_type==<bytes>'V':
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
         
        for i in range(_TREE_N_VOLS):
            if self.volume_wk[i]<0.0:
                self.volume_wk[i] = 0.0
        
        if dbh_ob<1.0:
            for i in range(_TREE_N_VOLS):
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
        
        if self.calc_products:
            self.log_prod_wk[:] = -1
            self.num_products = self.log_prod_lims.shape[0]
            # Classify the log product and populate the product tallys
            for i in range(self.num_logs):
                # Get the log product index number
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
            for i in range(self.num_products):
                self.log_prod_diam[i] = sqrt(self.log_prod_diam[i]/self.log_prod_count[i])
            
        # TODO: raise an error or recalculate with a default equation
            
#         if error_flag!=0:
#             print('Error Code {}: {}'.format(error_flag,error_codes[error_flag]))
        #TODO: raise an exception for critical error flags
        self._error_flag = error_flag
        return error_flag
