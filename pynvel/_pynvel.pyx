import numpy as np
from collections import OrderedDict
cimport numpy as np

include 'nvelcommon.pxi'

cdef extern from *:    
    void vernum_(int *v)
    void getvoleq_(int *region, char* forest, char* district
            , int *species, char* product, char* vol_eq, int *err_flag
            , int fl, int dl, int pl, int vl)
    void getfiavoleq_(int *region, char* forest, char* district
            , int *species, char* vol_eq, int *err_flag
            , int fl, int dl, int vl)
    void vollibc2_(
            int *regn, char* forsti, char* voleqi, float *mtopp, float *mtops
            , float *stump, float *dbhob, float *drcob, char* httypei
            , float *httot, int *htlog, float *ht1prd, float *ht2prd
            , float *upsht1, float *upsht2, float *upsd1, float *upsd2
            , int *htref, float *avgz1, float *avgz2, int *fclass
            , float *dbtbh, float *btr
            , int *i3, int *i7, int *i15, int *i20, int *i21
            , float *vol, float *logvoli, float *logdiai
            , float *loglen, float *bolht, int *tlogs
            , float *nologp, float *nologs
            , int *cutflg, int *bfpflg, int *cupflg, int *cdpflg, int *spflg
            , char* conspeci, char* prodi, int *httfll, char* livei
            , int *ba, int *si, char* ctypei, int *errflag, int *indeb
            , int *pmtflg, merchrules_ *merrules
            , int forsti_len, int voleqi_len, int httypei_len, int conspeci_len
            , int prodi_len, int livei_len, int ctypei_len
            )
    void volinit2_(
            int *regn, char* forsti, char* voleqi, float *mtopp, float *mtops
            , float *stump, float *dbhob, float *drcob, char* httypei
            , float *httot, int *htlog, float *ht1prd, float *ht2prd
            , float *upsht1, float *upsht2, float *upsd1, float *upsd2
            , int *htref, float *avgz1, float *avgz2, int *fclass
            , float *dbtbh, float *btr
            , int *i3, int *i7, int *i15, int *i20, int *i21
            , float *vol, float *logvoli, float *logdiai
            , float *loglen, float *bolht, int *tlogs
            , float *nologp
            , float *nologs
            , int *cutflg
            , int *bfpflg
            , int *cupflg
            , int *cdpflg
            , int *spflg
            , char* conspeci
            , char* prodi
            , int *httfll
            , char* livei
            , int *ba
            , int *si
            , char* ctypei
            , int *errflag
            , merchrules_ *merrules
            , int forsti_len, int voleqi_len, int httypei_len, int conspeci_len
            , int prodi_len, int livei_len, int ctypei_len
            )

cdef extern:
    ctypedef struct merchrules_:
        int evod
        int opt
        float maxlen
        float minlen
        float minlent
        float merchl
        float mtopp
        float mtops
        float stump
        float trim
        float btr
        float dbtbh
        float minbfd
        char cor #NOTE: **Must be single char, not pointer. Unsure how to pass a len arg in a struct

