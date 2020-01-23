setwd("E:/fund_index_weight/Download_data_for_all_mutual_funds")
source('getstr.R')
data_table = read.table(
  file = 'horizontaldata_intax.csv',
  header = T,
  sep = ',',
  as.is = T
)

data_table1 = data_table[!is.na(data_table$startdate), ]
data_table = data_table1

old_table = read.table(
  file = 'clean_fund_benchmark_weight_horizontal_monthly20171205.csv',
  header = T,
  sep = ',',
  as.is = T
)

old_table$status = 'O'


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
status = 'q'

library(WindR)
w.start()

num_row = nrow(data_table)
resumeday = as.Date("2017-09-29")

(1:nrow(data_table1))[data_table1$windcode == '000798.OF']
#488

for (i in 3155:num_row) {
  dec1 = (old_table$fundname == data_table$fundname[i])
  dec2 = (old_table$windcode == data_table$windcode[i])
  dec3 = (old_table$benchmark == data_table$benchmark[i])
  dec4 = (old_table$startdate == data_table$startdate[i])
  
  dec = dec1 * dec2 * dec3 * dec4
  
  if (sum(dec, na.rm = T) > 1) {
    if (resumeday < data_table$enddate[i]) {
      w_wsd_data <- w.wsd(
        data_table$windcode[i],
        "nav,NAV_adj",
        resumeday,
        data_table$enddate[i],
        "Period=M"
      )
      while (w_wsd_data$ErrorCode != 0) {
        w_wsd_data <- w.wsd(
          data_table$windcode[i],
          "nav,NAV_adj",
          resumeday,
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
      status = c(status, rep('N', t_len))
      
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
      if (length(grep('%', data_table$index1_code[i])) != 0) {
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
      if (length(grep('%', data_table$index2_code[i])) != 0) {
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
      if (length(grep('%', data_table$index3_code[i])) != 0) {
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
      if (length(grep('%', data_table$index4_code[i])) != 0) {
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
      if (length(grep('%', data_table$index5_code[i])) != 0) {
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
    
  }
  if (sum(dec, na.rm = T) <= 1) {
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
    status = c(status, rep('N', t_len))
    
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
    if (length(grep('%', data_table$index1_code[i])) != 0) {
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
    if (length(grep('%', data_table$index2_code[i])) != 0) {
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
    if (length(grep('%', data_table$index3_code[i])) != 0) {
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
    if (length(grep('%', data_table$index4_code[i])) != 0) {
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
    if (length(grep('%', data_table$index5_code[i])) != 0) {
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
  
}


for (i in 1:num_row) {
  loc = (old_table$windcode == data_table$windcode[i])
  if (sum(loc, na.rm = T) > 1) {
    old_table$startdate[loc] = data_table$startdate[i]
  }
  
}

inid = (as.numeric(as.Date(old_table$date)) >=
          as.numeric(as.Date(old_table$startdate)))

old_table1 = old_table[inid, ]


add_date1 = c(add_date, old_table1$date)
windcode_1 = c(windcode_, old_table1$windcode)
add_fund_nav1 = c(add_fund_nav, old_table1$fundnav)
add_fund_nav_adj1 = c(add_fund_nav_adj, old_table1$fundnav_adj)
fundname_1 = c(fundname_, old_table1$fundname)
yiji_1 = c(yiji_, old_table1$yiji)
erji_1 = c(erji_, old_table1$erji)
benchmark_1 = c(benchmark_, old_table1$benchmark)
startdate_1 = c(startdate_, old_table1$startdate)
enddate_1 = c(enddate_, old_table1$enddate)
index1_1 = c(index1_, old_table1$index1)
add_index1_pri1 = c(add_index1_pri, old_table1$index1_close)
name1_1 = c(name1_, old_table1$index1_name)
tax1_1 = c(tax1_, old_table1$index1_tax)
weight1_1 = c(weight1_, old_table1$index1_weight)
index2_1 = c(index2_, old_table1$index2)
add_index2_pri1 = c(add_index2_pri, old_table1$index2_close)
name2_1 = c(name2_, old_table1$index2_name)
tax2_1 = c(tax2_, old_table1$index2_tax)
weight2_1 = c(weight2_, old_table1$index2_weight)
index3_1 = c(index3_, old_table1$index3)
add_index3_pri1 = c(add_index3_pri, old_table1$index3_close)
name3_1 = c(name3_, old_table1$index3_name)
tax3_1 = c(tax3_, old_table1$index3_tax)
weight3_1 = c(weight3_, old_table1$index3_weight)
index4_1 = c(index4_, old_table1$index4)
add_index4_pri1 = c(add_index4_pri, old_table1$index4_close)
name4_1 = c(name4_, old_table1$index4_name)
tax4_1 = c(tax4_, old_table1$index4_tax)
weight4_1 = c(weight4_, old_table1$index4_weight)
index5_1 = c(index5_, old_table1$index5)
add_index5_pri1 = c(add_index5_pri, old_table1$index5_close)
name5_1 = c(name5_, old_table1$index5_name)
tax5_1 = c(tax5_, old_table1$index5_tax)
weight5_1 = c(weight5_, old_table1$index5_weight)
status1 = c(status, old_table1$status)



output_data = data.frame(
  date = add_date1,
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
  index5_weight = weight5_1
)

write.table(output_data,
            file = 'fund_benchmark_weight_horizontal_monthly.csv',
            sep = c(','),
            col.names = NA)





#these are just in case
(1:222501)[windcode_1 == "000844.OF"]



erji_1 = c(erji_1[1:1997], rep("股票多空", 3), erji_1[1998:222498])
benchmark_1 = c(benchmark_1[1:1997],
                rep("中国人民银行公布的同期一年期定期存款基准利率(税后)+2%", 3),
                benchmark_1[1998:222498])

startdate_1 = c(startdate_1[1:1997], rep("2014/12/1", 3), startdate_1[1998:222498])

enddate_1 = c(enddate_1[1:1997], rep("2017/12/04", 3), enddate_1[1998:222498])
index1_1 = c(index1_1[1:1997], rep("中国人民银行公布的同期一年期定期存款基准利率(税后)", 3), index1_1[1998:222498])
add_index1_pri1 = c(add_index1_pri1[1:1997], rep("", 3), add_index1_pri1[1998:222498])

name1_1 = c(name1_1[1:1997], rep("", 3), name1_1[1998:222498])

tax1_1 = c(tax1_1[1:1997], rep(1, 3), tax1_1[1998:222498])

weight1_1 = c(weight1_1[1:1997], rep(1, 3), weight1_1[1998:222498])

index2_1 = c(index2_1[1:1997], rep("2%", 3), index2_1[1998:222498])

add_index2_pri1 =  c(add_index2_pri1[1:1997], rep("2%", 3), add_index2_pri1[1998:222498])

name2_1 = c(name2_1[1:1997], rep("", 3), name2_1[1998:222498])
tax2_1 = c(tax2_1[1:1997], rep("", 3), tax2_1[1998:222498])

weight2_1 = c(weight2_1[1:1997], rep("", 3), weight2_1[1998:222498])
index3_1 = c(index3_1[1:1997], rep("", 3), index3_1[1998:222498])

add_index3_pri1 = c(add_index3_pri1[1:1997], rep("", 3), add_index3_pri1[1998:222498])

name3_1 = c(name3_1[1:1997], rep("", 3), name3_1[1998:222498])

tax3_1 = c(tax3_1[1:1997], rep("", 3), tax3_1[1998:222498])

weight3_1 = c(weight3_1[1:1997], rep("", 3), weight3_1[1998:222498])

index4_1 = c(index4_1[1:1997], rep("", 3), index4_1[1998:222498])

add_index4_pri1 = c(add_index4_pri1[1:1997], rep("", 3), add_index4_pri1[1998:222498])

name4_1 = c(name4_1[1:1997], rep("", 3), name4_1[1998:222498])

tax4_1 = c(tax4_1[1:1997], rep("", 3), tax4_1[1998:222498])

weight4_1 = c(weight4_1[1:1997], rep("", 3), weight4_1[1998:222498])

index5_1 = c(index5_1[1:1997], rep("", 3), index5_1[1998:222498])
add_index5_pri1 = c(add_index5_pri1[1:1997], rep("", 3), add_index5_pri1[1998:222498])

name5_1 = c(name5_1[1:1997], rep("", 3), name5_1[1998:222498])

tax5_1 = c(tax5_1[1:1997], rep("", 3), tax5_1[1998:222498])

weight5_1 = c(weight5_1[1:1997], rep("", 3), weight5_1[1998:222498])

status1 = c(status1[1:1997], rep("", 3), status1[1998:222498])




#> i
#[1] 3155

output_data = data.frame(
  date = add_date[2:9019],
  windcode = windcode_[2:9019],
  fundnav = add_fund_nav[2:9019],
  fundnavadj = add_fund_nav_adj[2:9019],
  fundname = fundname_[2:9019],
  yiji = yiji_[2:9019],
  erji = erji_[2:9019],
  bench = benchmark_[2:9019],
  start = startdate_[2:9019],
  end = enddate_[2:9019],
  ind1 = index1_[2:9019],
  close1 = add_index1_pri[2:9019],
  name1 = name1_[2:9019],
  tax1 = tax1_[2:9019],
  weight1 = weight1_[2:9019],
  ind2 = index2_[2:9019],
  close2 = add_index2_pri[2:9019],
  name2 = name2_[2:9019],
  tax2 = tax2_[2:9019],
  weight2 = weight2_[2:9019],
  ind3 = index3_[2:9019],
  close3 = add_index3_pri[2:9019],
  name3 = name3_[2:9019],
  tax3 = tax3_[2:9019],
  weight3 = weight3_[2:9019],
  ind4 = index4_[2:9019],
  close4 = add_index4_pri[2:9019],
  name4 = name4_[2:9019],
  tax4 = tax4_[2:9019],
  weight4 = weight4_[2:9019],
  ind5 = index5_[2:9019],
  close5 = add_index5_pri[2:9019],
  name5 = name5_[2:9019],
  tax5 = tax5_[2:9019],
  weight5 = weight5_[2:9019],
  status = status[2:9019]
)

write.table(output_data,
            file = 'download_data20180106.csv',
            sep = c(','),
            col.names = NA)


part1 = read.table(
  file = 'download_data20180105.csv',
  header = T,
  sep = ',',
  as.is = T
)
part2 = read.table(
  file = 'download_data20180106.csv',
  header = T,
  sep = ',',
  as.is = T
)
part11 = part1[-1, ]
temp = as.Date(as.numeric(part11$date), origin = "1970-01-01")
part11$date = temp
temp = as.Date(as.numeric(part2$date), origin = "1970-01-01")
part2$date = temp
temp = as.Date(part11$start)
part11$start = temp
temp = as.Date(part2$start)
part2$start = temp
temp = as.Date(part11$end)
part11$end = temp
temp = as.Date(part2$end)
part2$end = temp
parts = rbind(part11, part2)

parts[is.na(parts)] = ''
old_table1[is.na(old_table1)] = ''
temp = as.Date(old_table1$date)
old_table1$date = temp
temp = as.Date(old_table1$startdate)
old_table1$startdate = temp
temp = as.Date(old_table1$enddate)
old_table1$enddate = temp

add_date1 = c(parts$date, old_table1$date)
windcode_1 = c(parts$windcode, old_table1$windcode)
add_fund_nav1 = c(parts$fundnav, old_table1$fundnav)
add_fund_nav_adj1 = c(parts$fundnavadj, old_table1$fundnav_adj)
fundname_1 = c(parts$fundname, old_table1$fundname)
yiji_1 = c(parts$yiji, old_table1$yiji)
erji_1 = c(parts$erji, old_table1$erji)
benchmark_1 = c(parts$bench, old_table1$benchmark)
startdate_1 = c(parts$start, old_table1$startdate)
enddate_1 = c(parts$end, old_table1$enddate)
index1_1 = c(parts$ind1, old_table1$index1)
add_index1_pri1 = c(parts$close1, old_table1$index1_close)
name1_1 = c(parts$name1, old_table1$index1_name)
tax1_1 = c(parts$tax1, old_table1$index1_tax)
weight1_1 = c(parts$weight1, old_table1$index1_weight)
index2_1 = c(parts$ind2, old_table1$index2)
add_index2_pri1 = c(parts$close2, old_table1$index2_close)
name2_1 = c(parts$name2, old_table1$index2_name)
tax2_1 = c(parts$tax2, old_table1$index2_tax)
weight2_1 = c(parts$weight2, old_table1$index2_weight)
index3_1 = c(parts$ind3, old_table1$index3)
add_index3_pri1 = c(parts$close3, old_table1$index3_close)
name3_1 = c(parts$name3, old_table1$index3_name)
tax3_1 = c(parts$tax3, old_table1$index3_tax)
weight3_1 = c(parts$weight3, old_table1$index3_weight)
index4_1 = c(parts$ind4, old_table1$index4)
add_index4_pri1 = c(parts$close4, old_table1$index4_close)
name4_1 = c(parts$name4, old_table1$index4_name)
tax4_1 = c(parts$tax4, old_table1$index4_tax)
weight4_1 = c(parts$weight4, old_table1$index4_weight)
index5_1 = c(parts$ind5, old_table1$index5)
add_index5_pri1 = c(parts$close5, old_table1$index5_close)
name5_1 = c(parts$name5, old_table1$index5_name)
tax5_1 = c(parts$tax5, old_table1$index5_tax)
weight5_1 = c(parts$weight5, old_table1$index5_weight)
status1 = c(parts$status, old_table1$status)

output_data = data.frame(
  date = add_date1,
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
  index5_weight = weight5_1
)

write.table(output_data,
            file = 'fund_benchmark_weight_horizontal_monthly20180105.csv',
            sep = c(','),
            col.names = NA)






length(add_date)
length(windcode_)
length(add_fund_nav)
length(add_fund_nav_adj)
length(fundname_)
length(yiji_)
length(erji_)
length(benchmark_)
length(startdate_)
length(enddate_)
length(index1_)
length(add_index1_pri)
length(name1_)
length(tax1_)
length(weight1_)
length(index2_)
length(add_index2_pri)
length(name2_)
length(tax2_)
length(weight2_)
length(index3_)
length(add_index3_pri)
length(name3_)
length(tax3_)
length(weight3_)
length(index4_)
length(add_index4_pri)
length(name4_)
length(tax4_)
length(weight4_)
length(index5_)
length(add_index5_pri)
length(name5_)
length(tax5_)
length(weight5_)
length(status)
