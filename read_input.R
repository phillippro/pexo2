option_list  <-  list(
    make_option(c("-m", "--mode"), type="character", default='emulate',
                help="PEXO mode: emulate or fit [optional; default=%default]", metavar="character"),
    make_option(c("-c", "--component"), type="character", default='TAR',
                help="PEXO model component: timing (T), astrometry (A), radial velocity (R) and their combinations [optional; default=%default]", metavar="character"),
    make_option(c("-t", "--time"), type="character", default=NULL,help='Timing file: epochs or times could be in 1-part or 2-part JD[UTC] format [mandatory if mode=emulate]'),
    make_option(c("-d", "--data"), type="character", default=NULL,help='Data directory: directory with timing, RV or astrometry data files [mandatory if mode=fit]'),
#    make_option(c("-C", "--companion"), type="character", default='',help='Companion data directory: directory with timing, RV or astrometry data files [optional; default=%default]'),
    make_option(c("-p", "--par"), type="character", default=NULL,help='Parameter file: parameters for models, observatory, for Keplerian/binary motion [mandatory]'),
    make_option(c("-v", "--var"), type="character", default=c('BJDtcb','BJDtdb','RvTot','ZB'),help='Output variables [optional; default=%default]'),
    make_option(c("-o", "--out"), type="character", default=NULL, help="Output file name: relative or absolute path [optional; default= %default]", metavar="character"),
    make_option(c("-f", "--figure"), type="character", default=FALSE,
                help="Output figure and verbose: FALSE or TRUE [optional; default= %default]", metavar="character")
)

opt_parser  <-  OptionParser(option_list=option_list)
opt  <- parse_args(opt_parser)
###Here are some examples for these arguments
if(TRUE){
#    star <- 'HD128621'
#     star <- 'HD103459'
#     star <- 'HD10790'
#     star <- 'HD10700'
#    star <- 'GJ551'
#    star <- 'HIP27321'
#    star <- 'HD239960'
    star <- 'HD128621'
#    opt$time <- '2456640.5 2458462.5 10'
#    opt$time <- '../input/HD10700pfs.tim'
#    opt$time <- paste0('../input/',star,'.tim')
#    opt$time <- '2440000.76 2470000 10'
    opt$mode <- 'fit'
#   opt$component <- 'TAR'
    opt$component <- 'TR'
#    opt$ins <- c('HARPSnew')
    opt$data <- paste0('../input/',star)
#    opt$data <- '../input/HD128621'
    opt$par <- paste0('../input/',star,'.par')
#    opt$par <- '../input/ACBfit.par'
#    opt$par <- '../input/TC_FBgeo.par'
#    opt$var <- 'BJDtdb ZB'
    opt$var <- 'BJDtdb RvRes ZB'
    opt$out <- paste0('../../dwarfs/bary/data/',star,'_PexoBary1.txt')
}
#    opt$out <- '../results/HD10700_PexoBary.txt'
###examples:
#star <- 'GJ4332'
##Rscript pexo.R -m emulate -c TR -t ../input/GJ4332.tim -P ../input/norm.prior -p ../input/GJ4332pfs.par -v BJDtdb,ZB -o ../../dwarfs/bary/data/GJ4332_PexoBary.txt
##Rscript pexo.R -m fit -c TR -d ../input/HD128620 -P ../input/kep_hybrid.prior -p ../input/HD128620.par -v BJDtdb,RvRes -o ../../dwarfs/bary/data/HD128620_PexoBary.txt

cat('opt=',unlist(opt),'\n')
if(is.null(opt$time) & opt$mode=='emulate'){
    print_help(opt_parser)
    stop("Error: at least one argument for -t must be supplied (input timing file).n", call.=FALSE)
}

if(is.null(opt$par)){
    print_help(opt_parser)
    stop("Error: at least one argument must be supplied (input parameter file).n", call.=FALSE)
}

###Usage example:
##Rscript pexo.R -m emulate -t ../input/TCpfs.tim -p ../input/TCpfs.par -v 'BJDtdb BJDtcb RvTot RvBT RvGO RvgsO RvgT RvlO RvLocal RvlT RvRemote RvSB RvSG RvSO RvsT RvST RvTot RvTropo ZB ZBwe' -o ../results/TC_obs.txt

###############################################################
##save parameters and derived parametrs into Par list
###############################################################
Par <- list()

###commandline parameters
Par$component <- opt$component
Par$figure <- as.logical(opt$figure)

###default values for optional parameters if there is no input
Par$xtelOff <- Par$ytelOff <- Par$ztelOff <- 0
Par$xgeoOff <- Par$ygeoOff <- Par$zgeoOff <- 0
Par$vxgeoOff <- Par$vygeoOff <- Par$vzgeoOff <- 0
Par$NpolyDelay <- Par$NpolyRv  <- Par$NpolyAstro  <- 0
Par$NsetRv <- Par$NsetAstro <- Par$NsetDelay <- 0
Par$raOff <- Par$decOff <- Par$pmraOff <- Par$pmdecOff <- Par$plxOff  <- Par$rvOff <- 0
Par$Einstein <- TRUE
Par$eta <- 1
if(!any(names(Par)=='RvType')) Par$RvType <- 'RAW'

