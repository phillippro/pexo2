  verbose <- FALSE
    ParNew <- update_par(Par,ParFit)
    for(n in names(ParFit)) ParNew[[n]] <- ParFit[n]
    if(length(RateBary)>0){
        OutBaryNew <- update_OutBary(ParFit,OutBary,RateBary)
    }else{
        OutBaryNew <- OutBary
    }
    OutTimeNew <- time_Ta2te(OutBaryNew,ParNew,fit=TRUE)
    LogLike <- 0
    ModelTrend <- ModelRed <- ModelKep <- model <- Data
    AstroList <- list()
    for(star in as.character(ParNew$stars)){
###RV model
        index <- which(Data$type=='rv' & Data$star==star)
        if(length(index)>0){
            RvKep <- fit_RvKep(OutTimeNew,Data,OutBaryNew,ParFit,ParNew,star)
            ModelKep[index,2] <- RvKep[index]
            RvTrend <- fit_RvTrend(OutTimeNew,Data,ParFit,ParNew,star)
            ModelTrend[index,2] <- RvTrend[index]
            RvHat <- RvKep+RvTrend
            RvRed <- fit_RvRed(OutTimeNew,RvHat,Data,ParFit,ParNew,star)
            ModelRed[index,2] <- RvRed[index]
            RvHat <- RvHat+RvRed
            model[index,2] <- RvHat[index]
            llike <- fit_RvLike(RvHat,Data,ParFit,ParNew,star)
            if(verbose) cat('star',star,';rv;llike=',llike,';b=',ParFit['bRv.alphaCenB.PFS'],'\n')
            LogLike <- LogLike+llike
        }
###absolute astrometry model
        ind <- which((Data$type=='abs' & Data$star==star) | Data$type=='rel')
        index <- which(Data$type=='abs' & Data$star==star)
        AstroHat <- AstroRed <- AstroKep <- array(0,dim=c(ParNew$Nepoch,2))
        if(length(ind)>0){
            AstroList[[star]] <- AstroKep <- fit_AstroKep(OutTimeNew,Data,OutBaryNew,ParFit,ParNew,star)#rad
            if(length(index)>0){
                ModelKep[index,c(2,4)] <- AstroKep[index,]
                AstroTrend <- fit_AstroTrend(OutTimeNew,Data,ParFit,ParNew,star=star,type='abs')#rad
                ModelTrend[index,c(2,4)] <- AstroTrend[index,]
                AstroHat <- AstroKep+AstroTrend
                AstroRed <- fit_AstroRed(OutTimeNew,AstroHat,Data,ParFit,ParNew,star=star,type='abs')#rad
                ModelRed[index,c(2,4)] <- AstroRed[index,]
                AstroHat <- AstroHat+AstroRed
                model[index,c(2,4)] <- AstroHat[index,]
                llike <- fit_AstroLike(AstroHat,Data,ParFit,ParNew,star=star,type='abs')
                if(verbose) cat('star',star,';abs; llike=',llike,'\n')
                LogLike <- LogLike+llike
            }
        }
    }

###relative astrometry model
    star <- ParNew$stars[1]
    AstroHat <- AstroRed <- AstroKep <- array(0,dim=c(ParNew$Nepoch,2))
    index <- which(Data$type=='rel')
    if(length(index)>0 & ParNew$Np>0){
        rd1 <- AstroList[[ParNew$stars[1]]]
        rd2 <- AstroList[[ParNew$stars[2]]]
        AstroKep <- cbind((rd1[,1]-rd2[,1])*cos((rd1[,2]+rd2[,2])/2),rd1[,2]-rd2[,2])/DMAS2R
        ModelKep[index,c(2,4)] <- AstroKep[index,]
        AstroTrend <- fit_AstroTrend(OutTimeNew,Data,ParFit,ParNew,star,type='rel')
        ModelTrend[index,c(2,4)] <- AstroTrend[index,]
        AstroHat <- AstroKep+AstroTrend
        AstroRed <- fit_AstroRed(OutTimeNew,AstroHat,Data,ParFit,ParNew,star,type='rel')
        ModelRed[index,c(2,4)] <- AstroRed[index,]
        AstroHat <- AstroHat+AstroRed
        model[index,c(2,4)] <- AstroHat[index,]
        llike <- fit_AstroLike(AstroHat,Data,ParFit,ParNew,star,type='rel')
        if(verbose) cat('star',star,';rel;llike=',llike,'\n')
        LogLike <- LogLike+llike
    }
    if(verbose){
        cat('LogLike=',LogLike,'\n')
    }
