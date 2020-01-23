setwd("E:/fund_index_weight/Download_data_for_all_mutual_funds")
source('getstr.R')
origo = read.table(
  file = 'stage1_fund_benchmark_weight_horizontal_monthly20180105.csv',
  header = T,
  sep = ',',
  as.is = T
)

origo[is.na(origo)]=''

temp=as.Date(origo$date)
origo$date=temp
origo1=origo[order(origo$windcode, origo$date),]
origo=origo1

numr=nrow(origo)

for(i in 1:(numr-1)){

if(origo$benchmark[i]==origo$benchmark[i+1]){

temp1=(origo$index1[i]==origo$index1[i+1])
temp2=(origo$index2[i]==origo$index2[i+1])
temp3=(origo$index3[i]==origo$index3[i+1])
temp4=(origo$index4[i]==origo$index4[i+1])
temp5=(origo$index5[i]==origo$index5[i+1])
temp=temp1*temp2*temp3*temp4*temp5
if(!is.na(temp)){

if(temp!=1){

store=origo[i+1,]
newstore=store
for(j in 1:5){

if(origo[i,5*j+7]!=''){
plac=(12:41)[store[12:41]==origo[i,5*j+7]]
if(length(plac)==1){
newstore[5*j+7]=store[plac]
newstore[5*j+8]=store[plac+1]
newstore[5*j+9]=store[plac+2]
newstore[5*j+10]=store[plac+3]
newstore[5*j+11]=store[plac+4]
origo[i+1,]=newstore
}
}

}

}

}

}

}

write.table(origo[,-c(1)],
            file = 'clean_fund_benchmark_weight_horizontal_monthly20180105.csv',
            sep = c(','),
            col.names = NA)


