
%let address = F:\fund_index_weight\brinson\;
%LET OUT = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';

%let m=20180515;*fill in export date;

*read in daily trade record and clean the dates. dates are saved as texts;
proc import out=brinson.dtr
datafile="E:\fund_index_weight\brinson\A基金股票交割单.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;
*no erroneous dates as in R;
*dates are texts;

data brinson.dtr1;
set brinson.dtr;
year1=substr(_COL0,1,4);
month1=substr(_COL0,5,2);
day1=substr(_COL0,7,2);
run;

data brinson.dtr1;
set brinson.dtr1;
year=input(year1,best12.);
month=input(month1,best12.);
day=input(day1,best12.);
run;

data brinson.dtr1;
set brinson.dtr1;
date1=mdy(month,day,year);
format date1 date9.;
run;

data brinson.dtr1;
set brinson.dtr1;
drop year1 month1 day1;
run;


*count freq of trade types included in the trade book;
proc freq data=brinson.dtr1;
   tables _COL3/ out=FreqCount outexpect sparse;
run;

*unify the stock code format in dtr1;
*636 and 000636 are the same stock;
data brinson.dtr1;
set brinson.dtr1;
stkcode=input(_COL1,best12.);
run;

data brinson.dtr1;
set brinson.dtr1;
if stkcode ne .;
run;

*extract entries affecting holding;
data brinson.dtr2;
set brinson.dtr1;
if _COL3='证券买入' or 
_COL3='证券卖出' or
_COL3='红股入账' or
_COL3='配股入帐' or
_COL3='新股入帐' or
_COL3='股份转出';
run;

data brinson.dtr2;
set brinson.dtr2;
rename _COL1=stockcode
_COL2=stockname
_COL3=tradetype
_COL6=tradeamount;
run;

data temp;
set brinson.dtr2;
keep stockname;
run;

proc sql;
 create table temp1 as
 select DISTINCT (stockname)
 from temp order by stockname;
quit;

*some stock name with XD means that they pay dividend that day;
*however, they are of the same stock code but the stock name with XD is trancated missing last Chinese;
*character;

data dtr3;
set brinson.dtr;
if _COL1='600999';
run;

PROC EXPORT DATA=dtr3
FILE="&address.s600999"
DBMS=xlsx REPLACE;
SHEET="stk";
RUN;

data dtr3;
set brinson.dtr;
if _COL1='603993';
run;

PROC EXPORT DATA=dtr3
FILE="&address.s603993"
DBMS=xlsx REPLACE;
SHEET="stk";
RUN;

data dtr3;
set brinson.dtr;
if _COL1='839';
run;

PROC EXPORT DATA=dtr3
FILE="&address.s839"
DBMS=xlsx REPLACE;
SHEET="stk";
RUN;




data brinson.dtr3;
set brinson.dtr2;
if stockcode='593' or stockcode='600999' or stockcode='603993';
keep stockcode stockname tradetype tradeamount date1;
run;

data brinson.dtr3;
set brinson.dtr2;
if stockcode='600999';
keep stockcode stockname tradetype tradeamount date1;
run;

data brinson.dtr3; 
set brinson.dtr3;
if tradetype='证券买入' or 
tradetype='红股入账' or
tradetype='配股入帐' or
tradetype='新股入帐'
then phold=tradeamount;
if tradetype='股份转出' or
tradetype='证券卖出' 
then phold=-tradeamount;
run;

proc sql;
create table brinson.dtr31 as
select stockcode, stockname, date1, sum(phold) as sum_trade
from brinson.dtr3
group by date1;
run;quit;

proc sql;
 create table brinson.dtr32 as
 select DISTINCT (date1), stockcode, stockname, sum_trade
 from brinson.dtr31 order by date1;
quit;

data brinson.dtr32; 
set brinson.dtr32;
retain cum_sum;
cum_sum+sum_trade;
run;



data brinson.dtr3;
set brinson.dtr2;
if stockcode='603993';
keep stockcode stockname tradetype tradeamount date1;
run;

