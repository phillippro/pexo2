#!/bin/bash
#scp ffeng@further.dtm.ciw.edu:Documents/projects/pexo/pars/HD128620.par pars/
#scp ffeng@further.dtm.ciw.edu:Documents/projects/pexo/input/HD128620.astro input/
rsync -azP pars/ ffeng@astro.tdli.sjtu.edu.cn:Documents/projects/pexo/pars
rsync -azP input/ ffeng@astro.tdli.sjtu.edu.cn:Documents/projects/pexo/input
rsync -azP code/ ffeng@astro.tdli.sjtu.edu.cn:Documents/projects/pexo/code
#rsync -azP ffeng@astro.tdli.sjtu.edu.cn:Documents/projects/pexo/code/ code
#scp pars/HD128620.par tdlffb@data.hpc.sjtu.edu.cn:Documents/projects/pexo/pars/
#scp input/HD128620.astro tdlffb@data.hpc.sjtu.edu.cn:Documents/projects/pexo/input/

