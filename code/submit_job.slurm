#!/bin/bash                                                                                                                                                               
#SBATCH --job-name=pexo                                                                                                                                                 
#SBATCH --partition=super                                                                                                                                                
#SBATCH -n 16                                                                                                                                          
#SBATCH --mail-type=fail                                                                                                                                                  
#SBATCH --mail-user=ffeng@stju.edu.cn                                                                                                                                     
#SBATCH --output=out/slurm%j.out                                                                                                                                          
##%j.out                                                                                                                                                                  
#SBATCH --error=out/slurm%j.err                                                                                                                                           
##${SLURM_JOBID}.er                                                                                                                                                       
##%j.err                                                                                                                                                                  
#SBATCH --time=144:00:00                                                                                                                                                  
echo "SLURM_JOBID: ${SLURM_JOBID}"
#echo "SLURM_ARRAY_TASK_ID: ${SLURM_ARRAY_TASK_ID}"                                                                                                                       
#echo "SLURM_ARRAY_JOB_ID: ${SLURM_ARRAY_JOB_ID}"                                                                                                                         
#echo "${SLURM_JOB_NODELIST}"                                                                                                                                             
#module purge
#module load miniconda3
#source activate r-base
#source activate python3

Niter=$1
star='HD128620'
#echo $star
Ncores=32
companion=1
fout="logs/${star}_N${Niter}_Ncore${Ncores}_pexo.log"
echo "$fout"
R CMD BATCH --no-save --no-restore "--args -m fit -c TAR -p ${star} -N ${Niter} -n ${Ncores} -C ${companion}" pexo.R "$fout" 2>1 out/slurm%j.out
