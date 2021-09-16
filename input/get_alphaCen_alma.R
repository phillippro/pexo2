source('../code/timing_function.R')
source('../code/sofa_function.R')
source('../code/astrometry_function.R')
tab <- read.table('alphaCenab_alma.txt',header=TRUE)
mons <- c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')
out <- c()
for(j in 1:nrow(tab)){
    day <- unlist(strsplit(tab[j,1],split='-'))
    day[2] <- match(day[2],mons)
    day <- rev(as.numeric(day))
    hms <-  as.numeric(unlist(strsplit(tab[j,2],split=':')))
    out <- rbind(out,c(day,hms))
}
jd <- rowSums(time_CalHms2JD(out))
tmp <- cbind(jd,tab[,'ra'],tab[,'era']*1e3,tab[,'dec'],tab[,'edec']*1e3,874)
indA <- which(tab[,'comp']=='A')
indB <- which(tab[,'comp']=='B')
fa <- 'HD128620/HD128620_ALMA.abs'
fb <- 'HD128621/HD128621_ALMA.abs'
cat(fa,'\n')
colnames(tmp) <- c('JD','ra','era','dec','edec','lambda')
write.table(tmp[indA,],file=fa,quote=FALSE,row.names=FALSE)

cat(fb,'\n')
write.table(tmp[indB,],file=fb,quote=FALSE,row.names=FALSE)
