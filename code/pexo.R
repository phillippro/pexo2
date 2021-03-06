options(digits=20)
#library("Rmpfr")
#library("magicaxis")
library(optparse)
library(orthopolynom)
library(pracma)
library(foreach)
library(compiler)
#library(fields)
#library(MASS)
library(foreach)
library(doMC)
#library(Matrix)
#library(doParallel)
#library(parallel)
library(e1071)
#library(kernlab)
#library(glasso)
#library(JPEN)
#library(matrixcalc)
#library(mvtnorm)
library(MASS)
#library(rootSolve)
#library(lqmm)
source('constants.R')
source('sofa_function.R')
source('astrometry_function.R')
source('general_function.R')
source('timing_function.R')
source('rv_function.R')
source('update_function.R')
source('fit_function.R')
source('mcmc_func.R')
source('plot_function.R')

tt0 <- proc.time()
Tstart <- proc.time()
####Read parameter files
source('read_input.R')
tmp <- gen_CombineModel(utc,Data,Par,component=Par$component)
if(opt$mode=='fit'){
    cat('\n Run MCMC fit:\n')
    OutObs <- tmp$OutObs
    OutTime0 <- OutTime <- tmp$OutTime
    OutAstro <- tmp$OutAstro
    OutRv <- tmp$OutRv
    source('solution.R')
}else{
    OutObs <- tmp$OutObs[[1]][[1]]
    OutTime0 <- OutTime <- tmp$OutTime[[1]][[1]]
    if(grepl('A',Par$component)){
        OutAstro <- tmp$OutAstro[[1]][[1]]
    }else{
        OutAstro <- tmp$OutAstro
    }
    if(grepl('R',Par$component)){
        OutRv <- tmp$OutRv[[1]][[1]]
    }else{
        OutRv <- tmp$OutRv
    }
}

cat('\n Plot and save results!\n')
if(!is.null(opt$var) & !is.null(opt$out) & opt$mode=='emulate'){
    source('emulate_output.R')
}else{
    source('fit_output.R')
}

cat('Total computation time:',round((proc.time()-tt0)[3]/60,3),'min\n')
