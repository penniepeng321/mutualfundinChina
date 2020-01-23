%let address = E:\fund_index_weight\Download_data_for_all_mutual_funds\;
%LET OUT = E:\fund_index_weight\Download_data_for_all_mutual_funds\;
libname ddd 'E:\fund_index_weight\Download_data_for_all_mutual_funds\';
*save fund_benchmark_BD_ED_weight_vertical.csv as excel;
*set index_code and index_name to be text in excel;
PROC IMPORT OUT= ddd.vertical
            DATAFILE= "&address.fund_benchmark_BD_ED_weight_vertical.xlsx" 
            DBMS=excel REPLACE; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
data vertical1;
set ddd.vertical;
keep index_code index_name;
run;
data vertical2;
set vertical1;
rename index_code=index_c index_name=index_n;
run;
data vertical3;
set ddd.index_code_name_dictionary vertical2;
run;

PROC SORT DATA=vertical3
 OUT=index_code_name_dictionary
 NODUPRECS ;
 BY index_n ;
RUN ;

/*
proc sql;
create table ddd.index_code_name_dictionary as
select DISTINCT (index_n),index_c
from vertical3
order by index_c;
quit;*/

PROC EXPORT 
DATA=index_code_name_dictionary
DBMS=excel
OUTFILE="&address.index_code_name_dictionary20180103.xlsx"
REPLACE;
run;






PROC IMPORT OUT= ddd.fund_benchmark_weight_monthly
            DATAFILE= "&address.clean_fund_benchmark_weight_horizontal_monthly20170824.xlsx" 
            DBMS=excel REPLACE; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
data temp1;
set ddd.fund_benchmark_weight_monthly;
keep index1 index1_name;
rename index1=index_c index1_name=index_n;
run;
data temp2;
set ddd.fund_benchmark_weight_monthly;
keep index2 index2_name;
rename index2=index_c index2_name=index_n;
run;
data temp3;
set ddd.fund_benchmark_weight_monthly;
keep index3 index3_name;
rename index3=index_c index3_name=index_n;
run;
data temp4;
set ddd.fund_benchmark_weight_monthly;
keep index4 index4_name;
rename index4=index_c index4_name=index_n;
run;
data temp5;
set ddd.fund_benchmark_weight_monthly;
keep index5 index5_name;
rename index5=index_c index5_name=index_n;
run;
data temp;
set temp1 temp2;
run;
data temp;
set temp temp3;
run;
data temp;
set temp temp4;
run;
data temp;
set temp temp5;
run;

PROC SQL;
INSERT INTO temp
VALUES ("881001.WI","ÍòµÃÈ«A");
QUIT;

/*this works too.

data temp1;
set ddd.fund_benchmark_weight_monthly;
keep index1 index1_name;
run;
data temp2;
set ddd.fund_benchmark_weight_monthly;
keep index2 index2_name;
run;
data temp3;
set ddd.fund_benchmark_weight_monthly;
keep index3 index3_name;
run;
data temp4;
set ddd.fund_benchmark_weight_monthly;
keep index4 index4_name;
run;
data temp5;
set ddd.fund_benchmark_weight_monthly;
keep index5 index5_name;
run;
data temp;
set 
	temp1(rename=(index1=index_c index1_name=index_n))
	temp2(rename=(index2=index_c index2_name=index_n))
	temp3(rename=(index3=index_c index3_name=index_n))
	temp4(rename=(index4=index_c index4_name=index_n))
	temp5(rename=(index5=index_c index5_name=index_n));
run;
*/

proc sql;
create table ddd.index_code_name_dictionary as
select DISTINCT (index_c),index_n
from temp
order by index_c;
quit;




PROC EXPORT 
DATA=ddd.index_code_name_dictionary
DBMS=excel
OUTFILE="&address.index_code_name_dictionary.xlsx"
REPLACE;
run;