data brinson.dtr3; 
set brinson.dtr3;
if tradetype='证券买入' or 
tradetype='红股入账' or
tradetype='配股入帐' or
tradetype='新股入帐'
then phold=tradeamount;
if tradetype='股份转出' or
tradetype='证券卖出' 
then phold=-tradeamount;
run;

proc sql;
create table brinson.dtr31 as
select stockcode, stockname, date1, sum(phold) as sum_trade
from brinson.dtr3
group by date1;
run;quit;

proc sql;
 create table brinson.dtr32 as
 select DISTINCT (date1), stockcode, stockname, sum_trade
 from brinson.dtr31 order by date1;
quit;

data brinson.dtr32; 
set brinson.dtr32;
retain cum_sum;
cum_sum+sum_trade;
run;




data brinson.dtr3;
set brinson.dtr1;
if _COL1='839';
run;

data brinson.dtr3;
set brinson.dtr2;
if stockcode='839';
keep stockcode stockname tradetype tradeamount date1;
run;

data brinson.dtr3; 
set brinson.dtr3;
if tradetype='证券买入' or 
tradetype='红股入账' or
tradetype='配股入帐' or
tradetype='新股入帐'
then phold=tradeamount;
if tradetype='股份转出' or
tradetype='证券卖出' 
then phold=-tradeamount;
run;

proc sql;
create table brinson.dtr31 as
select stockcode, stockname, date1, sum(phold) as sum_trade
from brinson.dtr3
group by date1;
run;quit;

proc sql;
 create table brinson.dtr32 as
 select DISTINCT (date1), stockcode, stockname, sum_trade
 from brinson.dtr31 order by date1;
quit;

data brinson.dtr32; 
set brinson.dtr32;
retain cum_sum;
cum_sum+sum_trade;
run;


*create trade record by simulation for one fund;
*use msci a share;
*and macd;

*create msci stock list, six-digits;

proc import out=brinson.mscialst
datafile="E:\fund_index_weight\brinson\msciashareindex.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;


*now we update brinson model from semi-annual frequency to daily frequency;

*read in simulated daily holding;
proc import out=brinson.dailyhold
datafile="E:\fund_index_weight\brinson\simulated_dailyholding1.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sort data=brinson.dailyhold;
by date;
run;

data brinson.dailyhold1;
set brinson.dailyhold;
if holding ne 0;
run;

*benchmark of this fund is MSCI A share;
*prepare daily input of index components in SAS;
*prepare daily close of MSCI A share in SAS;
*prepare MKT_CAP daily of MSCI A share in SAS;
*impute daily industry from monthly in SAS;


*prepare daily input of index components in SAS;
proc import out=brinson.dclose
datafile="F:\fund_index_weight\brinson\2017dc.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.dclose;
set brinson.dclose;
year=year(date);
month=month(date);
run;

data brinson.datelst;
set brinson.dclose;
keep date;
run;

proc sql;
 create table brinson.datelst1 as
 select DISTINCT (date)
 from brinson.datelst order by date;
quit;

data brinson.mscilst;
set brinson.mscialst;
keep windcode;
run;

proc sql;
 create table brinson.mscilst1 as
 select DISTINCT (windcode)
 from brinson.mscilst order by windcode;
quit;

proc sql;
create table brinson.dsframe as
select a.*,b.*
from brinson.datelst1 as a cross join brinson.mscilst1 as b;
run;quit;

proc sql;
create table brinson.dclose1 as
select a.*, b.*
from brinson.dsframe as a, brinson.dclose as b 
where a.WINDCODE=b.STOCK_CODE 
and a.date=b.date;
run;quit;

*the following works as well;
/*
proc sql;
create table brinson.dclose1 as
select a.*, b.*
from brinson.mscialst as a, brinson.dclose as b 
where a.WINDCODE=b.STOCK_CODE;
run;quit;*/

**monthly index components of MSCI A share;
data brinson.msciam4;
set brinson.dclose1;
if year>=2005;
run;

