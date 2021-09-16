#!/bin/tcsh -f 
set Ncore=8
set target=$1
set Niter=$2
#set component="TAR"
set component=$3
set fout="logs/${target}_core${Ncore}_N$Niter.log"
echo $fout
R CMD BATCH --no-save --no-restore "--args -p ${target} -n ${Ncore} -N ${Niter} -c ${component}" pexo.R "$fout" &
