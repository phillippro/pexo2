args <- commandArgs(trailingOnly=TRUE)
if(length(args)>0){
    fobjs <- args
}else{
#     fobjs <- 'GJ144_Nmax0_llmax-1720_N110000_einsteinTRUE.Robj'
    fobjs <- 'HD128620_1companion_TR_llmax-41999_N40000_einsteinTRUE_Nrv4_bary.Robj'
}
library(optparse)
library(orthopolynom)
library(pracma)
library(foreach)
library(foreach)
library(doMC)
library(MASS)
library(ggplot2)
source('plot_function.R')
source('constants.R')
source('sofa_function.R')
source('astrometry_function.R')
source('general_function.R')
source('timing_function.R')
source('rv_function.R')
source('update_function.R')
source('fit_function.R')
for(fobj in fobjs){
    load(paste0('../results/',fobj))
    outf <- TRUE
    source('fit_output.R')
}