cpdef merchrules_ init_merchrule(
        int evod=1, int opt=23, float maxlen=40.0, float minlen=12.0
        , float minlent=12.0, float merchl=12.0, float mtopp=5.0
        , float mtops=2.0, float stump=1.0, float trim=1.0
        , float btr=0.0, float dbtbh=0.0, float minbfd=8.0, str cor='Y'
        ):
    """
    Return a structure that defines log merchandization rules.
    
    Args
    ----
    :param evod: Even/Odd 1: Odd number of segments allowed; 2: Even segments only
            11-14: Segmentation options allow odd lengths by definition.
    :param opt: Specified segmentation option codes are as follows:
            11 = 16 ft log scale (fsh 2409.11)
            12 = 20 ft log scale (fsh 2409.11)
            13 = 32 ft log scale
            14 = 40 ft log scale
            21 = Nominal log length (NLL), if top less than half
                 of NLL it is combined with next lowest log and
                 segmented acording to rules for NLL max length.
                 if segment is half or more of NLL then segment
                 stands on its' own.
            22 = Nominal log length, top is placed with next lowest
                 log and segmented acording to rules for NLL max
                 length.
            23 = Nominal log length, top segment stands on its' own.
            24 = Nominal log length, top segment less than 1/4 of
                 NLL then segment is droped, if segment is
                 1/4 to 3/4 then segment is = 1/2 of NLL,
                 if segment is greater than 3/4 of NLL then
                 segment is = NLL.
    :param maxlen: Maximum segment length
    :param minlen: Minimum segment length
    :param minlent: Minimum segment length, secondary product
    :param merchl: Minimum tree merch length
    :param mtopp: Minimum top diameter, primary product
    :param mtops: Minimum top diameter, secondary product
    :param stump: Stump height
    :param trim: Segment trim length
    :param btr: Bark thickness ratio (breast height)
    :param dbtbh: Double bark thickness (breast height)
    :param minbfd: Minimum merch. tree diameter
    :param cor: Make corrections to Scribner factor volumes (Y/N)
    
    Refs:
    segmnt.f  
    """
    
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

def vernum():
    cdef int v = 0
    vernum_(&v)
     
    return v

cpdef char* getvoleq(
        int region, char* forest, char* district
        , int species, char* product):
    """
    Return the default volume equation for a species
    """
    cdef char* vol_eq = ''
    cdef int err_flag = 0
    
    getvoleq_(
            &region, forest, district
            , &species, product, vol_eq, &err_flag
            , 2, 2, 2, 10
            )
    
    return vol_eq[:10]

cpdef char* getfiavoleq(int region, char* forest, char* district, int species):
    """
    Return the default FIA volume equation for a species
    """
    cdef char* vol_eq = ''
    cdef int err_flag = 0
    
    getfiavoleq_(
            &region, forest, district
            , &species, vol_eq, &err_flag
            , 2, 2, 10
            )
    
    return vol_eq[:10]

DTYPE_float32 = np.float32
ctypedef np.float32_t DTYPE_float32_t

