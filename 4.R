setwd("E:/fund_index_weight/Download_data_for_all_mutual_funds")
source('getstr.R')

a=read.table(file='stage1_fund_benchmark_weight_horizontal_monthly20180105.csv',
             header=T, sep=',', as.is = T) 
add_date2=as.Date(a$date,origin="1970-01-01")
keep_indicator=((add_date2<=as.Date("2017-12-31"))&(a$startdate!=''))


add_date1=a$date[keep_indicator]
add_date2=as.Date(add_date1,origin="1970-01-01")
windcode_1=a$windcode[keep_indicator]
add_fund_nav1=a$fundnav[keep_indicator]
add_fund_nav_adj1=a$fundnav_adj[keep_indicator]
fundname_1=a$fundname[keep_indicator]
yiji_1=a$yiji[keep_indicator]
erji_1=a$erji[keep_indicator]
benchmark_1=a$benchmark[keep_indicator]
startdate_1=a$startdate[keep_indicator]
enddate_1=a$enddate[keep_indicator]
index1_1=a$index1[keep_indicator]
add_index1_pri1=a$index1_close[keep_indicator]
name1_1=a$index1_name[keep_indicator]
tax1_1=a$index1_tax[keep_indicator]
weight1_1=a$index1_weight[keep_indicator]
index2_1=a$index2[keep_indicator]
add_index2_pri1=a$index2_close[keep_indicator]
name2_1=a$index2_name[keep_indicator]
tax2_1=a$index2_tax[keep_indicator]
weight2_1=a$index2_weight[keep_indicator]
index3_1=a$index3[keep_indicator]
add_index3_pri1=a$index3_close[keep_indicator]
name3_1=a$index3_name[keep_indicator]
tax3_1=a$index3_tax[keep_indicator]
weight3_1=a$index3_weight[keep_indicator]
index4_1=a$index4[keep_indicator]
add_index4_pri1=a$index4_close[keep_indicator]
name4_1=a$index4_name[keep_indicator]
tax4_1=a$index4_tax[keep_indicator]
weight4_1=a$index4_weight[keep_indicator]
index5_1=a$index5[keep_indicator]
add_index5_pri1=a$index5_close[keep_indicator]
name5_1=a$index5_name[keep_indicator]
tax5_1=a$index5_tax[keep_indicator]
weight5_1=a$index5_weight[keep_indicator]
interest_rate1_1=a$interest_rate1[keep_indicator]
interest_rate2_1=a$interest_rate2[keep_indicator]
interest_rate3_1=a$interest_rate3[keep_indicator]
interest_rate4_1=a$interest_rate4[keep_indicator]
interest_rate5_1=a$interest_rate5[keep_indicator]

enddate_1[enddate_1>as.Date("2017-12-31")]='2017-12-31'

num_row_a=length(windcode_1)


#correct mistakes when downloading data
#if indexi='' then indexi_close='' not copy things in previous close column
#replace '' in enddates with 'jintian'

for(i in 1:num_row_a){

  if(!is.na(add_index1_pri1[i])){
    if(index1_1[i]==''&add_index1_pri1[i]!=''){
      add_index1_pri1[i]=''
    }
  }
  if(!is.na(add_index2_pri1[i])){
    if(index2_1[i]==''&add_index2_pri1[i]!=''){
      add_index2_pri1[i]=''
    }
  }
  if(!is.na(add_index3_pri1[i])){
    if(index3_1[i]==''&add_index3_pri1[i]!=''){
      add_index3_pri1[i]=''
    }
  }
  if(!is.na(add_index4_pri1[i])){
    if(index4_1[i]==''&add_index4_pri1[i]!=''){
      add_index4_pri1[i]=''
    }
  }
  if(!is.na(add_index5_pri1[i])){
    if(index5_1[i]==''&add_index5_pri1[i]!=''){
      add_index5_pri1[i]=''
    }
  }
}





library(WindR)
w.start()



#record_missing_navadj_indicator=is.na(add_fund_nav_adj1)
#record_NaN_item_indicator=(add_fund_nav=='NaN')
#NaN and NA are both regarded as NA
#nav and navadj have the same missing rows
#maxdelay is the maximum num of changes made to every fund
#so far. for instance the maximum of 000166!3.OF is 3

maxdelay=4


record_missing_nav_indicator=is.na(add_fund_nav1)
record_missing_nav_index=
  (1:num_row_a)[record_missing_nav_indicator]

