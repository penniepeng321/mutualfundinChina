setwd("E:/fund_index_weight/Download_data_for_all_mutual_funds")
source('getstr.R')
data_table = read.table(
  file = 'horizontaldata_intax.csv',
  header = T,
  sep = ',',
  as.is = T
)

add_date = '0000-00-00'
windcode_ = '0000000'
add_fund_nav = 0
add_fund_nav_adj = 0
fundname_ = '0000000'
yiji_ = '0000000'
erji_ = '0000000'
benchmark_ = '0000000'
startdate_ = '0000-00-00'
enddate_ = '0000-00-00'
index1_ = '0000000'
add_index1_pri = 0
name1_ = '0000000'
tax1_ = 0
weight1_ = 0
index2_ = '0000000'
add_index2_pri = 0
name2_ = '0000000'
tax2_ = 0
weight2_ = 0
index3_ = '0000000'
add_index3_pri = 0
name3_ = '0000000'
tax3_ = 0
weight3_ = 0
index4_ = '0000000'
add_index4_pri = 0
name4_ = '0000000'
tax4_ = 0
weight4_ = 0
index5_ = '0000000'
add_index5_pri = 0
name5_ = '0000000'
tax5_ = 0
weight5_ = 0

library(WindR)
w.start()
num_row = nrow(data_table)
for (i in 1:num_row) {
  w_wsd_data <- w.wsd(
    data_table$windcode[i],
    "nav,NAV_adj",
    data_table$startdate[i],
    data_table$enddate[i],
    "Period=M"
  )
  while (w_wsd_data$ErrorCode != 0) {
    w_wsd_data <- w.wsd(
      data_table$windcode[i],
      "nav,NAV_adj",
      data_table$startdate[i],
      data_table$enddate[i],
      "Period=M"
    )
  }
  
  t_len = length(w_wsd_data$Data$DATETIME)
  
  add_date = c(add_date, w_wsd_data$Data$DATETIME)
  windcode_ = c(windcode_, rep(data_table$windcode[i], t_len))
  add_fund_nav = c(add_fund_nav, w_wsd_data$Data$NAV)
  add_fund_nav_adj = c(add_fund_nav_adj, w_wsd_data$Data$NAV_ADJ)
  fundname_ = c(fundname_, rep(data_table$fundname[i], t_len))
  yiji_ = c(yiji_, rep(data_table$yiji[i], t_len))
  erji_ = c(erji_, rep(data_table$erji[i], t_len))
  benchmark_ = c(benchmark_, rep(data_table$benchmark[i], t_len))
  startdate_ = c(startdate_, rep(data_table$startdate[i], t_len))
  enddate_ = c(enddate_, rep(data_table$enddate[i], t_len))
  
  if (data_table$index1_code[i] != "" &
      length(grep('%', data_table$index1_code[i])) == 0) {
    w_wsd_data0 <- w.wsd(
      data_table$index1_code[i],
      "close",
      w_wsd_data$Data$DATETIME[1],
      w_wsd_data$Data$DATETIME[t_len],
      "Period=M"
    )
    
    while (w_wsd_data0$ErrorCode != 0) {
      w_wsd_data0 <- w.wsd(
        data_table$index1_code[i],
        "close",
        w_wsd_data$Data$DATETIME[1],
        w_wsd_data$Data$DATETIME[t_len],
        "Period=M"
      )
    }
    index1_ = c(index1_, rep(data_table$index1_code[i], t_len))
    name1_ = c(name1_, rep(data_table$index1_name[i], t_len))
    tax1_ = c(tax1_, rep(data_table$index1_intax[i], t_len))
    weight1_ = c(weight1_, rep(data_table$index1_weight[i], t_len))
    if (length(w_wsd_data0$Data$DATETIME) != t_len) {
      add_index1_pri = c(add_index1_pri, rep("", t_len))
    }
    if (length(w_wsd_data0$Data$DATETIME) == t_len) {
      add_index1_pri = c(add_index1_pri, w_wsd_data0$Data$CLOSE)
    }
  }
  if (length(grep('%', data_table$index1_code[i])) == 1) {
    index1_ = c(index1_, rep(data_table$index1_code[i], t_len))
    add_index1_pri = c(add_index1_pri, rep(data_table$index1_code[i], t_len))
    name1_ = c(name1_, rep(data_table$index1_name[i], t_len))
    tax1_ = c(tax1_, rep(data_table$index1_intax[i], t_len))
    weight1_ = c(weight1_, rep(data_table$index1_weight[i], t_len))
  }
  
  if (data_table$index1_code[i] == "") {
    index1_ = c(index1_, rep("", t_len))
    add_index1_pri = c(add_index1_pri, rep("", t_len))
    name1_ = c(name1_, rep("", t_len))
    tax1_ = c(tax1_, rep("", t_len))
    weight1_ = c(weight1_, rep("", t_len))
  }
  
  
  
  
  
  if (data_table$index2_code[i] != "" &
      length(grep('%', data_table$index2_code[i])) == 0) {
    w_wsd_data0 <- w.wsd(
      data_table$index2_code[i],
      "close",
      w_wsd_data$Data$DATETIME[1],
      w_wsd_data$Data$DATETIME[t_len],
      "Period=M"
    )
    
    while (w_wsd_data0$ErrorCode != 0) {
      w_wsd_data0 <- w.wsd(
        data_table$index2_code[i],
        "close",
        w_wsd_data$Data$DATETIME[1],
        w_wsd_data$Data$DATETIME[t_len],
        "Period=M"
      )
    }
    index2_ = c(index2_, rep(data_table$index2_code[i], t_len))
    name2_ = c(name2_, rep(data_table$index2_name[i], t_len))
    tax2_ = c(tax2_, rep(data_table$index2_intax[i], t_len))
    weight2_ = c(weight2_, rep(data_table$index2_weight[i], t_len))
    if (length(w_wsd_data0$Data$DATETIME) != t_len) {
      add_index2_pri = c(add_index2_pri, rep("", t_len))
    }
    if (length(w_wsd_data0$Data$DATETIME) == t_len) {
      add_index2_pri = c(add_index2_pri, w_wsd_data0$Data$CLOSE)
    }
  }
  if (length(grep('%', data_table$index2_code[i])) == 1) {
    index2_ = c(index2_, rep(data_table$index2_code[i], t_len))
    add_index2_pri = c(add_index2_pri, rep(data_table$index2_code[i], t_len))
    name2_ = c(name2_, rep(data_table$index2_name[i], t_len))
    tax2_ = c(tax2_, rep(data_table$index2_intax[i], t_len))
    weight2_ = c(weight2_, rep(data_table$index2_weight[i], t_len))
  }
  
  if (data_table$index2_code[i] == "") {
    index2_ = c(index2_, rep("", t_len))
    add_index2_pri = c(add_index2_pri, rep("", t_len))
    name2_ = c(name2_, rep("", t_len))
    tax2_ = c(tax2_, rep("", t_len))
    weight2_ = c(weight2_, rep("", t_len))
  }
  
  
  
  
  
  
  if (data_table$index3_code[i] != "" &
      length(grep('%', data_table$index3_code[i])) == 0) {
    w_wsd_data0 <- w.wsd(
      data_table$index3_code[i],
      "close",
      w_wsd_data$Data$DATETIME[1],
      w_wsd_data$Data$DATETIME[t_len],
      "Period=M"
    )
    
    while (w_wsd_data0$ErrorCode != 0) {
      w_wsd_data0 <- w.wsd(
        data_table$index3_code[i],
        "close",
        w_wsd_data$Data$DATETIME[1],
        w_wsd_data$Data$DATETIME[t_len],
        "Period=M"
      )
    }
    index3_ = c(index3_, rep(data_table$index3_code[i], t_len))
    name3_ = c(name3_, rep(data_table$index3_name[i], t_len))
    tax3_ = c(tax3_, rep(data_table$index3_intax[i], t_len))
    weight3_ = c(weight3_, rep(data_table$index3_weight[i], t_len))
    if (length(w_wsd_data0$Data$DATETIME) != t_len) {
      add_index3_pri = c(add_index3_pri, rep("", t_len))
    }
    if (length(w_wsd_data0$Data$DATETIME) == t_len) {
      add_index3_pri = c(add_index3_pri, w_wsd_data0$Data$CLOSE)
    }
  }
  if (length(grep('%', data_table$index3_code[i])) == 1) {
    index3_ = c(index3_, rep(data_table$index3_code[i], t_len))
    add_index3_pri = c(add_index3_pri, rep(data_table$index3_code[i], t_len))
    name3_ = c(name3_, rep(data_table$index3_name[i], t_len))
    tax3_ = c(tax3_, rep(data_table$index3_intax[i], t_len))
    weight3_ = c(weight3_, rep(data_table$index3_weight[i], t_len))
  }
  
  if (data_table$index3_code[i] == "") {
    index3_ = c(index3_, rep("", t_len))
    add_index3_pri = c(add_index3_pri, rep("", t_len))
    name3_ = c(name3_, rep("", t_len))
    tax3_ = c(tax3_, rep("", t_len))
    weight3_ = c(weight3_, rep("", t_len))
  }
  
  
  
  
  
  
  if (data_table$index4_code[i] != "" &
      length(grep('%', data_table$index4_code[i])) == 0) {
    w_wsd_data0 <- w.wsd(
      data_table$index4_code[i],
      "close",
      w_wsd_data$Data$DATETIME[1],
      w_wsd_data$Data$DATETIME[t_len],
      "Period=M"
    )
    
    while (w_wsd_data0$ErrorCode != 0) {
      w_wsd_data0 <- w.wsd(
        data_table$index4_code[i],
        "close",
        w_wsd_data$Data$DATETIME[1],
        w_wsd_data$Data$DATETIME[t_len],
        "Period=M"
      )
    }
    index4_ = c(index4_, rep(data_table$index4_code[i], t_len))
    name4_ = c(name4_, rep(data_table$index4_name[i], t_len))
    tax4_ = c(tax4_, rep(data_table$index4_intax[i], t_len))
    weight4_ = c(weight4_, rep(data_table$index4_weight[i], t_len))
    if (length(w_wsd_data0$Data$DATETIME) != t_len) {
      add_index4_pri = c(add_index4_pri, rep("", t_len))
    }
    if (length(w_wsd_data0$Data$DATETIME) == t_len) {
      add_index4_pri = c(add_index4_pri, w_wsd_data0$Data$CLOSE)
    }
  }
  if (length(grep('%', data_table$index4_code[i])) == 1) {
    index4_ = c(index4_, rep(data_table$index4_code[i], t_len))
    add_index4_pri = c(add_index4_pri, rep(data_table$index4_code[i], t_len))
    name4_ = c(name4_, rep(data_table$index4_name[i], t_len))
    tax4_ = c(tax4_, rep(data_table$index4_intax[i], t_len))
    weight4_ = c(weight4_, rep(data_table$index4_weight[i], t_len))
  }
  
  if (data_table$index4_code[i] == "") {
    index4_ = c(index4_, rep("", t_len))
    add_index4_pri = c(add_index4_pri, rep("", t_len))
    name4_ = c(name4_, rep("", t_len))
    tax4_ = c(tax4_, rep("", t_len))
    weight4_ = c(weight4_, rep("", t_len))
  }
  
  
  
  
  if (data_table$index5_code[i] != "" &
      length(grep('%', data_table$index5_code[i])) == 0) {
    w_wsd_data0 <- w.wsd(
      data_table$index5_code[i],
      "close",
      w_wsd_data$Data$DATETIME[1],
      w_wsd_data$Data$DATETIME[t_len],
      "Period=M"
    )
    
    while (w_wsd_data0$ErrorCode != 0) {
      w_wsd_data0 <- w.wsd(
        data_table$index5_code[i],
        "close",
        w_wsd_data$Data$DATETIME[1],
        w_wsd_data$Data$DATETIME[t_len],
        "Period=M"
      )
    }
    index5_ = c(index5_, rep(data_table$index5_code[i], t_len))
    name5_ = c(name5_, rep(data_table$index5_name[i], t_len))
    tax5_ = c(tax5_, rep(data_table$index5_intax[i], t_len))
    weight5_ = c(weight5_, rep(data_table$index5_weight[i], t_len))
    if (length(w_wsd_data0$Data$DATETIME) != t_len) {
      add_index5_pri = c(add_index5_pri, rep("", t_len))
    }
    if (length(w_wsd_data0$Data$DATETIME) == t_len) {
      add_index5_pri = c(add_index5_pri, w_wsd_data0$Data$CLOSE)
    }
  }
  if (length(grep('%', data_table$index5_code[i])) == 1) {
    index5_ = c(index5_, rep(data_table$index5_code[i], t_len))
    add_index5_pri = c(add_index5_pri, rep(data_table$index5_code[i], t_len))
    name5_ = c(name5_, rep(data_table$index5_name[i], t_len))
    tax5_ = c(tax5_, rep(data_table$index5_intax[i], t_len))
    weight5_ = c(weight5_, rep(data_table$index5_weight[i], t_len))
  }
  
  if (data_table$index5_code[i] == "") {
    index5_ = c(index5_, rep("", t_len))
    add_index5_pri = c(add_index5_pri, rep("", t_len))
    name5_ = c(name5_, rep("", t_len))
    tax5_ = c(tax5_, rep("", t_len))
    weight5_ = c(weight5_, rep("", t_len))
  }
  
}





