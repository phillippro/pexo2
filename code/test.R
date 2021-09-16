fit <- fit_LogLike(Data,OutObs,RateObs=RateObs,ParFit=ParOpt,Par=Par,OutTime0=OutTime0,TimeUpdate=TRUE)
model <- fit$model
llmax <- round(fit$llike)
##model prediction
tmp <- fit_ModelPredict(Data,Par,ParOpt)
pred <- tmp$pred
pdf('test.pdf')
  index <- inds[Data[inds,'instrument']==instr]
        plot(Data[index,2],Data[index,4],xlab='ra*',ylab='dec',main=paste(instr,'relative astrometry'),xlim=range(model[index,2],Data[index,2]),ylim=range(model[index,4],Data[index,4]))
        points(model[index,2],model[index,4],col='red')
dev.off()