def get_volume(
        int region=0, forest=0, volume_eq='', float min_top_prim=5.0
        , float min_top_sec=2.0, float stump_ht=1.0, float dbh_ob=0.0, float drc_ob=0.0
        , ht_type='F', float total_ht=0.0, int ht_log=0, float ht_prim=0.0, float ht_sec=0.0
        , float upper_ht1=0.0, float upper_ht2=0.0, float upper_diam1=0.0, float upper_diam2=0.0
        , int ht_ref=0, float avg_z1=0.0, float avg_z2=0.0, int form_class=0
        , float bark_thick=0.0, float bark_ratio=0.0, log_len=[]
        , int num_logs=0, float num_logs_prim=0.0, float num_logs_sec=0.0
        , int cubic_total_flag=1, int bdft_prim_flag=1, int cubic_prim_flag=1
        , int cord_prim_flag=1, int sec_vol_flag=1, con_spp='', prod_code=1
        , int ht_1st_limb=0, live='L', int basal_area=0, int site_index=0
        , cruise_type='C', int debug=0
        , merchrules_ merch_rule=init_merchrule()):
    """
    Calculate total tree and log volumes for a single tree.
    
    Arguments
    ---------
    :param region: USFS region number
    :param forest: USFS forest number
    :param volume_eq: Volume equation Identifier
    :param min_top_prim: rimary product minimum top diameter
    :param min_top_sec: Secondary product minimum top diameter
    :param stump_ht: Stump height
    :param dbh_ob: Diameter at breast height
    :param drc_ob: Diameter at root collar
    :param ht_type: Height measurement type (F)eet; (L)ogs
    :param total_ht: Total tree height
    :param ht_log: Length of logs if ht_type=='L'
    :param ht_prim: Height to top of primary product
    :param ht_sec: Height to top of secondary product
    :param upper_ht1: Reference height for 1st upper stem diameter
    :param upper_ht2: Reference height for 2nd upper stem diameter
    :param upper_diam1: First upper stem diameter
    :param upper_diam2: Second upper stem diameter
    :param ht_ref: Height reference
    :param avg_z1: Flewellings average Z factor (1st)
    :param avg_z2: Flewellings average Z factor (2nd)
    :param form_class: Girard's form class
    :param bark_thick: Double bark thickness
    :param bark_ratio: Bark thickness ratio
    :param log_len: Individual log lengths
    :param num_logs: Number of logs
    :param num_logs_prim: Number of logs primary product
    :param num_logs_sec: Number of logs secondary product
    :param cubic_total_flag: Tota cubic foot calculation flag
    :param bdft_prim_flag: Board foot calculation flag
    :param cubic_prim_flag: Primary product cubic foot calculation flag
    :param cord_prim_flag: Secondary product cubic foot calculation flag
    :param sec_vol_flag: Secondary volume calculation flag
    :param con_spp: Contract species
    :param prod_code: Product code 1-Sawtimber; 2-Pulpwood; 3-Roundwood 
    :param live: Tree status (L)ive;(D)ead
    :param basal_area: Basal area per acre
    :param site_index: Site index
    :param cruise_type: Volume calculation method:
            (C)ruise method requires all necessary fields.
            (F)VS method will impute missing heights and form_class.
            (V)ariable method requires num_logs and log_len.
    :param debug: Debug flag
    :param merch_rule: Merchandization rule (object). If None then defaults 
            will be used for the region and forest.
    """
    
    forest = '{:>02d}'.format(forest)
    cdef char* forest_c = forest
    cdef int fl = 2
    cdef char* volume_eq_c = volume_eq
    cdef int vl = 10     
    cdef char* ht_type_c = 'F'
    cdef int hl = 1
    
    # Array size variables
    cdef int i3 = 3
    cdef int i7 = 7
    cdef int i15 = 15
    cdef int i20 = 20
    cdef int i21 = 21
    # NOTE:vollib.vollibcs is a wrapper that handles reshaping the arrays and variables between C and Fortran
    # TODO: Call vollib.volinit and volinit2 directly to avoid unecessary variable manipulation
    cdef np.ndarray[DTYPE_float32_t, ndim=1, mode='c'] volume_c = np.zeros((i15,), dtype=DTYPE_float32)
