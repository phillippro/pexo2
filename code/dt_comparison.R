#star1 <- star <- 'GJ551'
star1 <- star <- 'HD128620'
star1 <- 'HD128620raw'
ii <- which(Data$star==star)
jj <- which(Data$instrument[ii]=='HARPS' | Data$instrument[ii]=='HARPSpre')
bjd <- rowSums(fit$OutTime[[star]]$rv$BJDtdb[jj,])
tobs <- rowSums(utc[ii[jj],])
roemer <- fit$OutTime[[star]]$rv$RoemerSolar[jj]
dt <- (tobs-bjd)*24*60
dd <- paste0('/Users/ffeng/Documents/projects/dwarfs/data/HARPSpre')
if(star=='HD128620') dd <- paste0('/Users/ffeng/Documents/projects/dwarfs/data/combined/',star1)
fin <- list.files(path=dd,pattern=paste0(star1,'_HARPS'),full.name=TRUE)[1]

#paste0(dd,'/',star1,'_HARPS.dat')
bjd1 <- read.table(fin,header=TRUE)[,1]
dt1 <- (tobs-bjd1)*24*60
fout <- paste0(star,'_test.pdf')
cat(fout,'\n')
pdf(fout,8,8)
par(mfrow=c(2,2))
plot(bjd,roemer)
plot(roemer,(dt-dt1)*60)
dev.off()
