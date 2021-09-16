#!/bin/tcsh -f 
#set target=$1
set Niter=$1
set Ncore=32
set companion=1
foreach target ( `cat targets.txt`)
      set fout="logs/${target}_core${Ncore}_N$Niter.log"
      echo $fout
      R CMD BATCH --no-save --no-restore "--args -m fit -p ${target} -n ${Ncore} -N ${Niter} -C ${companion}" pexo.R "$fout" &
end
