setwd("E:/fund_index_weight/Download_data_for_all_mutual_funds")
source('getstr.R')

arrangeintrate = function(date, intrate) {
  date_int = as.integer(date)
  startdate_int = min(date_int)
  
  enddate_int = as.integer(as.Date("2021-01-01"))
  
  cont_dates = c(startdate_int:enddate_int)
  
  cont_dates_time = as.Date(cont_dates, origin = "1970-01-01")
  len_date = length(cont_dates)
  cont_intrate = rep(NA, len_date)
  count = 1
  
  #this loop is to fill in the gaps of days between the interest rates
  #report days
  
  for (i in 1:len_date) {
    if (as.integer(date[count]) <= cont_dates[i] &
        as.integer(date[count + 1]) > cont_dates[i]) {
      cont_intrate[i] = intrate[count]
    }
    if (as.integer(date[count + 1]) == cont_dates[i]) {
      count = count + 1
      cont_intrate[i] = intrate[count]
    }
  }
  data.frame(date = cont_dates_time, interest_rate = cont_intrate)
}


a = read.table(
  file = 'fund_benchmark_weight_horizontal_monthly20180105.csv',
  header = T,
  sep = ',',
  as.is = T
)

add_date1 = a$date[-1]
windcode_1 = a$windcode[-1]
add_fund_nav1 = a$fundnav[-1]
add_fund_nav_adj1 = a$fundnav_adj[-1]
fundname_1 = a$fundname[-1]
yiji_1 = a$yiji[-1]
erji_1 = a$erji[-1]
benchmark_1 = a$benchmark[-1]
startdate_1 = a$startdate[-1]
enddate_1 = a$enddate[-1]
index1_1 = a$index1[-1]
add_index1_pri1 = a$index1_close[-1]
name1_1 = a$index1_name[-1]
tax1_1 = a$index1_tax[-1]
weight1_1 = a$index1_weight[-1]
index2_1 = a$index2[-1]
add_index2_pri1 = a$index2_close[-1]
name2_1 = a$index2_name[-1]
tax2_1 = a$index2_tax[-1]
weight2_1 = a$index2_weight[-1]
index3_1 = a$index3[-1]
add_index3_pri1 = a$index3_close[-1]
name3_1 = a$index3_name[-1]
tax3_1 = a$index3_tax[-1]
weight3_1 = a$index3_weight[-1]
index4_1 = a$index4[-1]
add_index4_pri1 = a$index4_close[-1]
name4_1 = a$index4_name[-1]
tax4_1 = a$index4_tax[-1]
weight4_1 = a$index4_weight[-1]
index5_1 = a$index5[-1]
add_index5_pri1 = a$index5_close[-1]
name5_1 = a$index5_name[-1]
tax5_1 = a$index5_tax[-1]
weight5_1 = a$index5_weight[-1]

temp = as.numeric(add_date1)
cutoff = min((1:length(temp))[is.na(temp)])
#30212 entries downloaded from Oct to Dec cost 30M data...
#30212: are dates
#before it are num times

temp1 = as.Date(temp[1:(cutoff - 1)], origin = "1970-01-01")


temp10 = as.Date(add_date1[cutoff:length(add_date1)], "%Y/%m/%d")

add_date2 = c(temp1, temp10)

temp2 = as.Date(enddate_1[1:(cutoff - 1)], "%Y/%m/%d")

temp20 = as.Date(enddate_1[cutoff:length(enddate_1)])

enddate_1 = c(temp2, temp20)

temp30 = as.Date(startdate_1, "%Y/%m/%d")

startdate_1 = temp30

enddate_1[enddate_1 == as.Date("2017-08-24")] = as.Date("2017-12-05")

nnn = nrow(a) - 1
interest_rate1 = rep(0, nnn)
interest_rate2 = rep(0, nnn)
interest_rate3 = rep(0, nnn)
interest_rate4 = rep(0, nnn)
interest_rate5 = rep(0, nnn)

