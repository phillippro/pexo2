EpochHip <- 2448349.0625
EpochGaia <- 2457206.375
strs <- unique(Data[,c('star','instrument','type')])
ss <- c()
for(j in 1:nrow(strs)){
    if(opt$mode=='fit'){
        if(Par$Einstein)   ss <- c(ss,'gamma 1 0 10 U')
        if(strs[j,3]=='rv'){
                                        #        ss <- c(ss,paste0('jitterRv.',strs[j,1],'.',strs[j,2],' 1 0 1e2 U'))
            ss <- c(ss,paste0('logjitterRv.',strs[j,1],'.',strs[j,2],' 0 -10 5 U'))
            ss <- c(ss,paste0('bRv.',strs[j,1],'.',strs[j,2],' 0 -1e6 1e6 U'))
        }else if(strs[j,3]=='rel' | strs[j,3]=='abs'){
            ss <- c(ss,paste0('logjitterAstro.',strs[j,1],'.',strs[j,2],' 0 -10 10 U'))
        }
                                        #        ss <- c(ss,paste0('xtel.',strs[j,2],' 0'))
                                        #        ss <- c(ss,paste0('ytel.',strs[j,2],' 0'))
                                        #        ss <- c(ss,paste0('ztel.',strs[j,2],' 0'))
    }

    if(strs[j,2]=='AAT'){
        ss <- c(ss,'phi.AAT -31.27704')
        ss <- c(ss,'elong.AAT 149.0661')
        ss <- c(ss,'height.AAT 1.164')
    }
    if(strs[j,2]=='PFS'){
        ss <- c(ss,'phi.PFS -29.013983')
        ss <- c(ss,'elong.PFS -70.692633')
        ss <- c(ss,'height.PFS 2.40792')
    }
    if(strs[j,2]=='MIKE'){
        ss <- c(ss,'phi.MIKE -29.013983')
        ss <- c(ss,'elong.MIKE -70.692633')
        ss <- c(ss,'height.MIKE 2.40792')
    }
    if(strs[j,2]=='KECK'){
        ss <- c(ss,'phi.KECK 19.82636')
        ss <- c(ss,'elong.KECK -155.47501')
        ss <- c(ss,'height.KECK 4.145')
    }
    if(strs[j,2]=='SOPHIE' | strs[j,2]=='ELODIE'){
        ss <- c(ss,paste0('phi.',strs[j,2],' 43.92944'))
        ss <- c(ss,paste0('elong.',strs[j,2],' 5.7125'))
        ss <- c(ss,paste0('height.',strs[j,2],' 0.65'))
    }
    if(grepl('CARM',strs[j,2])){
        ss <- c(ss,paste0('phi.',strs[j,2],' 37.220791'))
        ss <- c(ss,paste0('elong.',strs[j,2],' -2.546847'))
        ss <- c(ss,paste0('height.',strs[j,2],' 2.168'))
    }
    if(strs[j,2]=='UVES'){
        ss <- c(ss,'phi.UVES -24.625407')
        ss <- c(ss,'elong.UVES -70.403015')
        ss <- c(ss,'height.UVES 2.648')
    }
    if(strs[j,2]=='HARPN'){
        ss <- c(ss,'phi.HARPN 28.754')
        ss <- c(ss,'elong.HARPN -17.88814')
        ss <- c(ss,'height.HARPN 2.37')
    }
    if(strs[j,2]=='APF'){
        ss <- c(ss,'phi.APF 37.3425')
        ss <- c(ss,'elong.APF -121.63825')
        ss <- c(ss,'height.APF 1.274')
    }
    if(strs[j,2]=='LICK'){
        ss <- c(ss,'phi.LICK 37.3425')
        ss <- c(ss,'elong.LICK -121.63825')
        ss <- c(ss,'height.LICK 1.274')
    }
    if(grepl('HARPS',strs[j,2])){
        ss <- c(ss,paste0('phi.',strs[j,2],' -29.2584'))
        ss <- c(ss,paste0('elong.',strs[j,2],' -70.7345'))
        ss <- c(ss,paste0('height.',strs[j,2],' 2.4'))
    }
    if(strs[j,2]=='WDS'){
        ss <- c(ss,'phi.WDS 0')
        ss <- c(ss,'elong.WDS 0')
        ss <- c(ss,'height.WDS 0')
    }
}
####add astrometric data
star.name <- c(gsub(' ','',Par$star),gsub('GJ','GL',Par$star),gsub('-','',Par$star))
cname <- c('ra','dec','pmra','pmdec','parallax','radial_velocity')
star <- Par$star
source('simbad_cor.R')
ns <- names(StarAstro)
names(StarAstro)[ns=='parallax'] <- 'plx'
names(StarAstro)[ns=='radial_velocity'] <- 'rv'
s <- paste(names(StarAstro),StarAstro)
#s <- paste(c('ra','dec','pmra','pmdec','plx','rv','epoch'),StarAstro)
ss <- c(ss,s)

###add planetary parameters if there is not any
##find signal
if(Par$Nmax>0){
    ss <- c(ss,paste('logmC',opt$orbit['logmC'],'-10 10 U'))
    ss <- c(ss,paste('logP',opt$orbit['logP'],'-10 20 U'))
    ss <- c(ss,paste('e',opt$orbit['e'],'0 1 U'))
    ss <- c(ss,paste('I',opt$orbit['I'],'0 3.141592653589793116 sinU'))
    ss <- c(ss,paste('omegaT',opt$orbit['omegaT'],'0 6.283185307179586232 U'))
    if(!grepl('R',opt$component)){
       if(opt$orbit['Omega']<3.141592653589793116) ss <- c(ss,paste('Omega',opt$orbit['Omega'],'0 3.141592653589793116 U'))
       if(opt$orbit['Omega']>=3.141592653589793116) ss <- c(ss,paste('Omega',opt$orbit['Omega'],'3.141592653589793116 6.283185307179586232 U'))
    }else{
       ss <- c(ss,paste('Omega',opt$orbit['Omega'],'0 360 U'))
    }
    ss <- c(ss,paste('Tp',opt$orbit['Tp'],opt$orbit['Tp']-1e5,opt$orbit['Tp']+1e5,'U'))
}
tmp <- c(tmp,ss)
#cat('\nadded parameters!\n')
#cat(paste(ss,collapse='\n'),'\n')