###Read parameter file
try(if(!file.exists(opt$par)) stop('Error: parameter file does not exist!\n'))
#par0  <- read.table(opt$par)
tmp  <- readLines(opt$par)
##remove commented parameters
tmp <- gsub('#.+','',tmp)
tmp <- tmp[tmp!='']
##input parameters
for(p in tmp){
    s <- unlist(strsplit(p,' '))
    s <- s[s!='']
    if(!is.na(suppressWarnings(as.numeric(s[2])))){
        Par[[s[1]]] <- as.numeric(s[2])
    }else{
        Par[[s[1]]] <- s[2]
    }
    if(length(s)>2){
        if(any(is.na(suppressWarnings(as.numeric(s[2:4]))))) stop('Error: parameteres for',s[1],'is not numerical!')
        Par$Ini[[s[1]]] <- as.numeric(s[2])
        Par$PriorPar1[[s[1]]] <- as.numeric(s[3])
        Par$PriorPar2[[s[1]]] <- as.numeric(s[4])
        Par$prior[[s[1]]] <- s[5]
        if(s[5]=='N'){
            Par$Min[[s[1]]] <- as.numeric(s[3])-10*as.numeric(s[4])
	    if(grepl('^jitter',s[1])) Par$Min[[s[1]]] <- 0
            Par$Max[[s[1]]] <- as.numeric(s[3])+10*as.numeric(s[4])
        }else{
            Par$Min[[s[1]]] <- as.numeric(s[3])
            Par$Max[[s[1]]] <- as.numeric(s[4])
        }
    }
}

##check if mandatory parameters are missing or value type is correct
par.num.error <- c('ra','dec','pmra','pmdec','epoch')
par.alter <- c('plx dist')
par.logic <- c('PlanetShapiro','SBscaling','CompareT2')
#par.num.erro <- c('logmC','mC','mTC','mCT','mT','aC','aT','aTC','aCT','omegaT','omegaC')
#par.char.warn <- c('EopType','TaiType','TtType','unit','TtTdbMethod','SBscaling','PlanetShapiro','RVmethod','CompareT2','LenRVmethod','BinaryModel','ellipsoid','BinaryUnit')
par.num <- c('Niter','Ncore','NpolyDelay','NpolyRv','NpolyAstro','pRvT','qRvT','pRvC','qRvC','DE','Tstep','g','epoch','rv','mC','logmC','mTC','mCT','mT','aC','aT','aTC','aCT','omegaT','omegaC','omegaT','omegaC','I','Mo','Tc','Tasc','Tp','T0','e','P','logP','plx','pmra','pmdec','ra','dec','dist')
cn <- names(Par)
for(p in par.num.error){
    if(!any(cn==p)) stop('Error:',p,' is not found in parameter file!\n')
    if(is.na(Par[[p]])) stop('Error:',p,' is not numerical!\n')
}
for(p in par.alter){
    p <- unlist(strsplit(p,' '))
    p <- p[p!='']
    ind <- match(p,cn)
    if(all(is.na(ind))) stop('Error:',paste(p,collapse='or'),'is not found in parameter file!\n')
}
for(p in cn){
    if(any(p==par.num)){
        if(is.na(suppressWarnings(as.numeric(Par[[p]])))) stop('Error:',p,'is not numerical!\n')
    }
}
for(p in cn){
    if(any(p==par.logic)){
        if(is.na(as.logical(Par[[p]]))) stop('Error:',p,'is not logical!\n')
        Par[[p]] <- as.logical(Par[[p]])
    }
}

###register cores if Ncore>0
if(Par$Ncore>0) {registerDoMC(Par$Ncore)} else {registerDoMC()}

if(!any(cn=='primary')){
    ss <- gsub('.+\\/|\\.|par','',opt$par)
    Par$star <- substr(ss,1,nchar(ss))
}else{
    Par$star <- Par$primary
}

