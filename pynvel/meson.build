# _dummy_init = [
#   fs.copyfile('__init__.py'),
#   fs.copyfile('nvelcommon.pxi'),
#   fs.copyfile('_vollib.pxd'),
# ]

fs.copyfile('_vollib.pxd')

python_sources = [
  '__init__.py',
  '__main__.py',
  'volume_height.py',
  'behres.py',
  # 'config.py',
  'pynvel_ctypes.py',
  'nvelcommon.py',
  'volume_calculator.py',
  '_vollib.pxd',
  'nvelcommon.pxi',
]

dep_py = py3.dependency()

# Cython extension
py3.extension_module(
    '_pynvel',
    '_pynvel.pyx',
    dependencies : dep_py,
    link_with : [nvel_static_lib,],
    include_directories : incdir_numpy,
    cython_args : [
      '--include-dir',
      meson.current_build_dir(),
      ],
    install : true,
    subdir: 'pynvel',
)

py3.install_sources(
  python_sources,
  subdir: 'pynvel'
)

# install_subdir(
#   'keywords',
#   install_dir: py3.get_install_dir() / 'pyfvs',
#   exclude_directories : ['__pycache__']
#   )

install_data(
  'pynvel.toml',
  install_dir: py3.get_install_dir() / 'pynvel',
)

install_subdir(
  'test',
  install_dir: py3.get_install_dir() / 'pynvel',
  # exclude_files: ['nvel_validate.xlsx',],
  exclude_directories : ['__pycache__','.pytest_cache','notebooks'], #,'reg_test','fia_test','api_test']
  # exclude_directories: exclude_dirs,
  )
