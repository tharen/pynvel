
import numpy as np
from collections import OrderedDict
cimport numpy as np

include 'nvelcommon.pxi'

cdef extern from *:    
    void vernum_(int *v)
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
            , int *idist
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

def calc_volume():
    cdef int regn = 6
    forsti_ = '12'
    cdef char* forsti = forsti_
    voleqi_ = 'F01FW2W202'
    cdef char* voleqi = voleqi_
    cdef float mtopp = 6.0
    cdef float mtops = 2.0
    cdef float stump = 1.0
    cdef float dbhob = 18.0
    cdef float drcob = 0.0
    httypei_ = 'F'
    cdef char* httypei = httypei_
    cdef float httot = 120.0
    cdef int htlog = 0
    cdef float ht1prd = 0.0
    cdef float ht2prd = 0.0
    cdef float upsht1 = 0.0
    cdef float upsht2 = 0.0
    cdef float upsd1 = 0.0
    cdef float upsd2 = 0.0
    cdef int htref = 0
    cdef float avgz1 = 0.0
    cdef float avgz2 = 0.0
    cdef int fclass = 82
    cdef float dbtbh = 0.0
    cdef float btr = 0.0
    cdef int i3 = 3
    cdef int i7 = 7
    cdef int i15 = 15
    cdef int i20 = 20
    cdef int i21 = 21
    cdef np.ndarray[np.float32_t, ndim=1, mode='c'] vol = np.zeros((i15,), dtype=np.float32)
    cdef np.ndarray[np.float32_t, ndim=2, mode='c'] logvoli = np.zeros((i7, i20), dtype=np.float32)
    cdef np.ndarray[np.float32_t, ndim=2, mode='c'] logdiai = np.zeros((i21, i3), dtype=np.float32)
    cdef np.ndarray[np.float32_t, ndim=1, mode='c'] loglen = np.zeros((i20, ), dtype=np.float32)
    cdef np.ndarray[np.float32_t, ndim=1, mode='c'] bolht = np.zeros((i21, ), dtype=np.float32)

    cdef int tlogs = 0
    cdef float nologp = 0.0
    cdef float nologs = 0.0
    cdef int cutflg = 1
    cdef int bfpflg = 1
    cdef int cupflg = 1
    cdef int cdpflg = 1
    cdef int spflg = 1
    conspeci_ = '    '
    cdef char* conspeci = conspeci_
    prodi_ = '01'
    cdef char* prodi = prodi_
    cdef int httfll = 0
    livei_ = 'L'
    cdef char* livei = livei_
    cdef int ba = 0
    cdef int si = 0
    ctypei_ = 'C'
    cdef char* ctypei = ctypei_
    cdef int errflag = 0
    mrule = init_merchrule()
    cdef int idist
    cdef merchrules_ = mrule
    cdef int forsti_len = 2
    cdef int voleqi_len = 10
    cdef int httypei_len = 1
    cdef int conspeci_len = 4
    cdef int prodi_len = 2
    cdef int livei_len = 1
    cdef int ctypei_len = 1
    
    volinit2_(
            &regn
            ,forsti
            ,voleqi
            ,&mtopp
            ,&mtops
            ,&stump
            ,&dbhob
            ,&drcob
            ,httypei
            ,&httot
            ,&htlog
            ,&ht1prd
            ,&ht2prd
            ,&upsht1
            ,&upsht2
            ,&upsd1
            ,&upsd2
            ,&htref
            ,&avgz1
            ,&avgz2
            ,&fclass
            ,&dbtbh
            ,&btr
            ,&i3
            ,&i7
            ,&i15
            ,&i20
            ,&i21
            ,&vol[0]
            ,&logvoli[0,0]
            ,&logdiai[0,0]
            ,&loglen[0]
            ,&bolht[0]
            ,&tlogs
            ,&nologp
            ,&nologs
            ,&cutflg
            ,&bfpflg
            ,&cupflg
            ,&cdpflg
            ,&spflg
            ,conspeci
            ,prodi
            ,&httfll
            ,livei
            ,&ba
            ,&si
            ,ctypei
            ,&errflag
            ,&mrule
            ,&idist
            ,forsti_len
            ,voleqi_len
            ,httypei_len
            ,conspeci_len
            ,prodi_len
            ,livei_len
            ,ctypei_len
            )
    
    print errflag
    print avgz1
    print avgz2
    print upsht1
    print upsht2
    print upsd1
    print upsd2
    
    return vol
