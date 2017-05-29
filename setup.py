from distutils.core import setup
from distutils.extension import Extension

have_cython = False
try:
    from Cython.Distutils import build_ext
    have_cython = True
except ImportError:
    from distutils.command.build_ext import build_ext

if have_cython:
    psha_module = Extension('psha', ['psha.pyx'], libraries=['crypto'])
else:
    psha_module = Extension('psha', ['psha.c'], libraries=['crypto'])

setup(
    name='SHA1 with serializable state',
    ext_modules=[psha_module],
    cmdclass={'build_ext': build_ext}
)
