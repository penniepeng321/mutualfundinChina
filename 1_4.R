setwd("E:/fund_index_weight/Download_data_for_all_mutual_funds")
source('getstr.R')
ho_data = read.table(
  file = 'horizontaldata.csv',
  header = T,
  sep = c(','),
  as.is = T
)
nnn = nrow(ho_data)
index1_intax = rep(0, nnn)
index2_intax = rep(0, nnn)
index3_intax = rep(0, nnn)
index4_intax = rep(0, nnn)
index5_intax = rep(0, nnn)
for (i in 1:nnn) {
  if (length(grep('税后', ho_data$index1_name[i])) > 0) {
    index1_intax[i] = 1
  }
  if (length(grep('税后', ho_data$index2_name[i])) > 0) {
    index2_intax[i] = 1
  }
  if (length(grep('税后', ho_data$index3_name[i])) > 0) {
    index3_intax[i] = 1
  }
  if (length(grep('税后', ho_data$index4_name[i])) > 0) {
    index4_intax[i] = 1
  }
  if (length(grep('税后', ho_data$index5_name[i])) > 0) {
    index5_intax[i] = 1
  }
  
}
ho_data$index1_intax = index1_intax
ho_data$index2_intax = index2_intax
ho_data$index3_intax = index3_intax
ho_data$index4_intax = index4_intax
ho_data$index5_intax = index5_intax

ho_data$index1_weight[is.na(ho_data$index1_weight)] = ''
ho_data$index2_weight[is.na(ho_data$index2_weight)] = ''
ho_data$index3_weight[is.na(ho_data$index3_weight)] = ''
ho_data$index4_weight[is.na(ho_data$index4_weight)] = ''
ho_data$index5_weight[is.na(ho_data$index5_weight)] = ''

ho_data$startdate[is.na(ho_data$startdate)] = ''

ho_data$startdate = as.Date(ho_data$startdate, origin = "1970-01-01")
ho_data$enddate = as.Date(ho_data$enddate, origin = "1970-01-01")


write.table(ho_data[, -c(1)],
            file = 'horizontaldata_intax.csv',
            sep = c(','),
            col.names = NA)
