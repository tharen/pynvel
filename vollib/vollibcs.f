C  C# .Net entry point to the volume library
C
C
C  created TDH 03/04/10
C
c  revised 06/23/11
C  Cleaned up code and added comments
C
C  Revised TDH 10/04/10
C  Adding logic to expand the profile model tutorial
C_______________________________________________________________________

      SUBROUTINE VOLLIBCS(REGN,FORSTI,VOLEQI,MTOPP,MTOPS,STUMP,
     +    DBHOB,
     &    DRCOB,HTTYPEI,HTTOT,HTLOG,HT1PRD,HT2PRD,UPSHT1,UPSHT2,UPSD1,
     &    UPSD2,HTREF,AVGZ1,AVGZ2,FCLASS,DBTBH,BTR,I3,I7,I15,I20,I21,
     &    VOL,LOGVOLI,LOGDIAI,LOGLEN,BOLHT,TLOGS,NOLOGP,NOLOGS,CUTFLG,
     &    BFPFLG,CUPFLG,CDPFLG,SPFLG,CONSPECI,PRODI,HTTFLL,LIVEI,
     &    BA,SI,CTYPEI,ERRFLAG, INDEB, PMTFLG, MERRULES)
C_______________________________________________________________________


! Expose subroutine VOLLIBCS to C# users of this DLL
      !DEC$ ATTRIBUTES DLLEXPORT::VOLLIBCS

      USE DEBUG_MOD
      USE MRULES_MOD

      IMPLICIT NONE

C**********************************************************************      
!     Parameters
      INTEGER         REGN
      CHARACTER*(*)   FORSTI, VOLEQI
      REAL            MTOPP, MTOPS, STUMP,DBHOB, DRCOB
      CHARACTER*(*)   HTTYPEI
      REAL            HTTOT
      INTEGER         HTLOG
      REAL            HT1PRD, HT2PRD, UPSHT1, UPSHT2, UPSD1, UPSD2
      INTEGER         HTREF
      REAL            AVGZ1, AVGZ2
      INTEGER         FCLASS
      REAL            DBTBH, BTR
      INTEGER         I3, I7, I15, I20, I21
      REAL            LOGVOLI(I7,I20), LOGDIAI(I21,I3), LOGLEN(I20)
      REAL            BOLHT(I21)
      INTEGER         TLOGS
      REAL            NOLOGP,NOLOGS
      INTEGER         CUTFLG, BFPFLG, CUPFLG, CDPFLG, CUSFLG, CDSFLG
      CHARACTER*(*)   PRODI
      CHARACTER*(*)   CONSPECI
      INTEGER         HTTFLL
      CHARACTER*(*)   LIVEI, CTYPEI
      INTEGER         ERRFLG, INDEB, PMTFLG
      TYPE(MERCHRULES):: MERRULES
      
      
!     Local variables      
!     Variable required for call to VOLINIT      
      INTEGER         SPFLG
      REAL            VOL(15)
      INTEGER         BA, SI
      INTEGER         ERRFLAG
      
!     Local variables
      CHARACTER(2)   FORST
      CHARACTER(10)  VOLEQ
      CHARACTER(1)   HTTYPE
      CHARACTER(4)   CONSPEC
      CHARACTER(2)   PROD
      CHARACTER(1)   LIVE
      CHARACTER(1)   CTYPE
      CHARACTER*3    MDL,SPECIES
      CHARACTER*2    DIST,VAR   
      CHARACTER*10   EQNUM
      INTEGER        SPEC
      REAL           LOGVOL(I7,I20),LOGDIA(I21,I3),DIBO 
      
!- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

      !Convert the CHAR*256 types to Char(*) so I don't have to rename 
      !all references below
     
!--------------------------------------------------------------------
      FORST   = FORSTI(1:2)
      VOLEQ   = VOLEQI(1:10)
      HTTYPE  = HTTYPEI(1:1)
      CONSPEC = CONSPECI(1:4)
      PROD    = PRODI(1:2)
      LIVE    = LIVEI(1:1)
      CTYPE   = CTYPEI(1:1)
