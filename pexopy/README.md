A python wrapper for [PEXO](https://github.com/phillippro/pexo) software.

**NOTE** : this is an early alpha and is under development.

# Requirements

- Python 3+
- NumPy
- [PEXO](https://github.com/phillippro/pexo) and its dependencies, see [documentation](http://rpubs.com/Fabo/pexo) for installation guidance.

# Installation

Install the dependencies and set an environment variable `$PEXODIR` to a path to the PEXO repository. Add `export PEXODIR=/example/path/to/pexo` to your `~/.bashrc` or `~/.bash_profile` if you’re using bash, or `setenv PEXODIR /example/path/to/pexo`to `~/.tcshrc` if you’re using tcsh.

## from this repository

```sh
git clone https://github.com/timberhill/pexopy.git
cd pexopy
python setup.py install
```

or

```sh
pip install git+https://github.com/timberhill/pexopy.git -U
```

## uninstall

```sh
pip uninstall pexopy
```

# Usage

`Pexo` object takes the same parameters as PEXO software, except in a pythonic way.

To run PEXO, call function `Pexo().run()` and specify the parameters.

## Using input file paths

The files in this example are from [PEXO repository](https://github.com/phillippro/pexo/tree/master/input).

```python
from pexopy import Pexo

pexo_output = Pexo().run(
    mode="emulate",
    component="TAR",
    time= "../pexo/input/gaia80yrby10day.tim",
    par="../pexo/input/ACAgaia.par" # Alpha Centauri input file
)

print(type(pexo_output))
print(pexo_output.dtype.names)
print(pexo_output)
```

Output:

```plain
<class 'numpy.ndarray'>

('BJDtcb1', 'BJDtcb2', 'BJDtdb1', 'BJDtdb2')

[(2442596., 0.00380966, 2442596., 0.00381816)
 (2443192., 0.32709   , 2443192., 0.32708926)
 (2443788., 0.65067419, 2443788., 0.6506642 )
 ...
 (2471816., 0.00452725, 2471816., 0.00408269)]
```

See output column description in [PEXO documentation](http://rpubs.com/Fabo/pexo).

## Input files as dictionaries

```python
from pexopy import Pexo
from numpy import arange

tauCeti_par = {
    "name"          : "TauCeti",
    "EopType"       : "2000B",
    "RefType"       : "none",
    "TaiType"       : "instant",
    "TtType"        : "TAI",
    "unit"          : "TDB",
    "DE"            : "430",
    "TtTdbMethod"   : "eph",
    "SBscaling"     : False,
    "PlanetShapiro" : True,
    "CompareT2"     : True,
    "LenRVmethod"   : "T2",
    "RVmethod"      : "analytical",
    "g"             : 1,
    "ellipsoid"     : "GRS80",
    "observatory"   : "CTIO",
    "xtel"          : 1814985.3,
    "ytel"          : -5213916.8,
    "ztel"          : -3187738.1,
    "tdk"           : 278,
    "pmb"           : 1013.25,
    "rh"            : 0.1,
    "wl"            : 0.5,
    "tlr"           : 0.0065,
    "epoch"         : 2448349.06250,
    "mT"            : 0.783,
    "mC"            : 0,
    "ra"            : 026.02136459,
    "dec"           : -15.93955572,
    "plx"           : 273.96,
    "pmra"          : -1721.05,
    "pmdec"         : 854.16,
    "rv"            : -16.68
}

pexo_output = Pexo().run(
    mode="emulate",
    component="TAR",
    time=arange(2442000.5, 2443000.5, 10),
    par=tauCeti_par,
)
```

## Using `PexoPar` and `PexoTim` objects

```python
from pexopy import Pexo, PexoPar, PexoTim
import numpy as np

tauCeti_par = PexoPar(
    name="TauCeti",
    EopType="2000B",
    RefType="none",
    TaiType="instant",
    TtType="TAI",
    unit="TDB",
    DE="430",
    TtTdbMethod="eph",
    SBscaling=False,
    PlanetShapiro=True,
    CompareT2=True,
    LenRVmethod="T2",
    RVmethod="analytical",
    g=1,
    ellipsoid="GRS80",
    observatory="CTIO",
    xtel=1814985.3,
    ytel=-5213916.8,
    ztel=-3187738.1,
    tdk=278,
    pmb=1013.25,
    rh=0.1,
    wl=0.5,
    tlr=0.0065,
    epoch=2448349.06250,
    mT=0.783,
    mC=0,
    ra=026.02136459,
    dec=-15.93955572,
    plx=273.96,
    pmra=-1721.05,
    pmdec=854.16,
    rv=-16.68
)
# or, if you have a file, tauCeti_par = PexoPar("../pexo/input/TC_Fig11b.par")

tim = PexoTim(np.arange(2442000.5, 2443000.5, 10))

pexo_output = Pexo().run(
    mode="emulate",
    component="TAR",
    time=tim,
    par=tauCeti_par,
)
```

## `setup()`

`Pexo().setup()` is needed is you want to specify custom paths to you Rscript installation (determined from `which Rscript` otherwise) or PEXO repository (uses `$PEXODIR` environment variable otherwise):

```python
from pexopy import Pexo
pexo = Pexo()
pexo.setup(Rscript="/path/to/Rscript", pexodir="/path/to/pexo")
```

## `clear_cache()`

As `pexopy` creates temporary input and output files, you might want to clear them with `Pexo().clear_cache()`.
