if(!exists('star')) star <- commandArgs(trailingOnly=TRUE)
if(!exists('EpochGaia')) EpochGaia <- 2457206.375
if(!exists('cname')) cname <- c('ra','dec','pmra','pmdec','parallax','radial_velocity')
cmd <- paste('python2.7 cross_match_gaia_hip.py',star)
py.path <- '/Users/ffeng/miniconda2/bin/python'
ff <- paste0('../input/',star,'.astro')
if(file.exists(ff)){
    dat <- read.table(ff)
    StarAstro <- dat[,2]
    names(StarAstro) <- dat[,1]
    if(!any(dat[,1]=='epoch')){
        epoch <- StarAstro['epoch'] <- EpochGaia
    }else{
        epoch <- dat[dat[,1]=='epoch',2]
    }
}else{
    if(file.exists(py.path)) cmd <- paste(py.path,'cross_match_gaia_hip.py',star)
                                        #if(file.exists(py.path)) cmd <- paste('python2 cross_match_gaia_hip.py',star)
    cat(cmd,'\n')
    try(system(cmd),TRUE)
    fin <- paste0(star,'_gaia_hip.csv')
    if(file.exists(fin)){
###Gaia data
        astro <- read.csv(fin,check.names=FALSE)[1,]
        epoch <- EpochGaia
        ra <- as.numeric(astro['ra'])
        dec <- as.numeric(astro['dec'])
        plx <- as.numeric(astro['parallax'])
        pmra <- as.numeric(astro['pmra'])
        pmdec <- as.numeric(astro['pmdec'])
        rv <- as.numeric(astro['radial_velocity'])
        if(is.na(rv)) rv <- as.numeric(astro['RV'])
        StarAstro <- c(ra,dec,pmra,pmdec,plx,rv)
        if(is.na(rv)) rv <- 0
        if(any(is.na(StarAstro))){
            epoch <- EpochHip
            hip <- read.csv('../data/hip2.csv',check.names=FALSE,sep='|')
            ind <- which(hip[,'HIP']==astro['HIP'])
            ra <- hip[ind,'RArad']
            dec <- hip[ind,'DErad']
            plx <- astro['Plx']
            pmra <- astro['pmRA']
            pmdec <- astro['pmDE']
            rv <- astro['radial_velocity']
            if(is.na(rv)) rv <- astro['RV']
            if(is.na(rv)) rv <- 0
            StarAstro <- c(ra,dec,pmra,pmdec,plx,rv)
        }
        names(StarAstro) <- cname
        if(TRUE){
            cat('\n Astrometry information for',star,'\n')
            cat('ra=',StarAstro['ra'],'\n')
            cat('dec=',StarAstro['dec'],'\n')
            cat('plx=',StarAstro['parallax'],'\n')
            cat('pmra=',StarAstro['pmra'],'\n')
            cat('pmdec=',StarAstro['pmdec'],'\n')
            cat('rv=',StarAstro['radial_velocity'],'\n')
            cat('epoch=',epoch,'\n\n')
        }
        system(paste('rm',fin))
        if(any(is.na(StarAstro))) stop(paste('No full astrometric information found for',star,'!'))
    }else{
        epoch <- EpochGaia
        tab <- read.csv('../data/star_planet_info.csv')
        ind <- which(tab[,'target']==star)
        if(length(ind)==0)  stop(paste('cross_match_gaia_hip.py does not work for',star,'!'))
        StarAstro <- tab[ind[1],c('ra','dec','pmra','pmdec','parallax','radial_velocity')][1,]
                                        #    cat(StarAstro,'\n')
    }
}
