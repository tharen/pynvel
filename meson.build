# Build PyFVS with Meson+Ninja
# Adapted from SciPy, https://github.com/scipy/scipy/blob/main/meson.build

project(
  'pynvel',
  'c', 'cpp', 'cython',
  meson_version: '>= 0.64.0',
  default_options : [
    'buildtype=debugoptimized',
    'c_std=c99',
    'cpp_std=c++14',
    'fortran_std=legacy',
    #'blas=openblas',
    #'lapack=openblas'
    ],
  version: run_command('python','-m','setuptools_scm', check:true).stdout().strip().split('+')[0],
  )

fs = import('fs')

project_folder = meson.project_source_root()

# Compiler settings
mingw = meson.get_compiler('c').get_id() == 'mingw'
cc = meson.get_compiler('c')

## TODO: SciPy suppresses many compiler warnings, copy that here

m_dep = cc.find_library('m', required : false)
if m_dep.found()
  add_project_link_arguments('-lm', language : 'c')
endif

# Adding at project level causes many spurious -lgfortran flags.
add_languages('fortran', native: false)
ff = meson.get_compiler('fortran')
if ff.has_argument('-Wno-conversion')
  add_project_arguments('-Wno-conversion', language: 'fortran')
endif

is_windows = host_machine.system() == 'windows'

# https://mesonbuild.com/Python-module.html
py_mod = import('python')
py3 = py_mod.find_installation(pure: false)
py3_dep = py3.dependency()
message(py3.full_path())
message(py3.get_install_dir())

if ff.get_id() == 'gcc'
  add_global_arguments(
    '-DCMPgcc',
    '-DANSI',
    language:['c','fortran']
    )
  add_project_arguments(
      '-cpp',
      language: 'fortran',
    )

  if is_windows
    add_global_arguments(
      '-DWINDOWS',
      '-DMS_WIN64',
      language:['c','fortran']
    )
  else
    # TODO: Add elif for Intel Compilers, and Mac
    add_global_arguments(
      '-Dunix',
      language:['c','fortran']
    )

  endif
endif

############## From scipy/meson.build subdir ###################
# Platform detection
is_mingw = is_windows and cc.get_id() == 'gcc'

cython_c_args = []
if is_windows
  # For mingw-w64, link statically against the UCRT.
  gcc_link_args = ['-lucrt', '-static', '-lquadmath']
  if is_mingw
    add_project_link_arguments(gcc_link_args, language: ['c', 'cpp'])
    # Force gcc to float64 long doubles for compatibility with MSVC
    # builds, for C only.
    add_project_arguments('-mlong-double-64', language: 'c')
    # Make fprintf("%zd") work (see https://github.com/rgommers/scipy/issues/118)
    add_project_arguments('-D__USE_MINGW_ANSI_STDIO=1', language: ['c', 'cpp'])

    # Manual add of MS_WIN64 macro when not using MSVC.
    # https://bugs.python.org/issue28267
    # NOTE: gcc -v reports to stderr not stdout
    target = run_command('gcc','-v', check:true).stderr().strip().to_lower()
    if target.contains('target: x86_64')
      message('*** Add MS_WIN64 compiler flag')
      add_project_arguments('-DMS_WIN64', language: ['c', 'cpp', 'fortran'])
    endif

    # Silence warnings emitted by PyOS_snprintf for (%zd), see
    # https://github.com/rgommers/scipy/issues/118.
    # Use as c_args for extensions containing Cython code
    cython_c_args += ['-Wno-format-extra-args', '-Wno-format']
  endif
  if meson.get_compiler('fortran').get_id() == 'gcc'
    add_project_link_arguments(gcc_link_args, language: ['fortran'])
    # Flag needed to work around BLAS and LAPACK Gfortran dependence on
    # undocumented C feature when passing single character string
    # arguments.
    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=90329
    # https://github.com/wch/r-source/blob/838f9d5a7be08f2a8c08e47bcd28756f5d0aac90/src/gnuwin32/MkRules.rules#L121
    add_project_arguments('-fno-optimize-sibling-calls', language: ['fortran'])
  endif
