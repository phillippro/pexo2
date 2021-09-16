t0 <- proc.time()
Ntry <- 100
star <- 'HD128620'
type <- 'rv'
ParNew <- Par
for(i in 1:Ntry){
     fit <- time_Ta2te(OutObs[[star]][[type]],ParNew,fit=TRUE,OutTime0=OutTime0[[star]][[type]])
}
t1 <- fit_TimeCount(t0,'dur1',ofac=Ntry)