###Read timing or data files
Data <- c()
lambda <- list()
if(opt$mode=='emulate'){
    if(!file.exists(opt$time)){
        s <- unlist(strsplit(opt$time,split=' '))
        s <- s[s!='']
        StrError <- 'Error: the UTC timing data cannot be found or the UTC sequence cannot be generated from the argument after -t !\n'
        if(length(s)==3){
            ts <- try(seq(as.numeric(s[1]),as.numeric(s[2]),by=as.numeric(s[3])),TRUE)
            if(class(ts)=='try-error'){
                stop(StrError,call. = FALSE)
            }else{
                utc <- time_ChangeBase(cbind(time_ToJD(ts),0))
            }
        }else{
            stop(StrError,call. = FALSE)
        }
    }else{
        utc <- read.table(opt$time)
        if(ncol(utc)==1){
            utc <- cbind(utc,0)
        }
        utc <- time_ToJD(utc)
        utc <- time_ChangeBase(utc,1)
    }
    Data <- utc
}else{
    if(any(names(Par)=='companion')){
        stars <- Par$stars <- c(Par$star,Par$companion)
    }else{
        stars <- Par$stars <- c(Par$star)
        Par$companion <- "NA"
    }
    Nt <- 0
    for(kk in 1:length(stars)){
        star <-  stars[kk]
        fin <- paste0('../input/',stars[kk])
        fs <- list.files(path=fin,full.name=TRUE)
        ind.delay <- grep('delay$',fs)
        Ndelay <- length(ind.delay)
        Par[[star]]$NsetDelay <- length(ind.delay)
        inss <- c()
        if(Ndelay>0){
            cat(Ndelay,'.delay file found in ',fin,'\n')
            for(j in ind.delay){
                ins <- gsub('.delay|.+_','',fs[j])
#                if(any(ins==opt$ins)){
                if(TRUE){
                    inss <- c(inss,ins)
                    tab <- read.table(fs[j])
                    if(class(tab[,1])=='factor'){
                        tab <- read.table(fs[j],header=TRUE)
                    }
                                        #                tab[,2] <- tab[,2]-mean(tab[,2])#automatically remove offset
                    tmp <- cbind(time_ToJD(tab[,1]),tab[,2:3],NA,NA,as.character(star),'delay',ins,NA)
                    Data <- rbind(Data,as.matrix(tmp))
                }else{
                    cat('No .delay file found in ',fin,'!\n')
                }
            }
        }else{
            cat('No .delay file found in ',fin,'!\n')
        }
        Par$ins[[star]]$delay <- inss

        ind.rv <- grep('rv$',fs)
        Nrv <- length(ind.rv)
        Par[[star]]$NsetRv <- length(ind.rv)
        inss <- c()
        if(length(ind.rv)>0 & grepl('R',Par$component)){
            cat(Nrv,'.rv file found in ',fin,'!\n')
            for(j in ind.rv){
                ins <- gsub('.rv|.+_','',fs[j])
#                if(any(ins==opt$ins)){
                if(TRUE){
                    inss <- c(inss,ins)
                    tab <- read.table(fs[j])
                    if(class(tab[,1])=='factor'){
                        tab <- read.table(fs[j],header=TRUE)
                    }
                    rvbar <- mean(tab[,2])
                                        #                tab[,2] <- tab[,2]-rvbar#automatically remove offset
                    tmp <- cbind(time_ToJD(tab[,1]),tab[,2:3],NA,NA,as.character(star),'rv',ins,NA)
                    Data <- rbind(Data,as.matrix(tmp))
                }else{
                    cat('No .rv file found in ',fin,'!\n')
                }
            }
        }else{
            cat('No .rv file found in ',fin,'!\n')
        }
        Par$ins[[star]]$rv <- inss

        ind.abs <- grep('abs$',fs)
        Nabs <- length(ind.abs)
        Par[[star]]$NsetAbs <- length(ind.abs)
        inss <- c()
        if(length(ind.abs)>0 & grepl('A',Par$component)){
            cat(Nabs,'.abs file found in ',fin,'!\n')
            for(j in ind.abs){
                ins <- gsub('.abs|.+_','',fs[j])
#                if(any(ins==opt$ins)){
                if(TRUE){
                    inss <- c(inss,ins)
                    tab <- read.table(fs[j])
                    if(class(tab[,1])=='factor'){
                        tab <- read.table(fs[j],header=TRUE)
                    }
                    tab[,c(2,4)] <- tab[,c(2,4)]/180*pi#from deg to rad
                    Nd <- nrow(tab)
                    if(ncol(tab)>5){
                        tmp <- cbind(time_ToJD(tab[,1]),tab[,2:5],as.character(star),'abs',ins,tab[,6])
                    }else{
                        tmp <- cbind(time_ToJD(tab[,1]),tab[,2:5],as.character(star),'abs',ins,NA)
                    }
                    Data <- rbind(Data,as.matrix(tmp))
                }else{
                    cat('No .abs file found in ',fin,'!\n')
                }
            }
        }else{
            cat('No .abs file found in ',fin,'!\n')
        }
        Par$ins[[star]]$abs <- inss

        ind.rel <- grep('rel$',fs)
        Nrel <- length(ind.rel)
        if(Nrel==0) cat('No .rel file found in ',fin,'!\n')
        Par[[star]]$NsetRel <- length(ind.rel)
        inss <- c()
        if(length(ind.rel)>0 & grepl('A',Par$component)){
            cat(Nrel,'.rel file found in ',fin,'!\n')
            for(j in ind.rel){
                ins <- gsub('.rel|.+_','',fs[j])
                inss <- c(inss,ins)
                tab <- read.table(fs[j])
                if(class(tab[,1])=='factor'){
                    tab <- read.table(fs[j],header=TRUE)
                }
                Nd <- nrow(tab)
                if(ncol(tab)>5){
                    tmp <- cbind(time_ToJD(tab[,1]),tab[,2:5],as.character(star),'rel',ins,tab[,6])
                }else{
                    tmp <- cbind(time_ToJD(tab[,1]),tab[,2:5],as.character(star),'rel',ins,NA)
                }
                Data <- rbind(Data,as.matrix(tmp))
            }
        }else{
            cat('No .rel file found in ',fin,'!\n')
        }
        Par$ins[[star]]$rel <- inss
#        if(Nrv==0 & Nabs==0 & Nrel==0 & Ndelay==0) stop('No data file found in',fin,'\n')
    }
    colnames(Data) <- c('utc','V1','eV1','V2','eV2','star','type','instrument','wavelength')
    Data <- fit_changeType(Data,c(rep('n',5),rep('c',3)))
    utc <- time_ChangeBase(cbind(Data[,1],0),1)
    Par$Dtypes <- unique(Data$type)
    if(any('rel'==Data[,'type']) & length(Par$stars)==1){
#        Par$companion <- paste0(Par$star,'C')
        Par$stars <- c(Par$stars,Par$companion)
    }
}
Par$tmin <- min(rowSums(utc))
Par$Nepoch <- nrow(utc)

