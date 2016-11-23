module vollib_wrap

    use iso_c_binding
    implicit none

!    interface
!        subroutine getfiavoleq_c(region, forest, district, species, vol_eq, err_flag) bind(C, name='GETFIAVOLEQ')
!            use iso_c_binding
!            implicit none
!            integer(kind=c_int), intent(in) :: region, species
!            character(kind=c_char, len=1), intent(in) :: forest, district
!            character(kind=c_char, len=1), intent(out) :: vol_eq
!            integer(kind=c_int), intent(out) :: err_flag
!        end subroutine getfiavoleq_c
!
!        subroutine vernum_c(ver) bind(C, name='VERNUM2')
!            use iso_c_binding, only : c_int
!            implicit none
!            integer(kind=c_int), intent(out) :: ver
!        end subroutine vernum_c
!
!    end interface

    contains

    subroutine vernum_f(ver) bind(C)
        integer(kind=c_int), intent(out) :: ver
!        call vernum_c(ver)
        write (*,*) ver
        ver = 999
    end subroutine vernum_f

    subroutine getfiavoleq_f(region, forest, district, species, vol_eq, err_flag) bind(C)
        integer(kind=c_int), intent(in) :: region, species
        character(kind=c_char, len=1), intent(in) :: forest, district
        character(kind=c_char, len=1), intent(out) :: vol_eq
        integer(kind=c_int), intent(out) :: err_flag
!        call getfiavoleq_c(region, forest, district, species, vol_eq, err_flag)
        write (*,*) species
        vol_eq = 'f'
    end subroutine getfiavoleq_f

end module vollib_wrap