#     cdef np.ndarray[np.float32_t, ndim=1, mode='c'] volume_c = np.zeros((i15, ), dtype=np.float32)
    cdef np.ndarray[np.float32_t, ndim=2, mode='c'] log_vol_c = np.zeros((i7, i20), dtype=np.float32)
    cdef np.ndarray[np.float32_t, ndim=2, mode='c'] log_diam_c = np.zeros((i21, i3), dtype=np.float32)
    cdef np.ndarray[np.float32_t, ndim=1, mode='c'] log_len_c = np.zeros((i20, ), dtype=np.float32)
    cdef np.ndarray[np.float32_t, ndim=1, mode='c'] bole_ht_c = np.zeros((i21, ), dtype=np.float32)
    
    con_spp = '{:>4s}'.format(con_spp)
    cdef char* con_spp_c = con_spp
    cdef int csl = 4
    
    prod_code = '{:>02d}'.format(prod_code)
    cdef char* prod_code_c = prod_code
    cdef int pl = 2
     
    cdef int ht_1st_limb_c = ht_1st_limb
     
    cdef char* live_c = live 
    cdef int ll = 1
    
    cdef char* cruise_type_c = cruise_type
    cdef int ctl = 1
    
    cdef int user_merch_flag = 2    
    cdef int error_flag = 0
    
    if num_logs>0:
        log_len_c[:num_logs] = log_len[:num_logs]
        cruise_type_c='V'
    
    vollibc2_(
            &region
            , forest_c
            , volume_eq_c
            , &min_top_prim
            , &min_top_sec
            , &stump_ht
            , &dbh_ob
            , &drc_ob
            , ht_type_c
            , &total_ht
            , &ht_log
            , &ht_prim
            , &ht_sec
            , &upper_ht1
            , &upper_ht2
            , &upper_diam1
            , &upper_diam2
            , &ht_ref
            , &avg_z1
            , &avg_z2
            , &form_class
            , &bark_thick
            , &bark_ratio
            , &i3
            , &i7
            , &i15
            , &i20
            , &i21
            , &volume_c[0]
            , &log_vol_c[0,0]
            , &log_diam_c[0,0]
            , &log_len_c[0]
            , &bole_ht_c[0]
            , &num_logs
            , &num_logs_prim
            , &num_logs_sec
            , &cubic_total_flag
            , &bdft_prim_flag
            , &cubic_prim_flag
            , &cord_prim_flag
            , &sec_vol_flag
            , con_spp_c
            , prod_code_c
            , &ht_1st_limb
            , live_c
            , &basal_area
            , &site_index
            , cruise_type_c
            , &error_flag
            , &debug
            , &user_merch_flag
            , &merch_rule
            , fl
            , vl
            , hl
            , csl
            , pl
            , ll
            , ctl
            )
    
    print 'region -', region
    print 'forest_c -', forest_c
    print 'volume_eq_c -', volume_eq_c
    print 'min_top_prim -', min_top_prim
    print 'min_top_sec -', min_top_sec
    print 'stump_ht -', stump_ht
    print 'dbh_ob -', dbh_ob
    print 'drc_ob -', drc_ob
    print 'ht_type_c -', ht_type_c
    print 'total_ht -', total_ht
    print 'ht_log -', ht_log
    print 'ht_prim -', ht_prim
    print 'ht_sec -', ht_sec
    print 'upper_ht1 -', upper_ht1
    print 'upper_ht2 -', upper_ht2
    print 'upper_diam1 -', upper_diam1
    print 'upper_diam2 -', upper_diam2
    print 'ht_ref -', ht_ref
    print 'avg_z1 -', avg_z1
    print 'avg_z2 -', avg_z2
    print 'form_class -', form_class
    print 'bark_thick -', bark_thick
    print 'bark_ratio -', bark_ratio
    print 'i3 -', i3
    print 'i7 -', i7
    print 'i15 -', i15
    print 'i20 -', i20
    print 'i21 -', i21
    print 'volume_c[0] -', volume_c[0:5]
    print 'log_vol_c[0,0] -', log_vol_c[0,0]
    print 'log_diam_c[0,0] -', log_diam_c[0,0]
    print 'log_len_c[0] -', log_len_c[0]
    print 'bole_ht_c[0] -', bole_ht_c[0]
    print 'num_logs -', num_logs
    print 'num_logs_prim -', num_logs_prim
    print 'num_logs_sec -', num_logs_sec
    print 'cubic_total_flag -', cubic_total_flag
    print 'bdft_prim_flag -', bdft_prim_flag
    print 'cubic_prim_flag -', cubic_prim_flag
    print 'cord_prim_flag -', cord_prim_flag
    print 'sec_vol_flag -', sec_vol_flag
    print 'con_spp_c -', con_spp_c
    print 'prod_code_c -', prod_code_c
    print 'ht_1st_limb -', ht_1st_limb
    print 'live_c -', live_c
    print 'basal_area -', basal_area
    print 'site_index -', site_index
    print 'cruise_type_c -', cruise_type_c
    print 'error_flag -', error_flag
    print 'debug -', debug
    print 'user_merch_flag -', user_merch_flag
    print 'merch_rule -', merch_rule
    print 'fl -', fl
    print 'vl -', vl
    print 'hl -', hl
    print 'csl -', csl
    print 'pl -', pl
    print 'll -', ll
    print 'ctl -', ctl

    if error_flag!=0:
        print 'Error Code {}: {}'.format(error_flag,error_codes[error_flag])
    