###Read global parameters
if(any(cn=='RefType')){
    ref <- Par$RefType
    refs <- c('none','refro','refcoq')
    if(!any(refs==ref)) stop('Error: RefType is not recognized!\n')
}else{
    Par$RefType <- 'none'
}

ind <- which(cn=='pRvT')
if(length(ind)==0){
    p <- rep(0,length(Par$ins[[stars[1]]]$rv))
}
names(p) <- Par$ins[[stars[1]]]$rv
Par$p[[Par$stars[1]]]$rv <- p

ind <- which(cn=='qRvT')
if(length(ind)==0){
    q <- rep(0,length(Par$ins[[stars[1]]]$rv))
}
names(q) <- Par$ins[[stars[1]]]$rv
Par$q[[Par$stars[1]]]$rv <- q

if(length(Par$stars)==2){
    ind <- which(cn=='pRvC')
    if(length(ind)==0){
        p <- rep(0,length(Par$ins[[stars[2]]]$rv))
    }
    names(p) <- Par$ins[[stars[2]]]$rv
    Par$p[[Par$stars[2]]]$rv <- p

    ind <- which(cn=='qRvC')
    if(length(ind)==0){
        q <- rep(0,length(Par$ins[[stars[2]]]$rv))
    }
    names(q) <- Par$ins[[stars[2]]]$rv
    Par$q[[Par$stars[2]]]$rv <- q
}

##   EopType - Version of EOP parameter file
if(any(cn=='EopType')){
    eop <- c('2000B','2006','approx')
    if(!any(eop==Par$EopType)) stop(paste0('Error: in',opt$par,', EopType value is not valid, it should be 2000B, 2006, or approx!'))
}else{
    Par$EopType <- '2006'
}

if(any(cn=='TaiType')){
    taitype <- c('scale','instant')
    if(!any(eop==Par$EopType)) stop(paste0('Error: In',opt$par,', TaiType value is not valid, it should be instant or scale!'),call. = FALSE)
}else{
    Par$TaiType <- 'instant'
}

if(any(cn=='TtType')){
    tttype <- c('BIPM','TAI')
    if(!any(tttype==Par$TtType)) stop(paste0('Error: In',opt$par,', TtType value is not valid, it should be BIPM or TAI!'),call. = FALSE)
}else{
    Par$TtType <- 'BIPM'
}

if(any(cn=='unit')){
    units <- c('TCB','TDB')
    if(!any(units==Par$unit)) stop(paste0('Error: In',opt$par,', unit value is not valid, it should be TCB or TDB!'),call. = FALSE)
}else{
    Par$unit <- 'TCB'
}

##   DE - Version of JPL ephemeris
if(any(cn=='DE')){
##Remove t from the DE value and thus DE430t is the same as DE430. For both, the DE430t ephemerides would be used.
    Par$DE <- as.integer(gsub('t','',Par$DE))
}else{
    Par$DE <- 430
}

if(any(cn=='TtTdbMethod')){
    tttdb <- c('eph','FB01','FBgeo')
    if(!any(tttdb==Par$TtTdbMethod)) stop(paste0('Error: In',opt$par,', TtTdbMethod value is not valid, it should be eph or FB01 or FBgeo!'),call. = FALSE)
}else{
    Par$TtTdbMethod <- 'eph'
}

if(Par$TtTdbMethod=='FB01'){
   tmp <- try(system('cd FB01 ; ./fb2001 <fb2001.in >fb2001.out'),TRUE)
   if(tmp>0){
       tmp <- try(system('cd FB01 ; gfortran -O2 fb2001.f -o fb2001'),TRUE)
   }
   if(tmp>0) stop("Error: fb2001.f cannot be compiled or fb2001.in is not found in code/FB01/!", call.=FALSE)
}

## SBscaling - Whether or not transform the coordinate time at the SSB (tS) to the coordinate time at the TSB (tB). Since it is a linear transformation, it could be absorbed into the fit of orbital period or other time-scale parameters. So we follow TEMPO2 not to do this transformation/scaling by using scaling=FALSE as default.
if(any(cn=='SBscaling')){
    sb <-  c('TRUE','FALSE')
    if(!any(sb==Par$SBscaling)) stop(paste0('Error: In',opt$par,', SBscaling value is not valid, it should be TRUE or FALSE!'),call. = FALSE)
}else{
    Par$SBscaling <- FALSE
}

##   planet - Whether or not the planet Shapiro delay is calculated.
if(any(cn=='PlanetShapiro')){
    ps <-  c('TRUE','FALSE')
    if(!any(ps==Par$SBscaling)) stop(paste0('In',opt$par,', PlanetShapiro value is not valid, it should be TRUE or FALSE!'),call. = FALSE)
}else{
    Par$PlanetShapiro <- TRUE
}

###The method used for RV modeling, analytical is more efficient and thus is default.
if(any(cn=='RVmethod')){
    rm <- c('numerical','analytical')
    if(!any(rm==Par$RVmethod)) stop(paste0('Error: In',opt$par,', RVmethod value is not valid, it should be analytical or numerical!'),call. = FALSE)
    Par$RVmethod <- pars['RVmethod']
}else{
    Par$RVmethod <- 'analytical'
}

