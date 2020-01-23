%let address = E:\fund_index_weight\Download_data_for_all_mutual_funds\;
%LET OUT = E:\fund_index_weight\Download_data_for_all_mutual_funds\;
libname five 'E:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'E:\fund_index_weight\';

data five.num_total;
set five.Mutualbasic_adjustabc;
rename _COL1=fundname _COL3=benchmark _COL5=startdate _COL6=enddate _COL7=investmenttype1 
_COL8=investmenttype2 _COL9=shifoufenji;
keep windcode _COL1 fullname _COL3 _COL5 _COL6 _COL7 _COL8 _COL9;
run;

/*replace NA with space in .xlsx file before import data*/
PROC IMPORT OUT= five.fund_benchmark_weight 
/* DATAFILE= "&address.clean_fund_benchmark_weight_horizontal_monthly.xlsx" */
DATAFILE= "&address.clean_fund_benchmark_weight_horizontal_monthly20180105.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;
proc sort data=five.fund_benchmark_weight;by windcode date;run;quit;
data five.fund_benchmark_weight;
set five.fund_benchmark_weight;
if fundnav=. OR fundnav_adj=.  then delete;
run;quit;

data five.fund_benchmark_weight;
set five.fund_benchmark_weight;
year=year(date);
month=month(date);
day=day(date);
wym = compress(windcode||year||month,"");
run;

*keep entries with greatest day in each month;

*if duplicated, delete;

proc sort data=five.fund_benchmark_weight;
by wym descending day;
run;

data temp;
set five.fund_benchmark_weight;
by wym;
If first.wym then output temp;
run;

data temp;
set temp;
if year=2018 and month=1 then delete;
run;

data temp;
set temp;
if day<20 then delete;
if year<2001 then delete;
run;

data five.fund_benchmark_weight;
set temp;
run;


proc sort data=five.fund_benchmark_weight;by windcode date;run;quit;

data five.fund_benchmark_weight;
set five.fund_benchmark_weight;
fundnavlag=lag(fundnav);
fundnav_adjlag=lag(fundnav_adj);
index1_closelag=lag(index1_close);
index2_closelag=lag(index2_close);
index3_closelag=lag(index3_close);
index4_closelag=lag(index4_close);
index5_closelag=lag(index5_close);
run;quit;
data five.fund_benchmark_weight;
set five.fund_benchmark_weight;
by windcode;

retain i 1;
if first.windcode then do;
i=1;
changeratefundnav=0;
changeratefundnav_adj=0;
chgindex1=0;
chgindex2=0;
chgindex3=0;
chgindex4=0;
chgindex5=0;
end;

else do;
i=i+1;
changeratefundnav= fundnav/fundnavlag-1;
changeratefundnav_adj=  fundnav_adj/fundnav_adjlag-1;
chgindex1=  index1_close/index1_closelag-1;
chgindex2=  index2_close/index2_closelag-1;
chgindex3=  index3_close/index3_closelag-1;
chgindex4=  index4_close/index4_closelag-1;
chgindex5=  index5_close/index5_closelag-1;
end;

run;quit;

data five.fund_benchmark_weight;
set five.fund_benchmark_weight;
if interest_rate1 ne 0 then chgindex1=interest_rate1/12;
if interest_rate2 ne 0 then chgindex2=interest_rate2/12;
if interest_rate3 ne 0 then chgindex3=interest_rate3/12;
if interest_rate4 ne 0 then chgindex4=interest_rate4/12;
if interest_rate5 ne 0 then chgindex5=interest_rate5/12;
onepluschgnav=1+changeratefundnav;
onepluschgnav_adj=1+changeratefundnav_adj;
opchgindex1=1+chgindex1;
opchgindex2=1+chgindex2;
opchgindex3=1+chgindex3;
opchgindex4=1+chgindex4;
opchgindex5=1+chgindex5;
run;quit;

proc sort data=five.fund_benchmark_weight; by windcode; run;quit;

data five.fund_benchmark_weight;
set five.fund_benchmark_weight;
by windcode;

retain cumchgfundnav 1;
if first.windcode then cumchgfundnav = 1;
else cumchgfundnav=cumchgfundnav*onepluschgnav;

retain cumchgfundnav_adj 1;
if first.windcode then cumchgfundnav_adj = 1;
else cumchgfundnav_adj=cumchgfundnav_adj*onepluschgnav_adj;

retain cumchgindex1 1;
if first.windcode then cumchgindex1=1;
else cumchgindex1=cumchgindex1*opchgindex1;

retain cumchgindex2 1;
if first.windcode then cumchgindex2=1;
else cumchgindex2=cumchgindex2*opchgindex2;

retain cumchgindex3 1;
if first.windcode then cumchgindex3=1;
else cumchgindex3=cumchgindex3*opchgindex3;

