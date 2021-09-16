outf <- FALSE
  Data0 <- Data
    Ncore <- Par$Ncore
    Niter0 <- Par$Niter
    ParOpt <- ParIni0 <- ParIni <- Par$Ini
    ParMin0 <- ParMin <- Par$Min
    ParMax0 <- ParMax <- Par$Max
    prior <- Par$prior
    PriorPar1 <- Par$PriorPar1
    PriorPar2 <- Par$PriorPar2
    Res <- ParML <- ParMP <- McOpt <- list()
    Np0 <- Par$Np
    Nsig <- Np0
    ll0 <- -1e6#initi
np <- Np0
Par$Np <- np
###Parallel signal identification and constraints
        if(np>0){
            Par$Np <- 1
            ParIni <- fit_Add1Kep(ParIni0,Par$KepIni,0,Par$KepName)
            ParMin <- fit_Add1Kep(ParMin0,Par$KepMin,0,Par$KepName)
            ParMax <- fit_Add1Kep(ParMax0,Par$KepMax,0,Par$KepName)
            Par$prior <- fit_Add1Kep(prior,Par$KepPrior,0,Par$KepName)
            Par$PriorPar1 <- fit_Add1Kep(PriorPar1,Par$KepPar1,0,Par$KepName)
            Par$PriorPar2 <- fit_Add1Kep(PriorPar2,Par$KepPar2,0,Par$KepName)
        }
        Par$Npar <- length(ParIni)
	f3 <- list.files(path='../pars',pattern=paste0('^',Par$target,'\\.par$'),full.name=TRUE)
###If there is input parameter file from pexo/pars/,then use it as the initial parameters and then run cold chains directly
            dd <- read.table(f3)
            parname <- dd[,1]
            par <- dd[,2]
            names(par) <- parname
            n <- intersect(parname,names(ParIni))
            ParIni[n] <- par[n]

###update the initial condition
 l1 <- fit_LogLike(Data,OutObs,RateObs,ParIni,Par,OutTime0=OutTime0)$llike
            ParIni2 <- fit_OptIni(Data,OutObs,RateObs,ParIni,Par,OutTime0=OutTime0)#optimize offsets
            l2 <- fit_LogLike(Data,OutObs,RateObs,ParIni2,Par,OutTime0=OutTime0)$llike
            if(l2>l1) ParIni <- ParIni2

#            names(ParIni) <- parname
        cat('ParIni:',names(ParIni),'\n')
        cat('ParIni:',ParIni,'\n')

fit <- fit_LogLike(Data,OutObs,RateObs=RateObs,ParFit=ParIni,Par=Par,OutTime0=OutTime0,TimeUpdate=TRUE)
model <- fit$model
llmax <- round(fit$llike)


source('plot_test.R')
