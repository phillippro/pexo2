ParOpt0 <- ParOpt
models <- list()
llike <- c()
for(j in 1){
par <- ParOpt
ParFit <- fit_OptIni(Data,OutObs,RateObs,par,Par)#only optimize offsets
ParNew <- update_par(Par,par)
OutObs <- update_OutObs(par,OutObs,RateObs)
tmp <- gen_CombineModel(utc,Data,ParNew,component=Par$component)
OutObs <- tmp$OutObs
OutTime <- tmp$OutTime
OutAstro <- tmp$OutAstro
OutRv <- tmp$OutRv
fit <- fit_LogLike(Data,OutObs,RateObs,ParFit,ParNew)
models[[j]] <- fit$model
llike <- c(llike,fit$llike)
}
fout <- paste0('../results/relativity_',star,'.pdf')
cat(fout,'\n')
pdf(fout,16,16)
par(mfrow=c(4,4))
jd <- rowSums(OutTime[[star]]$rv$tauE)
RVsT <- OutRv[[star]]$rv$RvsT
RVgT <- OutRv[[star]]$rv$RvgT
RVgsT <- RVsT+RVgT
RVall <- model[,2]
ind <- which(Data$type=='rv')
res <- Data[ind,2]-model[ind,2]
RESsT <- res+RVsT
RESgT <- res+RVgT
RESsgT <- res+RVgsT
plot(jd,RVgT,xlab='JD',ylab='RVgT')
plot(jd,RVsT,xlab='JD',ylab='RVsT')
plot(jd,RVgsT,xlab='JD',ylab='RVgsT')
plot(jd,res,xlab='JD',ylab='Data-Model [m/s]',main=paste0('residual for all;sd=',round(sd(res),2)))
plot(jd,RESsT,xlab='JD',ylab='Data-Model [m/s]',main=paste0('residual for sT;sd=',round(sd(RESsT),2)))
plot(jd,RESgT,xlab='JD',ylab='Data-Model [m/s]',main=paste0('residual for gT;sd=',round(sd(RESgT),2)))
plot(jd,RESsgT,xlab='JD',ylab='Data-Model [m/s]',main=paste0('residual for gsT;sd=',round(sd(RESsgT),2)))
plot(jd,scale(res),xlab='JD',ylab='Data-Model', main='Normalized residual')
points(jd,scale(RESsT),col='red')
points(jd,scale(RESgT),col='blue')
points(jd,scale(RESsgT),col='green')
dev.off()
