args <- commandArgs(trailingOnly=TRUE)
if(length(args)>0){
   f <- args[1]
}else{
   f <- 'HD128620_1companion_llmax-151535_N40000_einsteinTRUE_ParStat.txt'
}
star <- gsub('_.+','',f)
tab <- read.table(paste0('../results/',f),header=TRUE)
fout <- paste0(star,'.par')
cat(fout,'\n')
write.table(t(tab[1,]),file=fout,quote=FALSE,col.names=FALSE)
