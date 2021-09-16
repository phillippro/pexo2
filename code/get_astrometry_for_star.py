import sys
import string
import numpy as np
from astroquery.simbad import Simbad
from astroquery.gaia import Gaia
from astropy.io import ascii

star = sys.argv[1]

if any(c.isalpha() for c in star):
    Simbad.add_votable_fields('pm', 'plx','rv_value')
    result_table = Simbad.query_object(star)

    ra0 = map(lambda x: float(x),string.split(result_table['RA'][0]))
    ra1 = (ra0[0] + ra0[1]/60 + ra0[2]/3600) * 360/24#deg
    dec0 = map(lambda x: float(x),string.split(result_table['DEC'][0]))
    dec1 = dec0[0] + dec0[1]/60 + dec0[2]/3600#deg
    pmra = result_table['PMRA'][0]
    pmdec = result_table['PMDEC'][0]

    ##convert to Gaia epoch
    dec = dec1  +  15.5*pmdec/3600000#deg
    ra = ra1  +  (15.5*pmra/3600000)/np.cos((dec + dec1)*np.pi/360)#deg
    rv = float(result_table['RV_VALUE'][0])
    #plx = result_table['PLX_VALUE_3'][0]
    plx = result_table['PLX_VALUE'][0]
else:
    query = "select * from gaiadr2.gaia_source where source_id=" + str(star)
    job = Gaia.launch_job(query=query)
    out = job.get_results()

    ra = out['ra'][0]
    dec = out['dec'][0]
    plx = out['parallax'][0]
    pmra = out['pmra'][0]
    pmdec = out['pmdec'][0]
    rv = float(out['radial_velocity'][0])

if np.isnan(rv):
    rv = 0

ascii.write(np.array([ra,dec,plx,pmra,pmdec,rv]), 'test.txt')