for(i in record_missing_nav_index){ 
  
  repeat_download_=
    w.wsd(windcode_1[i],"nav",add_date2[i],add_date2[i],"Period=M")
  while(repeat_download_$ErrorCode!=0 | is.null(repeat_download_$Data$NAV)){
    repeat_download_=
      w.wsd(windcode_1[i],"nav",add_date2[i],add_date2[i],"Period=M")
  }
  
  
  if(!is.na(repeat_download_$Data$NAV)){
    temp_windcode_nav=repeat_download_
    temp_windcode_nav_adj=
      w.wsd(windcode_1[i],"NAV_adj",add_date2[i],add_date2[i],"Period=M")
    while(temp_windcode_nav_adj$ErrorCode!=0 | 
          is.null(temp_windcode_nav_adj$Data$NAV_ADJ)){
      temp_windcode_nav_adj=
        w.wsd(windcode_1[i],"NAV_adj",add_date2[i],add_date2[i],"Period=M")
    }
    
    add_fund_nav1[i]=temp_windcode_nav$Data$NAV
    add_fund_nav_adj1[i]=temp_windcode_nav_adj$Data$NAV_ADJ
  }
  
  #if any changes happened to the fundname
  #the fundname was updated
  #we need to from 000166.OF to 000166!1.OF

  if(is.na(repeat_download_$Data$NAV)){
    if(length(grep('!',windcode_1[i]))==0){
      
      temp_windcode=paste(
        getstr(windcode_1[i], initial.character='^a\\.', 
               final.character='\\.'),
        "!",1,".",
        getstr(windcode_1[i], initial.character='\\.', final.character='$'),
        sep="")
      
    }
    
    if(length(grep('!',windcode_1[i]))==1){
      
      for(j in 1:maxdelay){
        if(length(grep(paste('!',j,sep=""),windcode_1[i]))==1){
          
          temp_windcode=paste(
            getstr(windcode_1[i], initial.character='^a\\.', 
                   final.character='\\.'),
            "!",j+1,".",
            getstr(windcode_1[i], initial.character='\\.', 
                   final.character='$'),
            sep="")
          
        }
      }
      
    }
    
    temp_windcode_nav=
      w.wsd(temp_windcode,"nav",add_date2[i],add_date2[i],"Period=M")
    while(temp_windcode_nav$ErrorCode!=0 | 
          is.null(temp_windcode_nav$Data$NAV)){
      temp_windcode_nav=
        w.wsd(temp_windcode,"nav",add_date2[i],add_date2[i],"Period=M")
    }
    temp_windcode_nav_adj=
      w.wsd(temp_windcode,"NAV_adj",add_date2[i],add_date2[i],"Period=M")
    while(temp_windcode_nav_adj$ErrorCode!=0 | 
          is.null(temp_windcode_nav_adj$Data$NAV_ADJ)){
      temp_windcode_nav_adj=
        w.wsd(temp_windcode,"NAV_adj",add_date2[i],add_date2[i],"Period=M")
    }
    add_fund_nav1[i]=temp_windcode_nav$Data$NAV
    add_fund_nav_adj1[i]=temp_windcode_nav_adj$Data$NAV_ADJ
    
  }
}



#fill in missing index close prices
#download these as proxy for missing index

wandequanA881001WI=
  w.wsd('881001.WI',"close",min(add_date2),"2017-10-23","Period=D")
while(wandequanA881001WI$ErrorCode!=0){
  wandequanA881001WI=
    w.wsd('881001.WI',"close",min(add_date2),"2017-10-23","Period=D")
}

# write.table(
#   
#   wandequanA881001WI$Data,
#   file='wandequanA881001WI.csv',
#   sep=c(','), col.names = NA
#   
# )
# min(add_date2)#"1990-12-31"
# max(add_date2)#"2020-12-31"

hushen300000300SH=
  w.wsd('000300.SH',"close",min(add_date2),"2017-10-23","Period=D")
while(hushen300000300SH$ErrorCode!=0){
  hushen300000300SH=
    w.wsd('000300.SH',"close",min(add_date2),"2017-10-23","Period=D")
}

# write.table(
#   
#   hushen300000300SH$Data,
#   file='hushen300000300SH.csv',
#   sep=c(','), col.names = NA
#   
# )

zhongzhaicaifu057CS=
  w.wsd('057.CS',"close",min(add_date2),"2017-10-23","Period=D")
while(zhongzhaicaifu057CS$ErrorCode!=0){
  zhongzhaicaifu057CS=
    w.wsd('057.CS',"close",min(add_date2),"2017-10-23","Period=D")
}

# write.table(
#   
#   zhongzhaicaifu057CS$Data,
#   file='zhongzhaicaifu057CS.csv',
#   sep=c(','), col.names = NA
#   
# )



#fill some zhishu so that the missing zhishu close price can be
#substituted with the wandequanA zhishu or zhongzhai caifu zhishu