!---------------------------------------------------
!Use array converter to reshape c arrays to fortran notation
      LOGVOL = RESHAPE(LOGVOLI, SHAPE(LOGVOL))
      LOGDIA = RESHAPE(LOGDIAI, SHAPE(LOGDIA))
      ERRFLAG = 0

! This is for manual debug only
!      IF (INDEB.eq.1 .AND. VOLEQ .EQ. 'F06FW2W202') THEN
!	   OPEN (UNIT=LUDBG, FILE='Debug.txt', STATUS='UNKNOWN')
!	   WRITE (LUDBG,2)'Debugging VOLLIBCS'
!   2     FORMAT(A)
!         WRITE  (LUDBG, 50)'REGN FORST VOLEQ     HTTYPE CONSPEC PROD
!     & LIVE CTYPE DBHOB MTOPP STUMP  BTR DBTBH HTTOT HT1PRD'
!  50     FORMAT (A)
!         WRITE  (LUDBG, 70) REGN, FORST, VOLEQ, HTTYPE, CONSPEC, PROD, 
!     &    LIVE, CTYPE, DBHOB, MTOPP, STUMP, BTR, DBTBH,
!     &    HTTOT, HT1PRD 
!   70    FORMAT (I2, 3X, A, 3X, A,1X, A, 2X, A,8X, A,3X,A,4X,
!     &           A, 2X, F7.1, F7.1, F6.1,F5.1, F5.2, F7.1,F7.1)
!
!	   CLOSE(LUDBG)
!      ENDIF
      
      IF (PMTFLG .EQ. 1) THEN
!         CALL PMTPROFILE (FORST,VOLEQ,MTOPP,MTOPS,STUMP,DBHOB,
!     >   HTTYPE,HTTOT,HTLOG,HT1PRD,HT2PRD,UPSHT1,UPSHT2,UPSD1,UPSD2,
!     >   AVGZ1,AVGZ2,HTREF,DBTBH,BTR,LOGDIA,BOLHT,LOGLEN,LOGVOL,VOL,
!     >   TLOGS,NOLOGP,NOLOGS,CUTFLG,BFPFLG,CUPFLG,CDPFLG,SPFLG,DRCOB,
!     >   CTYPE,FCLASS,PROD,DIBO,ERRFLAG)
     
!         NOLOGP = DIBO
     
      ELSE IF (PMTFLG .EQ. 2) THEN
    
           CALL VOLINIT2(REGN,FORST,VOLEQ,MTOPP,MTOPS,STUMP,DBHOB,
     +    DRCOB,HTTYPE,HTTOT,HTLOG,HT1PRD,HT2PRD,UPSHT1,UPSHT2,UPSD1,
     +    UPSD2,HTREF,AVGZ1,AVGZ2,FCLASS,DBTBH,BTR,3,7,15,20,21,
     +    VOL,LOGVOL,LOGDIA,LOGLEN,BOLHT,TLOGS,NOLOGP,NOLOGS,CUTFLG,
     +    BFPFLG,CUPFLG,CDPFLG,SPFLG,CONSPEC,PROD,HTTFLL,LIVE,
     +    BA,SI,CTYPE,ERRFLAG, MERRULES)
     
      
      ELSE
 !     	   IF (INDEB.eq.1 .AND. VOLEQ .EQ. 'F06FW2W202') THEN
 !     	   WRITE (LUDBG,2)'Before call VOLINIT'
 !     	   ENDIF

           CALL VOLINIT(REGN,FORST,VOLEQ,MTOPP,MTOPS,STUMP,DBHOB,
     +    DRCOB,HTTYPE,HTTOT,HTLOG,HT1PRD,HT2PRD,UPSHT1,UPSHT2,UPSD1,
     +    UPSD2,HTREF,AVGZ1,AVGZ2,FCLASS,DBTBH,BTR,I3,I7,I15,I20,I21,
     +    VOL,LOGVOL,LOGDIA,LOGLEN,BOLHT,TLOGS,NOLOGP,NOLOGS,CUTFLG,
     +    BFPFLG,CUPFLG,CDPFLG,SPFLG,CONSPEC,PROD,HTTFLL,LIVE,
     +    BA,SI,CTYPE,ERRFLAG)
          