add_date = add_date[-1]
windcode_ = windcode_[-1]
add_fund_nav = add_fund_nav[-1]
add_fund_nav_adj = add_fund_nav_adj[-1]
fundname_ = fundname_[-1]
yiji_ = yiji_[-1]
erji_ = erji_[-1]
benchmark_ = benchmark_[-1]
startdate_ = startdate_[-1]
enddate_ = enddate_[-1]
index1_ = index1_[-1]
add_index1_pri = add_index1_pri[-1]
name1_ = name1_[-1]
tax1_ = tax1_[-1]
weight1_ = weight1_[-1]
index2_ = index2_[-1]
add_index2_pri = add_index2_pri[-1]
name2_ = name2_[-1]
tax2_ = tax2_[-1]
weight2_ = weight2_[-1]
index3_ = index3_[-1]
add_index3_pri = add_index3_pri[-1]
name3_ = name3_[-1]
tax3_ = tax3_[-1]
weight3_ = weight3_[-1]
index4_ = index4_[-1]
add_index4_pri = add_index4_pri[-1]
name4_ = name4_[-1]
tax4_ = tax4_[-1]
weight4_ = weight4_[-1]
index5_ = index5_[-1]
add_index5_pri = add_index5_pri[-1]
name5_ = name5_[-1]
tax5_ = tax5_[-1]
weight5_ = weight5_[-1]





output_data = data.frame(
  date = add_date,
  windcode = windcode_,
  fundnav = add_fund_nav,
  fundnav_adj = add_fund_nav_adj,
  fundname = fundname_,
  yiji = yiji_,
  erji = erji_,
  benchmark = benchmark_,
  startdate = startdate_,
  enddate = enddate_,
  index1 = index1_,
  index1_close = add_index1_pri,
  index1_name = name1_,
  index1_tax = tax1_,
  index1_weight = weight1_,
  index2 = index2_,
  index2_close = add_index2_pri,
  index2_name = name2_,
  index2_tax = tax2_,
  index2_weight = weight2_,
  index3 = index3_,
  index3_close = add_index3_pri,
  index3_name = name3_,
  index3_tax = tax3_,
  index3_weight = weight3_,
  index4 = index4_,
  index4_close = add_index4_pri,
  index4_name = name4_,
  index4_tax = tax4_,
  index4_weight = weight4_,
  index5 = index5_,
  index5_close = add_index5_pri,
  index5_name = name5_,
  index5_tax = tax5_,
  index5_weight = weight5_
)

write.table(output_data,
            file = 'fund_benchmark_weight_horizontal_monthly.csv',
            sep = c(','),
            col.names = NA)
