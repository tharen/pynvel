import numpy as np
cimport numpy as np

include 'nvelcommon.pxi'

cdef extern from *:    
    void vernum_(int *v)
    void getvoleq_(int *region, char* forest, char* district
            , int *species, int *product, char* vol_eq, int *err_flag
            , int fl, int dl, int vl)
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
        char cor #NOTE: single char, not pointer. Unsure how to pass a len arg in a struct

cdef class FChar:
    cdef char* rep
    cdef int len
    
    def __cinit__(self,rep,len):
        self.rep=rep
        self.len=len
        
cpdef init_merchrule(
        int evod=1, int opt=23, float maxlen=40.0, float minlen=12.0
        , float minlent=12.0, float merchl=12.0, float mtopp=5.0
        , float mtops=2.0, float stump=1.0, float trim=1.0
        , float btr=0.0, float dbtbh=0.0, float minbfd=8.0, char cor='Y'):
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
    :param minlent: 
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
#     cdef cor_c = FChar('Y',1)
    cdef merchrules_ mr = merchrules_(
            evod=evod, opt=opt, maxlen=maxlen, minlen=minlen, minlent=minlent
            , merchl=merchl, mtopp=mtopp, mtops=mtops, stump=stump
            , trim=trim, btr=btr, dbtbh=dbtbh, minbfd=minbfd, cor='Y')
    
    return mr

def vernum():
    cdef int v = 0
    vernum_(&v)
     
    return v

def getvoleq(region, forest, district, species, product):
    cdef int region_c = region
    cdef char* forest_c = forest
    cdef char* district_c = district
    cdef int prod_c = product
    cdef int species_c = species
    cdef char* vol_eq_c = ''
    cdef int err_flag_c = 0
    
    getvoleq_(
            &region_c, forest_c, district_c
            , &species_c, &prod_c, vol_eq_c, &err_flag_c
            , 2, 2, 10
            )
    
    return vol_eq_c[:10]

def getfiavoleq(region, forest, district, species):
    cdef int region_c = region
    cdef char* forest_c = forest
    cdef char* district_c = district
    cdef int species_c = species
    cdef char* vol_eq_c = ''
    cdef int err_flag_c = 0
    
    getfiavoleq_(
            &region_c, forest_c, district_c
            , &species_c, vol_eq_c, &err_flag_c
            , 2, 2, 10
            )
    
    return vol_eq_c[:10]

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
    cdef int forest_len = 2
    cdef char* volume_eq_c = volume_eq
    cdef int volume_eq_len = 10     
    cdef char* ht_type_c = 'F'
    cdef int ht_type_len = 1
    
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
    cdef int con_spp_len = 4
    
    prod_code = '{:>02d}'.format(prod_code)
    cdef char* prod_code_c = prod_code
    cdef int prod_code_len = 2
     
    cdef int ht_1st_limb_c = ht_1st_limb
     
    cdef char* live_c = live 
    cdef int live_len = 1
    
    cdef char* cruise_type_c = cruise_type
    cdef int cruise_type_len = 1
    
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
            , forest_len
            , volume_eq_len
            , ht_type_len
            , con_spp_len
            , prod_code_len
            , live_len
            , cruise_type_len
            )
    
    if error_flag!=0:
        print 'Error Code {}: {}'.format(error_flag,error_codes[error_flag])
    
    print log_len_c
#     print log_diam_c
    return dict(zip(vol_lbl,volume_c))

cdef class VolumeCalculator:
    cdef int region
    cdef char* forest
    cdef char* volume_eq
    cdef float min_top_prim
    cdef float min_top_sec
    cdef float stump_ht
    cdef float dbh_ob
    cdef float drc_ob
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
    cdef int form_class
    cdef float bark_thick
    cdef float bark_ratio
#     cdef np.ndarray[np.float32_t, ndim=1, mode='c'] volume = np.zeros((15, ), dtype=np.float32)
#     cdef np.ndarray[np.float32_t, ndim=2, mode='c'] log_vol = np.zeros((7, 20), dtype=np.float32)
#     cdef np.ndarray[np.float32_t, ndim=2, mode='c'] log_diam = np.zeros((21, 3), dtype=np.float32)
#     cdef np.ndarray[np.float32_t, ndim=1, mode='c'] log_len = np.zeros((20, ), dtype=np.float32)
#     cdef np.ndarray[np.float32_t, ndim=1, mode='c'] bole_ht = np.zeros((21, ), dtype=np.float32)
    cdef int num_logs
    cdef float num_logs_prim
    cdef float num_logs_sec
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
    cdef int error_flag
    cdef int debug
    cdef int user_merch_flag
    cdef merchrules_ merch_rule
    cdef int vl
 
#     cdef public np.ndarray[np.float32_t, ndim=1, mode='c'] volume
#     cdef public np.ndarray[np.float32_t, ndim=2, mode='c'] log_vol
#     cdef public np.ndarray[np.float32_t, ndim=2, mode='c'] log_diam
#     cdef public np.ndarray[np.float32_t, ndim=1, mode='c'] log_len
#     cdef public np.ndarray[np.float32_t, ndim=1, mode='c'] bole_ht
    cdef public np.float32_t[:] volume
    cdef public np.float32_t[:,:] log_vol
    cdef public np.float32_t[:,:] log_diam
    cdef public np.float32_t[:] log_len
    cdef public np.float32_t[:] bole_ht
     
    def calc(self
            , float dbh_ob=0.0, float drc_ob=0.0, float total_ht=0.0, int ht_log=0
            , char* ht_type='F', float ht_prim=0.0, float ht_sec=0.0
            , float upper_ht1=0.0, float upper_ht2=0.0, float upper_diam1=0.0, float upper_diam2=0.0
            , int ht_ref=0, float avg_z1=0.0, float avg_z2=0.0, int form_class=0
            , float bark_thick=0.0, float bark_ratio=0.0, int ht_1st_limb=0, char* live='L'
            , np.ndarray[np.float32_t, ndim=1] log_len=np.zeros((20,),np.float32), int num_logs=0):
         
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
         
