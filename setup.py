from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

setup(
    name='SHA1 with serializable state',
    ext_modules=cythonize([
        Extension('psha', ['psha.pyx'], libraries=['crypto'])
    ]),
)
