setwd('f:/fund_index_weight/brinson')

library(haven)

a06=read_sas('brinsonfilled06.sas7bdat')
naid=(a06$reportperiod!='2017年年报')
a06=a06[naid,]

a17=read_sas('brinsonfilled17.sas7bdat')
naid=(a17$reportperiod!='2017年年报')
a17=a17[naid,]

a28=read_sas('brinsonfilled28.sas7bdat')
naid=(a28$reportperiod!='2017年年报')
a28=a28[naid,]

a39=read_sas('brinsonfilled39.sas7bdat')
naid=(a39$reportperiod!='2017年年报')
a39=a39[naid,]

a410=read_sas('brinsonfilled410.sas7bdat')
naid=(a410$reportperiod!='2017年年报')
a410=a410[naid,]

a511=read_sas('brinsonfilled511.sas7bdat')
naid=(a511$reportperiod!='2017年年报')
a511=a511[naid,]

a612=read_sas('brinsonfilled612.sas7bdat')
naid=(a612$reportperiod!='2017年年报')
a612=a612[naid,]

a06=as.matrix(a06[,3:6])
a17=as.matrix(a17[,3:6])
a28=as.matrix(a28[,3:6])
a39=as.matrix(a39[,3:6])
a410=as.matrix(a410[,3:6])
a511=as.matrix(a511[,3:6])
a612=as.matrix(a612[,3:6])

max(abs(a612-a17))
mean(abs(a612-a17))
median(abs(a612-a17))
sd(abs(a612-a17))
quantile(abs(a612-a17),c(0.025,0.975))
apply(abs(a612-a17),2,max)
apply(abs(a612-a17),2,mean)
apply(abs(a612-a17),2,median)
apply(abs(a612-a17),2,sd)
apply(abs(a612-a17),2,function(x) quantile(x,c(0.025,0.975)))

max(abs(a612-a28))
mean(abs(a612-a28))
median(abs(a612-a28))
sd(abs(a612-a28))
quantile(abs(a612-a28),c(0.025,0.975))
apply(abs(a612-a28),2,max)
apply(abs(a612-a28),2,mean)
apply(abs(a612-a28),2,median)
apply(abs(a612-a28),2,sd)
apply(abs(a612-a28),2,function(x) quantile(x,c(0.025,0.975)))

max(abs(a612-a39))
mean(abs(a612-a39))
median(abs(a612-a39))
sd(abs(a612-a39))
quantile(abs(a612-a39),c(0.025,0.975))
apply(abs(a612-a39),2,max)
apply(abs(a612-a39),2,mean)
apply(abs(a612-a39),2,median)
apply(abs(a612-a39),2,sd)
apply(abs(a612-a39),2,function(x) quantile(x,c(0.025,0.975)))

max(abs(a612-a410))
mean(abs(a612-a410))
median(abs(a612-a410))
sd(abs(a612-a410))
quantile(abs(a612-a410),c(0.025,0.975))
apply(abs(a612-a410),2,max)
apply(abs(a612-a410),2,mean)
apply(abs(a612-a410),2,median)
apply(abs(a612-a410),2,sd)
apply(abs(a612-a410),2,function(x) quantile(x,c(0.025,0.975)))

max(abs(a612-a511))
mean(abs(a612-a511))
median(abs(a612-a511))
sd(abs(a612-a511))
quantile(abs(a612-a511),c(0.025,0.975))
t(apply(abs(a612-a511),2,max))
apply(abs(a612-a511),2,mean)
apply(abs(a612-a511),2,median)
apply(abs(a612-a511),2,sd)
apply(abs(a612-a511),2,function(x) quantile(x,c(0.025,0.975)))


t1=rbind(t(apply(abs(a612-a511),2,max)),
      t(apply(abs(a612-a410),2,max)),
      t(apply(abs(a612-a39),2,max)),
      t(apply(abs(a612-a28),2,max)),
      t(apply(abs(a612-a17),2,max)))

t2=rbind(t(apply(abs(a612-a511),2,mean)),
      t(apply(abs(a612-a410),2,mean)),
      t(apply(abs(a612-a39),2,mean)),
      t(apply(abs(a612-a28),2,mean)),
      t(apply(abs(a612-a17),2,mean)))

t3=rbind(t(apply(abs(a612-a511),2,median)),
      t(apply(abs(a612-a410),2,median)),
      t(apply(abs(a612-a39),2,median)),
      t(apply(abs(a612-a28),2,median)),
      t(apply(abs(a612-a17),2,median)))

write.table(t1,'t1.csv', sep=c(','), col.names = NA, row.names = TRUE)
write.table(t2,'t2.csv', sep=c(','), col.names = NA, row.names = TRUE)
write.table(t3,'t3.csv', sep=c(','), col.names = NA, row.names = TRUE)


max((a612-a17))
mean((a612-a17))
median((a612-a17))
sd((a612-a17))
quantile((a612-a17),c(0.025,0.975))
apply((a612-a17),2,max)
apply((a612-a17),2,mean)
apply((a612-a17),2,median)
apply((a612-a17),2,sd)
apply((a612-a17),2,function(x) quantile(x,c(0.025,0.975)))

max((a612-a28))
mean((a612-a28))
median((a612-a28))
sd((a612-a28))
quantile((a612-a28),c(0.025,0.975))
apply((a612-a28),2,max)
apply((a612-a28),2,mean)
apply((a612-a28),2,median)
apply((a612-a28),2,sd)
apply((a612-a28),2,function(x) quantile(x,c(0.025,0.975)))

max((a612-a39))
mean((a612-a39))
median((a612-a39))
sd((a612-a39))
quantile((a612-a39),c(0.025,0.975))
apply((a612-a39),2,max)
apply((a612-a39),2,mean)
apply((a612-a39),2,median)
apply((a612-a39),2,sd)
apply((a612-a39),2,function(x) quantile(x,c(0.025,0.975)))

max((a612-a410))
mean((a612-a410))
median((a612-a410))
sd((a612-a410))
quantile((a612-a410),c(0.025,0.975))
apply((a612-a410),2,max)
apply((a612-a410),2,mean)
apply((a612-a410),2,median)
apply((a612-a410),2,sd)
apply((a612-a410),2,function(x) quantile(x,c(0.025,0.975)))

max((a612-a511))
mean((a612-a511))
median((a612-a511))
sd((a612-a511))
quantile((a612-a511),c(0.025,0.975))
t(apply((a612-a511),2,max))
apply((a612-a511),2,mean)
apply((a612-a511),2,median)
apply((a612-a511),2,sd)
apply((a612-a511),2,function(x) quantile(x,c(0.025,0.975)))


t1=rbind(t(apply((a612-a511),2,max)),
         t(apply((a612-a410),2,max)),
         t(apply((a612-a39),2,max)),
         t(apply((a612-a28),2,max)),
         t(apply((a612-a17),2,max)))

t2=rbind(t(apply((a612-a511),2,mean)),
         t(apply((a612-a410),2,mean)),
         t(apply((a612-a39),2,mean)),
         t(apply((a612-a28),2,mean)),
         t(apply((a612-a17),2,mean)))

t3=rbind(t(apply((a612-a511),2,median)),
         t(apply((a612-a410),2,median)),
         t(apply((a612-a39),2,median)),
         t(apply((a612-a28),2,median)),
         t(apply((a612-a17),2,median)))