retain cumchgindex4 1;
if first.windcode then cumchgindex4=1;
else cumchgindex4=cumchgindex4*opchgindex4;

retain cumchgindex5 1;
if first.windcode then cumchgindex5=1;
else cumchgindex5=cumchgindex5*opchgindex5;

drop fundnavlag fundnav_adjlag index1_closelag index2_closelag 
index3_closelag index4_closelag index5_closelag onepluschgnav
onepluschgnav_adj opchgindex1 opchgindex2 opchgindex3 opchgindex4
opchgindex5;

Benchmark_ret = SUM(index1_weight*chgindex1*(1-index1_tax),
index2_weight*chgindex2*(1-index2_tax),
index3_weight*chgindex3*(1-index3_tax),
index4_weight*chgindex4*(1-index4_tax),
index5_weight*chgindex5*(1-index5_tax));

/*first date for every fund, benchmark return = . */
if i = 1 then Benchmark_ret = .;

run;quit;

data five.fund_benchmark_weight;
set five.fund_benchmark_weight;
drop i chgindex1 chgindex2 chgindex3 chgindex4 chgindex5
cumchgindex1 cumchgindex2 cumchgindex3 cumchgindex4 cumchgindex5;
run;


PROC EXPORT 
DATA=five.fund_benchmark_weight
DBMS=excel
OUTFILE="&address.fund_benchmark_weight.xlsx"
REPLACE;
run;

/*
PROC IMPORT OUT= hs300
DATAFILE= "&address.hs300.xlsx" 
DBMS=EXCEL REPLACE;
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;quit;

data five.hs300;
set hs300;
year = year(datetime);
month = month(datetime);
y_m = compress(year||month,"");
keep datetime close year month y_m;
run;

*change to monthly data;
proc sort data=five.hs300; by y_m datetime; run;

data five.hs300;
set five.hs300;
by y_m;
if last.y_m;
if datetime ne  .;
run;
*/

data five.fund_benchmark_weight;
set five.fund_benchmark_weight;
*year = year(date);
*month = month(date);
y_m = compress(year||month,"");
run;quit;

proc sort data=five.fund_benchmark_weight; by year month; run;
proc sort data=self_ben.wandequanA3; by year month; run;

data fund_benchmark_weight1;
merge five.fund_benchmark_weight(in=xxx) self_ben.wandequanA3;
by  year month;
if xxx;
run;

proc sort data=five.fund_benchmark_weight; by year month; run;
proc sort data=five.hs300; by year month; run;
data fund_benchmark_weight11;
merge five.fund_benchmark_weight(in=xxx) five.hs300;
by  year month;
if xxx;
run;

proc sort data=fund_benchmark_weight11; by windcode year month; run;

data fund_benchmark_weight11;
set fund_benchmark_weight11;
by windcode year month;

ret_hs = close / lag(close) - 1;
if i=1 then do;
ret_hs = 0;
Benchmark_ret=0;
end;

opchghs=1+ret_hs;
retain cumchghs 1;
if first.windcode then cumchghs=1;
else cumchghs=cumchghs*opchghs;

opchgBench=1+Benchmark_ret;
retain cumchgBench 1;
if first.windcode then cumchgBench=1;
else cumchgBench=cumchgBench*opchgBench;

run;quit;


/*
After merge, they only kept the obs with nonNA close price in wandequanA data
*/
proc sort data=fund_benchmark_weight1; by windcode year month; run;

data fund_benchmark_weight1;
set fund_benchmark_weight1;
by windcode year month;

ret_winda = close / lag(close) - 1;
if i=1 then do;
ret_winda = 0;
Benchmark_ret=0;
end;

opchgwinda=1+ret_winda;
retain cumchgwinda 1;
if first.windcode then cumchgwinda=1;
else cumchgwinda=cumchgwinda*opchgwinda;

opchgBench=1+Benchmark_ret;
retain cumchgBench 1;
if first.windcode then cumchgBench=1;
else cumchgBench=cumchgBench*opchgBench;

run;quit;

/*some closed-end funds have dates before 2001, this closed-end fund actually
has no benchmark reported but filled in with wandequana as a proxy*/

data fund_benchmark_weight1;
set fund_benchmark_weight1;
drop i opchgwinda opchgBench datetime;
rename close=winda;
run;

data fund_benchmark_weight11;
set fund_benchmark_weight11;
drop i opchghs opchgBench datetime;
rename close=hs;
run;

data rf_ym;
set self_ben.rf_rate;
keep rf year month;
run;

proc sort data=rf_ym noduprecs;
by _all_ ; Run;


proc sort data=fund_benchmark_weight1; by year month; run;
proc sort data=rf_ym; by year month; run;
data fund_benchmark_weight2;
merge fund_benchmark_weight1(in=xxx) rf_ym;
by year month;
if xxx;
run;