#read in downloaded data of interest rates
#cleaned by adding last day as of today 2017-10-18
#after combining time series and delete duplicate ways by hand


M0071614 = read.table(
  file = 'M0071614.csv',
  header = F,
  sep = ',',
  as.is = T,
  colClasses = c("Date", "numeric")
)

temp = arrangeintrate(M0071614$V1, M0071614$V2)
write.table(temp,
            file = 'M0071614_filled.csv',
            sep = c(','),
            col.names = NA)



num_row_a = length(add_date2)

temp1 = (index1_1 == 'M0071614')
temp1_1 = (1:num_row_a)[temp1]
for (j in temp1_1) {
  interest_rate1[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp2 = (index2_1 == 'M0071614')
temp2_1 = (1:num_row_a)[temp2]
for (j in temp2_1) {
  interest_rate2[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp3 = (index3_1 == 'M0071614')
temp3_1 = (1:num_row_a)[temp3]
for (j in temp3_1) {
  interest_rate3[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp4 = (index4_1 == 'M0071614')
temp4_1 = (1:num_row_a)[temp4]
for (j in temp4_1) {
  interest_rate4[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp5 = (index5_1 == 'M0071614')
temp5_1 = (1:num_row_a)[temp5]
for (j in temp5_1) {
  interest_rate5[j] = temp$interest_rate[temp$date == add_date2[j]]
}







HKDIBO3M = read.table(
  file = 'HKDIBO3M.csv',
  header = F,
  sep = ',',
  as.is = T,
  colClasses = c("Date", "numeric")
)

temp = arrangeintrate(HKDIBO3M$V1, HKDIBO3M$V2)
write.table(temp,
            file = 'HKDIBO3M_filled.csv',
            sep = c(','),
            col.names = NA)



temp1 = (index1_1 == 'HKDIBO3M')
temp1_1 = (1:num_row_a)[temp1]
for (j in temp1_1) {
  interest_rate1[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp2 = (index2_1 == 'HKDIBO3M')
temp2_1 = (1:num_row_a)[temp2]
for (j in temp2_1) {
  interest_rate2[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp3 = (index3_1 == 'HKDIBO3M')
temp3_1 = (1:num_row_a)[temp3]
for (j in temp3_1) {
  interest_rate3[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp4 = (index4_1 == 'HKDIBO3M')
temp4_1 = (1:num_row_a)[temp4]
for (j in temp4_1) {
  interest_rate4[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp5 = (index5_1 == 'HKDIBO3M')
temp5_1 = (1:num_row_a)[temp5]
for (j in temp5_1) {
  interest_rate5[j] = temp$interest_rate[temp$date == add_date2[j]]
}






IBDEPO120 = read.table(
  file = 'IBDEPO120.csv',
  header = F,
  sep = ',',
  as.is = T,
  colClasses = c("Date", "numeric")
)

temp = arrangeintrate(IBDEPO120$V1, IBDEPO120$V2)
write.table(temp,
            file = 'IBDEPO120_filled.csv',
            sep = c(','),
            col.names = NA)


temp1 = (index1_1 == 'IBDEPO120')
temp1_1 = (1:num_row_a)[temp1]
for (j in temp1_1) {
  interest_rate1[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp2 = (index2_1 == 'IBDEPO120')
temp2_1 = (1:num_row_a)[temp2]
for (j in temp2_1) {
  interest_rate2[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp3 = (index3_1 == 'IBDEPO120')
temp3_1 = (1:num_row_a)[temp3]
for (j in temp3_1) {
  interest_rate3[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp4 = (index4_1 == 'IBDEPO120')
temp4_1 = (1:num_row_a)[temp4]
for (j in temp4_1) {
  interest_rate4[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp5 = (index5_1 == 'IBDEPO120')
temp5_1 = (1:num_row_a)[temp5]
for (j in temp5_1) {
  interest_rate5[j] = temp$interest_rate[temp$date == add_date2[j]]
}









M0017142 = read.table(
  file = 'M0017142.csv',
  header = F,
  sep = ',',
  as.is = T,
  colClasses = c("Date", "numeric")
)

temp = arrangeintrate(M0017142$V1, M0017142$V2)
write.table(temp,
            file = 'M0017142_filled.csv',
            sep = c(','),
            col.names = NA)



temp1 = (index1_1 == 'M0017142')
temp1_1 = (1:num_row_a)[temp1]
for (j in temp1_1) {
  interest_rate1[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp2 = (index2_1 == 'M0017142')
temp2_1 = (1:num_row_a)[temp2]
for (j in temp2_1) {
  interest_rate2[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp3 = (index3_1 == 'M0017142')
temp3_1 = (1:num_row_a)[temp3]
for (j in temp3_1) {
  interest_rate3[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp4 = (index4_1 == 'M0017142')
temp4_1 = (1:num_row_a)[temp4]
for (j in temp4_1) {
  interest_rate4[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp5 = (index5_1 == 'M0017142')
temp5_1 = (1:num_row_a)[temp5]
for (j in temp5_1) {
  interest_rate5[j] = temp$interest_rate[temp$date == add_date2[j]]
}






M0017141 = read.table(
  file = 'M0017141.csv',
  header = F,
  sep = ',',
  as.is = T,
  colClasses = c("Date", "numeric")
)

temp = arrangeintrate(M0017141$V1, M0017141$V2)
write.table(temp,
            file = 'M0017141_filled.csv',
            sep = c(','),
            col.names = NA)



temp1 = (index1_1 == 'M0017141')
temp1_1 = (1:num_row_a)[temp1]
for (j in temp1_1) {
  interest_rate1[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp2 = (index2_1 == 'M0017141')
temp2_1 = (1:num_row_a)[temp2]
for (j in temp2_1) {
  interest_rate2[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp3 = (index3_1 == 'M0017141')
temp3_1 = (1:num_row_a)[temp3]
for (j in temp3_1) {
  interest_rate3[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp4 = (index4_1 == 'M0017141')
temp4_1 = (1:num_row_a)[temp4]
for (j in temp4_1) {
  interest_rate4[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp5 = (index5_1 == 'M0017141')
temp5_1 = (1:num_row_a)[temp5]
for (j in temp5_1) {
  interest_rate5[j] = temp$interest_rate[temp$date == add_date2[j]]
}






M0010190 = read.table(
  file = 'M0010190.csv',
  header = F,
  sep = ',',
  as.is = T,
  colClasses = c("Date", "numeric")
)

temp = arrangeintrate(M0010190$V1, M0010190$V2)
write.table(temp,
            file = 'M0010190_filled.csv',
            sep = c(','),
            col.names = NA)


temp1 = (index1_1 == 'M0010190')
temp1_1 = (1:num_row_a)[temp1]
for (j in temp1_1) {
  interest_rate1[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp2 = (index2_1 == 'M0010190')
temp2_1 = (1:num_row_a)[temp2]
for (j in temp2_1) {
  interest_rate2[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp3 = (index3_1 == 'M0010190')
temp3_1 = (1:num_row_a)[temp3]
for (j in temp3_1) {
  interest_rate3[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp4 = (index4_1 == 'M0010190')
temp4_1 = (1:num_row_a)[temp4]
for (j in temp4_1) {
  interest_rate4[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp5 = (index5_1 == 'M0010190')
temp5_1 = (1:num_row_a)[temp5]
for (j in temp5_1) {
  interest_rate5[j] = temp$interest_rate[temp$date == add_date2[j]]
}







M0009811 = read.table(
  file = 'M0009811.csv',
  header = F,
  sep = ',',
  as.is = T,
  colClasses = c("Date", "numeric")
)

temp = arrangeintrate(M0009811$V1, M0009811$V2)
write.table(temp,
            file = 'M0009811_filled.csv',
            sep = c(','),
            col.names = NA)



temp1 = (index1_1 == 'M0009811')
temp1_1 = (1:num_row_a)[temp1]
for (j in temp1_1) {
  interest_rate1[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp2 = (index2_1 == 'M0009811')
temp2_1 = (1:num_row_a)[temp2]
for (j in temp2_1) {
  interest_rate2[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp3 = (index3_1 == 'M0009811')
temp3_1 = (1:num_row_a)[temp3]
for (j in temp3_1) {
  interest_rate3[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp4 = (index4_1 == 'M0009811')
temp4_1 = (1:num_row_a)[temp4]
for (j in temp4_1) {
  interest_rate4[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp5 = (index5_1 == 'M0009811')
temp5_1 = (1:num_row_a)[temp5]
for (j in temp5_1) {
  interest_rate5[j] = temp$interest_rate[temp$date == add_date2[j]]
}






M0041348 = read.table(
  file = 'M0041348.csv',
  header = F,
  sep = ',',
  as.is = T,
  colClasses = c("Date", "numeric")
)

temp = arrangeintrate(M0041348$V1, M0041348$V2)
write.table(temp,
            file = 'M0041348_filled.csv',
            sep = c(','),
            col.names = NA)


temp1 = (index1_1 == 'M0041348')
temp1_1 = (1:num_row_a)[temp1]
for (j in temp1_1) {
  interest_rate1[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp2 = (index2_1 == 'M0041348')
temp2_1 = (1:num_row_a)[temp2]
for (j in temp2_1) {
  interest_rate2[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp3 = (index3_1 == 'M0041348')
temp3_1 = (1:num_row_a)[temp3]
for (j in temp3_1) {
  interest_rate3[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp4 = (index4_1 == 'M0041348')
temp4_1 = (1:num_row_a)[temp4]
for (j in temp4_1) {
  interest_rate4[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp5 = (index5_1 == 'M0041348')
temp5_1 = (1:num_row_a)[temp5]
for (j in temp5_1) {
  interest_rate5[j] = temp$interest_rate[temp$date == add_date2[j]]
}






M0009810 = read.table(
  file = 'M0009810.csv',
  header = F,
  sep = ',',
  as.is = T,
  colClasses = c("Date", "numeric")
)

temp = arrangeintrate(M0009810$V1, M0009810$V2)
write.table(temp,
            file = 'M0009810_filled.csv',
            sep = c(','),
            col.names = NA)


temp1 = (index1_1 == 'M0009810')
temp1_1 = (1:num_row_a)[temp1]
for (j in temp1_1) {
  interest_rate1[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp2 = (index2_1 == 'M0009810')
temp2_1 = (1:num_row_a)[temp2]
for (j in temp2_1) {
  interest_rate2[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp3 = (index3_1 == 'M0009810')
temp3_1 = (1:num_row_a)[temp3]
for (j in temp3_1) {
  interest_rate3[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp4 = (index4_1 == 'M0009810')
temp4_1 = (1:num_row_a)[temp4]
for (j in temp4_1) {
  interest_rate4[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp5 = (index5_1 == 'M0009810')
temp5_1 = (1:num_row_a)[temp5]
for (j in temp5_1) {
  interest_rate5[j] = temp$interest_rate[temp$date == add_date2[j]]
}






M0009809 = read.table(
  file = 'M0009809.csv',
  header = F,
  sep = ',',
  as.is = T,
  colClasses = c("Date", "numeric")
)

temp = arrangeintrate(M0009809$V1, M0009809$V2)
write.table(temp,
            file = 'M0009809_filled.csv',
            sep = c(','),
            col.names = NA)


temp1 = (index1_1 == 'M0009809')
temp1_1 = (1:num_row_a)[temp1]
for (j in temp1_1) {
  interest_rate1[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp2 = (index2_1 == 'M0009809')
temp2_1 = (1:num_row_a)[temp2]
for (j in temp2_1) {
  interest_rate2[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp3 = (index3_1 == 'M0009809')
temp3_1 = (1:num_row_a)[temp3]
for (j in temp3_1) {
  interest_rate3[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp4 = (index4_1 == 'M0009809')
temp4_1 = (1:num_row_a)[temp4]
for (j in temp4_1) {
  interest_rate4[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp5 = (index5_1 == 'M0009809')
temp5_1 = (1:num_row_a)[temp5]
for (j in temp5_1) {
  interest_rate5[j] = temp$interest_rate[temp$date == add_date2[j]]
}







M0009808 = read.table(
  file = 'M0009808.csv',
  header = F,
  sep = ',',
  as.is = T,
  colClasses = c("Date", "numeric")
)

temp = arrangeintrate(M0009808$V1, M0009808$V2)
write.table(temp,
            file = 'M0009808_filled.csv',
            sep = c(','),
            col.names = NA)


temp1 = (index1_1 == 'M0009808')
temp1_1 = (1:num_row_a)[temp1]
for (j in temp1_1) {
  interest_rate1[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp2 = (index2_1 == 'M0009808')
temp2_1 = (1:num_row_a)[temp2]
for (j in temp2_1) {
  interest_rate2[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp3 = (index3_1 == 'M0009808')
temp3_1 = (1:num_row_a)[temp3]
for (j in temp3_1) {
  interest_rate3[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp4 = (index4_1 == 'M0009808')
temp4_1 = (1:num_row_a)[temp4]
for (j in temp4_1) {
  interest_rate4[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp5 = (index5_1 == 'M0009808')
temp5_1 = (1:num_row_a)[temp5]
for (j in temp5_1) {
  interest_rate5[j] = temp$interest_rate[temp$date == add_date2[j]]
}






M0009807 = read.table(
  file = 'M0009807.csv',
  header = F,
  sep = ',',
  as.is = T,
  colClasses = c("Date", "numeric")
)

temp = arrangeintrate(M0009807$V1, M0009807$V2)
write.table(temp,
            file = 'M0009807_filled.csv',
            sep = c(','),
            col.names = NA)


temp1 = (index1_1 == 'M0009807')
temp1_1 = (1:num_row_a)[temp1]
for (j in temp1_1) {
  interest_rate1[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp2 = (index2_1 == 'M0009807')
temp2_1 = (1:num_row_a)[temp2]
for (j in temp2_1) {
  interest_rate2[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp3 = (index3_1 == 'M0009807')
temp3_1 = (1:num_row_a)[temp3]
for (j in temp3_1) {
  interest_rate3[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp4 = (index4_1 == 'M0009807')
temp4_1 = (1:num_row_a)[temp4]
for (j in temp4_1) {
  interest_rate4[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp5 = (index5_1 == 'M0009807')
temp5_1 = (1:num_row_a)[temp5]
for (j in temp5_1) {
  interest_rate5[j] = temp$interest_rate[temp$date == add_date2[j]]
}





M0009806 = read.table(
  file = 'M0009806.csv',
  header = F,
  sep = ',',
  as.is = T,
  colClasses = c("Date", "numeric")
)

temp = arrangeintrate(M0009806$V1, M0009806$V2)
write.table(temp,
            file = 'M0009806_filled.csv',
            sep = c(','),
            col.names = NA)


temp1 = (index1_1 == 'M0009806')
temp1_1 = (1:num_row_a)[temp1]
for (j in temp1_1) {
  interest_rate1[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp2 = (index2_1 == 'M0009806')
temp2_1 = (1:num_row_a)[temp2]
for (j in temp2_1) {
  interest_rate2[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp3 = (index3_1 == 'M0009806')
temp3_1 = (1:num_row_a)[temp3]
for (j in temp3_1) {
  interest_rate3[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp4 = (index4_1 == 'M0009806')
temp4_1 = (1:num_row_a)[temp4]
for (j in temp4_1) {
  interest_rate4[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp5 = (index5_1 == 'M0009806')
temp5_1 = (1:num_row_a)[temp5]
for (j in temp5_1) {
  interest_rate5[j] = temp$interest_rate[temp$date == add_date2[j]]
}






M0009805 = read.table(
  file = 'M0009805.csv',
  header = F,
  sep = ',',
  as.is = T,
  colClasses = c("Date", "numeric")
)

temp = arrangeintrate(M0009805$V1, M0009805$V2)
write.table(temp,
            file = 'M0009805_filled.csv',
            sep = c(','),
            col.names = NA)


temp1 = (index1_1 == 'M0009805')
temp1_1 = (1:num_row_a)[temp1]
for (j in temp1_1) {
  interest_rate1[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp2 = (index2_1 == 'M0009805')
temp2_1 = (1:num_row_a)[temp2]
for (j in temp2_1) {
  interest_rate2[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp3 = (index3_1 == 'M0009805')
temp3_1 = (1:num_row_a)[temp3]
for (j in temp3_1) {
  interest_rate3[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp4 = (index4_1 == 'M0009805')
temp4_1 = (1:num_row_a)[temp4]
for (j in temp4_1) {
  interest_rate4[j] = temp$interest_rate[temp$date == add_date2[j]]
}
temp5 = (index5_1 == 'M0009805')
temp5_1 = (1:num_row_a)[temp5]
for (j in temp5_1) {
  interest_rate5[j] = temp$interest_rate[temp$date == add_date2[j]]
}


interest_rate1 = as.numeric(interest_rate1) / 100
interest_rate2 = as.numeric(interest_rate2) / 100
interest_rate3 = as.numeric(interest_rate3) / 100
interest_rate4 = as.numeric(interest_rate4) / 100
interest_rate5 = as.numeric(interest_rate5) / 100





temp = as.numeric(as.Date(add_date2))
timeline_int_tax = as.Date(min(temp):max(temp), origin = "1970-01-01")

len_time_int_tax = length(timeline_int_tax)

int_tax_series = rep(NA, len_time_int_tax)

for (i in 1:len_time_int_tax) {
  if (timeline_int_tax[i] < as.Date("1999-11-01")) {
    int_tax_series[i] = 0
  }
  if (timeline_int_tax[i] >= as.Date("1999-11-01") &
      timeline_int_tax[i] < as.Date("2007-08-15")) {
    int_tax_series[i] = 0.2
  }
  if (timeline_int_tax[i] >= as.Date("2007-08-15") &
      timeline_int_tax[i] < as.Date("2008-10-09")) {
    int_tax_series[i] = 0.05
  }
  if (timeline_int_tax[i] >= as.Date("2008-10-09")) {
    int_tax_series[i] = 0
  }
}
int_tax_table = data.frame(date = timeline_int_tax,
                           interest_tax = int_tax_series)
write.table(
  int_tax_table,
  file = 'int_tax_table20171019.csv',
  sep = c(','),
  col.names = NA
)


tax1_1[is.na(tax1_1)] = 0
temp1 = (tax1_1 == 1)
temp1_1 = (1:num_row_a)[temp1]
for (j in temp1_1) {
  tax1_1[j] = int_tax_table$interest_tax[int_tax_table$date == add_date2[j]]
}
tax2_1[is.na(tax2_1)] = 0
temp2 = (tax2_1 == 1)
temp2_1 = (1:num_row_a)[temp2]
for (j in temp2_1) {
  tax2_1[j] = int_tax_table$interest_tax[int_tax_table$date == add_date2[j]]
}
tax3_1[is.na(tax3_1)] = 0
temp3 = (tax3_1 == 1)
temp3_1 = (1:num_row_a)[temp3]
for (j in temp3_1) {
  tax3_1[j] = int_tax_table$interest_tax[int_tax_table$date == add_date2[j]]
}
tax4_1[is.na(tax4_1)] = 0
temp4 = (tax4_1 == 1)
temp4_1 = (1:num_row_a)[temp4]
for (j in temp4_1) {
  tax4_1[j] = int_tax_table$interest_tax[int_tax_table$date == add_date2[j]]
}
tax5_1[is.na(tax5_1)] = 0
temp5 = (tax5_1 == 1)
temp5_1 = (1:num_row_a)[temp5]
for (j in temp5_1) {
  tax5_1[j] = int_tax_table$interest_tax[int_tax_table$date == add_date2[j]]
}


length(add_fund_nav_adj1)
length(fundname_1)
length(yiji_1)
length()
length()
length()
length()
length()
length()
length(interest_rate1)
length(weight1_1)
length(tax1_1)
length(name1_1)
length(add_index1_pri1)
length(index1_1)
length(enddate_1)
length(startdate_1)
length(benchmark_1)
length(erji_1)


output_data = data.frame(
  date = add_date2,
  windcode = windcode_1,
  fundnav = add_fund_nav1,
  fundnav_adj = add_fund_nav_adj1,
  fundname = fundname_1,
  yiji = yiji_1,
  erji = erji_1,
  benchmark = benchmark_1,
  startdate = startdate_1,
  enddate = enddate_1,
  index1 = index1_1,
  index1_close = add_index1_pri1,
  index1_name = name1_1,
  index1_tax = tax1_1,
  index1_weight = weight1_1,
  index2 = index2_1,
  index2_close = add_index2_pri1,
  index2_name = name2_1,
  index2_tax = tax2_1,
  index2_weight = weight2_1,
  index3 = index3_1,
  index3_close = add_index3_pri1,
  index3_name = name3_1,
  index3_tax = tax3_1,
  index3_weight = weight3_1,
  index4 = index4_1,
  index4_close = add_index4_pri1,
  index4_name = name4_1,
  index4_tax = tax4_1,
  index4_weight = weight4_1,
  index5 = index5_1,
  index5_close = add_index5_pri1,
  index5_name = name5_1,
  index5_tax = tax5_1,
  index5_weight = weight5_1,
  interest_rate1 = interest_rate1,
  interest_rate2 = interest_rate2,
  interest_rate3 = interest_rate3,
  interest_rate4 = interest_rate4,
  interest_rate5 = interest_rate5
)

output_data[is.na(output_data)] = ''
write.table(output_data,
            file = 'stage1_fund_benchmark_weight_horizontal_monthly20180105.csv',
            sep = c(','),
            col.names = NA)








#######################################################
add_date2 = a$date
windcode_1 = a$windcode
add_fund_nav1 = a$fundnav
add_fund_nav_adj1 = a$fundnav_adj
fundname_1 = a$fundname
yiji_1 = a$yiji
erji_1 = a$erji
benchmark_1 = a$benchmark
startdate_1 = a$startdate
enddate_1 = a$enddate
index1_1 = a$index1
add_index1_pri1 = a$index1_close
name1_1 = a$index1_name
tax1_1 = a$index1_tax
weight1_1 = a$index1_weight
index2_1 = a$index2
add_index2_pri1 = a$index2_close
name2_1 = a$index2_name
tax2_1 = a$index2_tax
weight2_1 = a$index2_weight
index3_1 = a$index3
add_index3_pri1 = a$index3_close
name3_1 = a$index3_name
tax3_1 = a$index3_tax
weight3_1 = a$index3_weight
index4_1 = a$index4
add_index4_pri1 = a$index4_close
name4_1 = a$index4_name
tax4_1 = a$index4_tax
weight4_1 = a$index4_weight
index5_1 = a$index5
add_index5_pri1 = a$index5_close
name5_1 = a$index5_name
tax5_1 = a$index5_tax
weight5_1 = a$index5_weight