!          IF (INDEB.eq.1 .AND. VOLEQ .EQ. 'F06FW2W202') THEN
!          WRITE (LUDBG,2)'After call VOLINIT'
!          ENDIF
       ENDIF

     
      !add null terminator required by C# strings
      FORSTI = FORST // char(0)
      VOLEQI = VOLEQ // char(0)
      HTTYPEI = HTTYPE // char(0)
      CONSPECI = CONSPEC // char(0)
      PRODI = PROD // char(0)
      LIVEI = LIVE // char(0)
      CTYPEI = CTYPE // char(0)
      !MERRULES%OPT = ' '//char(0)
     
           
      !copy the logvol and logdia data back into the subroutine 
      !paramater for return to c#
      LOGVOLI = RESHAPE(LOGVOL, SHAPE(LOGVOL))
      LOGDIAI = RESHAPE(LOGDIA, SHAPE(LOGDIA))
 
!      IF (INDEB.eq.1 .AND. VOLEQ .EQ. 'F06FW2W202') THEN
!         WRITE  (LUDBG, 80)'After call NVEL: Vol(1)  Vol(2)  Vol(4)' 
!  80     FORMAT (A)
!         WRITE  (LUDBG, 90) VOL(1), VOL(2), VOL(4) 
!  90    FORMAT (16X, F7.1,F7.1, F7.1)

!	   CLOSE(LUDBG)
!      ENDIF

 4000 RETURN
      END SUBROUTINE VOLLIBCS
      
C_______________________________________________________________________

      SUBROUTINE VOLLIBC2(REGN,FORSTI,VOLEQI,MTOPP,MTOPS,STUMP,
     +    DBHOB,
     &    DRCOB,HTTYPEI,HTTOT,HTLOG,HT1PRD,HT2PRD,UPSHT1,UPSHT2,UPSD1,
     &    UPSD2,HTREF,AVGZ1,AVGZ2,FCLASS,DBTBH,BTR,I3,I7,I15,I20,I21,
     &    VOL,LOGVOLI,LOGDIAI,LOGLEN,BOLHT,TLOGS,NOLOGP,NOLOGS,CUTFLG,
     &    BFPFLG,CUPFLG,CDPFLG,SPFLG,CONSPECI,PRODI,HTTFLL,LIVEI,
     &    BA,SI,CTYPEI,ERRFLAG, INDEB, PMTFLG, MERRULES)
C_______________________________________________________________________
C This function is for the user to use costom merch rules.
C The pathon script can call it with user defined merch rules.

! Expose subroutine VOLUMELIBRARY2 to users of this DLL
!
      !DEC$ ATTRIBUTES STDCALL,REFERENCE, DLLEXPORT::VOLLIBC2
      !DEC$ ATTRIBUTES MIXED_STR_LEN_ARG :: VOLLIBC2
  !    !DEC$ ATTRIBUTES DECORATE,ALIAS:'_VOLUMELIBRARY@224'::VOLUMELIBRARY
      !DEC$ ATTRIBUTES DECORATE, ALIAS:'VOLLIBC2'::VOLLIBC2

      USE DEBUG_MOD
      USE MRULES_MOD

      IMPLICIT NONE

