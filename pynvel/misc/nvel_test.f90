program nvel_test
!    use iso_c_binding
    implicit none

!    interface
!        subroutine vernum(ver) bind(C, name='VERNUM2')
!            integer :: ver
!        end subroutine
!    end interface

    TYPE MERCHRULES
        SEQUENCE
        INTEGER        EVOD
        INTEGER        OPT     


        REAL           MAXLEN
        REAL           MINLEN
        REAL           MINLENT
        REAL           MERCHL
        REAL           MTOPP
        REAL           MTOPS

        REAL           STUMP
        REAL           TRIM
        REAL		   BTR
        REAL		   DBTBH
        REAL		   MINBFD

        CHARACTER     COR 

    END TYPE MERCHRULES

    integer region, species, errflag, ver
    character(len=2) :: forest, district
    character(len=10) ::vol_eq
    
    real :: dbh,drc,httot,ht1prd,ht2prd,mtopp,mtops,stump
    real :: dbtbh,btr,upsht1,upsht2,upsd1,upsd2,avgz1,avgz2
    integer :: fclass,ba,si,httfll,cutflg,bfpflg,cupflg,cdpflg,spflg
    integer :: htref,I3,I7,I15,I20,I21
    type(merchrules) :: mrule
    
    real :: vol(15),logvol(7,20),logdia(21,3),loglen(20),bolht(21)
    real :: nologp,nologs
    integer :: htlog,tlogs
    character(len=1) :: httype,live,ctype
    character(len=4) :: conspec
    character(len=2) :: prod

    region = 6
    forest = '12'
    district = '12'
    species = 202
    
    dbh = 18.0
    drc = 0.0
    httot = 120.0
    htlog = 0
    ht1prd = 0.0
    ht2prd = 0.0
    fclass = 82
    mtopp = 6.0
    mtops = 2.0
    stump = 1.0
    httype = 'F'
    conspec = '    '
    prod = '01'
    live = 'L'
    ctype = 'C'
    ba = 0
    si = 0
    httfll = 0
    cutflg = 1
    bfpflg = 1
    cupflg = 1
    cdpflg = 1
    spflg = 1
    I3 = 3
    I7 = 7
    I15 = 15
    I20 = 20
    I21 = 21
    dbtbh = 0.0
    btr = 0.0
    upsht1 = 0.0
    upsht2 = 0.0
    upsd1 = 0.0
    upsd2 = 0.0
    htref = 0
    avgz1 = 0.0
    avgz2 = 0.0
    
    call vernum(ver)
    write(*,*) ver

    call getfiavoleq(region, forest, district, species, vol_eq, errflag)
    write(*,*) vol_eq, errflag
    
    vol_eq = 'F01FW3W202'
    !vol_eq = '632BEHW202'
    
    mrule%evod = 1
    mrule%opt = 23
    mrule%maxlen = 40.0
    mrule%minlen = 12.0
    mrule%minlent = 12.0
    mrule%merchl = 12.0
    mrule%mtopp = 6.0
    mrule%mtops = 2.0
    mrule%stump = 1.0
    mrule%trim = 1.0
    mrule%btr = 0.0
    mrule%dbtbh = 0.0
    mrule%minbfd = 6.0
    mrule%cor = 'N'
    
    call volinit2( &
            region,forest,vol_eq,mtopp,mtops,stump,dbh &
            ,drc,httype,httot,htlog,ht1prd,ht2prd,upsht1,upsht2,upsd1 &
            ,upsd2,htref,avgz1,avgz2,fclass,dbtbh,btr,I3,I7,I15,I20,I21 &
            ,vol,logvol,logdia,loglen,bolht,tlogs,nologp,nologs,cutflg &
            ,bfpflg,cupflg,cdpflg,spflg,conspec,prod,httfll,live &
            ,ba,si,ctype,errflag,mrule)
    
    write(*,*) 'Error Code:', errflag
    write(*,*) vol
    write(*,*) logvol(1,1:5)
    
end program
