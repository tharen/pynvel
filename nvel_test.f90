program nvel_test
!    use iso_c_binding
    implicit none

!    interface
!        subroutine vernum(ver) bind(C, name='VERNUM2')
!            integer :: ver
!        end subroutine
!    end interface

    integer region, species, err_flag, ver
    character(len=2) :: forest, district
    character(len=10) ::vol_eq

    region = 6
    forest = '04'
    district = '12'
    species = 202

    call vernum(ver)
    write(*,*) ver

    call getfiavoleq(region, forest, district, species, vol_eq, err_flag)
    write(*,*) vol_eq, err_flag

end program