proc sort data=fund_benchmark_weight11; by year month; run;
proc sort data=rf_ym; by year month; run;
data fund_benchmark_weight21;
merge fund_benchmark_weight11(in=xxx) rf_ym;
by year month;
if xxx;
run;

/*
proc sql;
create table fund_benchmark_weight2 as
select a.*, b.*
from fund_benchmark_weight1 as a, rf_ym as b
where a.year=b.year and a.month=b.month;
quit;
*/

proc sort data=self_ben.ff3_monthly20180105; by year month; run;
proc sort data=fund_benchmark_weight2; by year month; run;
data table fund_benchmark_weight3;
merge fund_benchmark_weight2(in=xxx) self_ben.ff3_monthly20180105;
by year month;
if xxx;
run;

proc sort data=self_ben.ff3_monthly20180105; by year month; run;
proc sort data=fund_benchmark_weight21; by year month; run;
data table fund_benchmark_weight31;
merge fund_benchmark_weight21(in=xxx) self_ben.ff3_monthly20180105;
by year month;
if xxx;
run;

/*
proc sql;
create table fund_benchmark_weight3 as
select a.*, b.*
from fund_benchmark_weight2 as a , self_ben.ff3_monthly20180105 as b
where a.year = b.year and a.month=b.month;
run;quit;
*/

data fund_benchmark_weight3;
set fund_benchmark_weight3;
drop _NAME_ BH BL BM SH SL SM;
run;

data fund_benchmark_weight31;
set fund_benchmark_weight31;
drop _NAME_ BH BL BM SH SL SM;
run;


proc sort data=fund_benchmark_weight3; by year month; run;
proc sort data=self_ben.ff_mom_monthly2; by year month; run;
data fund_benchmark_weight4;
merge fund_benchmark_weight3(in=xxx) self_ben.ff_mom_monthly20180105;
by year month;
if xxx;
run;

proc sort data=fund_benchmark_weight31; by year month; run;
proc sort data=self_ben.ff_mom_monthly2; by year month; run;
data fund_benchmark_weight41;
merge fund_benchmark_weight31(in=xxx) self_ben.ff_mom_monthly20180105;
by year month;
if xxx;
run;

/*
proc sql;
create table fund_benchmark_weight4 as
select a.*, b.*
from fund_benchmark_weight3 as a , self_ben.ff_mom_monthly2 as b
where a.year = b.year and a.month=b.month;
run;quit;
*/

data five.fund_benchmark_weight3;
set fund_benchmark_weight4;
benchmark_adjusted_return=changeratefundnav_adj-Benchmark_ret;
Benchmark_ret_adj=Benchmark_ret-(rf/12);
Benchmark_ret_adjsq=Benchmark_ret_adj**2;
excess_return=changeratefundnav_adj-(rf/12);
sys_risk=ret_winda-(rf/12);
sys_square=(ret_winda-(rf/12))**2;
run;

data five.fund_benchmark_weight31;
set fund_benchmark_weight41;
benchmark_adjusted_return=changeratefundnav_adj-Benchmark_ret;
Benchmark_ret_adj=Benchmark_ret-(rf/12);
Benchmark_ret_adjsq=Benchmark_ret_adj**2;
excess_return=changeratefundnav_adj-(rf/12);
sys_risk=ret_hs-(rf/12);
sys_square=(ret_hs-(rf/12))**2;
run;

proc sort data=five.fund_benchmark_weight3;by windcode;run;

data five.fund_benchmark_weight4;
set five.fund_benchmark_weight3;
if erji in ('普通股票型基金','偏股混合型基金', '灵活配置型基金');
if smb ne .;
if hml ne .;
if fundnav ne .;
if fundnav_adj ne .;
run;

proc sort data=five.fund_benchmark_weight31;by windcode;run;

data five.fund_benchmark_weight41;
set five.fund_benchmark_weight31;
if erji in ('普通股票型基金','偏股混合型基金', '灵活配置型基金');
if smb ne .;
if hml ne .;
if fundnav ne .;
if fundnav_adj ne .;
run;

data five.fund_benchmark_weight4;
set five.fund_benchmark_weight4;
if enddate='05DEC2017'd then enddate='03JAN2018'd;
if enddate=. then enddate='03JAN2018'd;
run;

data five.fund_benchmark_weight41;
set five.fund_benchmark_weight41;
if enddate='05DEC2017'd then enddate='03JAN2018'd;
if enddate=. then enddate='03JAN2018'd;
run;

/*
data five.fund_benchmark_weight4;
set five.fund_benchmark_weight4;
where windcode not in
('373020.OF',
'200001.OF',
'257010.OF',
'540003.OF',
'750005.OF',
'519029.OF');
run;
*/

