#ins <- 'HARPSpre'
ins <- 'AAT'
#ins <- 'PFS'
CMPS <- 299792458
data <- read.table(paste0('../input/HD128620/HD128620_',ins,'.rv'),header=TRUE)
#fin <- paste0('~/Documents/projects/dwarfs/data/combined/HD128620raw/HD128620raw_',ins,'.dat')
#fin <- '../../dwarfs/bary/data/HD128620_PFSbary.dat'
if(ins=='AAT'){
    fin <- '../results/aat_test.txt'
}else if(ins=='PFS'){
    fin <- '../../dwarfs/bary/data/HD128620_PFSbary.dat'
}
cat('input:',fin,'\n')
bary <- read.table(fin,header=TRUE)
inds <- sapply(data[,1],function(t) which.min(abs(t-244e4-bary[,'MJDutc'])))
bary <- bary[inds,]

fout <- paste0(ins,'_compare_data_fit.pdf')
cat(fout,'\n')
pdf(fout,8,8)
par(mfrow=c(2,2))
drv <- data[,2]-OutRv$RvTot
drv <- drv-mean(drv)
plot(data[,1],drv,xlab='JD[UTC] [day]',ylab='RV[m/s]',main=paste0('RVo-RVf;RMS=',round(sd(drv),3)))

#drv <- data[,2]-OutRv$RvTot-OutRv$RvTot*data[,2]/CMPS
ZB <- OutRv$Zcomb$ZB
Zmeas <- data[,2]/CMPS
drv <- ((1+Zmeas)*(1+ZB)-1)*CMPS
#drv <- drv-mean(drv)
plot(data[,1],drv,xlab='JD[UTC] [day]',ylab='RV[m/s]',main=paste0('RVo-RVf-RVo*RVf/c;RMS=',round(sd(drv),3)))

#dbary <- bary[,2]-OutRv$RvTot
#OutRv$RvTot
dbary <- bary[,'BARYpaul']-CMPS*OutRv$Zcomb$ZB
plot(data[,1],dbary,xlab='JD[UTC]',ylab='RV[m/s]',main='Paul Bary - PEXO Bary')

dbary <- bary[,'BARYpaul']-bary[,'BARYpexo']
plot(data[,1],dbary,xlab='JD[UTC]',ylab='RV[m/s]',main='Paul Bary - PEXO RACK Bary')

dbary <- bary[,'BARYpexo']-CMPS*OutRv$Zcomb$ZB
plot(data[,1],dbary,xlab='JD[UTC]',ylab='RV[m/s]',main='PEXO RACK Bary - PEXO Bary')

dev.off()

