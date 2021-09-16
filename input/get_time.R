args <- commandArgs(trailingOnly=TRUE)
if(length(args)>0){
    file <- args[1]
}else{
    file <- 'HD128620/HD128620_HARPSpre.rv'
}
if(!file.exists(file)) stop(paste(file,'does not exist!'))
tab <- read.table(file,header=TRUE)
fout <- gsub('.+\\/|\\..+','',file)
fout <- paste0(fout,'.tim')
cat(fout,'\n')
write.table(tab[,1,drop=FALSE],file=fout,quote=FALSE,row.names=FALSE,col.names=FALSE)