#         cdef int *my_ints
# 
#         my_ints = <int *>malloc(len(a)*cython.sizeof(int))
#         if my_ints is NULL:
#             raise MemoryError()
#     
#         for i in xrange(len(a)):
#             my_ints[i] = a[i]
         
#         self.volume = volume
#         self.log_vol = log_vol
#         self.log_diam = log_diam
#         self.log_len = log_len
#         self.bole_ht = bole_ht
        cdef int i3=3
        cdef int i7=7
        cdef int i15=15
        cdef int i20=20
        cdef int i21=21
         
#         cdef float [:] volume_mv = volume
         
        self.num_logs_prim = 0.0
        self.num_logs_sec = 0.0
         
        cdef int error_flag = 0
         
        self.num_logs = log_len.shape[0]
        cdef int i
        for i in xrange(self.num_logs):
            self.num_logs += 1
            self.log_len[i] = log_len[i]
         
        cdef int forest_len = 2
        cdef int volume_eq_len = 10
        cdef int ht_type_len = 1
        cdef int con_spp_len = 4
        cdef int prod_code_len = 2
        cdef int live_len = 1
        cdef int cruise_type_len = 1
 
#         if self.num_logs>0:
#             log_len[:self.num_logs] = log_len[:self.num_logs]
#             cruise_type='V'
        print 'call vollibc2'
        print 'volume eq', self.volume_eq
        cdef char* ve='F01FW3W202'
        cdef char* ht='F'
        cdef char* cs='    '
        cdef char* pc='01'
        cdef char* lv='L'
        cdef char* ct='C'
         
        vollibc2_(
                &self.region
                , self.forest
                , ve
                , &self.min_top_prim
                , &self.min_top_sec
                , &self.stump_ht
                , &self.dbh_ob
                , &self.drc_ob
                , ht
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
                , &self.volume[0]
                , &self.log_vol[0,0]
                , &self.log_diam[0,0]
                , &self.log_len[0]
                , &self.bole_ht[0]
                , &self.num_logs
                , &self.num_logs_prim
                , &self.num_logs_sec
                , &self.cubic_total_flag
                , &self.bdft_prim_flag
                , &self.cubic_prim_flag
                , &self.cord_prim_flag
                , &self.sec_vol_flag
                , cs
                , pc
                , &self.ht_1st_limb
                , lv
                , &self.basal_area
                , &self.site_index
                , ct
                , &error_flag
                , &self.debug
                , &self.user_merch_flag
                , &self.merch_rule
#                 , 2,10,1,4,2,1,1
                , forest_len
                , volume_eq_len
                , ht_type_len
                , con_spp_len
                , prod_code_len
                , live_len
                , cruise_type_len
                )
     
        if error_flag!=0:
            print 'Error Code {}: {}'.format(error_flag,error_codes[error_flag])
         
    def __cinit__(self, merchrules_ merch_rule=init_merchrule(), *args, **kargs):
        self.merch_rule = merch_rule
        
        self.volume = np.zeros((15, ), dtype=np.float32)
        self.log_vol = np.zeros((7, 20), dtype=np.float32)
        self.log_diam = np.zeros((21, 3), dtype=np.float32)
        self.log_len = np.zeros((20, ), dtype=np.float32)
        self.bole_ht = np.zeros((21, ), dtype=np.float32)

    def __init__(self, int region=6, forest=12, volume_eq=''
            , min_top_prim=5.0, min_top_sec=2.0, stump_ht=1.0
            , cubic_total_flag=1, bdft_prim_flag=1, cubic_prim_flag=1
            , cord_prim_flag=1, sec_vol_flag=1
            , con_spp='', prod_code=1, basal_area=0.0, site_index=0.0
            , cruise_type='C', debug=0, *args, **kargs
            ):
         
        self.region = region
        forest = '{:>02d}'.format(forest)
        self.forest = forest
        volume_eq = '{:>10s}'.format(volume_eq)
        self.volume_eq = volume_eq
        self.min_top_prim = min_top_prim
        self.min_top_sec = min_top_sec
        self.stump_ht = stump_ht
         
        self.cubic_total_flag = cubic_total_flag
        self.bdft_prim_flag = bdft_prim_flag
        self.cubic_prim_flag = cubic_prim_flag
        self.cord_prim_flag = cord_prim_flag
        self.sec_vol_flag = sec_vol_flag
         
        con_spp = '{:>4s}'.format(con_spp)
        self.con_spp = con_spp
        prod_code = '{:>02d}'.format(prod_code)
        self.prod_code = prod_code
        self.basal_area = basal_area
        self.site_index = site_index
        self.cruise_type = cruise_type
        self.debug = debug
        
        self.user_merch_flag = 2
        
# 
# if __name__=='_main__':
#     volcalc = VolumeCalculator(volume_eq='F01FW3W202')
#     volcalc.calc(dbh_ob=20, total_ht=150.0)
#     print volcalc.volume