add_index1_pri1[is.na(add_index1_pri1)]=''
record_missing_close_index1=
  (1:num_row_a)[index1_1!=""&add_index1_pri1==""]

for(i in record_missing_close_index1){
  
  repeat_download_index1=
    w.wsd(index1_1[i],"close",add_date2[i],add_date2[i],"Period=M")
  while(repeat_download_index1$ErrorCode!=0){
    repeat_download_index1=
      w.wsd(index1_1[i],"close",add_date2[i],add_date2[i],"Period=M")
  }
  if(!is.null(repeat_download_index1$Data$CLOSE)){
    add_index1_pri1[i]=repeat_download_index1$Data$CLOSE
    if(is.na(repeat_download_index1$Data$CLOSE)){
      if(yiji_1[i]=="债券型基金"){
        add_index1_pri1[i]=
          zhongzhaicaifu057CS$Data$CLOSE[zhongzhaicaifu057CS$Data$DATETIME==
                                           add_date2[i]]
      }
      if(yiji_1[i]!="债券型基金"){
        add_index1_pri1[i]=
          wandequanA881001WI$Data$CLOSE[wandequanA881001WI$Data$DATETIME==
                                          add_date2[i]]
      }
    }
  }
}

add_index2_pri1[is.na(add_index2_pri1)]=''
record_missing_close_index2=
  (1:num_row_a)[index2_1!=""&add_index2_pri1==""]

for(i in record_missing_close_index2){
  
  repeat_download_index2=
    w.wsd(index2_1[i],"close",add_date2[i],add_date2[i],"Period=M")
  while(repeat_download_index2$ErrorCode!=0){
    repeat_download_index2=
      w.wsd(index2_1[i],"close",add_date2[i],add_date2[i],"Period=M")
  }
  if(!is.null(repeat_download_index2$Data$CLOSE)){
    add_index2_pri1[i]=repeat_download_index2$Data$CLOSE
    if(is.na(repeat_download_index2$Data$CLOSE)){
      if(yiji_1[i]=="债券型基金"){
        add_index2_pri1[i]=
          zhongzhaicaifu057CS$Data$CLOSE[zhongzhaicaifu057CS$Data$DATETIME==
                                           add_date2[i]]
      }
      if(yiji_1[i]!="债券型基金"){
        add_index2_pri1[i]=
          wandequanA881001WI$Data$CLOSE[wandequanA881001WI$Data$DATETIME==
                                          add_date2[i]]
      }
    }
  }
}

add_index3_pri1[is.na(add_index3_pri1)]=''
record_missing_close_index3=
  (1:num_row_a)[index3_1!=""&add_index3_pri1==""]

for(i in record_missing_close_index3){
  
  repeat_download_index3=
    w.wsd(index3_1[i],"close",add_date2[i],add_date2[i],"Period=M")
  while(repeat_download_index3$ErrorCode!=0){
    repeat_download_index3=
      w.wsd(index3_1[i],"close",add_date2[i],add_date2[i],"Period=M")
  }
  if(!is.null(repeat_download_index3$Data$CLOSE)){
    add_index3_pri1[i]=repeat_download_index3$Data$CLOSE
    if(is.na(repeat_download_index3$Data$CLOSE)){
      if(yiji_1[i]=="债券型基金"){
        add_index3_pri1[i]=
          zhongzhaicaifu057CS$Data$CLOSE[zhongzhaicaifu057CS$Data$DATETIME==
                                           add_date2[i]]
      }
      if(yiji_1[i]!="债券型基金"){
        add_index3_pri1[i]=
          wandequanA881001WI$Data$CLOSE[wandequanA881001WI$Data$DATETIME==
                                          add_date2[i]]
      }
    }
  }
}

add_index4_pri1[is.na(add_index4_pri1)]=''
record_missing_close_index4=
  (1:num_row_a)[index4_1!=""&add_index4_pri1==""]

for(i in record_missing_close_index4){
  
  repeat_download_index4=
    w.wsd(index4_1[i],"close",add_date2[i],add_date2[i],"Period=M")
  while(repeat_download_index4$ErrorCode!=0){
    repeat_download_index4=
      w.wsd(index4_1[i],"close",add_date2[i],add_date2[i],"Period=M")
  }
  if(!is.null(repeat_download_index4$Data$CLOSE)){
    add_index4_pri1[i]=repeat_download_index4$Data$CLOSE
    if(is.na(repeat_download_index4$Data$CLOSE)){
      if(yiji_1[i]=="债券型基金"){
        add_index4_pri1[i]=
          zhongzhaicaifu057CS$Data$CLOSE[zhongzhaicaifu057CS$Data$DATETIME==
                                           add_date2[i]]
      }
      if(yiji_1[i]!="债券型基金"){
        add_index4_pri1[i]=
          wandequanA881001WI$Data$CLOSE[wandequanA881001WI$Data$DATETIME==
                                          add_date2[i]]
      }
    }
  }
}

