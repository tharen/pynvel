from ctypes import *

mydll = windll.LoadLibrary("vollib.dll")


#*****************************************************************
#-------test the VERNUM routine----------------------------------#
version = c_int()

mydll.VERNUM(byref(version))

print('version = ', version.value)
#*****************************************************************

# this class represents a c style string which has
# the string (str) and an integer length parameter(len)
class fchar(Structure):
  _fields_ = [
	('str', c_char_p),
	('len', c_int),
	 ]

#*****************************************************************
#-------test the GETVOLEQ routine--------------------------------#
# call getvoleq
regn = c_int(6)

forst = fchar()
forst.str = "11 "
forst.len = 3

dist = fchar()
dist.str = "01 "
dist.len = 3

spec = c_int(202)

prod = fchar()
prod.str = "01 "
prod.len = 3

voleq = fchar()
voleq.str = "           "
voleq.len = 11

errflag = c_int()

class Mrule(Structure):
  _fields_ = [
		('evod', c_int),
		('opt', c_int),
        ('maxlen', c_float),
        ('minlen', c_float),
        ('minlent', c_float),
        ('merchl', c_float),
        ('mtopp', c_float),
        ('mtops', c_float),
        ('stump', c_float),
        ('trim', c_float),
        ('btr', c_float),
        ('dbtbh', c_float),
        ('minbfd', c_float),
        ('cor', c_char),
		 ]

myMrule = Mrule(2, 23, 40, 8, 8, 8, 5, 2, 1.0, 1.0, 0, 0, 8.0, "N")
# Reset the value to what you need
myMrule.maxlen = 40
print ('User defined LOG Lenth = ', myMrule.maxlen)


mydll.GETVOLEQ(byref(regn), forst, dist, byref(spec), prod, voleq, byref(errflag))


print('after GETVOLEQ voleq = ', voleq.str)
# print('regn = ', regn)
# print('forst = ', forst.str)
# print('forst = ', forst.str)
# print('dist = ', dist.str)
# print('errflag = ', errflag)

#*****************************************************************
#-------test the GETVOL routine----------------------------------#

MTOPP = c_float(0)
MTOPS = c_float(0)
STUMP = c_float(0)
DBHOB = c_float(8.0)
DRCOB = c_float(0)
HTTYPE = fchar()
HTTYPE.str = "F"
HTTYPE.len = 2
HTTOT = c_float(23.0)
HTLOG = c_int()
HT1PRD = c_float(0)
HT2PRD = c_float(0)
UPSHT1 = c_float(0)
UPSHT2 = c_float(0)
UPSD1 = c_float(0)
UPSD2 = c_float(0)
HTREF = c_int(0)
AVGZ1 = c_float(0)
AVGZ2 = c_float(0)
FCLASS = c_int(0)
DBTBH = c_float(0)
BTR = c_float(0)
I3 = c_int(3)
I7 = c_int(7)
I15 = c_int(15)
I20 = c_int(20)
I21 = c_int(21)

REAL = c_float
REAL_P = POINTER(REAL)

VOL = (REAL * 15)()

LOGVOL = (REAL * 7 * 20)()

LOGDIA = (REAL * 21 * 3)()

LOGLEN = (REAL * 20)()

BOLHT = (REAL * 21)()

TLOGS = c_int(0)
NOLOGP = c_float(0)
NOLOGS = c_float(0)
CUTFLG = c_int(1)
BFPFLG = c_int(1)
CUPFLG = c_int(1)
CDPFLG = c_int(1)
CUSFLG = c_int(1)
CDSFLG = c_int(1)
SPFLG = c_int(1)
PROD = fchar()
PROD.str = "002"
PROD.len = 3
CONSPEC = fchar()
CONSPEC.str = "     "
CONSPEC.len = 5
HTTFLL = c_int(0)
LIVE = fchar()
LIVE.str = "L "
LIVE.len = 2
BA = c_int(0)
SI = c_int(0)
mCTYPE = fchar()
mCTYPE.str = "F "
mCTYPE.len = 2
ERRFLAG = c_int(0)

# voleq.str = "632BEHW202 "
FCLASS = c_int(80)

INDEB = c_int(0)
# To use user defined merch rule, PMTFLG has to be set to 2
# otherwise it will use default rule
PMTFLG = c_int(2)
if PMTFLG.value == 2:
  print ('Using user defined merch rule for volume calculation')
else:
  print ('Using DEFAULT merch rule for volume calculation')
strlen = c_int(256)
charlen = c_int(1)
print('(Input for DLL) voleq = ', voleq.str)

mydll.VOLLIBC2(byref(regn), forst, voleq, byref(MTOPP), byref(MTOPS), byref(STUMP), byref(DBHOB),
byref(DRCOB), HTTYPE, byref(HTTOT), byref(HTLOG), byref(HT1PRD), byref(HT2PRD), byref(UPSHT1), byref(UPSHT2), byref(UPSD1),
byref(UPSD2), HTREF, byref(AVGZ1), byref(AVGZ2), byref(FCLASS), byref(DBTBH), byref(BTR), byref(I3), byref(I7), byref(I15), byref(I20), byref(I21),
byref(VOL), byref(LOGVOL), byref(LOGDIA), byref(LOGLEN), byref(BOLHT), byref(TLOGS), byref(NOLOGP), byref(NOLOGS), byref(CUTFLG),
byref(BFPFLG), byref(CUPFLG), byref(CDPFLG), byref(SPFLG), CONSPEC, PROD, byref(HTTFLL), LIVE,
byref(BA) , byref(SI), mCTYPE, byref(ERRFLAG), byref(INDEB), byref(PMTFLG), byref(myMrule))

# mydll.VOLUMELIBRARY(byref(regn), forst,voleq, byref(MTOPP), byref(MTOPS), byref(STUMP),byref(DBHOB),
# byref(DRCOB), HTTYPE, byref(HTTOT), byref(HTLOG), byref(HT1PRD), byref(HT2PRD), byref(UPSHT1), byref(UPSHT2), byref(UPSD1),
# byref(UPSD2), HTREF, byref(AVGZ1), byref(AVGZ2), byref(FCLASS), byref(DBTBH), byref(BTR), byref(I3), byref(I7), byref(I15), byref(I20), byref(I21),
# byref(VOL), byref(LOGVOL), byref(LOGDIA), byref(LOGLEN), byref(BOLHT), byref(TLOGS), byref(NOLOGP), byref(NOLOGS), byref(CUTFLG),
# byref(BFPFLG), byref(CUPFLG), byref(CDPFLG), byref(SPFLG), CONSPEC,PROD, byref(HTTFLL),LIVE,
# byref(BA) , byref(SI),mCTYPE, byref(ERRFLAG))
if ERRFLAG.value <> 0:
  print ('errflag = ', errflag.value)

# arrays are column major in fortran and row major in c/python ALSO, arrays are zero subscripted in c/python
# and 1 in fortran.
# So, LOGVOL(4,1) in fortran becomes LOGVOL[0][3] in python and so forth

for index, item in enumerate(VOL):
	print'vol[', index + 1, '] = ', item

print '\nht2prd = ', HT2PRD.value

print 'nologp = ', NOLOGP.value
print 'nologs = ', NOLOGS.value
print 'tlogs  = ', TLOGS.value

# print('logvol 2 = ', LOGVOL[0][3])
# for y in VOL:
# print y
# for x in LOGVOL:
#  print x[3]