endif

# add_project_arguments('-fno-second-underscore', language:'fortran')
if is_windows
  add_project_link_arguments('-Wl,--add-stdcall-alias', language:['c','fortran'])
endif

thread_dep = dependency('threads', required: false)

# NumPy include directory - needed in all submodules
incdir_numpy = run_command(py3,
  [
    '-c',
    'import os; import numpy; os.chdir(".."); print(numpy.get_include())'
  ],
  check: true
).stdout().strip()
message(incdir_numpy)

inc_np = include_directories(incdir_numpy)

# incdir_f2py = run_command(py3,
#     ['-c', 'import os; import numpy.f2py; print(numpy.f2py.get_include())'],
#     check : true
# ).stdout().strip()
# message(incdir_f2py)
# inc_f2py = include_directories(incdir_f2py)
# fortranobject_c = incdir_f2py / 'fortranobject.c'

cc = meson.get_compiler('c')
npymath_path = incdir_numpy / '..' / 'lib'
npymath_lib = cc.find_library('npymath', dirs: npymath_path)
npyrandom_path = incdir_numpy / '..' / '..' / 'random' / 'lib'
# Note: `required: false` can be removed once numpy 1.19 is the minimum version
npyrandom_lib = cc.find_library('npyrandom', dirs: npyrandom_path, required: false)

numpy_nodepr_api = '-DNPY_NO_DEPRECATED_API=NPY_1_9_API_VERSION'

# # Share this object across multiple modules.
# fortranobject_lib = static_library('_fortranobject',
#   fortranobject_c,
#   c_args: numpy_nodepr_api,
#   dependencies: py3_dep,
#   include_directories: [inc_np, inc_f2py],
#   )
# fortranobject_dep = declare_dependency(
#   link_with: fortranobject_lib,
#   include_directories: [inc_np, inc_f2py],
#   )


# Fortran warning flags
_fflag_Wno_argument_mismatch = ff.get_supported_arguments('-Wno-argument-mismatch')
_fflag_Wno_conversion = ff.get_supported_arguments('-Wno-conversion')
_fflag_Wno_intrinsic_shadow = ff.get_supported_arguments('-Wno-intrinsic-shadow')
_fflag_Wno_maybe_uninitialized = ff.get_supported_arguments('-Wno-maybe-uninitialized')
_fflag_Wno_surprising = ff.get_supported_arguments('-Wno-surprising')
_fflag_Wno_uninitialized = ff.get_supported_arguments('-Wno-uninitialized')
_fflag_Wno_unused_dummy_argument = ff.get_supported_arguments('-Wno-unused-dummy-argument')
_fflag_Wno_unused_label = ff.get_supported_arguments('-Wno-unused-label')
_fflag_Wno_unused_variable = ff.get_supported_arguments('-Wno-unused-variable')
_fflag_Wno_tabs = ff.get_supported_arguments('-Wno-tabs')
# The default list of warnings to ignore from Fortran code. There is a lot of
# old, vendored code that is very bad and we want to compile it silently (at
# least with GCC and Clang)
fortran_ignore_warnings = ff.get_supported_arguments(
  _fflag_Wno_argument_mismatch,
  _fflag_Wno_conversion,
  _fflag_Wno_maybe_uninitialized,
  _fflag_Wno_unused_dummy_argument,
  _fflag_Wno_unused_label,
  _fflag_Wno_unused_variable,
  _fflag_Wno_tabs,
  )

###########################################################
###########################################################
###########################################################

subdir('VolumeLibrary')

# fvs_py_extension = py3.extension_module(
#   lib_name,
#   f2py_source,
#   incdir_f2py+'/fortranobject.c',
#   link_with: fvs_static_lib,
#   include_directories: [inc_np, inc_f2py],
#   dependencies: [py3_dep, fortranobject_dep],
#   link_language: 'fortran',
#   c_args : [numpy_nodepr_api,] + sqlite_c_args,
#   fortran_args : fortran_ignore_warnings,
#   install : true,
#   # install_dir : 'pyfvs',
#   subdir: 'pyfvs'
#   )

subdir('pynvel')