if(!any(cn=='Tstep')){
    if(Par$RVmethod=='numerical') cat('warning: No time step is given for numerical modeling of RV and a step of 0.01 days would be used!\n')
    Par$Tstep <- 0.01
}

if(Par$RVmethod=='numerical'){
    ts <- c()
    for(j in 1:nrow(utc)){
        ts <- rbind(ts,rbind(c(utc[j,1],utc[j,2]-Par$Tstep),utc[j,],c(utc[j,1],utc[j,2]+Par$Tstep)))
    }
    utc <- ts
}

##   CompareT2 - whether or not to compare TEMPO2 Roemer delay (second order) and PEXO Roemer delay (>=3nd order)
if(any(cn=='CompareT2')){
    ct <- c('TRUE','FALSE')
    if(!any(ct==Par$CompareT2)) stop(paste0('Error: In',opt$par,', CompareT2 value is not valid, it should be TRUE or FALSE!'),call. = FALSE)
}else{
    Par$CompareT2 <- FALSE
}

if(any(cn=='LenRVmethod')){
    lr <- c('PEXO','T2')
    if(!any(lr==Par$LenRVmethod)) stop(paste0('Error: In',opt$par,', LenRVmethod value is not valid, it should be PEXO or T2!'),call. = FALSE)
}else{
    Par$LenRVmethod <- 'T2'
}

## Binary model type: classical kepler, DDGR (default), DD
#default values
Par$binary <- FALSE
Par$Np <- 0
if(any(cn=='BinaryModel')){
    bm <- c('DDGR','kepler','none')
    if(any(bm==Par$BinaryModel)){
        if(Par$BinaryModel!='none'){
            Par$binary <- TRUE
            Par$Np <- 1
            cat('PEXO will treat the target system as a binary or multiple-star systems!\n')
        }else{
            cat('PEXO will treat the target system as a single star!\n')
        }
    }else{
        stop('BinaryModel value is not DDGR, kepler, or none!')
    }
}else{
    Par$BinaryModel <- 'none'
}

## PPN parameter g (or gamma)
if(!any(cn=='g')){
    Par$g <- 1
}

##   BinaryUnit - Unit used in the computation of byinary orbit
##   unit 1: au and year (auyr)
##   unit 2: natural unit (c=1,[L]=[M]=[T]=s)
if(any(cn=='BinaryUnit')){
    bu <- c('auyr','natural')
    if(!any(cn==bu)) stop('Error: BinaryUnit is not auyr or natural!')
}else{
    Par$BinaryUnit <- 'auyr'
}

###Read observertory/telescope parameters
if(any(cn=='ellipsoid')){
    ep <- c('WGS84','GRS80','WGS72')
    if(!any(ep==Par$ellipsoid)) stop('Error: BinaryUnit is not WGS84 or GRS80 or WGS72!')
}else{
    Par$ellipsoid <- 'WGS84'
}

if(Par$ellipsoid=='WGS84'){
    Par$n <- 1
}else if(Par$ellipsoid=='GRS80'){
    Par$n <- 2
}else if(Par$ellipsoid=='WGS72'){
    Par$n <- 3
}else{
    stop('Error: reference ellipsoid for Earth rotation model is not given!')
}


###If GPS location is specified, using the given ones instead of the ones from the observatory data file
ObsInfo <- array(NA,dim=c(nrow(utc),15))
other <- array(NA,dim=c(nrow(utc),15))
tmp <- c()
if(opt$mode=='fit'){
    for(star in Par$stars){
        vn <- paste0('vOff.',star)
        if(!any(cn==vn)){
            if(any(cn=='vOff')){
                Par[[vn]] <- Par$vOff
            }else if(any(cn==vn)){
                Par[[vn]] <- 0
            }
        }
        for(type in Par$Dtypes){
            for(ins in Par$ins[[star]][[type]]){
                index <- which(Data[,'star']==star & Data[,'type']==type & Data[,'instrument']==ins)
                source('get_MultiObsPar.R')
                if(length(index)>0){
#                    ObsInfo[index,] <- t(replicate(length(index),c(Par[[xn]],Par[[yn]],Par[[zn]],Par[[en]],Par[[pn]],Par[[hn]],Par[[tdk]],Par[[pmb]],Par[[rh]],Par[[wl]],Par[[tlr]],Par[[ref]])))
                    ObsInfo[index,] <- as.matrix(obscor)
                }
            }
        }
    }
}else{
    source('get_ObsPar.R')
    ObsInfo <- t(replicate(nrow(utc),c(Par$xtel,Par$ytel,Par$ztel,Par$elong,Par$phi,Par$height,Par$tdk,Par$pmb,Par$rh,Par$wl,Par$tlr,Par$RefType)))
}
colnames(ObsInfo) <- c('xtel','ytel','ztel','elong','phi','height','ObsType','RefType','tdk','pmb','rh','wl','tlr','p','q')
ObsInfo <- fit_changeType(ObsInfo,c(rep('n',6),rep('c',2),rep('n',7)))
Par$ObsInfo <- ObsInfo
Par$tpos <- time_ToJD(Par$epoch)#reference astrometry epoch