proc sort data=brinson.msciam4; 
by date;
run;

data brinson.msciam5;
set brinson.msciam4;
if CLOSE ne .;
run;

proc means data=brinson.msciam5 noprint;
  class DATE;
  var MKT_CAP_ARD;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table brinson.msciam6 as
select a.*, b.sumweight 
from brinson.msciam5 as a, temp1 as b 
where a.date = b.date;
run;quit;

data brinson.msciam6;
set brinson.msciam6;
nindexw=MKT_CAP_ARD/sumweight;
run;

data brinson.msciam6;
set brinson.msciam6;
rename STOCK_NAME=sec_name
STOCK_CODE=wind_code
nindexw=i_weight;
run;

data brinson.msciam6;
set brinson.msciam6;
indexcode='133333.CSI';
keep date wind_code sec_name i_weight indexcode;
run;

*daily index components of msci a share index is in brinson.msciam6;

*prepare daily close of MSCI A share in SAS in brinson.dclose1;

*impute daily industry from monthly in SAS;

data brinson.dsframe;
set brinson.dsframe;
year=year(date);
month=month(date);
run;

proc sql;
create table brinson.msciind as
select a.*, b.* 
from brinson.dsframe as a, brinson.msciam as b 
where a.year=b.year and a.month=b.month and a.windcode=b.windcode;
run;quit;

data brinson.msciind;
set brinson.msciind;
keep date WINDCODE SEC_NAME INDUSTRY_CSRC12 INDUSTRY_CSRCCODE12;
run;

proc sort data=brinson.msciind;
by date;
run;

data brinson.msciind;
set brinson.msciind;
marker=substr(WINDCODE, 1, length(WINDCODE)-3);
run;

*calculate daily return for all MSCI A share stocks;

proc sort data=brinson.dclose1;
by WINDCODE date;
run;

data brinson.dclose2;
set brinson.dclose1;
keep date windcode STOCK_NAME CLOSE year month;
run;

data brinson.dclose2;
set brinson.dclose2;
lclose=lag(close);
run;

data brinson.dclose2;
set brinson.dclose2;
by windcode;
retain i 1;
if first.windcode then do;
i=1;
pret=.;
end;
else do;
i=i+1;
pret=close/lclose-1;
end;
run;

data brinson.dclose2;
set brinson.dclose2;
if pret ne .;
run;

data brinson.dclose2;
set brinson.dclose2;
marker=substr(WINDCODE, 1, length(WINDCODE)-3);
run;

*merge stock daily return with stock daily industry;

proc sql;
create table brinson.stkdaily as
select a.*, b.* 
from brinson.msciind as a, brinson.dclose2 as b 
where a.date=b.date and a.windcode=b.windcode;
run;quit;

*standardize weights in fund holding;
data brinson.dailyhold1;
set brinson.dailyhold1;
rename stockcode=marker;
run;

proc means data=brinson.dailyhold1 noprint;
  class date;
  var holding;
  output out=brinson.dailyhold2 sum=sumweight;
run;

data brinson.dailyhold3;
set brinson.dailyhold2;
if _TYPE_=1;
keep date sumweight;
run;

proc sql;
create table brinson.dailyhold4 as
select a.*, b.sumweight 
from brinson.dailyhold1 as a, brinson.dailyhold3 as b 
where a.date=b.date;
run;quit;

data brinson.dailyhold4;
set brinson.dailyhold4;
stockweight=holding/sumweight;
run;

*now we have cleaned daily fund holding & benchmark holding;
*we merge stock daily data with these two holding datasets;

proc sql;
create table brinson.dfundhold as
select a.*, b.* 
from brinson.dailyhold4 as a, brinson.stkdaily as b 
where a.marker = b.marker and a.date=b.date;
run;quit;

proc sql;
create table brinson.dbenchhold as
select a.*, b.* 
from brinson.msciam6 as a, brinson.stkdaily as b 
where a.wind_code = b.windcode and a.date=b.date;
run;quit;

