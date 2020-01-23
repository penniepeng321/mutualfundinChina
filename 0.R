#grep A B C from fund name

setwd("E:/fund_index_weight/Download_data_for_all_mutual_funds")
source('getstr.R')

#Input:fund name, start date, end date
#Output:keep or drop indicator

# ABC_screening=function(fundname,windcode,startdate,enddate){
#
# marker=read.table(file='fund_fullname.csv',
#              header=T, sep=',', as.is = T)
#
# code=marker$证券代码
# fullname=marker$基金全称
#
# nnn=length(fundname)
# fund_fullname=rep('q',nnn)
#
# for(i in 1:nnn){
#
# temp00=(code==windcode[i])
#
# if(sum(temp00)==1){
#
# fund_fullname[i]=fullname[temp00]
#
# }
#
# }
#
# timelength=as.numeric(as.Date(enddate)-as.Date(startdate))
#
# unique_fundname=unique(fund_fullname)
# mmm=length(unique_fundname)
#
# out_indicator=rep(TRUE,nnn)
#
# for(i in 1:mmm){
#
# temp0=(fund_fullname==unique_fundname[i])
# if(sum(temp0)>1){
#
# temp1=(1:nnn)[temp0]
# temp2=which.max(timelength[temp0])
# if(length(temp2)>1){ #if same time length, keep the first one
#
# temp2=temp2[1]
#
# }
#
# out_indicator[temp1[-temp2]]=FALSE
#
# }
#
# }
# out_indicator[fund_fullname=='q']=FALSE
#
# return(out_indicator)
#
# }


#test
# a=read.table(file='mutualfundbasic_20171204.csv',
#              header=T, sep=',', as.is = T)
# a$基金到期日[a$基金到期日=='']='2017-12-04' #put here download date
#
# indicator0=ABC_screening(a$证券简称,a$证券代码,a$基金成立日,a$基金到期日)
# a=a[indicator0,]

library(haven)
a = read_sas('mutualbasic_adjustabc.sas7bdat')

b = read.table(
  file = 'clean_fund_benchmark_weight_horizontal_monthly20170824.csv',
  header = T,
  sep = ',',
  as.is = T
)
b$enddate[b$enddate == 'today'] = '2017-08-24' #put here download date

xxx = nrow(b)
keep_indicator = rep(TRUE, xxx)
for (i in 1:xxx) {
  temp = (a$windcode == b$windcode[i])
  if (sum(temp) == 0) {
    keep_indicator[i] = FALSE
  }
  
}

b = b[keep_indicator, -c(1, 2)]
b$index1_close[is.na(b$index1_close)] = ''
b$index2_close[is.na(b$index2_close)] = ''
b$index3_close[is.na(b$index3_close)] = ''
b$index4_close[is.na(b$index4_close)] = ''
b$index5_close[is.na(b$index5_close)] = ''
b$index1_tax[is.na(b$index1_tax)] = 0
b$index2_tax[is.na(b$index2_tax)] = 0
b$index3_tax[is.na(b$index3_tax)] = 0
b$index4_tax[is.na(b$index4_tax)] = 0
b$index5_tax[is.na(b$index5_tax)] = 0
b$index1_weight[is.na(b$index1_weight)] = ''
b$index2_weight[is.na(b$index2_weight)] = ''
b$index3_weight[is.na(b$index3_weight)] = ''
b$index4_weight[is.na(b$index4_weight)] = ''
b$index5_weight[is.na(b$index5_weight)] = ''


write.table(b,
            file = 'clean_fund_benchmark_weight_horizontal_monthly20170824_adjustabc.csv',
            sep = c(','),
            col.names = NA)
