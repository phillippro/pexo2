dvar <- 10
ParFit <- ParIni
rate10 <- update_NumDerivBary(utc,ParAll,ParFit,drTel=dvar,drGeo=dvar,dvGeo=dvar)
dvar <- 5
rate5 <- update_NumDerivBary(utc,ParAll,ParFit,drTel=dvar,drGeo=dvar,dvGeo=dvar)
dvar <- 2
rate2 <- update_NumDerivBary(utc,ParAll,ParFit,drTel=dvar,drGeo=dvar,dvGeo=dvar)
dvar <- 1
rate1 <- update_NumDerivBary(utc,ParAll,ParFit,drTel=dvar,drGeo=dvar,dvGeo=dvar)
dvar <- 0.1
rate01 <- update_NumDerivBary(utc,ParAll,ParFit,drTel=dvar,drGeo=dvar,dvGeo=dvar)
dvar <- 0.01
rate001 <- update_NumDerivBary(utc,ParAll,ParFit,drTel=dvar,drGeo=dvar,dvGeo=dvar)
dvar <- 0.001
rate0001 <- update_NumDerivBary(utc,ParAll,ParFit,drTel=dvar,drGeo=dvar,dvGeo=dvar)


ind <- grep('geoOff|telOff',Par$ParName)
vars <- Par$ParName[ind]
#VarTest <- 'dTCB.dTT'
VarTest <- 'SG'
for(var in vars){
if(!is.null(dim(rate10[[var]][[VarTest]]))){
r10 <- rate10[[var]][[VarTest]][1,]
r5 <- rate5[[var]][[VarTest]][1,]
r2 <- rate1[[var]][[VarTest]][1,]
r1 <- rate1[[var]][[VarTest]][1,]
r01 <- rate01[[var]][[VarTest]][1,]
r001 <- rate001[[var]][[VarTest]][1,]
r0001 <- rate0001[[var]][[VarTest]][1,]
}else{
r10 <- rate10[[var]][[VarTest]][1]
r5 <- rate5[[var]][[VarTest]][1]
r2 <- rate1[[var]][[VarTest]][1]
r1 <- rate1[[var]][[VarTest]][1]
r01 <- rate01[[var]][[VarTest]][1]
r001 <- rate001[[var]][[VarTest]][1]
r0001 <- rate0001[[var]][[VarTest]][1]
}
cat('\nvar:',var,'\n')
cat('r10=',r10,'\n')
cat('r5=',r5,'\n')
cat('r2=',r2,'\n')
cat('r1=',r1,'\n')
cat('r01=',r01,'\n')
cat('r001=',r001,'\n')
cat('r0001=',r0001,'\n')
}
