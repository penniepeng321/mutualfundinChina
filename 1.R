

setwd("E:/fund_index_weight/Download_data_for_all_mutual_funds")
source('getstr.R')
library(haven)
a = read_sas('mutualbasic_final.sas7bdat')

#colnames(a)=c('windcode','fundname','fullname','benchmark',
#'startdate','enddate','yiji','erji','fenji')

num_row = nrow(a)
list_benchmark = 'q'
list_fundIndex = 'q'
list_v1 = 'q'
list_v3 = 'q'
list_v4 = 'q'
list_v5 = 'q'
list_v6 = 'q'
list_v7 = 'q'

for (add_ind in 1:num_row) {
  temp = unlist(strsplit(a$benchmark[add_ind], '\\+'))
  temp_n = length(temp)
  list_benchmark = c(list_benchmark,
                     temp)
  list_fundIndex = c(list_fundIndex,
                     rep(a$windcode[add_ind], temp_n))
  list_v1 = c(list_v1, rep(a$fundname[add_ind], temp_n))
  list_v3 = c(list_v3, rep(a$benchmark[add_ind], temp_n))
  list_v4 = c(list_v4, rep(a$startdate[add_ind], temp_n))
  list_v5 = c(list_v5, rep(a$enddate[add_ind], temp_n))
  list_v6 = c(list_v6, rep(a$yiji[add_ind], temp_n))
  list_v7 = c(list_v7, rep(a$erji[add_ind], temp_n))
  
}
list_benchmark = list_benchmark[-1]
list_fundIndex = list_fundIndex[-1]
list_v1 = list_v1[-1]
list_v3 = list_v3[-1]
list_v4 = list_v4[-1]
list_v5 = list_v5[-1]
list_v6 = list_v6[-1]
list_v7 = list_v7[-1]

num_row_ab = length(list_benchmark)
list_weight = c(0)
list_indexbenchmark = c(0)
options(warn = -1)
for (addin in 1:num_row_ab) {
  temp1 = getstr(list_benchmark[addin],
                 initial.character = '^a\\.',
                 final.character = '\\*') #from start to *
  
  temp2 = as.numeric(getstr(
    list_benchmark[addin],
    initial.character = '\\*',
    final.character = '%'
  )) / 100 #from * to %
  #warnings: NA introduced by coercing char to numeric
  
  temp2[is.na(temp2)] <- ''
  
  if ('' == temp1) {
    #consider no * case
    
    temp1 = list_benchmark[addin]
    temp2 = 1
  }
  
  if (('' != temp1) &
      ('' == temp2)) {
    #consider case with * but not %
    
    temp1 = getstr(list_benchmark[addin],
                   initial.character = '^a\\.',
                   final.character = '\\*')
    temp2 = as.numeric(getstr(
      list_benchmark[addin],
      initial.character = '\\*',
      final.character = '$'
    ))     #from * to end
  }
  
  list_indexbenchmark = c(list_indexbenchmark, temp1)
  list_weight = c(list_weight, temp2)
  
}

options(warn = 0) #warnings on

list_weight = list_weight[-1]
list_indexbenchmark = list_indexbenchmark[-1]

dict = read.table(
  file = 'index_code_name_dictionary.csv',
  header = T,
  sep = ',',
  as.is = T
)
num_abc = length(list_indexbenchmark)
list_indexbenchmarkcode = rep(NA, length(num_abc))
list_tax = rep(NA, length(num_abc))

for (i in 1:num_abc) {
  temp0 = (dict$index_n == list_indexbenchmark[i])
  
  if (sum(temp0) == 0) {
    list_indexbenchmarkcode[i] = NA
  }
  
  if (sum(temp0) > 0) {
    temp = dict$index_c[temp0]
    if (length(temp) > 1) {
      list_indexbenchmarkcode[i] = temp[1]
    }
    if (length(temp) == 1) {
      list_indexbenchmarkcode[i] = temp
    }
  }
  
}

#list_v4=as.Date(as.numeric(list_v4), origin = "1970-01-01")
#list_v5=as.Date(as.numeric(list_v5), origin = "1970-01-01")

odd_output2 = data.frame(
  windcode = list_fundIndex,
  fundname = list_v1,
  yiji = list_v6,
  erji = list_v7,
  index_code = list_indexbenchmarkcode,
  index_name = list_indexbenchmark,
  index_weight = list_weight,
  benchmark = list_v3,
  startdate = list_v4,
  enddate = list_v5
)

write.table(odd_output2,
            file = 'fund_benchmark_BD_ED_weight_vertical.csv',
            sep = c(','),
            col.names = NA)
