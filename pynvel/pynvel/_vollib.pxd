"""
External references to the NVEL/VOLLIB library
"""

import numpy as np
cimport numpy as np

cdef extern from *:
    # vernum.f
    void vernum_(int *v)
    
#    void foo_(char* s, int sl)
    
    void scrib_(float *dia, float *len, char* cor, float *vol, int cl)

#     # getvoleq.f
#     void getvoleq_(int *region, char* forest, char* district
#             , int *species, char* product, char* vol_eq, int *err_flag
#             , int fl, int dl, int pl, int vl)
#     void getfiavoleq_(int *region, char* forest, char* district
#             , int *species, char* vol_eq, int *err_flag
#             , int fl, int dl, int vl)
    
    # Return the default equation for a species
    # voleqdef.f
#    void voleqdef_(char* var, int *region, char* forest, char* district
#            , int *species, char* product, char* vol_eq, int *err_flag
#            , int vl, int fl, int dl, int pl, int el)
    void voleqdef_(char* var, int* region, char* forest, char* district
            , int* species, char* product, char* vol_eq, int* err_flag
            , int vl, int fl, int dl, int pl, int el)

    # Return the FIA default equation for a species
    # voleqdef.f
    void fiavoleqdef_(char* var, int *region, char* forest, char* district
            , int *species, char* vol_eq, int *err_flag
            , int vl, int fl, int dl, int el)
    
    # vollibcs.f
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
    
    # Calculate tree volume according to user defined merchandizing rules.
    # volinit2.f
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
