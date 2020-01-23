#convert vertical table to horizontal table ready for downloading

#put 指数+1.5% to be 指数 1 1.5% 1 rather than 1.5% 1 指数
#In addition, put everything containing % to be last

setwd("E:/fund_index_weight/Download_data_for_all_mutual_funds")
source('getstr.R')

vert_table = read.table(
  file = 'fund_benchmark_BD_ED_weight_vertical.csv',
  header = T,
  sep = c(','),
  as.is = T
)
#sort vert table in increasing order of windcode

num_row_vert_table = nrow(vert_table)

horrow = length(unique(vert_table$windcode))

hordata = matrix(NA, horrow, 22)
k = 1
j = 1

for (i in 1:(num_row_vert_table - 1)) {
  temp = vert_table$windcode[i]
  temp_n = vert_table$windcode[i + 1]
  
  if (temp == temp_n) {
    hordata[k, (3 * j + 5)] = vert_table$index_code[i]
    hordata[k, (3 * j + 6)] = vert_table$index_name[i]
    hordata[k, (3 * j + 7)] = vert_table$index_weight[i]
    j = j + 1
  }
  
  if (temp != temp_n) {
    hordata[k, (3 * j + 5)] = vert_table$index_code[i]
    hordata[k, (3 * j + 6)] = vert_table$index_name[i]
    hordata[k, (3 * j + 7)] = vert_table$index_weight[i]
    hordata[k, 1] = vert_table$windcode[i]
    hordata[k, 2] = vert_table$fundname[i]
    hordata[k, 3] = vert_table$yiji[i]
    hordata[k, 4] = vert_table$erji[i]
    hordata[k, 5] = vert_table$benchmark[i]
    hordata[k, 6] = vert_table$startdate[i]
    hordata[k, 7] = vert_table$enddate[i]
    k = k + 1
    j = 1
  }
}

i = num_row_vert_table
if (temp == temp_n) {
  hordata[k, (3 * j + 5)] = vert_table$index_code[i]
  hordata[k, (3 * j + 6)] = vert_table$index_name[i]
  hordata[k, (3 * j + 7)] = vert_table$index_weight[i]
  hordata[k, 1] = vert_table$windcode[i]
  hordata[k, 2] = vert_table$fundname[i]
  hordata[k, 3] = vert_table$yiji[i]
  hordata[k, 4] = vert_table$erji[i]
  hordata[k, 5] = vert_table$benchmark[i]
  hordata[k, 6] = vert_table$startdate[i]
  hordata[k, 7] = vert_table$enddate[i]
  j = j + 1
}

if (temp != temp_n) {
  hordata[k, (3 * j + 5)] = vert_table$index_code[i]
  hordata[k, (3 * j + 6)] = vert_table$index_name[i]
  hordata[k, (3 * j + 7)] = vert_table$index_weight[i]
  hordata[k, 1] = vert_table$windcode[i]
  hordata[k, 2] = vert_table$fundname[i]
  hordata[k, 3] = vert_table$yiji[i]
  hordata[k, 4] = vert_table$erji[i]
  hordata[k, 5] = vert_table$benchmark[i]
  hordata[k, 6] = vert_table$startdate[i]
  hordata[k, 7] = vert_table$enddate[i]
  k = k + 1
  j = 1
}

options(warn = -1)

for (i in 1:horrow) {
  temp = c(0, 5)
  org_hor = c(0, 15)
  
  for (j in 1:5) {
    temp[j] = as.numeric(hordata[i, (3 * j + 7)])
    org_hor[(3 * j - 2)] = hordata[i, (3 * j + 5)]
    org_hor[(3 * j - 1)] = hordata[i, (3 * j + 6)]
    org_hor[(3 * j)] = hordata[i, (3 * j + 7)]
  }
  
  temp1 = sort(
    temp,
    decreasing = T,
    index.return = T,
    na.last = T
  )$ix
  
  for (j in 1:5) {
    org_temp1 = temp1
    if (length(grep("%", org_hor[(3 * j - 1)])) == 1) {
      temp1[j] = 5 - sum(is.na(temp))
      temp1[org_temp1 == temp1[j]] = org_temp1[j]
    }
  }
  
  for (j in 1:5) {
    hordata[i, (3 * j + 5)] = org_hor[(3 * temp1[j] - 2)]
    hordata[i, (3 * j + 6)] = org_hor[(3 * temp1[j] - 1)]
    hordata[i, (3 * j + 7)] = org_hor[(3 * temp1[j])]
  }
}

options(warn = 0)

hordata[is.na(hordata)] = ''
output_hordata = as.data.frame(hordata)
colnames(output_hordata) = c(
  'windcode',
  'fundname',
  'yiji',
  'erji',
  'benchmark',
  'startdate',
  'enddate',
  'index1_code',
  'index1_name',
  'index1_weight',
  'index2_code',
  'index2_name',
  'index2_weight',
  'index3_code',
  'index3_name',
  'index3_weight',
  'index4_code',
  'index4_name',
  'index4_weight',
  'index5_code',
  'index5_name',
  'index5_weight'
)

write.table(
  output_hordata,
  file = 'horizontaldata.csv',
  sep = c(','),
  col.names = NA
)