#     print log_len_c
#     print log_diam_c
    return dict(zip(vol_lbl,volume_c))

# def get_merch_ht(spp, dbh, dib, total_ht=None, stump_ht=1.0, vol_eq=None, *args, **kargs):
#     """
#     Call NVEL and get back the estimated height to the minimum DIB
#     """
#     # get default profile vol_eq for spp
#     if not vol_eq:
#         vol_eq = get_volume_eq(spp)
# 
#     result = _VOLLIBC2(dbh=dbh
#         , tot_ht=total_ht
#         , vol_eq=vol_eq
#         , top_dib_1=dib
#         , stump_ht=stump_ht
#         , *args, **kargs
#         )
# 
#     return result['HTPRD1']

cdef class Log:
    cdef public int pos
    cdef public float bole_ht
    cdef public float length
    cdef public float large_dib
    cdef public float large_dob
    cdef public float small_dib
    cdef public float small_dob
    cdef public float scale_diam
    cdef public float cuft_gross
    cdef public float bdft_gross
    cdef public float intl_gross
    
    def __cinit__(self
            , int pos, float bole_ht, float length
            , float large_dib, float large_dob
            , float small_dib, float small_dob, float scale_diam
            , float cuft_gross, float bdft_gross, float intl_gross):
        self.pos = pos
        self.bole_ht = bole_ht
        self.length = length
        self.large_dib = large_dib
        self.large_dob = large_dob
        self.small_dib = small_dib
        self.small_dob = small_dob
        self.scale_diam = scale_diam
        self.cuft_gross = cuft_gross
        self.bdft_gross = bdft_gross
        self.intl_gross = intl_gross
    
    def __getitem__(self,item):
        return getattr(self,item)
    
    def __repr__(self):
        d = OrderedDict()
        d['position'] = self.pos
        d['bole_height'] = self.bole_ht
        d['length'] = self.length
        d['large_dib'] = self.large_dib
        d['large_dob'] = self.large_dob
        d['small_dib'] = self.small_dib
        d['small_dob'] = self.small_dob
        d['scale_diam'] = self.scale_diam
        d['cuft_gross'] = self.cuft_gross
        d['bdft_gross'] = self.bdft_gross
        d['intl_gross'] = self.intl_gross        
        return str(d)
    
#     def __str__(self):
#         return self.__repr__()
    