C**********************************************************************      
!     Parameters
      INTEGER         REGN
      CHARACTER*(*)   FORSTI, VOLEQI
      REAL            MTOPP, MTOPS, STUMP,DBHOB, DRCOB
      CHARACTER*(*)   HTTYPEI
      REAL            HTTOT
      INTEGER         HTLOG
      REAL            HT1PRD, HT2PRD, UPSHT1, UPSHT2, UPSD1, UPSD2
      INTEGER         HTREF
      REAL            AVGZ1, AVGZ2
      INTEGER         FCLASS
      REAL            DBTBH, BTR
      INTEGER         I3, I7, I15, I20, I21
      REAL            LOGVOLI(I7,I20), LOGDIAI(I21,I3), LOGLEN(I20)
      REAL            BOLHT(I21)
      INTEGER         TLOGS
      REAL            NOLOGP,NOLOGS
      INTEGER         CUTFLG, BFPFLG, CUPFLG, CDPFLG, CUSFLG, CDSFLG
      CHARACTER*(*)   PRODI
      CHARACTER*(*)   CONSPECI
      INTEGER         HTTFLL
      CHARACTER*(*)   LIVEI, CTYPEI
      INTEGER         ERRFLG, INDEB, PMTFLG
      TYPE(MERCHRULES):: MERRULES
      
      
!     Local variables      
!     Variable required for call to VOLINIT      
      INTEGER         SPFLG
      REAL            VOL(15)
      INTEGER         BA, SI
      INTEGER         ERRFLAG
      
!     Local variables
      CHARACTER(2)   FORST
      CHARACTER(10)  VOLEQ
      CHARACTER(1)   HTTYPE
      CHARACTER(4)   CONSPEC
      CHARACTER(2)   PROD
      CHARACTER(1)   LIVE
      CHARACTER(1)   CTYPE
      CHARACTER*3    MDL,SPECIES
      CHARACTER*2    DIST,VAR   
      CHARACTER*10   EQNUM
      INTEGER        SPEC
      REAL           LOGVOL(I7,I20),LOGDIA(I21,I3),DIBO 
      
      IF (INDEB.eq.1) THEN
	   OPEN (UNIT=LUDBG, FILE='Debug.txt', STATUS='UNKNOWN')
	   WRITE (LUDBG,5)'Debugging VOLLIBCS2'
   5     FORMAT(A)
         WRITE  (LUDBG, 108)'  COR EVOD OPT MAXLEN MINLEN MERCHL 
     &    MINLENT MTOPP MTOPS STUMP TRIM BTR DBTBH MINBFD'
  108    FORMAT (A)
         WRITE  (LUDBG, 110) MERRULES%COR, MERRULES%EVOD, MERRULES%OPT, 
     &    MERRULES%MAXLEN, MERRULES%MINLEN, MERRULES%MERCHL,
     &    MERRULES%MINLENT, MERRULES%MTOPP, MERRULES%MTOPS, 
     &    MERRULES%STUMP,MERRULES%TRIM, MERRULES%BTR, MERRULES%DBTBH,
     &    MERRULES%MINBFD
  110    FORMAT (2X, A, 3X, I2, 3X, I3,3X, F7.1, F7.1, F7.1,
     &           F7.1, F7.1, F7.1,F7.1, F7.1, F7.1,F7.1, F7.1)

	   CLOSE(LUDBG)
      ENDIF
c  PMTFLG = 2 will user defined rule. otherwise use default rule.
      IF (PMTFLG.NE.2) PMTFLG = 3
      CALL VOLLIBCS(REGN,FORSTI,VOLEQI,MTOPP,MTOPS,STUMP,
     +    DBHOB,
     &    DRCOB,HTTYPEI,HTTOT,HTLOG,HT1PRD,HT2PRD,UPSHT1,UPSHT2,UPSD1,
     &    UPSD2,HTREF,AVGZ1,AVGZ2,FCLASS,DBTBH,BTR,I3,I7,I15,I20,I21,
     &    VOL,LOGVOLI,LOGDIAI,LOGLEN,BOLHT,TLOGS,NOLOGP,NOLOGS,CUTFLG,
     &    BFPFLG,CUPFLG,CDPFLG,SPFLG,CONSPECI,PRODI,HTTFLL,LIVEI,
     &    BA,SI,CTYPEI,ERRFLAG, INDEB, PMTFLG, MERRULES)
      END SUBROUTINE VOLLIBC2