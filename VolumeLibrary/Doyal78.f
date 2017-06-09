!== last modified  01-25-2005
      SUBROUTINE DOYAL78 (DBHOB,HT1PRD,VOL,ERRFLAG)

C    PROGRAM DOYLE FORM CLASS 78
C

      REAL DBHOB, HT1PRD, LHT1, VOL(15), DOYAL(31,11)
      INTEGER ERRFLAG, INDEX, I

      DATA ((DOYAL(J,I),I=1,11),J=1,31) /
     >  14,17,20,21,22,0,0,0,0,0,0,
     >  22,27,32,35,38,0,0,0,0,0,0,
     >  29,36,43,48,53,54,56,0,0,0,0,
     >  38,48,59,66,73,76,80,0,0,0,0,
     >  48,62,75,84,93,98,103,0,0,0,0,
     >  60,78,96,108,121,128,136,0,0,0,0,
     >  72,94,116,132,149,160,170,0,0,0,0,
     >  86,113,140,161,182,196,209,0,0,0,0,
     >  100,132,164,190,215,232,248,0,0,0,0,
     >  118,156,194,225,256,276,297,0,0,0,0,
     >  135,180,225,261,297,322,346,364,383,0,0,
     >  154,207,260,302,344,374,404,428,452,0,0,
     >  174,234,295,344,392,427,462,492,521,0,0,
     >  195,264,332,388,444,483,522,558,594,0,0,
     >  216,293,370,433,496,539,582,625,668,0,0,
     >  241,328,414,486,558,609,660,709,758,0,0,
     >  266,362,459,539,619,678,737,793,849,0,0,
     >  292,398,505,594,684,749,814,877,940,0,0,
     >  317,434,551,650,750,820,890,961,1032,1096,1161,
     >  346,475,604,714,824,902,980,1061,1142,1218,1294,
     >  376,517,658,778,898,984,1069,1160,1251,1339,1427,
     >  408,562,717,850,983,1080,1176,1273,1370,1470,1570,
     >  441,608,776,922,1068,1176,1283,1386,1488,1600,1712,
     >  474,654,835,994,1152,1268,1385,1497,1609,1734,1858,
     >  506,700,894,1064,1235,1361,1487,1608,1730,1866,2003,
     >  544,754,964,1149,1334,1472,1610,1743,1876,2020,2163,
     >  581,808,1035,1234,1434,1583,1732,1878,2023,2173,2323,
     >  618,860,1102,1318,1534,1694,1854,2013,2172,2332,2492,
     >  655,912,1170,1402,1635,1805,1975,2148,2322,2491,2660,
     >  698,974,1250,1498,1746,1932,2118,2298,2479,2662,2844,
     >  740,1035,1330,1594,1858,2059,2260,2448,2636,2832,3027/

      DO 10 I=1,15
        VOL(I) = 0.0
 10   CONTINUE

      ERRFLAG = 0
      IF(DBHOB .LE. 1.0)THEN
        ERRFLAG = 3
        RETURN
      ENDIF
      IF(HT1PRD .LE. 0.0) THEN
        ERRFLAG = 7
        RETURN
      ENDIF

      INDEX = ANINT(DBHOB) - 9

      LHT1 = HT1PRD / 10.0

      IF (INDEX.LT.1.OR.INDEX.GT.31) THEN
        VOL(2) = 0.0
      ELSEIF (LHT1 .EQ. 1) THEN
         VOL(2) = DOYAL(INDEX,1)   
      ELSEIF (LHT1 .EQ. 1.5) THEN
         VOL(2) = DOYAL(INDEX,2)
      ELSEIF (LHT1 .EQ. 2.0) THEN
         VOL(2) = DOYAL(INDEX,3)
      ELSEIF (LHT1 .EQ. 2.5) THEN
         VOL(2) = DOYAL(INDEX,4)
      ELSEIF (LHT1 .EQ. 3.0) THEN
         VOL(2) = DOYAL(INDEX,5)
      ELSEIF (LHT1 .EQ. 3.5) THEN
         VOL(2) = DOYAL(INDEX,6)
      ELSEIF (LHT1 .EQ. 4.0) THEN
         VOL(2) = DOYAL(INDEX,7)
      ELSEIF (LHT1 .EQ. 4.5) THEN
         VOL(2) = DOYAL(INDEX,8)
      ELSEIF (LHT1 .EQ. 5.0) THEN
         VOL(2) = DOYAL(INDEX,9)
      ELSEIF (LHT1 .EQ. 5.5) THEN
         VOL(2) = DOYAL(INDEX,10)
      ELSEIF (LHT1 .EQ. 6.0) THEN
         VOL(2) = DOYAL(INDEX,11)
      ENDIF

      VOL(3) = VOL(2)

      RETURN
      END