*then we collapse the benchmark holding data & fund holding data to be;
*their corresponding industry holding data;
*we need industry weight & industry return;

data brinson.dfundhold;
set brinson.dfundhold;
wpret=stockweight*pret;
run;

data brinson.dbenchhold;
set brinson.dbenchhold;
wniret=i_weight*pret;
run;

proc means data=brinson.dfundhold noprint;
  class date INDUSTRY_CSRC12;
  var stockweight wpret;
  output out=brinson.dfundhold1 sum(stockweight)=sstkw sum(wpret)=swpret;
run;

data brinson.dfundhold2;
set brinson.dfundhold1;
if _TYPE_=3;
run;

data brinson.dfundhold2;
set brinson.dfundhold2;
keep date INDUSTRY_CSRC12 sstkw swpret;
run;

proc means data=brinson.dbenchhold noprint;
  class date INDUSTRY_CSRC12;
  var i_weight wniret;
  output out=brinson.dbenchhold1 sum(i_weight)=bsstkw sum(wniret)=bswnret;
run;

data brinson.dbenchhold2;
set brinson.dbenchhold1;
if _TYPE_=3;
run;

data brinson.dbenchhold2;
set brinson.dbenchhold2;
keep date INDUSTRY_CSRC12 bsstkw bswnret;
run;

*merge the benchmark holding & fund holding data;
*use stockcode date to merge the datasets;

proc sql;
create table brinson.dbenchfund as
select a.date, a.INDUSTRY_CSRC12, a.sstkw as fwi, a.swpret as fri, 
		b.bsstkw as bwi, b.bswnret as bri
from brinson.dfundhold2 as a, brinson.dbenchhold2 as b 
where a.INDUSTRY_CSRC12=b.INDUSTRY_CSRC12 and a.date=b.date;
run;quit;

*compute brinson model sum;

data brinson.dbenchfund;
set brinson.dbenchfund;
taa=(fwi-bwi)*bri;
stks=bwi*(fri-bri);
inte=(fwi-bwi)*(fri-bri);
tva=fwi*fri-bwi*bri;
run;

proc means data=brinson.dbenchfund noprint;
  class date;
  var taa stks inte tva;
  output out=brinson.dbenchfund1 sum(taa)=staa sum(stks)=sstks sum(inte)=sinte sum(tva)=stva;
run;

data brinson.dbenchfund1;
set brinson.dbenchfund1;
if _TYPE_=1;
run;

data brinson.dbenchfund1;
set brinson.dbenchfund1;
drop _TYPE_ _FREQ_;
run;

PROC EXPORT DATA=brinson.dbenchfund1
FILE="&address.table3"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

proc univariate data=brinson.dbenchfund1;
var staa;
histogram;
run;

proc univariate data=brinson.benchfundc5;
var staa;
histogram;
run;

proc univariate data=brinson.dbenchfund1;
var sstks;
histogram;
run;

proc univariate data=brinson.benchfundc5;
var sstks;
histogram;
run;

proc univariate data=brinson.dbenchfund1;
var sinte;
histogram;
run;

proc univariate data=brinson.benchfundc5;
var sinte;
histogram;
run;

proc univariate data=brinson.dbenchfund1;
var stva;
histogram;
run;

proc univariate data=brinson.benchfundc5;
var stva;
histogram;
run;

proc sort data=brinson.benchfundc5;
by windcode reportperiod;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
time=mdy(month,20,year);
format time date9.;
run;



***************************************************************;


* daily hedge fund holding clean up;


****************************************************************;

proc import out=brinson.hfdh
datafile="F:\fund_index_weight\brinson\dailyholding.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.hfdh;
set brinson.hfdh;
if timeline ne .;
run;

proc means data=brinson.hfdh noprint;
class timeline;
var accsum0;
output out=brinson.hfdh1 sum(accsum0)=hold;
run;

data brinson.hfdh1;
set brinson.hfdh1;
if _TYPE_=1;
run;

PROC EXPORT DATA=brinson.hfdh1
FILE="&address.holdingsummary"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;