ra0 <- Par$ra <- Par$ra/180*pi#rad
dec0 <- Par$dec <- Par$dec/180*pi#rad
Par$pqu <- cbind(c(-sin(ra0),cos(ra0),0),c(-sin(dec0)*cos(ra0),-sin(dec0)*sin(ra0),cos(dec0)),c(cos(dec0)*cos(ra0),cos(dec0)*sin(ra0),sin(dec0)))

ind1 <- grep('plx',cn)
ind2 <- grep('dist',cn)
if(length(ind1)>0){
    Par$dist <- 1000/Par$plx
}else if(length(ind2)>0){
    Par$plx <- 1000/Par$dist#dist in pc unit
}else{
    Par$plx <- 1e-3#equal to D=1 Mpc so that parallex can be ignored if not given.
    Par$dist <- 1e6#pc
}

if(Par$dist>1){
    Par$near <- FALSE
}else{
    Par$near <- TRUE
}

###Read Keplerian parameters, and if they are given the binary model should be used
if(!any(cn=='mT')) Par$mT <- 1 #for single stars just use default value; for binaries, error occurs.

#Par$aT <- Par$aTC <- Par$aC <- Par$P <- Par$e <- Par$I <- Par$omegaT <- Par$omegaC <- Par$Omega <- Par$Tp <- NA
Par$mC <- 1
Par$KepPar1 <- Par$KepPar2 <- Par$KepIni <- Par$KepMin <- Par$KepMax <- Par$KepPrior <- c()
if(Par$binary){
    ind <- grep('mT|mTC|mCT',cn)
    if(length(ind)==0) stop('Error: no mass in the target system is given!')
    ind <- grep('mC',cn)
    if(length(ind)==0){
	Par$mC <- 1e-3
        Par$logmC <- log(Par$mC)
    }else if(any(cn=='logmC')){
        Par$mC <- exp(Par$logmC)
    }
    if(any(cn=='mT')) Par$mTC <- Par$mT+Par$mC
    if(any(cn=='mTC')) Par$mT <- Par$mTC-Par$mC
    if(any(cn=='mCT')) Par$mT <- Par$mCT-Par$mC
    Par$logmTC <- log(Par$mTC)
    Par$logmT <- log(Par$mT)
    ind <- which('logmC'==names(Par$Max))
    if(length(ind)>0){
        Par$KepIni['logmC'] <- Par$Ini['logmC']
        Par$KepMax['logmC'] <- Par$Max['logmC']
        Par$KepMin['logmC'] <- Par$Min['logmC']
        Par$KepPrior['logmC'] <- Par$prior['logmC']
        Par$KepPar1['logmC'] <- Par$PriorPar1['logmC']
        Par$KepPar2['logmC'] <- Par$PriorPar2['logmC']
    }else{
        Par$KepIni['logmC'] <- Par$logmC
        Par$KepMin['logmC'] <- -10
        Par$KepMax['logmC'] <- 20
        Par$KepPrior['logmC'] <- 'U'
        Par$KepPar1['logmC'] <- Par$KepMin['logmC']
        Par$KepPar2['logmC'] <- Par$KepMax['logmC']
    }

    indP <- grep('^logP',cn)
    indC <- grep('^aT',cn)
    indT <- grep('^aC',cn)
    indTC <- grep('^aTC',cn)
    if(length(indP)>0){
        if(is.na(Par$logP)) stop('Error: logP value is not numerical!',call.=FALSE)
        Par$P <- exp(Par$logP)
        Par$aTC <- ((Par$P/DJY)^2*Par$mTC)^(1/3)#au
        Par$aT <- Par$aTC*Par$mC/Par$mTC
        Par$aC <- Par$aTC*Par$mT/Par$mTC
    }else if(length(indC)>0 | length(indT)>0 | length(indTC)>0){
        if(length(indTC)>0){
            Par$aT <- Par$aTC*Par$mC/Par$mTC
            Par$aC <- Par$aTC*Par$mT/Par$mTC
        }else if(length(indT)>0){
            Par$aC <- Par$aT/Par$mC*Par$mT
            Par$aTC <- Par$aT/Par$mC*Par$mTC
        }else if(length(indC)>0){
            Par$aT <- Par$aC/Par$mT*Par$mC
            Par$aTC <- Par$aC/Par$mT*Par$mTC
        }
        Par$P <- sqrt(Par$aTC^3/Par$mTC)#year
    }
    if(!any(names(Par)=='logP')) stop('Error: orbital period P or semi-major axis is not given!\n')
    Par$P <- exp(Par$logP)
    ind <- which('logP'==names(Par$Max))
    if(length(ind)>0){
        Par$KepIni['logP'] <- Par$Ini['logP']
        Par$KepMax['logP'] <- Par$Max['logP']
        Par$KepMin['logP'] <- Par$Min['logP']
        Par$KepPrior['logP'] <- Par$prior['logP']
        Par$KepPar1['logP'] <- Par$PriorPar1['logP']
        Par$KepPar2['logP'] <- Par$PriorPar2['logP']
    }else{
        Par$KepIni['logP'] <- Par$logP
        Par$KepMin['logP'] <- -10
        Par$KepMax['logP'] <- 10
        Par$KepPrior['logP'] <- 'U'
        Par$KepPar1['logP'] <- Par$KepMin['logP']
        Par$KepPar2['logP'] <- Par$KepMax['logP']
    }

    ind <- which(cn=='e')
    if(length(ind)==0) stop('Error: eccentricity e is not given!\n')
    ind <- which('e'==names(Par$Max))
    if(length(ind)>0){
        Par$KepIni['e'] <- Par$Ini['e']
        Par$KepMax['e'] <- Par$Max['e']
        Par$KepMin['e'] <- Par$Min['e']
        Par$KepPrior['e'] <- Par$prior['e']
        Par$KepPar1['e'] <- Par$PriorPar1['e']
        Par$KepPar2['e'] <- Par$PriorPar2['e']
    }else{
        Par$KepIni['e'] <- Par$e
        Par$KepMin['e'] <- 0
        Par$KepMax['e'] <- 1
        Par$KepPrior['e'] <- 'U'
        Par$KepPar1['e'] <- Par$KepMin['e']
        Par$KepPar2['e'] <- Par$KepMin['e']
    }

    ind <- which(cn=='I')
    if(length(ind)==0) stop('Error: Inclination I is not given!\n')
    Par$I <- Par$I/180*pi#rad
    Par$Ini['I'] <- Par$Ini['I']/180*pi#rad
    Par$Min['I'] <- Par$Min['I']/180*pi#rad
    Par$Max['I'] <- Par$Max['I']/180*pi#rad
    ind <- which('I'==names(Par$Max))
    if(length(ind)>0){
        Par$KepIni['I'] <- Par$Ini['I']
        Par$KepMax['I'] <- Par$Max['I']
        Par$KepMin['I'] <- Par$Min['I']
        Par$KepPrior['I'] <- Par$prior['I']
        Par$KepPar1['I'] <- Par$PriorPar1['I']
        Par$KepPar2['I'] <- Par$PriorPar2['I']
    }else{
        Par$KepIni['I'] <- Par$I
        Par$KepMin['I'] <- 0
        Par$KepMax['I'] <- pi
        Par$KepPrior['I'] <- 'U'
        Par$KepPar1['I'] <- Par$KepMin['I']
        Par$KepPar2['I'] <- Par$KepMin['I']
    }

    indC <- which('omegaC'==cn)
    indT <- which('omegaT'==cn)
    if(length(indC)==0 & length(indT)==0) stop('Error: argument of periastron omegaT or omegaC is not given!\n')
    if(length(indT)>0){
        Par$omegaT <- Par$omegaT/180*pi#rad
        Par$omegaC <- (Par$omegaT+pi)%%(2*pi)
    }
    if(length(indC)>0){
        Par$omegaC <- Par$omegaC/180*pi#rad
        Par$omegaT <- (Par$omegaC+pi)%%(2*pi)
    }
    Par$Ini['omegaT'] <- Par$Ini['omegaT']/180*pi#rad
    Par$Min['omegaT'] <- Par$Min['omegaT']/180*pi#rad
    Par$Max['omegaT'] <- Par$Max['omegaT']/180*pi#rad
    ind <- which('omegaT'==names(Par$Max))
    if(length(ind)>0){
        Par$KepIni['omegaT'] <- Par$Ini['omegaT']
        Par$KepMax['omegaT'] <- Par$Max['omegaT']
        Par$KepMin['omegaT'] <- Par$Min['omegaT']
        Par$KepPrior['omegaT'] <- Par$prior['omegaT']
        Par$KepPar1['omegaT'] <- Par$PriorPar1['omegaT']
        Par$KepPar2['omegaT'] <- Par$PriorPar2['omegaT']
    }else{
        Par$KepIni['omegaT'] <- Par$omegaT
        Par$KepMin['omegaT'] <- 0
        Par$KepMax['omegaT'] <- 2*pi
        Par$KepPrior['omegaT'] <- 'U'
        Par$KepPar1['omegaT'] <- Par$KepMin['omegaT']
        Par$KepPar2['omegaT'] <- Par$KepMax['omegaT']
    }

    ind <- grep('Omega',cn)
    if(length(ind)==0) stop('Error: longitude of ascending node Omega is not given!\n')
    Par$Omega <- Par$Omega/180*pi#rad
    Par$Ini['Omega'] <- Par$Ini['Omega']/180*pi#rad
    Par$Min['Omega'] <- Par$Min['Omega']/180*pi#rad
    Par$Max['Omega'] <- Par$Max['Omega']/180*pi#rad
    ind <- which('Omega'==names(Par$Max))
    if(length(ind)>0){
        Par$KepIni['Omega'] <- Par$Ini['Omega']
        Par$KepMax['Omega'] <- Par$Max['Omega']
        Par$KepMin['Omega'] <- Par$Min['Omega']
        Par$KepPrior['Omega'] <- Par$prior['Omega']
        Par$KepPar1['Omega'] <- Par$PriorPar1['Omega']
        Par$KepPar2['Omega'] <- Par$PriorPar2['Omega']
    }else{
        Par$KepIni['Omega'] <- Par$Omega
        Par$KepMin['Omega'] <- 0
        Par$KepMax['Omega'] <- 2*pi
        Par$KepPrior['Omega'] <- 'U'
        Par$KepPar1['Omega'] <- Par$KepMin['Omega']
        Par$KepPar2['Omega'] <- Par$KepMax['Omega']
    }
    ind.T0 <- which('T0'==cn)
    ind.Tp <- which('Tp'==cn)
    ind.Tc <- which('Tc'==cn)
    ind.Tasc <- which('Tasc'==cn)
    ind.Mo <- which('Mo'==cn)
    if(length(ind.Mo)==0 & length(ind.Tp)==0 & length(ind.Tc)==0 & length(ind.T0)==0) stop('Error: mean or true anomaly or reference epoch at periastron or primary transit (i.e. T0, Mo or Tp or Tc) is not given!\n')
    if(length(ind.T0)>0){
        Par$T0 <- time_ToJD(Par$T0)#jd
        if(is.na(Par$T0)) stop('Error: T0 value is not numerical!',call.=FALSE)
    }else{
        Par$T0 <- min(rowSums(utc))#first epoch of the utc time sequence
    }

    if(length(ind.Tasc)>0){
        Par$Tasc <- as.numeric(pars[ind.Tasc])#jd; sometimes used in ELL1 model (Wex 1998)
        if(is.na(ind.Tasc)) stop('Error: Tasc value is not numerical!',call.=FALSE)
    }else{
        Par$Tasc <- NA#first epoch of the utc time sequence
    }

    if(length(ind.Tc)>0){
        Par$Tp <- gen_Tc2tp(Par$e,Par$omegaT,Par$P,Par$Tc)
        Par$Mo <- (Par$T0-Par$Tp)/Par$P*2*pi
    }else if(length(ind.Tp)>0){
        Par$Tc <- gen_CalTc(Par$Tp,Par$P,Par$e,Par$omegaT)
        Par$Mo <- (Par$T0-Par$Tp)/Par$P*2*pi
    }else if(length(ind.Mo)>0){
        Par$Tp <- gen_Mo2tp(Par$Mo,Par$T0,exp(Par$logP))
        Par$Tc <- gen_CalTc(Par$Tp,Par$P,Par$e,Par$omegaT)#mid-transit epoch
    }
    Par$Mo <- Par$Mo%%(2*pi)
    ind <- which('Mo'==names(Par$Max))
    if(length(ind)>0){
        Par$KepIni['Mo'] <- Par$Ini['Mo']/180*pi
        Par$KepMax['Mo'] <- Par$Max['Mo']/180*pi
        Par$KepMin['Mo'] <- Par$Min['Mo']/180*pi
        Par$KepPrior['Mo'] <- Par$prior['Mo']
        Par$KepPar1['Mo'] <- Par$PriorPar1['Mo']
        Par$KepPar2['Mo'] <- Par$PriorPar2['Mo']
    }else{
        Par$KepIni['Mo'] <- Par$Mo
        Par$KepMin['Mo'] <- 0
        Par$KepMax['Mo'] <- 2*pi
        Par$KepPrior['Mo'] <- 'U'
        Par$KepPar1['Mo'] <- Par$KepMin['Mo']
        Par$KepPar2['Mo'] <- Par$KepMax['Mo']
    }
    Par$DD <- Par$DDGR <- list()
###Some default binary parameters for DD and DDGR
    Par$DDGR$xdot <- Par$DD$xdot <- 0
    Par$DDGR$edot <- Par$DD$edot <- 0
    Par$DDGR$omdot <- Par$DD$omdot <- 0
    Par$DDGR$pbdot <- Par$DD$pbdot <- 0
    Par$DDGR$xpbdot <- Par$DD$xpbdot <- 0
    Par$DDGR$wdot <- Par$DD$wdot <- 0
    Par$DDGR$sini <- Par$DD$sini <- sin(Par$I)
    Par$DD$dth <- 0
    Par$DD$gamma <- 0
    Par$DD$dr <- 0

###binary/companion parameters
#    Par$DDGR$a1 <- as.numeric(Par$mC/Par$mTC*(Par$P^2*Par$mTC)^(1/3))#au
    Par$DDGR$x0 <- Par$DDGR$a1 <-Par$aT*Par$DDGR$sini/YC#yr
    Par$DDGR$omz <- Par$omegaT
    Par$DDGR$pb <- Par$P
    Par$DD$ecc <- Par$DDGR$ecc <- Par$e
}
###remove all Keplerain parameters from Par$Ini, Par$Min, Par$Max, and Par$prior
kn <- c('Tp','Tasc','Tc','aT','aTC','aC','mC','mTC','Omega','omegaT','omegaC','I','e','logP','logmC','logmT','logmTC','logmCT','Mo','K','P')
for(n in c('Ini','Min','Max','prior','PriorPar1','PriorPar2')){
    ind <- match(kn,names(Par[[n]]))
    ind <- ind[!is.na(ind)]
    if(length(ind)>0){
        Par[[n]] <- Par[[n]][-ind]
    }
    ind <- match(kn,names(Par))
    ind <- ind[!is.na(ind)]
    if(length(ind)>0){
        ns <- names(Par)[ind]
        for(n in ns){
            Par[[n]] <- NULL
        }
    }
}
#Par$KepName <- c('mC','P','e','I','omegaT','Omega','Mo')
for(n in names(Par$KepIni)) Par[[paste0(n,1)]] <- Par$KepIni[n]
if(any(names(Par)=='logmC1')) Par$mC1 <- exp(Par$logmC1)
if(any(names(Par)=='logP1')) Par$P1 <- exp(Par$logP1)
Par$KepName <- names(Par$KepIni)
Par$ParName <- names(Par$Ini)
Par$Npar <- length(Par$Ini)
####load ephermies and EOP and other input data sets
source('load_data.R')
