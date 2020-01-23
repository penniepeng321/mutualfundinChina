#Summarize the main component of benchmark using frequency table.

setwd("E:/fund_index_weight/Download_data_for_all_mutual_funds")
source('getstr.R')

library(WindR)
w.start()
w_wset_data1 <-
  w.wset('sectorconstituent',
         'date=2017-12-14;sectorid=1000009415000000')
w_wset_data2 <-
  w.wset('sectorconstituent',
         'date=2017-12-14;sectorid=1000009416000000')
w_wset_data3 <-
  w.wset('sectorconstituent',
         'date=2017-12-14;sectorid=1000009417000000')
w_wset_data4 <-
  w.wset('sectorconstituent',
         'date=2017-12-14;sectorid=1000009418000000')
w_wset_data5 <-
  w.wset('sectorconstituent',
         'date=2017-12-14;sectorid=1000009419000000')
w_wset_data6 <-
  w.wset('sectorconstituent',
         'date=2017-12-14;sectorid=1000009420000000')
w_wset_data7 <-
  w.wset('sectorconstituent',
         'date=2017-12-14;sectorid=1000009421000000')

w_wset_data <-
  w.wset('sectorconstituent',
         'date=2017-12-14;sectorid=1000003630000000')
w_wset_data <-
  w.wset('sectorconstituent',
         'date=2017-12-14;sectorid=1000003627000000')
w_wset_data <-
  w.wset('sectorconstituent',
         'date=2017-12-14;sectorid=1000003634000000')
w_wset_data <-
  w.wset('sectorconstituent',
         'date=2017-12-14;sectorid=1000006202000000')
w_wset_data <-
  w.wset('sectorconstituent',
         'date=2017-12-14;sectorid=1000003628000000')
w_wset_data <-
  w.wset('sectorconstituent',
         'date=2017-12-14;sectorid=1000003629000000')
w_wset_data <-
  w.wset('sectorconstituent',
         'date=2017-12-14;sectorid=1000009422000000')

#a lot more index subgroups to be added, later...
#concatenate and output

write.table(
  w_wset_data$data,
  file = 'official_index_code_name_dictionary.csv',
  sep = c(','),
  col.names = NA
)


dict_table = read.table(
  file = 'benchmark_name_code_dictionary.csv',
  header = T,
  sep = c(','),
  as.is = T
)
colnames(dict_table) = c('windcode', 'fundname', 'fullname')



hori_table = read.table(
  file = 'horizontaldata.csv',
  header = T,
  sep = c(','),
  as.is = T
)
library(tidyr)
library(dplyr)

erji_benchmark =
  hori_table %>%
  gather(variable, value, index1_code) %>%
  group_by(erji, variable, value) %>%
  summarise(n = n()) %>%
  mutate(freq = n / sum(n))
nnn = length(erji_benchmark$value)

official_name = rep('', nnn)

for (i in 1:nnn) {
  temp = (dict_table$windcode == erji_benchmark$value[i])
  if (sum(temp) > 0) {
    official_name[i] = dict_table$fullname[temp]
  }
  
}

erji_benchmark$index_name = official_name

write.table(
  erji_benchmark,
  file = 'summary_main_component_benchmark.csv',
  sep = c(','),
  col.names = NA
)

temp = (erji_benchmark$freq > 0.05)
main_erji_benchmark = erji_benchmark[temp, ]
write.table(
  main_erji_benchmark,
  file = 'main_summary_main_component_benchmark.csv',
  sep = c(','),
  col.names = NA
)

yiji_erji =
  hori_table %>%
  gather(variable, value, erji) %>%
  group_by(yiji, variable, value) %>%
  summarise(n = n()) %>%
  mutate(freq = n / sum(n))

write.table(yiji_erji,
            file = 'num_yiji_erji_summary.csv',
            sep = c(','),
            col.names = NA)