add_index5_pri1[is.na(add_index5_pri1)]=''
record_missing_close_index5=
  (1:num_row_a)[index5_1!=""&add_index5_pri1==""]

for(i in record_missing_close_index5){
  
  repeat_download_index5=
    w.wsd(index5_1[i],"close",add_date2[i],add_date2[i],"Period=M")
  while(repeat_download_index5$ErrorCode!=0){
    repeat_download_index5=
      w.wsd(index5_1[i],"close",add_date2[i],add_date2[i],"Period=M")
  }
  if(!is.null(repeat_download_index5$Data$CLOSE)){
    add_index5_pri1[i]=repeat_download_index5$Data$CLOSE
    if(is.na(repeat_download_index5$Data$CLOSE)){
      if(yiji_1[i]=="债券型基金"){
        add_index5_pri1[i]=
          zhongzhaicaifu057CS$Data$CLOSE[zhongzhaicaifu057CS$Data$DATETIME==
                                           add_date2[i]]
      }
      if(yiji_1[i]!="债券型基金"){
        add_index5_pri1[i]=
          wandequanA881001WI$Data$CLOSE[wandequanA881001WI$Data$DATETIME==
                                          add_date2[i]]
      }
    }
  }
}

add_fund_nav1[is.na(add_fund_nav1)]=''
add_fund_nav_adj1[is.na(add_fund_nav_adj1)]=''
enddate_1[is.na(enddate_1)]=''
add_index2_pri1[is.na(add_index2_pri1)]=''
weight2_1[is.na(weight2_1)]=''
add_index3_pri1[is.na(add_index3_pri1)]=''
weight3_1[is.na(weight3_1)]=''
add_index4_pri1[is.na(add_index4_pri1)]=''
weight4_1[is.na(weight4_1)]=''
add_index5_pri1[is.na(add_index5_pri1)]=''
weight5_1[is.na(weight5_1)]=''



output_data=data.frame(date=add_date2,
                       windcode=windcode_1,
                       fundnav=add_fund_nav1,
                       fundnav_adj=add_fund_nav_adj1,
                       fundname=fundname_1,
                       yiji=yiji_1,
                       erji=erji_1,
                       benchmark=benchmark_1,
                       startdate=startdate_1,
                       enddate=enddate_1,
                       index1=index1_1,
                       index1_close=add_index1_pri1,
                       index1_name=name1_1,
                       index1_tax=tax1_1,
                       index1_weight=weight1_1,
                       interest_rate1=interest_rate1_1,
                       index2=index2_1,
                       index2_close=add_index2_pri1,
                       index2_name=name2_1,
                       index2_tax=tax2_1,
                       index2_weight=weight2_1,
                       interest_rate2=interest_rate2_1,
                       index3=index3_1,
                       index3_close=add_index3_pri1,
                       index3_name=name3_1,
                       index3_tax=tax3_1,
                       index3_weight=weight3_1,
                       interest_rate3=interest_rate3_1,
                       index4=index4_1,
                       index4_close=add_index4_pri1,
                       index4_name=name4_1,
                       index4_tax=tax4_1,
                       index4_weight=weight4_1,
                       interest_rate4=interest_rate4_1,
                       index5=index5_1,
                       index5_close=add_index5_pri1,
                       index5_name=name5_1,
                       index5_tax=tax5_1,
                       index5_weight=weight5_1,
                       interest_rate5=interest_rate5_1)



write.table(output_data, 
            file='clean_fund_benchmark_weight_horizontal_monthly20180105.csv',
            sep=c(','), col.names = NA)

sum(is.na(add_index1_pri1))
sum(add_index1_pri1=='')
sum(is.na(add_index2_pri1))
sum(add_index2_pri1=='')
sum(is.na(add_index3_pri1))
sum(add_index3_pri1=='')
sum(is.na(add_index4_pri1))
sum(add_index4_pri1=='')
sum(is.na(add_index5_pri1))
sum(add_index5_pri1=='')
sum(is.na(add_fund_nav1))
sum(is.na(add_fund_nav1))/num_row_a
sum(add_fund_nav1=='')
sum(add_fund_nav1=='')/num_row_a
sum(is.na(add_fund_nav_adj1))
sum(is.na(add_fund_nav_adj1))/num_row_a
sum(add_fund_nav_adj1=='')
sum(add_fund_nav_adj1=='',na.rm=T)/num_row_a



































