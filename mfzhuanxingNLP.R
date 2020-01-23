#提取转型notes里面的转型日期、转型前代码、转型后代码、转型前类型、转型后类型

setwd('F:/中国公募基金基本信息下载')

dbase = read.table(
  file = 'mfzhuanxing.csv',
  header = T,
  sep = ',',
  as.is = T
)

str(dbase)

source('F:/fund_index_weight/Download_data_for_all_mutual_funds/getstr.R')

#install.packages('lubridate')

indi=(dbase$notes!="")
dbase1=dbase[indi,]

str(dbase1)

numrow=nrow(dbase1)

addl=data.frame()

for (i in 1:numrow) {

if(length(grep('；',dbase1$notes[i]))!=0){
tr1=strsplit(dbase1$notes[i],'；')
tr1=tr1[[1]]
}
if(length(grep('；',dbase1$notes[i]))==0){
tr1=dbase1$notes[i]
}

nt=length(tr1)
zxrq=rep("",nt)
zxq_cdnm=rep("",nt)
zxq_cd=rep("",nt)
zxq_nm=rep("",nt)
zxh_cdnm=rep("",nt)
zxh_cd=rep("",nt)
zxh_nm=rep("",nt)
zxq_lx=rep("",nt)
zxh_lx=rep("",nt)

for(j in 1:nt){
zxrq[j]=getstr(tr1[j],initial.character='^a\\.',final.character='\\s+')
#regular expression '^a\\.' from start including start
#'*' from start excluding start, '\\s+' space
year=substr(zxrq[j],1,4)
month=substr(zxrq[j],5,6)
day=substr(zxrq[j],7,8)
zxrq[j]=paste(year,month,day,sep='-')
zxq_cdnm[j]=getstr(tr1[j],initial.character='\\s+',final.character='转型为')
tr2=strsplit(tr1[j],'转型为')
tr2=tr2[[1]]
tr3=strsplit(tr2[2],'，转型类别为')
tr3=tr3[[1]]
zxh_cdnm[j]=tr3[1]
tr4=strsplit(tr3[2],'转')
tr4=tr4[[1]]
zxq_lx[j]=tr4[1]
zxh_lx[j]=tr4[2]
zxq_cd[j]=gsub('[^a-zA-Z0-9.!]','',zxq_cdnm[j])
#正则匹配中文汉字根据页面编码不同而略有区别：
#GBK/GB2312编码：[x80-xff>]+ 或 [xa1-xff]+
#UTF-8编码：[x{4e00}-x{9fa5}]+/u
#将所有非字母数字替换成''得到的字符串 [^a-zA-Z0-9] 只剩下字母数字
#将所有字母数字替换成''得到的字符串 [a-zA-Z0-9] 只剩下汉字和标点符号
#标点符号：[.,\"\\?!:']
#所有字母数字和标点-点.和标点感叹号!：[a-zA-Z0-9.!]
zxq_nm[j]=gsub('[a-zA-Z0-9.!]','',zxq_cdnm[j])
zxh_cd[j]=gsub('[^a-zA-Z0-9.!]','',zxh_cdnm[j])
zxh_nm[j]=gsub('[a-zA-Z0-9.!]','',zxh_cdnm[j])
}

addl1=data.frame(zxrq=zxrq,zxq_cdnm=zxq_cdnm,zxh_cdnm=zxh_cdnm,
			zxq_cd=zxq_cd,zxq_nm=zxq_nm,
			zxh_cd=zxh_cd,zxh_nm=zxh_nm,
			zxq_lx=zxq_lx,zxh_lx=zxh_lx)

addl=rbind(addl,addl1)
}

write.table(
  addl,
  file = 'mfzhuanxingsummary.csv',
  sep = c(','),
  col.names = NA
)