cdef class VolumeCalculator:
    cdef int region
    cdef char* forest
    cdef public char* volume_eq
    cdef float min_top_prim
    cdef float min_top_sec
    cdef float stump_ht
    cdef public float dbh_ob
    cdef public float drc_ob
    cdef char* ht_type
    cdef public float total_ht
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
    cdef float num_logs_prim
    cdef float num_logs_sec
    cdef int cubic_total_flag
    cdef int bdft_prim_flag
    cdef int cubic_prim_flag
    cdef int cord_prim_flag
    cdef int sec_vol_flag
    cdef char* con_spp
    cdef public char* prod_code
    cdef int ht_1st_limb
    cdef char* live
    cdef int basal_area
    cdef int site_index
    cdef char* cruise_type
    cdef int error_flag
    cdef merchrules_ merch_rule
    
    cdef public np.float32_t[:] volume_wk
    cdef public np.float32_t[:,:] log_vol_wk
    cdef public np.float32_t[:,:] log_diam_wk
    cdef public np.float32_t[:] log_len_wk
    cdef public np.float32_t[:] bole_ht_wk
    
    property merch_height:
        """
        Return the height to the top of the primary product.
        """
        def __get__(self):
            return self.ht_prim
        
    property volume:
        """
        Return a dict of calculated tree volume.
        """
        def __get__(self):
            # zip vol_lbl from nvelcommon.pxi with the volume array
            return dict(zip(vol_lbl, self.volume_wk))
    
    property log_vol:
        """
        Return a list log segment volumes.
        """
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
        """
        Return a list predicted log diameters.
        """
        def __get__(self):
            
            cdef int i
            
            diams = []
            for i in range(self.num_logs+1):
                l = np.array(self.log_diam_wk[i])
                s = np.array(self.log_diam_wk[i+1])
                
                d = {
                        'large_ob':l[2]
                        ,'small_ob':s[2]
                        ,'large_ib':l[1]
                        ,'small_ib':s[1]
                        ,'scale':s[0]
                        }
                diams.append(d)
            
            return diams
    
    property logs:
        """
        Return an array of log objects.
        """
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
                
                logs.append(Log(i,bole,len
                        ,large[2],large[1]
                        ,small[2],small[1],small[0]
                        ,vol[3],vol[0],vol[6]
                        ))
            
            return logs
    
    property error_flag:
        """
        Return the decoded volume calculation error code.
        """
        def __get__(self):
            return error_codes[self.error_flag]
        
    cpdef int calc(self
            , float dbh_ob=0.0, float drc_ob=0.0, float total_ht=0.0, int ht_log=0
            , char* ht_type='F', float ht_prim=0.0, float ht_sec=0.0
            , float upper_ht1=0.0, float upper_ht2=0.0, float upper_diam1=0.0, float upper_diam2=0.0
            , int ht_ref=0, float avg_z1=0.0, float avg_z2=0.0, int form_class=0
            , float bark_thick=0.0, float bark_ratio=0.0, int ht_1st_limb=0, char* live='L'
            , np.ndarray log_len=np.zeros((20,),np.float32)
#             , int num_logs=0
            ):
         
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
                  
        cdef int fl = 2
        cdef int vl = 10
        cdef int hl = 1
        cdef int csl = 4
        cdef int pl = 2
        cdef int ll = 1
        cdef int ctl = 1
        
        # Ensure the result arrays are zero'd
        self.volume_wk[:] = 0.0
        self.log_vol_wk[:,:] = 0.0
        self.log_len_wk[:] = 0.0
        self.log_diam_wk[:,:] = 0.0
        self.bole_ht_wk[:] = 0.0
        
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
                
                # Lengths of char* arguments
                # TODO: This is the gfortran way, but perhaps not Intel, etc. 
                , fl, vl, hl, csl
                , pl, ll, ctl
                )
     
#         if error_flag!=0:
#             print 'Error Code {}: {}'.format(error_flag,error_codes[error_flag])
        #TODO: raise an exception for critical error flags
        return error_flag
         
    def __cinit__(self, merchrules_ merch_rule=init_merchrule(), *args, **kargs):
        self.merch_rule = merch_rule
        
        self.volume_wk = np.zeros((15, ), dtype=np.float32, order='F')
        self.log_vol_wk = np.zeros((7, 20), dtype=np.float32, order='F')
        self.log_diam_wk = np.zeros((21, 3), dtype=np.float32, order='F')
        self.log_len_wk = np.zeros((20, ), dtype=np.float32, order='F')
        self.bole_ht_wk = np.zeros((21, ), dtype=np.float32, order='F')

    def __init__(self, int region=6, char* forest='12', char* volume_eq=''
            , float min_top_prim=5.0, float min_top_sec=2.0, float stump_ht=1.0
            , int cubic_total_flag=1, int bdft_prim_flag=1, int cubic_prim_flag=1
            , int cord_prim_flag=1, int sec_vol_flag=1
            , char* con_spp='', char* prod_code='01'
            , int basal_area=0, int site_index=0
            , char* cruise_type='C', *args, **kargs
            ):
         
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
 
# if __name__=='_main__':
#     volcalc = VolumeCalculator(volume_eq='F01FW3W202')
#     volcalc.calc(dbh_ob=20, total_ht=150.0)
#     print volcalc.volume
