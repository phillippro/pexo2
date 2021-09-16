source('../code/timing_function.R')
source('../code/sofa_function.R')
source('../code/astrometry_function.R')
tab <- read.table('datafile12.txt',header=TRUE)
#cn <- c('Text','CMRAh','CMRAm','CMRAs','CMDEd','CMDEm','CMDEs','ARAh','ARAm','ARAs','ADEd','ADEm','ADEs','BRAh','BRAm','BRAs','BDEd','BDEm','BDEs','dRA','dEC','Sep','PA')
#colnames(tab) <-
#write.table('')
bjd <- rowSums(time_Yr2jd(tab[,1]))
tmp <- astro_hdms2deg(tab[,'CMRAh'],tab[,'CMRAm'],tab[,'CMRAs'],tab[,'CMDEd'],tab[,'CMDEm'],tab[,'CMDEs'])
ra.cm <- tmp[,1]
dec.cm <- tmp[,2]
tmp <- astro_hdms2deg(tab[,'ARAh'],tab[,'ARAm'],tab[,'ARAs'],tab[,'ADEd'],tab[,'ADEm'],tab[,'ADEs'])
raa <- tmp[,1]
deca <- tmp[,2]
tmp <- astro_hdms2deg(tab[,'BRAh'],tab[,'BRAm'],tab[,'BRAs'],tab[,'BDEd'],tab[,'BDEm'],tab[,'BDEs'])
rab <- tmp[,1]
decb <- tmp[,2]

fout <- 'alphaCen_absolute_astrometry.pdf'
cat(fout,'\n')
pdf(fout,6,6)
ras <- c(raa,rab,ra.cm)
decs <- c(deca,decb,dec.cm)
plot(ras,decs,xlab='RA [deg]',ylab='DEC [deg]')
points(raa,deca,col='red')
points(rab,decb,col='blue')
dev.off()

###output A astrometry
fa <- 'HD128620_ALMA.abs'

fb <- 'HD128621_ALMA.abs'
