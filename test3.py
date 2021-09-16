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
