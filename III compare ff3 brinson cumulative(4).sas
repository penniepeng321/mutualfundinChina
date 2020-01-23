
%let address = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';
libname ddaa 'F:\dataset_download_and_analysis\';

%let m=20180531;*fill in export date;
*********************************************************;


* compare our ranking to ff3 alpha ranking daily basis;


*********************************************************;

proc import out=brinson.ThrfacDay
datafile="F:\fund_index_weight\brinson\STK_MKT_ThrfacDay.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc import out=brinson.FivefacDay
datafile="F:\fund_index_weight\brinson\STK_MKT_FivefacDay.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.ThrfacDay1;
set brinson.ThrfacDay;
if MarkettypeID='P9706';
if RiskPremium1 ne .;
if SMB1 ne .;
if HML1 ne .;
year1=substr(TradingDate,1,4);
month1=substr(TradingDate,6,2);
day1=substr(TradingDate,9,2);
year2=input(year1,best12.);
month2=input(month1,best12.);
day2=input(day1,best12.);
rename year2=year month2=month day2=day;
run;

data brinson.ThrfacDay1;
set brinson.ThrfacDay1;
date=mdy(month,day,year);
format date date9.;
run;

proc sort data=brinson.ThrfacDay1;
by date;
run;

proc import out=brinson.dailyholding
datafile="F:\fund_index_weight\brinson\dailyholding.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.dailyholding1;
set brinson.dailyholding;
if stock_c ne .;
if stock_n ne '';
if accsum0 ne .;
run;

proc sort data=brinson.dailyholding;
by timeline stock_c;
run;

proc sort data=brinson.dailyholding1;
by timeline;
run;

proc sort data=brinson.dailyholding1;
by stock_n;
run;

*clean-up daily stock price change in R to merge with daily holding so we have;
*fund daily change;

proc import out=brinson.dc20167
datafile="F:\fund_index_weight\brinson\20167dc.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.dc20167;
set brinson.dc20167;
digitcode1=substr(STOCK_CODE,1,6);
digitcode=input(digitcode1,best12.);
chgr=PCT_CHG/100;
run;

*merge stock daily change rate with dailyholding to get fund daily change;

proc sql;
create table brinson.dcdh67 as
select a.chgr, b.*
from brinson.dc20167 as a, brinson.dailyholding1 as b 
where a.date=b.timeline and a.digitcode=b.stock_c;
run;quit;

*merge daily change rate with daily three-factor;

proc sql;
create table brinson.dctf67 as
select a.*, b.*
from brinson.dc20167 as a, brinson.ThrfacDay1 as b 
where a.date=b.date;
run;quit;

proc sort data=brinson.dctf67;
by STOCK_CODE;
run;

proc reg data=brinson.dctf67 outest=brinson.dctf67r edf  tableout  noprint;
model chgr=RiskPremium1 SMB1 HML1;
by STOCK_CODE;
quit;


*********************************************************;


* compare our ranking (semi-annual report) to 
* ff3 alpha ranking monthly basis;


*********************************************************;

proc import out=brinson.ThrfacMonth
datafile="F:\fund_index_weight\brinson\STK_MKT_ThrfacMonth.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc import out=brinson.FivefacMonth
datafile="F:\fund_index_weight\brinson\STK_MKT_FivefacMonth.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;


*******************************************************************;



* compare alpha of ff3 model with ranking here;



*******************************************************************;

*5-year sample;

data brinson.fda1;
set five.fund_benchmark_weight41;
if startdate<='01jan2013'd;
if enddate>='31dec2017'd;
if date>='01jan2013'd;
if date<='31dec2017'd;
run;

data brinson.fda1;
set brinson.fda1;
if smb ne .;
if hml ne .;
run;

/*run once;
data brinson.basic_abc;
set five.Mutualbasic_adjustabc;
keep windcode _COL2;
run;

data brinson.basic_abc;
set brinson.basic_abc;
rename _COL2=fundname;
run;*/

proc reg data=brinson.fda1 outest=brinson.fda2 edf  tableout  noprint;
model excess_return = sys_risk smb hml;
by windcode;
quit;

data brinson.fda3;
set brinson.fda2;
if _TYPE_='PARMS';
run;

proc rank data=brinson.fda3 out=brinson.fda4 descending;
var Intercept;
ranks r_alpha;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
rename fundcode=windcode;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
time=mdy(month,20,year);
format time date9.;
run;

data yfive;
set brinson.benchfundc5;
if year >= 2013;
run;

proc sort data=yfive;
by windcode;
run;

proc univariate data=yfive noprint;
   var sstks;
   by windcode;
   output out=yfivesummary NOBS=numfunds;
run;

data yfivesummary;
set yfivesummary;
if numfunds=10;
run;

proc sql;
create table yfivesummary1 as
select a.*, b.*
from yfivesummary as a left join yfive as b 
on a.windcode=b.windcode;
run;quit;

proc sort data=yfivesummary1;
by windcode time;
run;

data yfivesummary2;
set yfivesummary1;
otaa=1+staa;
oss=1+sstks;
oint=1+sinte;
otva=1+stva;
run;

proc sort data=yfivesummary2; 
by windcode time; 
run;

data yfivesummary3;
set yfivesummary2;
by windcode;
array products[*] cumtaa cumss cumint cumtva;
retain cumtaa cumss cumint cumtva;
if first.windcode then do i = 1 to dim(products);  /* Initialise products at start of id */
   products[i] = 1;
   end;
cumtaa=cumtaa*otaa;
cumss=cumss*oss;
cumint=cumint*oint;
cumtva=cumtva*otva;
run;

data yfivesummary4;
set yfivesummary3;
if reportperiod='2017年中报';
keep windcode numfunds cumtaa cumss cumint cumtva;
run;

data yfivesummary4;
set yfivesummary4;
marker=substr(windcode,1,length(windcode)-3);
run;











*****************************************************************;


*output excel to calculate correlation between ff3 and brinson;


*****************************************************************;

data brinson.multi1;
set brinson.benchfundc5;
otaa=1+staa;
oss=1+sstks;
oint=1+sinte;
otva=1+stva;
run;

proc sort data=brinson.multi1; 
by windcode time; 
run;quit;

/*
data brinson.multi1;
set brinson.multi1;
drop cumtaa cumss cumint cumtva;
run;
*/

data brinson.multi2;
set brinson.multi1;
by windcode;
array products[*] cumtaa cumss cumint cumtva;
retain cumtaa cumss cumint cumtva;
if first.windcode then do i = 1 to dim(products);  /* Initialise products at start of id */
   products[i] = 1;
   end;
cumtaa=cumtaa*otaa;
cumss=cumss*oss;
cumint=cumint*oint;
cumtva=cumtva*otva;
run;

data brinson.multi21;
set brinson.multi2;
if reportperiod='2017年中报';
run;

proc freq data=brinson.multi2 noprint;
tables windcode / out=brinson.multi3 sparse;
run;

data brinson.multi4;
set brinson.multi3;
if COUNT>=5;
run;

proc sql;
create table brinson.compare as
select a.windcode, a.COUNT, b.Intercept, c.cumtaa, c.cumss, c.cumint, c.cumtva
from brinson.multi4 as a, brinson.fda3 as b, yfivesummary4 as c 
where a.windcode=b.windcode=c.windcode;
run;quit;

PROC EXPORT DATA=brinson.compare
FILE="&address.compare&m"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

