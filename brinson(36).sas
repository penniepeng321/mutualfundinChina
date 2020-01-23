
%let address = F:\fund_index_weight\brinson\;
%LET OUT = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';

%let m=20180522;*fill in export date;

*to check assumption of no holding change between holding report semiannual;
*compare return under assumption & fund ret;

proc import out=brinson.fundnav
datafile="F:\fund_index_weight\brinson\clean_fund_benchmark_weight_horizontal_monthly20180105.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

*fundnav has duplicate observations in it;
*we delete duplicate obs first;
*we have dec5 and dec30 obs in it;
*we delete dec5 not month-end;
*we have 1.6206111968 and 1.620611197 taken as difference obs;
*indeed we need to rid of these duplicate ones as well;

data brinson.fundnav;
set brinson.fundnav;
fnavadj=round(fundnav_adj,0.0001);
run;

proc sql;
 create table brinson.fnav_nodup as
 select DISTINCT (windcode), fnavadj, date, erji
 from brinson.fundnav order by windcode;
quit;

proc sort data=brinson.fnav_nodup;
by windcode date;
run;

data brinson.fnav_nodup;
set brinson.fnav_nodup;
if date ne '05DEC2017'd and date ne '13OCT2017'd and date ne '16OCT2017'd
and date ne '03JAN2018'd;
run;

data brinson.fnav_nodup1;
set brinson.fnav_nodup;
year=year(date);
month=month(date);
run;

data brinson.fnav_nodup1;
set brinson.fnav_nodup1;
if month=6 or month=12;
run;

data brinson.fnav_nodup1;
set brinson.fnav_nodup1; 
if erji='普通股票型基金' or erji='偏股混合型基金' or erji='灵活配置型基金';
run;

proc sort data=brinson.fnav_nodup1;
by windcode date;
run;

data brinson.fnav_nodup1;
set brinson.fnav_nodup1;
lnav=lag(fnavadj);
run;

data brinson.fnav_nodup1;
set brinson.fnav_nodup1;
by windcode;
retain i 1;
if first.windcode then do;
i=1;
pret=.;
end;
else do;
i=i+1;
pret=fnavadj/lnav-1;
end;
run;

data brinson.fnav_nodup1;
set brinson.fnav_nodup1;
keep year month windcode pret;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
rename fundcode=windcode;
run;

proc sort data=brinson.benchfundc5;
by windcode year month;
run;

proc sort data=brinson.fnav_nodup1;
by windcode year month;
run;

data brinson.aspcheck;
merge brinson.benchfundc5(in=a) brinson.fnav_nodup1(in=b);
by windcode year month;
if a;
run;

*83021536;

data brinson.aspcheck;
set brinson.aspcheck;
prem=stva-pret;
run;

proc univariate data=brinson.aspcheck;
var prem;
histogram /barlabel=percent midpoints=-2 to 1 by 0.1;
run;

PROC EXPORT DATA=brinson.aspcheck
FILE="&address.table2"
DBMS=xlsx REPLACE;
SHEET="全期平均";
RUN;

proc sort data=brinson.aspcheck;
by reportperiod;
run;
proc univariate data=brinson.aspcheck;
var prem;
by reportperiod;
histogram /barlabel=percent midpoints=-2 to 1 by 0.1;
run;


*calculate turnover rate of stocks held;
proc sort data=brinson.ptgp;
by fundcode reportperiod;
run;

proc compare base=brinson.ptgp
out=stkturn outnoequal outbase outcomp outdif noprint;
by fundcode reportperiod;
var stockcode;
with stockcode1;
run;

data brinson.zptgp2017;
set brinson.zptgp2017;
rename _COL0=fundcode _COL3=stockcode;
run;

data brinson.nptgp2016;
set brinson.nptgp2016;
rename _COL0=fundcode _COL3=stockcode;
run;

proc sort data=brinson.zptgp2017;
by fundcode;
run;

proc sort data=brinson.nptgp2016;
by fundcode;
run;

proc compare base=brinson.zptgp2017
compare=brinson.nptgp2016
out=stkturn outnoequal outbase outcomp outdif noprint;
by fundcode;
var stockcode;
run;
*it does not work;
*I plan to use R to make this analysis;

PROC EXPORT DATA=brinson.ptgp
FILE="&address.ptgp"
DBMS=xlsx REPLACE;
SHEET="全期平均";
RUN;

*import results calculated in r;

proc import out=brinson.stkturnover
datafile="F:\fund_index_weight\brinson\stkturnover.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc univariate data=brinson.stkturnover;
var t2;
histogram /barlabel=percent midpoints=-0.1 to 1 by 0.1;
run;

proc sort data=brinson.stkturnover;
by year report;
run;

proc univariate data=brinson.stkturnover;
var t1;
by year report;
histogram /barlabel=percent midpoints=-0.1 to 1 by 0.1;
run;



/*
*some ptgp stock mutual funds summary;

data brinson.allfunds;
set funds;
run;

data brinson.ptgpfunds;
set brinson.allfunds;
if _COL10='普通股票型基金';
run;

data brinson.ptgpf05;
set brinson.ptgpfunds;
if _COL6<'01Jan2007'd;
run;
*/

/*program to read in data, run only once*/

%macro readata(y);

proc import out=brinson.nptgp&y
datafile="F:\fund_index_weight\brinson\全部持股(明细)&y.nptgp.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.nptgp&y;
format _COL0 $30.;
informat _COL0 $30.;
length _COL0 $30;
format _COL1 $30.;
informat _COL1 $30.;
length _COL1 $30;
format _COL4 $30.;
informat _COL4 $30.;
length _COL4 $30;
format _COL12 $30.;
informat _COL12 $30.;
length _COL12 $30;
set brinson.nptgp&y;
year=&y;
report='n';
run;

data brinson.ptgp;
set brinson.ptgp brinson.nptgp&y;
run;

proc import out=brinson.zptgp&y
datafile="F:\fund_index_weight\brinson\全部持股(明细)&y.zptgp.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.zptgp&y;
format _COL0 $30.;
informat _COL0 $30.;
length _COL0 $30;
format _COL1 $30.;
informat _COL1 $30.;
length _COL1 $30;
format _COL4 $30.;
informat _COL4 $30.;
length _COL4 $30;
format _COL12 $30.;
informat _COL12 $30.;
length _COL12 $30;
set brinson.zptgp&y;
year=&y;
report='z';
run;

data brinson.ptgp;
set brinson.ptgp brinson.zptgp&y;
run;


proc import out=brinson.npghh&y
datafile="F:\fund_index_weight\brinson\全部持股(明细)&y.npghh.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.npghh&y;
format _COL0 $30.;
informat _COL0 $30.;
length _COL0 $30;
format _COL1 $30.;
informat _COL1 $30.;
length _COL1 $30;
format _COL4 $30.;
informat _COL4 $30.;
length _COL4 $30;
format _COL12 $30.;
informat _COL12 $30.;
length _COL12 $30;
set brinson.npghh&y;
year=&y;
report='n';
run;

data brinson.ptgp;
set brinson.ptgp brinson.npghh&y;
run;

proc import out=brinson.zpghh&y
datafile="F:\fund_index_weight\brinson\全部持股(明细)&y.zpghh.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.zpghh&y;
format _COL0 $30.;
informat _COL0 $30.;
length _COL0 $30;
format _COL1 $30.;
informat _COL1 $30.;
length _COL1 $30;
format _COL4 $30.;
informat _COL4 $30.;
length _COL4 $30;
format _COL12 $30.;
informat _COL12 $30.;
length _COL12 $30;
set brinson.zpghh&y;
year=&y;
report='z';
run;

data brinson.ptgp;
set brinson.ptgp brinson.zpghh&y;
run;


proc import out=brinson.nlhpz&y
datafile="F:\fund_index_weight\brinson\全部持股(明细)&y.nlhpz.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.nlhpz&y;
format _COL0 $30.;
informat _COL0 $30.;
length _COL0 $30;
format _COL1 $30.;
informat _COL1 $30.;
length _COL1 $30;
format _COL4 $30.;
informat _COL4 $30.;
length _COL4 $30;
format _COL12 $30.;
informat _COL12 $30.;
length _COL12 $30;
set brinson.nlhpz&y;
year=&y;
report='n';
run;

data brinson.ptgp;
set brinson.ptgp brinson.nlhpz&y;
run;

proc import out=brinson.zlhpz&y
datafile="F:\fund_index_weight\brinson\全部持股(明细)&y.zlhpz.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.zlhpz&y;
format _COL0 $30.;
informat _COL0 $30.;
length _COL0 $30;
format _COL1 $30.;
informat _COL1 $30.;
length _COL1 $30;
format _COL4 $30.;
informat _COL4 $30.;
length _COL4 $30;
format _COL12 $30.;
informat _COL12 $30.;
length _COL12 $30;
set brinson.zlhpz&y;
year=&y;
report='z';
run;

data brinson.ptgp;
set brinson.ptgp brinson.zlhpz&y;
run;

%mend readata;

data brinson.ptgp;
set _null_;run;

%macro loopf1;

data _null_;
%do i=2003 %to 2017;
%readata(&i);
%end;
run;

%mend;

%loopf1;


/*create the list of all stocks covered by all the mutual funds*/

data brinson.ptgp;
set brinson.ptgp;
rename _COL0=windcode _COL1=fundname _COL2=reportperiod _COL3=stockcode _COL4=stockname 
_COL5=holdingq _COL6=chgholdingq _COL8=holdingp _COL9=prop_nav 
_COL10=prop_stock_inv;
run;

/*
data brinson.summary;
set brinson.ptgp;
keep windcode fundname reportperiod year report;
run;

proc sql;
 create table brinson.summary1 as
 select DISTINCT (windcode), fundname, reportperiod, year, report
 from brinson.summary order by windcode;
quit;
*/

proc means data=brinson.ptgp noprint;
  class reportperiod windcode;
  var holdingp;
  output out=brinson.summary sum=stkcap;
run;

data brinson.summary1;
set brinson.summary;
if _TYPE_=3;
run;

proc sql;
create table brinson.ptgp9 as
select a.*, b.* 
from brinson.summary1 as a, brinson.ptgp as b 
where a.windcode = b.windcode and a.reportperiod = b.reportperiod;
run;quit;

data brinson.ptgp9;
set brinson.ptgp9;
if report='n' then month=12;
if report='z' then month=6;
run;

data brinson.ptgp9;
set brinson.ptgp9;
timer=mdy(month,22,year);
format timer date9.;
run;

data brinson.ptgp9;
set brinson.ptgp9;
drop _TYPE_;
rename _FREQ_=numstkheld;
run;

data brinson.summary;
set brinson.ptgp9;
keep windcode fundname reportperiod numstkheld stkcap timer;
run;

proc sql;
 create table brinson.summary1 as
 select DISTINCT (windcode), fundname, reportperiod, numstkheld, stkcap, timer
 from brinson.summary order by windcode;
quit;

proc sort data=brinson.summary1;
by timer;
run;

PROC EXPORT DATA=brinson.summary1
FILE="&address.numstkheld20180505"
DBMS=xlsx REPLACE;
SHEET="全期平均";
RUN;

*ptgp9 contains holding of funds with complex, missing or fixed-rate benchmark;
*ptgp10 does not;

*brinson.summary1 has all the data entries summarized over stocks held by each fund;
*it is fund cross holding report level;
*we merge brinson.summary1 with hand-marked funds basic info;
*to exclude funds with fixed-rate benchmark;

proc import out=brinson.jizhun
datafile="F:\jizhun20180505.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

*I marked missing, complex or fixed-rate benchmark funds by hand;
*Data is in jizhun;

data brinson.jizhun1;
set brinson.jizhun;
if _COL2='普通股票型基金' or _COL2='偏股混合型基金' or _COL2='灵活配置型基金';;
run;

PROC EXPORT DATA=brinson.jizhun1
FILE="F:\jizhunppl20180505"
DBMS=xlsx REPLACE;
SHEET="全期平均";
RUN;

data brinson.summary1;
set brinson.summary1;
marker=substr(windcode,1,length(windcode)-3);
run;

data brinson.jizhun1;
set brinson.jizhun1;
marker=substr(_COL0,1,length(_COL0)-3);
run;

*merge holding data summary by fund & reportperiod;
*and fund basic info jizhun1 using marker;

proc sql;
create table summary2 as
select a.*, b._COL2 as tzlxej, b._COL3 as yjbjjz, b.indicator
from brinson.summary1 as a left join brinson.jizhun1 as b 
on a.marker=b.marker;
run;quit;

data summary3;
set summary2;
if indicator = 0;
run;

data brinson.summary2;
set summary3;
drop indicator;
run;

*brinson.summary2 excluded funds with missing or fixed-rate benchmark;

proc sort data=brinson.summary2;
by timer windcode;
run;

proc univariate data=brinson.summary1 noprint;
   var stkcap;
   by timer;
   output out=brinson.allsummary NOBS=numfunds MEAN=mstkcap SUM=hstkcap
STD=dstkcap MIN=istkcap MAX=astkcap pctlpts=5 25 50 75 95
                    pctlpre = stkcap
                    pctlname = pct5 pct25 pct50 pct75 pct95;
run;

proc univariate data=brinson.summary2 noprint;
   var stkcap;
   by timer;
   output out=brinson.allsummaryE1 NOBS=numfunds MEAN=mstkcap SUM=hstkcap
STD=dstkcap MIN=istkcap MAX=astkcap pctlpts=5 25 50 75 95
                    pctlpre = stkcap
                    pctlname = pct5 pct25 pct50 pct75 pct95;
run;

proc univariate data=brinson.summary1 noprint;
   var numstkheld;
   by timer;
   output out=brinson.allsummary1 NOBS=numfunds MEAN=mstkcap SUM=hstkcap
STD=dstkcap MIN=istkcap MAX=astkcap pctlpts=5 25 50 75 95
                    pctlpre = numstkheld
                    pctlname = pct5 pct25 pct50 pct75 pct95;
run;

proc univariate data=brinson.summary2 noprint;
   var numstkheld;
   by timer;
   output out=brinson.allsummaryE2 NOBS=numfunds MEAN=mstkcap SUM=hstkcap
STD=dstkcap MIN=istkcap MAX=astkcap pctlpts=5 25 50 75 95
                    pctlpre = numstkheld
                    pctlname = pct5 pct25 pct50 pct75 pct95;
run;

PROC EXPORT DATA=brinson.allsummaryE2
FILE="&address.fundsum20180505"
DBMS=xlsx REPLACE;
SHEET="全期平均";
RUN;

data brinson.summary;
set brinson.ptgp9;
if _COL11='普通股票型基金';
keep windcode fundname reportperiod numstkheld stkcap timer;
run;

proc sql;
 create table brinson.summary1 as
 select DISTINCT (windcode), fundname, reportperiod, numstkheld, stkcap, timer
 from brinson.summary order by windcode;
quit;

data brinson.summary1;
set brinson.summary1;
marker=substr(windcode,1,length(windcode)-3);
run;

proc sql;
create table summary2 as
select a.*, b._COL2 as tzlxej, b._COL3 as yjbjjz, b.indicator
from brinson.summary1 as a left join brinson.jizhun1 as b 
on a.marker=b.marker;
run;quit;

data summary3;
set summary2;
if indicator = 0;
run;

data brinson.summary2;
set summary3;
drop indicator;
run;

*brinson.summary2 excluded funds with missing or fixed-rate benchmark;

proc sort data=brinson.summary2;
by timer windcode;
run;

proc sort data=brinson.summary1;
by timer;
run;

proc univariate data=brinson.summary1 noprint;
   var stkcap;
   by timer;
   output out=brinson.ptgpsummary NOBS=numfunds MEAN=mstkcap SUM=hstkcap
STD=dstkcap MIN=istkcap MAX=astkcap pctlpts=5 25 50 75 95
                    pctlpre = stkcap
                    pctlname = pct5 pct25 pct50 pct75 pct95;
run;

proc univariate data=brinson.summary2 noprint;
   var stkcap;
   by timer;
   output out=brinson.ptgpsummaryE1 NOBS=numfunds MEAN=mstkcap SUM=hstkcap
STD=dstkcap MIN=istkcap MAX=astkcap pctlpts=5 25 50 75 95
                    pctlpre = stkcap
                    pctlname = pct5 pct25 pct50 pct75 pct95;
run;

proc univariate data=brinson.summary1 noprint;
   var numstkheld;
   by timer;
   output out=brinson.ptgpsummary1 NOBS=numfunds MEAN=mstkcap SUM=hstkcap
STD=dstkcap MIN=istkcap MAX=astkcap pctlpts=5 25 50 75 95
                    pctlpre = numstkheld
                    pctlname = pct5 pct25 pct50 pct75 pct95;
run;

proc univariate data=brinson.summary2 noprint;
   var numstkheld;
   by timer;
   output out=brinson.ptgpsummaryE2 NOBS=numfunds MEAN=mstkcap SUM=hstkcap
STD=dstkcap MIN=istkcap MAX=astkcap pctlpts=5 25 50 75 95
                    pctlpre = numstkheld
                    pctlname = pct5 pct25 pct50 pct75 pct95;
run;



data brinson.summary;
set brinson.ptgp9;
if _COL11='偏股混合型基金';
keep windcode fundname reportperiod numstkheld stkcap timer;
run;

proc sql;
 create table brinson.summary1 as
 select DISTINCT (windcode), fundname, reportperiod, numstkheld, stkcap, timer
 from brinson.summary order by windcode;
quit;

data brinson.summary1;
set brinson.summary1;
marker=substr(windcode,1,length(windcode)-3);
run;

proc sql;
create table summary2 as
select a.*, b._COL2 as tzlxej, b._COL3 as yjbjjz, b.indicator
from brinson.summary1 as a left join brinson.jizhun1 as b 
on a.marker=b.marker;
run;quit;

data summary3;
set summary2;
if indicator = 0;
run;

data brinson.summary2;
set summary3;
drop indicator;
run;

*brinson.summary2 excluded funds with missing or fixed-rate benchmark;

proc sort data=brinson.summary2;
by timer windcode;
run;

proc sort data=brinson.summary1;
by timer;
run;

proc univariate data=brinson.summary1 noprint;
   var stkcap;
   by timer;
   output out=brinson.pghhsummary NOBS=numfunds MEAN=mstkcap SUM=hstkcap
STD=dstkcap MIN=istkcap MAX=astkcap pctlpts=5 25 50 75 95
                    pctlpre = stkcap
                    pctlname = pct5 pct25 pct50 pct75 pct95;
run;

proc univariate data=brinson.summary2 noprint;
   var stkcap;
   by timer;
   output out=brinson.pghhsummaryE1 NOBS=numfunds MEAN=mstkcap SUM=hstkcap
STD=dstkcap MIN=istkcap MAX=astkcap pctlpts=5 25 50 75 95
                    pctlpre = stkcap
                    pctlname = pct5 pct25 pct50 pct75 pct95;
run;

proc univariate data=brinson.summary1 noprint;
   var numstkheld;
   by timer;
   output out=brinson.pghhsummary1 NOBS=numfunds MEAN=mstkcap SUM=hstkcap
STD=dstkcap MIN=istkcap MAX=astkcap pctlpts=5 25 50 75 95
                    pctlpre = numstkheld
                    pctlname = pct5 pct25 pct50 pct75 pct95;
run;

proc univariate data=brinson.summary2 noprint;
   var numstkheld;
   by timer;
   output out=brinson.pghhsummaryE2 NOBS=numfunds MEAN=mstkcap SUM=hstkcap
STD=dstkcap MIN=istkcap MAX=astkcap pctlpts=5 25 50 75 95
                    pctlpre = numstkheld
                    pctlname = pct5 pct25 pct50 pct75 pct95;
run;



data brinson.summary;
set brinson.ptgp9;
if _COL11='灵活配置型基金';
keep windcode fundname reportperiod numstkheld stkcap timer;
run;

proc sql;
 create table brinson.summary1 as
 select DISTINCT (windcode), fundname, reportperiod, numstkheld, stkcap, timer
 from brinson.summary order by windcode;
quit;

data brinson.summary1;
set brinson.summary1;
marker=substr(windcode,1,length(windcode)-3);
run;

proc sql;
create table summary2 as
select a.*, b._COL2 as tzlxej, b._COL3 as yjbjjz, b.indicator
from brinson.summary1 as a left join brinson.jizhun1 as b 
on a.marker=b.marker;
run;quit;

data summary3;
set summary2;
if indicator = 0;
run;

data brinson.summary2;
set summary3;
drop indicator;
run;

*brinson.summary2 excluded funds with missing or fixed-rate benchmark;

proc sort data=brinson.summary2;
by timer windcode;
run;

proc sort data=brinson.summary1;
by timer;
run;

proc univariate data=brinson.summary1 noprint;
   var stkcap;
   by timer;
   output out=brinson.lhpzsummary NOBS=numfunds MEAN=mstkcap SUM=hstkcap
STD=dstkcap MIN=istkcap MAX=astkcap pctlpts=5 25 50 75 95
                    pctlpre = stkcap
                    pctlname = pct5 pct25 pct50 pct75 pct95;
run;

proc univariate data=brinson.summary2 noprint;
   var stkcap;
   by timer;
   output out=brinson.lhpzsummaryE1 NOBS=numfunds MEAN=mstkcap SUM=hstkcap
STD=dstkcap MIN=istkcap MAX=astkcap pctlpts=5 25 50 75 95
                    pctlpre = stkcap
                    pctlname = pct5 pct25 pct50 pct75 pct95;
run;

proc univariate data=brinson.summary1 noprint;
   var numstkheld;
   by timer;
   output out=brinson.lhpzsummary1 NOBS=numfunds MEAN=mstkcap SUM=hstkcap
STD=dstkcap MIN=istkcap MAX=astkcap pctlpts=5 25 50 75 95
                    pctlpre = numstkheld
                    pctlname = pct5 pct25 pct50 pct75 pct95;
run;

proc univariate data=brinson.summary2 noprint;
   var numstkheld;
   by timer;
   output out=brinson.lhpzsummaryE2 NOBS=numfunds MEAN=mstkcap SUM=hstkcap
STD=dstkcap MIN=istkcap MAX=astkcap pctlpts=5 25 50 75 95
                    pctlpre = numstkheld
                    pctlname = pct5 pct25 pct50 pct75 pct95;
run;


*program to export the summary results;

data p1;
set brinson.summary1;
keep timer reportperiod;
run;

proc sql;
 create table brinson.rptimer as
 select DISTINCT (timer), reportperiod
 from p1 order by timer;
quit;

data r1;
set brinson.allsummaryE1;
keep timer mstkcap dstkcap numfunds;
run;

data r2;
set brinson.allsummaryE2;
keep timer mstkcap dstkcap numfunds;
run;

proc sql;
create table r3 as
select a.*, b.mstkcap as mstkheld, b.dstkcap as dstkheld
from r1 as a left join r2 as b 
on a.timer=b.timer;
run;quit;

proc sql;
create table r4 as
select a.*, b.numfunds as numfunds1
from r3 as a left join brinson.allsummary1 as b 
on a.timer=b.timer;
run;quit;

data r4;
set r4;
numfdrop=numfunds1-numfunds;
run;

proc sql;
create table r5 as
select a.*, b.reportperiod
from r4 as a left join brinson.rptimer as b 
on a.timer=b.timer;
run;quit;

data brinson.allr;
set r5;
run;

data r6;
set r5;
keep reportperiod numfunds mstkcap dstkcap mstkheld dstkheld;
run;

*unit of cap is wan yuan 10^4;

data r6;
retain reportperiod numfunds mstkheld dstkheld mstkcap dstkcap;
set r6;
run;

PROC EXPORT DATA=r6
FILE="F:\allfsummary20180505"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

PROC EXPORT DATA=brinson.allr
FILE="F:\allr20180505"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;


data r1;
set brinson.ptgpsummaryE1;
keep timer mstkcap dstkcap numfunds;
run;

data r2;
set brinson.ptgpsummaryE2;
keep timer mstkcap dstkcap numfunds;
run;

proc sql;
create table r3 as
select a.*, b.mstkcap as mstkheld, b.dstkcap as dstkheld
from r1 as a left join r2 as b 
on a.timer=b.timer;
run;quit;

proc sql;
create table r4 as
select a.*, b.numfunds as numfunds1
from r3 as a left join brinson.ptgpsummary1 as b 
on a.timer=b.timer;
run;quit;

data r4;
set r4;
numfdrop=numfunds1-numfunds;
run;

proc sql;
create table r5 as
select a.*, b.reportperiod
from r4 as a left join brinson.rptimer as b 
on a.timer=b.timer;
run;quit;

data brinson.ptgpr;
set r5;
run;

data r6;
set r5;
keep reportperiod numfunds mstkcap dstkcap mstkheld dstkheld;
run;

*unit of cap is wan yuan 10^4;

data r6;
retain reportperiod numfunds mstkheld dstkheld mstkcap dstkcap;
set r6;
run;

PROC EXPORT DATA=r6
FILE="F:\ptgpfsummary20180505"
DBMS=xlsx REPLACE;
SHEET="ptgp";
RUN;





data r1;
set brinson.pghhsummaryE1;
keep timer mstkcap dstkcap numfunds;
run;

data r2;
set brinson.pghhsummaryE2;
keep timer mstkcap dstkcap numfunds;
run;

proc sql;
create table r3 as
select a.*, b.mstkcap as mstkheld, b.dstkcap as dstkheld
from r1 as a left join r2 as b 
on a.timer=b.timer;
run;quit;

proc sql;
create table r4 as
select a.*, b.numfunds as numfunds1
from r3 as a left join brinson.pghhsummary1 as b 
on a.timer=b.timer;
run;quit;

data r4;
set r4;
numfdrop=numfunds1-numfunds;
run;

proc sql;
create table r5 as
select a.*, b.reportperiod
from r4 as a left join brinson.rptimer as b 
on a.timer=b.timer;
run;quit;

data brinson.pghhr;
set r5;
run;

data r6;
set r5;
keep reportperiod numfunds mstkcap dstkcap mstkheld dstkheld;
run;

*unit of cap is wan yuan 10^4;

data r6;
retain reportperiod numfunds mstkheld dstkheld mstkcap dstkcap;
set r6;
run;

PROC EXPORT DATA=r6
FILE="F:\pghhfsummary20180505"
DBMS=xlsx REPLACE;
SHEET="pghh";
RUN;




data r1;
set brinson.lhpzsummaryE1;
keep timer mstkcap dstkcap numfunds;
run;

data r2;
set brinson.lhpzsummaryE2;
keep timer mstkcap dstkcap numfunds;
run;

proc sql;
create table r3 as
select a.*, b.mstkcap as mstkheld, b.dstkcap as dstkheld
from r1 as a left join r2 as b 
on a.timer=b.timer;
run;quit;

proc sql;
create table r4 as
select a.*, b.numfunds as numfunds1
from r3 as a left join brinson.lhpzsummary1 as b 
on a.timer=b.timer;
run;quit;

data r4;
set r4;
numfdrop=numfunds1-numfunds;
run;

proc sql;
create table r5 as
select a.*, b.reportperiod
from r4 as a left join brinson.rptimer as b 
on a.timer=b.timer;
run;quit;

data brinson.lhpzr;
set r5;
run;

data r6;
set r5;
keep reportperiod numfunds mstkcap dstkcap mstkheld dstkheld;
run;

*unit of cap is wan yuan 10^4;

data r6;
retain reportperiod numfunds mstkheld dstkheld mstkcap dstkcap;
set r6;
run;

PROC EXPORT DATA=r6
FILE="F:\lhpzfsummary20180505"
DBMS=xlsx REPLACE;
SHEET="lhpz";
RUN;




/*
data temp;
set brinson.ptgp;
keep stockcode stockname;
run;

proc sql;
 create table brinson.stockpool as
 select DISTINCT (stockcode), stockname
 from temp order by stockcode;
quit;

PROC EXPORT DATA=brinson.stockpool
FILE="&address.stocklist&m"
DBMS=xlsx REPLACE;
SHEET="a1";
RUN;

*no need to do this. we used all stocks including delisted ones to download stock monthly data;
*/

/*
data brinson.ptgp1;
set brinson.ptgp;
rename windcode=fundcode _COL12=firm;*_COL0=fundcode _COL1=fundname;
run;

data brinson.fundlist;
set brinson.ptgp1;
keep fundcode;
run;

proc sql;
 create table brinson.fundlist1 as
 select DISTINCT (fundcode)
 from brinson.fundlist order by fundcode;
quit;
*/

*this is to create list of all A-share stock indices covered by benchmark;

proc import out=brinson.mutualbasicv
datafile="F:\fund_index_weight\brinson\fund_benchmark_BD_ED_weight_vertical.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.mutualbasicv;
set brinson.mutualbasicv;
if index_name='恒生金融行业指数收益率' then index_code='HSFSI.HI';
run;

*所有公募基金的基本信息包括已到期纵向表格;

data brinson.ptgpv;
set brinson.mutualbasicv;
if erji='普通股票型基金' or erji='偏股混合型基金' or erji='灵活配置型基金';
run;

data brinson.indices;
set brinson.ptgpv;
keep index_code index_name;
run;

proc sql;
 create table brinson.indices1 as
 select DISTINCT (index_code), index_name
 from brinson.indices order by index_code;
quit;

*delete duplicate combo of index code and name;

*indices starting with M is interest rate code which does not contain any stock; 

data brinson.indices1;
set brinson.indices1;
ii=SUBSTR(index_code,1,1);
run;

data brinson.indices1;
set brinson.indices1;
if ii ne 'M';
run;

*indices containing % are interest rate as well;

data brinson.indices1;
set brinson.indices1;
ir=find(index_code,'%');
run;

data brinson.indices1;
set brinson.indices1;
if ir = 0;
run;

data brinson.indices1;
set brinson.indices1;
drop ii ir;
run;

*delete 恒生 indices which covers H-share only and do not show stock components;
/*
data brinson.indices1;
set brinson.indices1;
ir=find(index_name,'恒生');
run;

data brinson.indices1;
set brinson.indices1;
if ir = 0;
run;

data brinson.indices1;
set brinson.indices1;
drop ir;
run;
*/

*delete 债 indices which covers debts only and do not show stock components;

data brinson.indices1;
set brinson.indices1;
ir=find(index_name,'债');
run;

data brinson.indices1;
set brinson.indices1;
if ir = 0;
run;

data brinson.indices1;
set brinson.indices1;
drop ir;
run;

*delete 利率 indices which do not show stock components;

data brinson.indices1;
set brinson.indices1;
ir=find(index_name,'利率');
run;

data brinson.indices1;
set brinson.indices1;
if ir = 0;
run;

data brinson.indices1;
set brinson.indices1;
drop ir;
run;

*delete 存款 indices which do not show stock components;

data brinson.indices1;
set brinson.indices1;
ir=find(index_name,'存款');
run;

data brinson.indices1;
set brinson.indices1;
if ir = 0;
run;

data brinson.indices1;
set brinson.indices1;
drop ir;
run;

*delete CI*****.WI zhongxin hangye zhishu since they do not show stock components as well;
*we download zhongxin industry for every A-share stock;
*we will replace it with industry ME-weighted stocks;

data brinson.indices1;
set brinson.indices1;
ii=SUBSTR(index_code,1,2);
run;

data brinson.indices1;
set brinson.indices1;
if ii ne 'CI';
run;

data brinson.indices1;
set brinson.indices1;
drop ii;
run;


*keep only index_code and delete duplicate index_code;

data brinson.indices2;
set brinson.indices1;
keep index_code;
run;

proc sql;
 create table brinson.indices3 as
 select DISTINCT (index_code)
 from brinson.indices1 order by index_code;
quit;

*only 57 indices need to be downloaded for their stock components;
*semiannually from 2003.06.end to 2017.12.end;
*we need the monthly stock components of these indices;
*extract to excel then to R to download the data;

PROC EXPORT DATA=brinson.indices3
FILE="&address.indexlist&m"
DBMS=xlsx REPLACE;
SHEET="a1";
RUN;

*extract basic info of both open-end and closed-end stock mutual funds;

*analyze ptgp semiannual holding;
*check to see which funds are not covered by Wind all mutual funds list;
*Now Ive seen closed-end funds in 2003-2004 uncovered;

data brinson.ptgp;
set brinson.ptgp;
rename windcode=fundcode;
run;

data brinson.ptgp_f;
set brinson.ptgp;
keep fundcode fundname;
run;

proc sql;
 create table brinson.ptgp_fl as
 select DISTINCT (fundcode), fundname
 from brinson.ptgp_f order by fundcode;
quit;

proc import out=brinson.flist
datafile="F:\fund_index_weight\brinson\fundlist.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.flist;
format _COL0 $38.;
informat _COL0 $38.;
set brinson.flist;
rename _COL0=fundcode _COL1=fundname _COL2=fullname;
run;

data brinson.ptgp_fl;
format fundname $38.;
informat fundname $38.;
set brinson.ptgp_fl;
run;

data brinson.flist;
format fundname $38.;
informat fundname $38.;
set brinson.flist;
run;

proc sort data=brinson.ptgp_fl;by fundcode;run;
proc sort data=brinson.flist;by fundcode;run;
data temp;
merge brinson.ptgp_fl(in=b) brinson.flist(in=a);
by fundcode;
if b;
run;

*check funds not in Wind all fundslist;
data brinson.sfunds;
set temp;
if fullname='';
run;

*they end in SZ or SH not OF as in Wind all fundslist;
data brinson.ptgp_fl;
set brinson.ptgp_fl;
codel=reverse(substr(reverse(strip(fundcode)),1,2));
pl=find(strip(fundcode),'OF');
po=find(strip(fundcode),'SZ');
ph=find(strip(fundcode),'SH');
place=max(pl,po,ph);
coder=substr(strip(fundcode),1,(place-2));
run;

proc freq data=brinson.ptgp_fl;
   tables codel/ out=FreqCount sparse;
run;

data brinson.flist;
set brinson.flist;
codel=reverse(substr(reverse(strip(fundcode)),1,2));
place=find(strip(fundcode),'OF');
coder=substr(strip(fundcode),1,(place-2));
run;

proc freq data=brinson.flist;
   tables codel/ out=FreqCount sparse;
run;

*merge by number only excluding SH SZ or OF;
proc sort data=brinson.ptgp_fl;by coder;run;
proc sort data=brinson.flist;by coder;run;
data temp;
merge brinson.ptgp_fl(in=b) brinson.flist(in=a);
by coder;
if b;
run;

*check to see whether empty fund fullname;
data temp1;
set temp;
if fullname='';
run;
*no empty fund fullname; 
*they are all listed in Wind;

*check to see whether duplicate fund fullname;
data temp1;
set temp;
keep fullname;
run;

proc sql;
 create table temp2 as
 select DISTINCT (fullname)
 from temp1 order by fullname;
quit;
*duplicate fund fullname exists;
*duplicate fundname does not exist;

*we should not use this table from mutual research which;
*removed duplicate fund fullname;
*we should construct a counterpart of this table that;
*includes all funds with duplicate fund fullname;

*It does not matter actually;
*Later on, we used all funds vertical table;
*but actually in fund holding data, it already removed duplicate ones;
*so it does not matter which vertical table we use;

/*
proc import out=brinson.amutual
datafile="F:\fund_index_weight\brinson\amutualbasic.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.amutual;
set brinson.amutual;
rename _COL0=fundcode
_COL1=fundname
_COL2=fullname
_COL3=benchmark
_COL4=startdate
_COL5=enddate
_COL6=yiji
_COL7=erji
_COL8=fenji;
run;
*/

proc import out=brinson.amutual
datafile="F:\fund_index_weight\brinson\amutual20180508.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.amutual;
set brinson.amutual;
rename _COL0=fundcode
_COL1=fundname
_COL2=fullname
_COL3=benchmark
_COL4=startdate
_COL5=enddate
_COL6=yiji
_COL7=erji
_COL8=fenji;
run;

*run 1.R to transform amutual.sas dataset to vertical fund benchmark table;
*save csv as excel workbook;
*import updated vertical benchmark table including all funds;

proc import out=brinson.mutualbasicv
datafile="F:\fund_index_weight\brinson\fund_benchmark_vertical20180508.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.ptgpv;
set brinson.mutualbasicv;
if erji='普通股票型基金' or erji='偏股混合型基金' or erji='灵活配置型基金';
run;

*export this table to clean up NA's in indexcode;
PROC EXPORT DATA=brinson.ptgpv
FILE="&address.ptgpv20180508"
DBMS=xlsx REPLACE;
SHEET="a1";
RUN;

*import data after cleaning NA's in indexcode;
proc import out=brinson.ptgpv
datafile="F:\fund_index_weight\brinson\ptgpv20180508.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

*update dictionary;
data juk;
set brinson.ptgpv;
keep index_code index_name;
rename index_code=index_c index_name=index_n;
run;

data brinson.indexdictionary;
set brinson.dic23 juk;
run;

proc sql;
 create table brinson.indexdictionary1 as
 select DISTINCT (index_c), index_n
 from brinson.indexdictionary order by index_c;
quit;
*the updated index dictionary is brinson.indexdictionary1;

*clean up self benchmark data so that we keep only stock indices and normalize weights to be 1;
*so that later we can merge benchmark holding with this data;
*we got ptgp vertical benchmark table from mutual fund analysis;
*we remove irrelevant indices in it;
data brinson.ptgpv1;
set brinson.ptgpv;
ii=find(index_name,'利率');
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
if ii=0;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
drop ii;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
ii=find(index_name,'债');
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
if ii=0;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
drop ii;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
ii=find(index_name,'万得全');
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
if ii=0;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
drop ii;
run;

/*
data brinson.ptgpv1;
set brinson.ptgpv1;
ii=find(index_name,'恒生');
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
if ii=0;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
drop ii;
run;
*/

data brinson.ptgpv1;
set brinson.ptgpv1;
ii=SUBSTR(index_code,1,1);
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
if ii ne 'M';
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
drop ii;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
ii=find(index_name,'存款');
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
if ii=0;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
drop ii;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
ii=find(index_name,'定存');
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
if ii=0;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
drop ii;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
ii=find(index_name,'%');
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
if ii=0;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
drop ii;
run;

data jip;
set brinson.ptgpv1;
keep index_code index_name;
run;

proc sql;
 create table jip1 as
 select DISTINCT (index_code), index_name
 from jip order by index_code;
quit;

*after cleaning up the indices to include only stock indices, we standardize the indices weights;
*standardization here does not equal (x-mean)/sd, it means x/sum(x_i) so that summation is 1;

proc means data=brinson.ptgpv1 noprint;
  class windcode;
  var index_weight;
  output out=brinson.ptgpo1 sum=sumweight;
run;

data brinson.ptgpo2;
set brinson.ptgpo1;
if _TYPE_=1;
keep windcode sumweight;
run;

/*data brinson.ptgpo2;
set brinson.ptgpo1 (firstobs=2);
keep windcode sumweight;
run;*/

proc sql;
create table brinson.ptgpvo1 as
select a.*, b.sumweight 
from brinson.ptgpv1 as a left join brinson.ptgpo2 as b 
on a.windcode = b.windcode;
run;quit;

*2912 data entries in brinson.ptgpv1;
*2912 in brinson.ptgpvo1 as well;

data brinson.ptgpvo1;
set brinson.ptgpvo1;
nindexw=index_weight/sumweight;
run;

*replace some indices with easier proxies;
/*
data brinson.ptgpvo1;
set brinson.ptgpvo1;
nindexcode=index_code;
if index_code='816000.CI' then nindexcode='000300.SH';
run;
*/

*now starts model;

proc import out=brinson.indexcomponents
datafile="F:\fund_index_weight\brinson\indexcomponents20180226.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc import out=brinson.stkmonthly
datafile="F:\fund_index_weight\brinson\stkmonthlydata20180226.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc import out=brinson.stkmo1
datafile="F:\fund_index_weight\brinson\stkmonthlydata20180304_1.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc import out=brinson.stkmo2
datafile="F:\fund_index_weight\brinson\stkmonthlydata20180304_2.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc import out=brinson.stkmo3
datafile="F:\fund_index_weight\brinson\stkmonthlydata20180304_3.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

*clean up h share monthly data; 
*the rest part is for a share only;
*this is to add h share into consideration as well;

data brinson.hsmon1;
format SEC_NAME $38.;
informat SEC_NAME $38.;
set brinson.hsmon;
if close ne 0;
if close ne .;
if IPO_DATE ne .;
run;

data brinson.hsmon1;
set brinson.hsmon1;
year=year(datetime);
month=month(datetime);
run;

data brinson.hshy1;
set brinson.hsmon1;
if month=6 or month=12;
run;

proc sort data=brinson.hshy1;
by WINDCODE datetime;
run;

/*
data brinson.hshy1;
set brinson.hshy1;
if INDUSTRY_HS ne '';
run;
*/
*if missing industry, we should probably keep it and see what we can do with it later;

data brinson.hshy1;
set brinson.hshy1;
lclose=lag(close);
run;

data brinson.hshy1;
set brinson.hshy1;
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

*clean up stock monthly data;
*hand import stkmonthly csv into sas library, too large to open in excel;
*2018/3/5 I download data to be two parts 40M+60M or so;
*import these two dataset and set them together;
*due to date types problem, I split one dateset into two, which makes three datasets;
*stockmonthly20180304_1 20180304_2 20180304_add;

data brinson.stkmo1;
format SEC_NAME $38.;
informat SEC_NAME $38.;
set brinson.stkmo1;
if close ne 0;
if close ne .;
run;

data brinson.stkmo2;
format SEC_NAME $38.;
informat SEC_NAME $38.;
set brinson.stkmo2;
if close ne 0;
if close ne .;
run;

data brinson.stkmo3;
format SEC_NAME $38.;
informat SEC_NAME $38.;
set brinson.stkmo3;
if close ne 0;
if close ne .;
run;

data brinson.stkmonthly;
set brinson.stkmo1 brinson.stkmo2 brinson.stkmo3;
run;

proc sql;
 create table temp as
 select DISTINCT (SEC_NAME), DATETIME, WINDCODE, INDUSTRY_CITIC, INDUSTRY_CITICCODE,
 INDUSTRY_CSRC12, INDUSTRY_CSRCCODE12, CLOSE, MKT_CAP_FLOAT
 from brinson.stkmonthly order by SEC_NAME;
quit;

data brinson.stkmonthly;
set temp;
run;

*close char to close numeric;
data brinson.stkmonthly;
set brinson.stkmonthly;
close1=input(strip(close),best12.);
run;

data brinson.stkmonthly1;
set brinson.stkmonthly;
drop close;
run;

data brinson.stkmonthly1;
set brinson.stkmonthly1;
rename close1=close;
run;

data brinson.stkmonthly1;
set brinson.stkmonthly1;
if close ne .;
run;

*replace nan with missing values in sas;
proc sql;
     update brinson.stkmonthly1
         set INDUSTRY_CITIC=tranwrd(INDUSTRY_CITIC,'NaN','');
quit;

proc sql;
     update brinson.stkmonthly1
	 set INDUSTRY_CITICCODE=tranwrd(INDUSTRY_CITICCODE,'NaN','');
quit;

*drop redundant var;
data brinson.stkmonthly1;
set brinson.stkmonthly1;
drop VAR1;
run;

data brinson.stkmonthly1;
set brinson.stkmonthly1;
year=year(datetime);
month=month(datetime);
run;

data brinson.stksemiann;
set brinson.stkmonthly1;
if month=6 or month=12;
run;

*calculate semi-annual return for all stocks;

proc sort data=brinson.stksemiann;
by WINDCODE datetime;
run;

/*
data brinson.stksemiann;
set brinson.stksemiann;
if INDUSTRY_CSRC12 ne '';
run;
*/

*this is where some stocks went missing;
*there are stocks with INDUSTRY_CSRC but missing INDUSTRY_CSRCCODE12;
*we should not drop stock prices data with no CSRC industry classification code;
*If it has no classification, it should belong to the same no class group;

data brinson.stksemiann1;
set brinson.stksemiann;
lclose=lag(close);
run;

data brinson.stksemiann1;
set brinson.stksemiann1;
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

/*
data brinson.stksemiann3;
set brinson.stksemiann2;
run;
*/

*merge a share half-year return & h share half_year return;

data hshy2;
set brinson.hshy1;
if MKT_CAP_FLOAT ne 'NA';
if IPO_DATE ne .;
INDUSTRY_CITIC='';
run; 

data hshy2;
format INDUSTRY_HS $40.;
informat INDUSTRY_HS $40.;
format INDUSTRY_CITIC $40.;
informat INDUSTRY_CITIC $40.;
set hshy2;
me1=input(MKT_CAP_FLOAT,best18.);
run;

data hshy2;
set hshy2;
rename INDUSTRY_HS=INDUSTRY_CSRC12
me1=MKT_CAP_FLOAT;
keep sec_name windcode datetime INDUSTRY_HS INDUSTRY_CITIC me1 close pret;
run;

data stksemiann2;
format MKT_CAP_FLOAT best18.;
informat MKT_CAP_FLOAT best18.;
format INDUSTRY_CSRC12 $40.;
informat INDUSTRY_CSRC12 $40.;
format INDUSTRY_CITIC $40.;
informat INDUSTRY_CITIC $40.;
set brinson.stksemiann1;
keep sec_name windcode datetime INDUSTRY_CSRC12 INDUSTRY_CITIC MKT_CAP_FLOAT close pret;
run;

data tempo;
set hshy2 stksemiann2;
run;

data brinson.stksemiann1;
set tempo;
run;

data brinson.stksemiann1;
set brinson.stksemiann1;
year=year(datetime);
month=month(datetime);
run;


*hand import index components data using import wizard;

proc import out=brinson.icomp
datafile="F:\fund_index_weight\brinson\indexcomponents20180304.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.indexcomponents;
set brinson.icomp;
run;

/*data brinson.indexcomponents;
set brinson.indexcomponents;
drop VAR1 CODE;
run;*/

*delete duplicate entries due to data downloading;

proc sql;
 create table dindexcomp as
 select DISTINCT (indexcode), i_weight, sec_name, wind_code, date
 from brinson.indexcomponents order by indexcode;
quit;

proc sort data=dindexcomp; by date indexcode; run;

data brinson.indexcomponents;
set dindexcomp;
run;

*convert numeric date to date type;
/*data brinson.indexcomponents;
set brinson.indexcomponents;
format date date9.;
informat date date9.;
run;*/

*ADD ZHONGXIN industry holding by hand to indexcomponents dataset;

data brinson.stksemiann1;
set brinson.stksemiann1;
format datetime date9.;
informat datetime date9.;
run;

*convert me from character to numeric;
data brinson.stksemiann1;
set brinson.stksemiann1;
*me1=input(MKT_CAP_FLOAT,best30.);
me1=MKT_CAP_FLOAT;
run;

*CI005013.WI zhongxin qiche;
*CI005018.WI zhongxin yiyao;
*CI005019.WI shipin yinliao;
*CI005020.WI nonglin muyu;
*CI005025.WI dianzi yuanqijian;
*CI005026.WI tongxin;
*CI005027.WI jisuanji;

data brinson.stksemiann2;
set brinson.stksemiann1;
qci=find(INDUSTRY_CITIC,'汽车');
yyi=find(INDUSTRY_CITIC,'医药');
spi=find(INDUSTRY_CITIC,'食品');
nli=find(INDUSTRY_CITIC,'农林');
yqji=find(INDUSTRY_CITIC,'电子元器件');
txi=find(INDUSTRY_CITIC,'通信');
jsji=find(INDUSTRY_CITIC,'计算机');
run;


*zhongxin qiche;

data temp;
set brinson.stksemiann2;
if qci ne 0;
run;

data temp;
set temp;
indexcode='CI005013.WI';
run;

proc sort data=temp; by datetime; run;

proc means data=temp noprint;
  class DATETIME;
  var me1;
  output out=temp1 sum=sumweight;
run;

data temp1;
set temp1;
if _TYPE_=1;
run;

proc sql;
create table brinson.qiche as
select a.*, b.sumweight 
from temp as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data brinson.qiche;
set brinson.qiche;
nindexw=me1/sumweight;
run;

data brinson.qiche;
set brinson.qiche;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.qiche;
format sec_name $38.;
informat sec_name $38.;
set brinson.qiche;
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
format sec_name $38.;
informat sec_name $38.;
set brinson.indexcomponents;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.qiche;
run;

*zhongxin yiyao;

data temp;
set brinson.stksemiann2;
if yyi ne 0;
run;

data temp;
set temp;
indexcode='CI005018.WI';
run;

proc sort data=temp; 
by datetime; 
run;

proc means data=temp noprint;
  class DATETIME;
  var me1;
  output out=temp1 sum=sumweight;
run;

data temp1;
set temp1;
if _TYPE_=1;
run;

proc sql;
create table brinson.yiyao as
select a.*, b.sumweight 
from temp as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data brinson.yiyao;
set brinson.yiyao;
nindexw=me1/sumweight;
run;

data brinson.yiyao;
set brinson.yiyao;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.yiyao;
set brinson.yiyao;
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.yiyao;
run;

*shipinyinliao;

data temp;
set brinson.stksemiann2;
if spi ne 0;
run;

data temp;
set temp;
indexcode='CI005019.WI';
run;

proc sort data=temp; by datetime; run;

proc means data=temp noprint;
  class DATETIME;
  var me1;
  output out=temp1 sum=sumweight;
run;

data temp1;
set temp1;
if _TYPE_=1;
run;

proc sql;
create table brinson.shipin as
select a.*, b.sumweight 
from temp as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data brinson.shipin;
set brinson.shipin;
nindexw=me1/sumweight;
run;

data brinson.shipin;
set brinson.shipin;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.shipin;
set brinson.shipin;
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.shipin;
run;

*nonglin muyu;

data temp;
set brinson.stksemiann2;
if nli ne 0;
run;

data temp;
set temp;
indexcode='CI005020.WI';
run;

proc sort data=temp; by datetime; run;

proc means data=temp noprint;
  class DATETIME;
  var me1;
  output out=temp1 sum=sumweight;
run;

data temp1;
set temp1;
if _TYPE_=1;
run;

proc sql;
create table brinson.muyu as
select a.*, b.sumweight 
from temp as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data brinson.muyu;
set brinson.muyu;
nindexw=me1/sumweight;
run;

data brinson.muyu;
set brinson.muyu;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.muyu;
set brinson.muyu;
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.muyu;
run;

*yuanqijian;

data temp;
set brinson.stksemiann2;
if yqji ne 0;
run;

data temp;
set temp;
indexcode='CI005025.WI';
run;

proc sort data=temp; by datetime; run;

proc means data=temp noprint;
  class DATETIME;
  var me1;
  output out=temp1 sum=sumweight;
run;

data temp1;
set temp1;
if _TYPE_=1;
run;

proc sql;
create table brinson.yuanqij as
select a.*, b.sumweight 
from temp as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data brinson.yuanqij;
set brinson.yuanqij;
nindexw=me1/sumweight;
run;

data brinson.yuanqij;
set brinson.yuanqij;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.yuanqij;
set brinson.yuanqij;
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.yuanqij;
run;

*tongxin;

data temp;
set brinson.stksemiann2;
if txi ne 0;
run;

data temp;
set temp;
indexcode='CI005026.WI';
run;

proc sort data=temp; by datetime; run;

proc means data=temp noprint;
  class DATETIME;
  var me1;
  output out=temp1 sum=sumweight;
run;

data temp1;
set temp1;
if _TYPE_=1;
run;

proc sql;
create table brinson.tongx as
select a.*, b.sumweight 
from temp as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data brinson.tongx;
set brinson.tongx;
nindexw=me1/sumweight;
run;

data brinson.tongx;
set brinson.tongx;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.tongx;
set brinson.tongx;
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.tongx;
run;

*jisuanji;

data temp;
set brinson.stksemiann2;
if jsji ne 0;
run;

data temp;
set temp;
indexcode='CI005027.WI';
run;

proc sort data=temp; by datetime; run;

proc means data=temp noprint;
  class DATETIME;
  var me1;
  output out=temp1 sum=sumweight;
run;

data temp1;
set temp1;
if _TYPE_=1;
run;

proc sql;
create table brinson.jisuan as
select a.*, b.sumweight 
from temp as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data brinson.jisuan;
set brinson.jisuan;
nindexw=me1/sumweight;
run;

data brinson.jisuan;
set brinson.jisuan;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.jisuan;
set brinson.jisuan;
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.jisuan;
run;

*add MSCI China A share index into indexcomponents by hand;
*download MSCI A share list from Wind;
*apply stockmonthly.R to download MSCI stock monthly data;
*replace NaN and NA;
*delete redundant columns;
*import wizard: import msci monthly data into work. library;
data brinson.msciam;
set mscia;
run;

*this way imports the data well;
proc import out=mscia1
datafile="F:\fund_index_weight\brinson\mscimonthlydata20180304.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

*msci a share index starts in 2005 may;
*we download indexcomponents semi-annually;
*we by hand calculate msci a share index from 2005z;
data brinson.msciam;
set brinson.msciam;
year=year(DATETIME);
month=month(DATETIME);
run;

data brinson.msciam1;
set brinson.msciam;
if month=6 or month=12;
if year>=2005;
run;

proc sort data=brinson.msciam1; 
by datetime;
run;

*delete . missing close price of stocks;
data brinson.msciam2;
set brinson.msciam1;
if CLOSE ne .;
run;

proc means data=brinson.msciam2 noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table brinson.msciam3 as
select a.*, b.sumweight 
from brinson.msciam2 as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data brinson.msciam3;
set brinson.msciam3;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data brinson.msciam3;
set brinson.msciam3;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.msciam3;
set brinson.msciam3;
indexcode='133333.CSI';
keep date wind_code sec_name i_weight indexcode;
run;
* I checked benchmark index dictionary and saw that no index code 133333.CSI exists in it;
* it is likely that this index was not used;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.msciam3;
run;


*add hengsheng index components by hand into index components dataset;

proc import out=hpart1
datafile="F:\fund_index_weight\brinson\Hmonthlydata20180228.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc import out=hpart2
datafile="F:\fund_index_weight\brinson\Hmonthlydata20180331.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data hpart11;
informat SEC_NAME $38.;
format SEC_NAME $38.;
informat WINDCODE $18.;
format WINDCODE $18.;
set hpart1;
run;

data hpart21;
informat SEC_NAME $38.;
format SEC_NAME $38.;
informat WINDCODE $18.;
format WINDCODE $18.;
set hpart2;
run;

data brinson.hsmon;
set hpart11 hpart21;
run;

*HSI.HI hengshengzhishu;
*HSCI.HI hengshengzonghezhishu;
*HSHCI.HI hengshengyiliaobaojianzhishu;
*HSFSI.HI hengshengjinronghangyezhishu;

proc import out=HSI
datafile="F:\fund_index_weight\brinson\hsihihengshengzhishu.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table hsimon as
select a.sec_name, a.windcode, b.datetime, b.INDUSTRY_HS, b.MKT_CAP_FLOAT, b.CLOSE
from HSI as a, brinson.hsmon as b 
where a.windcode = b.windcode;
run;quit;

data hsimon;
set hsimon;
if MKT_CAP_FLOAT ne 'NA';
run;

data hsimon;
set hsimon;
me=input(MKT_CAP_FLOAT,best30.);
run;

proc sort data=hsimon;
by DATETIME;
run;

data hsimon;
set hsimon;
year=year(datetime);
run;

data hsimon;
set hsimon;
if year>=2005;
run;

proc means data=hsimon noprint;
  class DATETIME;
  var me;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table hsimon1 as
select a.*, b.sumweight 
from hsimon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data hsimon1;
set hsimon1;
nindexw=me/sumweight;
run;

data hsimon1;
set hsimon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.hsimon;
set hsimon1;
indexcode='HSI.HI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.hsimon;
run;




*HSCI.HI hengshengzonghezhishu;
*HSHCI.HI hengshengyiliaobaojianzhishu;
*HSFSI.HI hengshengjinronghangyezhishu;

proc import out=HSCI
datafile="F:\fund_index_weight\brinson\hscihihengshengzonghezhishu.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table HSCImon as
select a.sec_name, a.windcode, b.datetime, b.INDUSTRY_HS, b.MKT_CAP_FLOAT, b.CLOSE
from HSCI as a, brinson.hsmon as b 
where a.windcode = b.windcode;
run;quit;

data HSCImon;
set HSCImon;
if MKT_CAP_FLOAT ne 'NA';
run;

data HSCImon;
set HSCImon;
me=input(MKT_CAP_FLOAT,best30.);
run;

proc sort data=HSCImon;
by DATETIME;
run;

data HSCImon;
set HSCImon;
year=year(datetime);
run;

data HSCImon;
set HSCImon;
if year>=2005;
run;

proc means data=HSCImon noprint;
  class DATETIME;
  var me;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table HSCImon1 as
select a.*, b.sumweight 
from HSCImon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data HSCImon1;
set HSCImon1;
nindexw=me/sumweight;
run;

data HSCImon1;
set HSCImon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.HSCImon;
set HSCImon1;
indexcode='HSCI.HI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.HSCImon;
informat sec_name $38.;
format sec_name $38.;
set brinson.HSCImon;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.HSCImon;
run;




*HSHCI.HI hengshengyiliaobaojianzhishu;
*HSFSI.HI hengshengjinronghangyezhishu;

proc import out=HSHCI
datafile="F:\fund_index_weight\brinson\HSHCIhengshengyiliaobaojian.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table HSHCImon as
select a.sec_name, a.windcode, b.datetime, b.INDUSTRY_HS, b.MKT_CAP_FLOAT, b.CLOSE
from HSHCI as a, brinson.hsmon as b 
where a.windcode = b.windcode;
run;quit;

data HSHCImon;
set HSHCImon;
if MKT_CAP_FLOAT ne 'NA';
run;

data HSHCImon;
set HSHCImon;
me=input(MKT_CAP_FLOAT,best30.);
run;

proc sort data=HSHCImon;
by DATETIME;
run;

data HSHCImon;
set HSHCImon;
year=year(datetime);
run;

data HSHCImon;
set HSHCImon;
if year>=2005;
run;

proc means data=HSHCImon noprint;
  class DATETIME;
  var me;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table HSHCImon1 as
select a.*, b.sumweight 
from HSHCImon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data HSHCImon1;
set HSHCImon1;
nindexw=me/sumweight;
run;

data HSHCImon1;
set HSHCImon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.HSHCImon;
set HSHCImon1;
indexcode='HSHCI.HI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.HSHCImon;
informat sec_name $38.;
format sec_name $38.;
set brinson.HSHCImon;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.HSHCImon;
run;




*HSFSI.HI hengshengjinronghangyezhishu;

proc import out=HSFSI
datafile="F:\fund_index_weight\brinson\HSFSIhengshengjinrong.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table HSFSImon as
select a.sec_name, a.windcode, b.datetime, b.INDUSTRY_HS, b.MKT_CAP_FLOAT, b.CLOSE
from HSFSI as a, brinson.hsmon as b 
where a.windcode = b.windcode;
run;quit;

data HSFSImon;
set HSFSImon;
if MKT_CAP_FLOAT ne 'NA';
run;

data HSFSImon;
set HSFSImon;
me=input(MKT_CAP_FLOAT,best30.);
run;

proc sort data=HSFSImon;
by DATETIME;
run;

data HSFSImon;
set HSFSImon;
year=year(datetime);
run;

data HSFSImon;
set HSFSImon;
if year>=2005;
run;

proc means data=HSFSImon noprint;
  class DATETIME;
  var me;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table HSFSImon1 as
select a.*, b.sumweight 
from HSFSImon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data HSFSImon1;
set HSFSImon1;
nindexw=me/sumweight;
run;

data HSFSImon1;
set HSFSImon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.HSFSImon;
set HSFSImon1;
indexcode='HSFSI.HI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.HSFSImon;
informat sec_name $38.;
format sec_name $38.;
set brinson.HSFSImon;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.HSFSImon;
run;


 
*keep semi-annual data in indexcomponents dataset;
data brinson.indexcomponents1;
set brinson.indexcomponents;
year=year(date);
month=month(date);
run;

data brinson.indexcomponents1;
set brinson.indexcomponents1;
if month=6 or month=12;
run;

proc sort data=brinson.indexcomponents1;
by date indexcode;
run;


*standardize the i_weight in indexcomponents dataset;
proc means data=brinson.indexcomponents1 noprint;
  class indexcode date;
  var i_weight;
  output out=brinson.indcomp1 sum=sumweight;
run;

data brinson.indcomp2;
set brinson.indcomp1;
if _TYPE_=3;
keep indexcode date sumweight;
run;

/*data brinson.indcomp2;
set brinson.indcomp1 (firstobs=119);
keep indexcode date sumweight;
run;*/

proc sql;
create table brinson.indcompo1 as
select a.*, b.sumweight 
from brinson.indexcomponents1 as a, brinson.indcomp2 as b 
where a.indexcode = b.indexcode and a.date=b.date;
run;quit;

data brinson.indcompo1;
set brinson.indcompo1;
ni_weight=i_weight/sumweight;
run;



***************************************************;

* deal with fund holding;

*****************************************************;


*standardize weights in fund holding;
data brinson.ptgp;
set brinson.ptgp;
rename 
_COL12=firm
_COL2=reportperiod
holdingp=stockszfrac;
run;

proc means data=brinson.ptgp noprint;
  class fundcode reportperiod;
  var stockszfrac;
  output out=brinson.ptgpsum1 sum=sumweight;
run;

data brinson.ptgpsum2;
set brinson.ptgpsum1;
if _TYPE_=3;
keep fundcode reportperiod sumweight;
run;

/*data brinson.ptgpsum2;
set brinson.ptgpsum1 (firstobs=316);
keep fundcode reportperiod sumweight;
run;*/

proc sql;
create table brinson.ptgpsumo1 as
select a.*, b.sumweight 
from brinson.ptgp as a, brinson.ptgpsum2 as b 
where a.fundcode = b.fundcode and a.reportperiod=b.reportperiod;
run;quit;

data brinson.ptgpsumo1;
set brinson.ptgpsumo1;
stockweight=stockszfrac/sumweight;
run;

*in the fund holding, it reports a column which is equal to the computed weights;

*now we compute the prior semi-annual return of these stocks;

*we convert year & report to be date so that we can merge it with stock monthly data;

data brinson.ptgpsumo1;
set brinson.ptgpsumo1;
if report='n' then month=12;
if report='z' then month=6;
run;



*now we have cleaned semi-annual fund holding & benchmark holding;
*we merge stock semi-annual data with these two holding datasets;

proc sql;
create table brinson.fundholding as
select a.*, b.* 
from brinson.ptgpsumo1 as a, brinson.stksemiann1 as b 
where a.stockcode = b.windcode and a.year=b.year and a.month=b.month;
run;quit;

proc sql;
create table brinson.benchholding as
select a.*, b.* 
from brinson.indcompo1 as a, brinson.stksemiann1 as b 
where a.wind_code = b.windcode and a.year=b.year and a.month=b.month;
run;quit;

*then we collapse the benchmark holding data & fund holding data to be;
*their corresponding industry holding data;
*we need industry weight & industry return;

data brinson.fundholding;
set brinson.fundholding;
wpret=stockweight*pret;
run;

data brinson.benchholding;
set brinson.benchholding;
wniret=ni_weight*pret;
run;

proc means data=brinson.fundholding noprint;
  class fundcode reportperiod INDUSTRY_CSRC12;
  var stockweight wpret;
  output out=brinson.fundholdi sum(stockweight)=sstkw sum(wpret)=swpret;
run;

data brinson.fundholdi1;
set brinson.fundholdi;
if _TYPE_=7;
run;

data brinson.fundholdi1;
set brinson.fundholdi1;
keep fundcode reportperiod INDUSTRY_CSRC12 sstkw swpret;
run;

proc means data=brinson.benchholding noprint;
  class indexcode date INDUSTRY_CSRC12;
  var ni_weight wniret;
  output out=brinson.benchholdi sum(ni_weight)=bsstkw sum(wniret)=bswnret;
run;

data brinson.benchholdi1;
set brinson.benchholdi;
if _TYPE_=7;
run;

data brinson.benchholdi1;
set brinson.benchholdi1;
keep indexcode date INDUSTRY_CSRC12 bsstkw bswnret;
run;

*merge the benchmark holding & fund holding data;
*add year & month to benchmark holding & fund holding;
*use stockcode year month to merge the datasets;
data brinson.fundholdi1;
set brinson.fundholdi1;
year=substr(reportperiod,1,4);
mi=find(reportperiod,'年报');
run;

data brinson.fundholdi1;
set brinson.fundholdi1;
year1=input(strip(year),best12.);
run;

data brinson.fundholdi1;
set brinson.fundholdi1;
if mi ne 0 then month=12;
if mi=0 then month=6;
run;

data brinson.fundholdi1;
set brinson.fundholdi1;
drop mi year;
run;

data brinson.fundholdi1;
set brinson.fundholdi1;
rename year1=year;
run;

data brinson.benchholdi1;
set brinson.benchholdi1;
year=year(date);
month=month(date);
run;

*merge fundholdi with fund benchmark dataset ptgpvo1;

proc sql;
create table brinson.fundptgp as
select a.*, b.index_code, b.nindexw
from brinson.fundholdi1 as a, brinson.ptgpvo1 as b 
where a.fundcode=b.windcode;
run;quit;

proc sql;
create table brinson.benchfundc as
select a.*, b.bsstkw, b.bswnret
from brinson.fundptgp as a, brinson.benchholdi1 as b 
where a.INDUSTRY_CSRC12=b.INDUSTRY_CSRC12 and a.year=b.year and a.month=b.month and 
a.index_code=b.indexcode;
run;quit;

*row sum by fundcode and reportdate for benchmark with multiple indices and weights;

data brinson.benchfundc1;
set brinson.benchfundc;
hbsstkw=nindexw*bsstkw;
hbswnret=nindexw*bswnret;
run;

proc means data=brinson.benchfundc1 noprint;
  class fundcode reportperiod INDUSTRY_CSRC12 index_code;
  var hbsstkw hbswnret;
  output out=brinson.benchfundc2 sum(hbsstkw)=bwi sum(hbswnret)=bri;
run;

data brinson.benchfundc2;
set brinson.benchfundc2;
if _TYPE_=15;
run;

data brinson.benchfundc2;
set brinson.benchfundc2;
drop _TYPE_ _FREQ_;
run;

proc sql;
create table brinson.benchfundc3 as
select a.*, b.sstkw as fwi, b.swpret as fri
from brinson.benchfundc2 as a, brinson.benchfundc1 as b 
where a.fundcode=b.fundcode and a.reportperiod=b.reportperiod and 
a.INDUSTRY_CSRC12=b.INDUSTRY_CSRC12 and a.index_code=b.index_code;
run;quit;

*compute brinson model sum of squares;

data brinson.benchfundc4;
set brinson.benchfundc3;
taa=(fwi-bwi)*bri;
stks=bwi*(fri-bri);
inte=(fwi-bwi)*(fri-bri);
tva=fwi*fri-bwi*bri;
run;

proc means data=brinson.benchfundc4 noprint;
  class fundcode reportperiod;
  var taa stks inte tva;
  output out=brinson.benchfundc5 sum(taa)=staa sum(stks)=sstks sum(inte)=sinte sum(tva)=stva;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
if _TYPE_=3;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
drop _TYPE_ _FREQ_;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
year=substr(reportperiod,1,4);
ni=find(reportperiod,'年报');
zi=find(reportperiod,'中报');
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
year1=input(strip(year),best12.);
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
drop year;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
rename year1=year;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
if ni ne 0 then month=12;
if zi ne 0 then month=6;
drop ni zi;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
rename fundcode=windcode;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
timemaker=mdy(month,25,year);
format timemaker date9.;
run;

proc sort data=brinson.benchfundc5;
by windcode timemaker;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
rename windcode=fundcode;
run;

*******************APPENDIX****************************;

*these are not positive so that the proportions decomposition do not work;

data brinson.benchfundc5;
set brinson.benchfundc5;
sss=staa+sstks+sinte;
sel=sstks/sss;
tim=staa/sss;
run;

proc means data=brinson.benchfundc5 noprint;
  class fundcode;
  var staa sstks sinte stva;
  output out=brinson.benchfundc6 mean(staa)=mtaa mean(sstks)=mstks mean(sinte)=minte mean(stva)=mtva;
run;

data brinson.benchfundc6;
set brinson.benchfundc6;
if _TYPE_=1;
run;

data brinson.benchfundc6;
set brinson.benchfundc6;
drop _TYPE_ _FREQ_;
run;

proc rank data=brinson.benchfundc6 out=brinson.benchfundc7 ties=low;		
   var mtaa mstks;
   ranks timr selr;
run;

data brinson.benchfundc7;
set brinson.benchfundc7;
mws=sqrt(timr*selr);
run;

PROC EXPORT DATA=brinson.benchfundc7
FILE="&address.table1"
DBMS=xlsx REPLACE;
SHEET="全期平均";
RUN;

proc sort data=brinson.benchfundc5;
by reportperiod;
run;

proc rank data=brinson.benchfundc5
out=brinson.abrinson ties=low descending;
by reportperiod;
var staa sstks sinte stva;
ranks timr selr intr arr;
run;

*analyse correlation selectivity and timing between report dates in R;

%let y=2015;
%let m=6;
%let yp=2014;
%let mp=12;

data cory;
set _null_;
v1="000000000000000";
v2="0.00000000000000";
run;

data r&y&m;
set brinson.abrinson;
if year=&y;
if month=&m;
run;

data r&yp&mp;
set brinson.abrinson;
if year=&yp;
if month=&mp;
run;

proc sort data=r&y&m;
by windcode;
run;

proc sort data=r&yp&mp;
by windcode;
run;



data merged;
merge r&y&m(in=a) r&yp&mp(in=b);
by windcode;
if a and b;
run;


proc sql;
create table merged as
select a.*, b.timr as timrb, b.selr as selrb, b.intr as intrb, b.arr as arrb
from r&y&m as a, r&yp&mp as b 
where a.windcode=b.windcode;
run;quit;

proc corr data=merged nomiss outp=CorrOutp;
var timr timrb;
run;





*hard to read in Hsharelist.csv;
*read in sas first;
*then read in R;

proc import out=brinson.hlst
datafile="E:\fund_index_weight\brinson\Hsharelist.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;



*work with H share;
data brinson.hshare;
set brinson.ptgpv;
igf=find(index_name,'恒生');
run;

data brinson.hshare;
set brinson.hshare;
if igf ne 0;
run;

*these H share appears after May2015;
*there are only two ptgp funds with >=0.9 proportion of H share;
*24 funds invest in H share;
*it's already 2years and only 24 funds, 24/262, less than 10% have exposure to HK;




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


********************************************************;


*summary statistics of brinson model semi-annually;


**********************************************************;
proc sort data=brinson.Benchfundc5;
by timemaker;
run;

proc univariate data=brinson.Benchfundc5 noprint;
   var staa;
   by timemaker;
   output out=taaStats mean=taaMean std=taaSD 
                       min=taaMin   max=taaMax
					   NOBS=taaN    SUM=taasum
					   var=taavar;
run;
/*
proc sql;
create table taaStats1 as
select a.*, b.*
from taaStats as a, brinson.Mutualbasicv as b
where a.windcode=b.windcode;
run;quit;*/

proc univariate data=brinson.Benchfundc5 noprint;
   var sstks;
   by timemaker;
   output out=ssStats mean=ssMean std=ssSD 
                       min=ssMin   max=ssMax
					   NOBS=ssN    SUM=sssum
					   var=ssvar;
run;
/*
proc sql;
create table ssStats1 as
select a.*, b.*
from ssStats as a, brinson.Mutualbasicv as b
where a.windcode=b.windcode;
run;quit;*/

proc univariate data=brinson.Benchfundc5 noprint;
   var sinte;
   by timemaker;
   output out=intStats mean=intMean std=intSD 
                       min=intMin   max=intMax
					   NOBS=intN    SUM=intsum
					   var=intvar;
run;
/*
proc sql;
create table intStats1 as
select a.*, b.*
from intStats as a, brinson.Mutualbasicv as b
where a.windcode=b.windcode;
run;quit;*/

proc univariate data=brinson.Benchfundc5 noprint;
   var stva;
   by timemaker;
   output out=tvaStats mean=tvaMean std=tvaSD 
                       min=tvaMin   max=tvaMax
					   NOBS=tvaN    SUM=tvasum
					   var=tvavar;
run;
/*
proc sql;
create table tvaStats1 as
select a.*, b.*
from tvaStats as a, brinson.Mutualbasicv as b
where a.windcode=b.windcode;
run;quit;*/

PROC EXPORT DATA=taaStats
FILE="&address.taaStats"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

PROC EXPORT DATA=ssStats
FILE="&address.ssStats"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

PROC EXPORT DATA=intStats
FILE="&address.intStats"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

PROC EXPORT DATA=tvaStats
FILE="&address.tvaStats"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;



proc sort data=brinson.Benchfundc5;
by windcode;
run;

proc univariate data=brinson.Benchfundc5 noprint;
   var staa;
   by windcode;
   output out=taaStats mean=taaMean std=taaSD 
                       min=taaMin   max=taaMax
					   NOBS=taaN    SUM=taasum
					   var=taavar;
run;

proc sql;
create table taaStats1 as
select a.*, b.*
from taaStats as a, brinson.Mutualbasic_final_ptgp as b
where a.windcode=b.windcode;
run;quit;

proc univariate data=brinson.Benchfundc5 noprint;
   var sstks;
   by windcode;
   output out=ssStats mean=ssMean std=ssSD 
                       min=ssMin   max=ssMax
					   NOBS=ssN    SUM=sssum
					   var=ssvar;
run;

proc sql;
create table ssStats1 as
select a.*, b.*
from ssStats as a, brinson.Mutualbasic_final_ptgp as b
where a.windcode=b.windcode;
run;quit;

proc univariate data=brinson.Benchfundc5 noprint;
   var sinte;
   by windcode;
   output out=intStats mean=intMean std=intSD 
                       min=intMin   max=intMax
					   NOBS=intN    SUM=intsum
					   var=intvar;
run;

proc sql;
create table intStats1 as
select a.*, b.*
from intStats as a, brinson.Mutualbasic_final_ptgp as b
where a.windcode=b.windcode;
run;quit;

proc univariate data=brinson.Benchfundc5 noprint;
   var stva;
   by windcode;
   output out=tvaStats mean=tvaMean std=tvaSD 
                       min=tvaMin   max=tvaMax
					   NOBS=tvaN    SUM=tvasum
					   var=tvavar;
run;

proc sql;
create table tvaStats1 as
select a.*, b.*
from tvaStats as a, brinson.Mutualbasic_final_ptgp as b
where a.windcode=b.windcode;
run;quit;

PROC EXPORT DATA=taaStats1
FILE="&address.wtaaStats"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

PROC EXPORT DATA=ssStats1
FILE="&address.wssStats"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

PROC EXPORT DATA=intStats1
FILE="&address.wintStats"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

PROC EXPORT DATA=tvaStats1
FILE="&address.wtvaStats"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

*combine several dictionary to build a better one;

proc import out=dic1
datafile="F:\fund_index_weight\brinson\index_code_name_dictionary.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc import out=dic2
datafile="F:\fund_index_weight\brinson\index_code_name_dictionary20180103.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data dic1;
set dic1;
marker=1;
run;

data dic2;
set dic2;
marker=2;
run;

data dic3;
set dic1 dic2;
run;

proc sql;
 create table dic4 as
 select DISTINCT (index_c), index_n, marker
 from dic3 order by index_c;
quit;

proc sort data=dic4; 
by index_n marker;
run;

data dic5;
set dic4;
by index_n;
If first.index_n then output dic5;
run;

data dic6;
set dic5;
drop marker;
run;

proc sql;
 create table dic7 as
 select DISTINCT (index_c), index_n
 from dic6 order by index_n;
quit;

data brinson.indexdic;
set dic7;
run;

PROC EXPORT DATA=dic7
FILE="&address.index_code_name_dictionary20180418"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

proc import out=dic22
datafile="F:\fund_index_weight\brinson\index_code_name_dictionary20180418.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
 create table brinson.dic23 as
 select DISTINCT (index_c), index_n
 from dic22 order by index_n;
quit;


*we have 66 indices already collected;

*after including pghh and lhpz, we should include more indices, how many more;

data lins;
set brinson.indexcomponents;
keep indexcode;
run;

proc sql;
 create table lins1 as
 select DISTINCT (indexcode)
 from lins order by indexcode;
quit;

*we have 66 indices already collected;

*after including pghh and lhpz, we should include more indices, how many more;

data jip2;
set jip1;
keep index_code;
run;

proc sql;
 create table jip3 as
 select DISTINCT (index_code)
 from jip2 order by index_code;
quit;

data jip3;
set jip3;
if index_code ne '';
run;

*we have 131 indices now; 

*we need to add some indices to our dataset;

*we consider the difference between these two dataset;

*these are what we need to further collect;

proc sort data=jip3;
   by index_code;
run;

data lins1;
set lins1;
rename indexcode=index_code;
run;

proc sort data=lins1;
   by index_code;
run;

data jiplin;
merge jip3(in=a) lins1(in=b);
by index_code;
if a=1 and b=1;
run;

data jiplin1;
merge jip3(in=a) lins1(in=b);
by index_code;
if a=1 and b=0;
run;

data jiplin2;
merge jip3(in=a) lins1(in=b);
by index_code;
if a=0 and b=1;
run;

*jiplin1 contains all indices we need to further work on;

*we export this set;

*check whether each index can be downloaded from wind;

*for those that can be downloaded, we produce code using R;

*for those that cannot be downloaded, we download components in Wind;

*hand calculate their weights;

PROC EXPORT DATA=jiplin1
FILE="&address.moreindex20180419"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;


proc sort data=brinson.ptgpv;
by windcode;
run;

*semiindcomp is the most complete benchmark stock index components up to end of 2017;
*except for several more indexes we need to download;

data brinson.hssemiann;
set brinson.hsmon;
month=month(datetime);
run;

data brinson.hssemiann;
set brinson.hssemiann;
if month=6 or month=12;
run;

data brinson.hssemiann;
set brinson.hssemiann;
if MKT_CAP_FLOAT ne 'NA';
if CLOSE ne .;
run;

data lis;
set brinson.hssemiann;
rename INDUSTRY_HS=industry;
keep SEC_NAME WINDCODE DATETIME INDUSTRY_HS MKT_CAP_FLOAT CLOSE;
run;

data lis1;
set brinson.stksemiann1;
rename INDUSTRY_CSRC12=industry;
keep SEC_NAME WINDCODE DATETIME INDUSTRY_CSRC12 MKT_CAP_FLOAT CLOSE;
run;

data lis;
set lis;
me=input(MKT_CAP_FLOAT,best18.);
run;

data lis;
set lis;
drop MKT_CAP_FLOAT;
run;

data lis;
set lis;
rename me=MKT_CAP_FLOAT;
run;

data lis2;
set lis lis1;
run;

proc sql;
 create table stkpsemi as
 select DISTINCT (SEC_NAME), WINDCODE, DATETIME, industry, CLOSE, MKT_CAP_FLOAT
 from lis2 order by WINDCODE;
quit;

data brinson.stkpsemi;
set stkpsemi;
run;

*stkpsemi is collection all semi-annual prices of all stocks including HK and A share;
*it is the most correct version so far until end of 2017;

*calculate semi-annual return for all stocks;

proc sort data=brinson.stkpsemi;
by WINDCODE datetime;
run;

data brinson.stkpsemi;
set brinson.stkpsemi;
if industry ne '';
run;

data brinson.stkpsemi;
set brinson.stkpsemi;
lclose=lag(close);
run;

data brinson.stkpsemi;
set brinson.stkpsemi;
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

data brinson.stkpsemi;
set brinson.stkpsemi;
drop lclose i;
run;



*************************************************************;

*after updating semi-annual index components & ;
*semi-annual stock prices including HK and A share;
*we compute brinson model using new pool of funds;
*covering ptgp, pghh and lhpz;

**************************************************************;



*standardize the i_weight in indexcomponents dataset;
proc means data=brinson.semiindcomp noprint;
  class indexcode date;
  var i_weight;
  output out=indcomp1 sum=sumweight;
run;

data indcomp2;
set indcomp1;
if _TYPE_=3;
keep indexcode date sumweight;
run;

proc sql;
create table indcompo1 as
select a.*, b.sumweight 
from brinson.semiindcomp as a, indcomp2 as b 
where a.indexcode = b.indexcode and a.date=b.date;
run;quit;

data indcompo1;
set indcompo1;
ni_weight=i_weight/sumweight;
run;

*deal with fund holding;
*ptgp9 is the most complete clean funds holding data including ptgp, lhpz and pghh;

*standardize weights in fund holding;

*we need to use jizhun1 indicators to remove ptgp9 funds with;
*complex, missing or fixed-rate benchmark;

data nptgp;
set brinson.ptgp9;
run;

data nptgp;
set nptgp;
marker=substr(windcode,1,length(windcode)-3);
run;

proc sql;
create table summary2 as
select a.*, b._COL2 as tzlxej, b._COL3 as yjbjjz, b.indicator
from nptgp as a left join brinson.jizhun1 as b 
on a.marker=b.marker;
run;quit;

*no data lost in the left join;

data summary2;
set summary2;
if indicator=0;
run;

*964983 to 882917 after removing complex, missing or fixed-rate benchmark;
*this is funds holding report data;

data summary2;
set summary2;
if stockcode ne '002257.SZ';
if stockcode ne '002525.SZ';
run;

*882917 to 882787 after removing IPO zhongzhi stocks;

data brinson.ptgp10;
set summary2;
run;

data ptgp;
set brinson.ptgp10;
rename windcode=fundcode holdingp=stockszfrac;
run;

*882917 rows read from brinson.ptgp10;
*all holding data downloaded from wind;

proc means data=ptgp noprint;
  class fundcode reportperiod;
  var stockszfrac;
  output out=ptgpsum1 sum=sumweight;
run;

data ptgpsum2;
set ptgpsum1;
if _TYPE_=3;
keep fundcode reportperiod sumweight;
run;

proc sql;
create table ptgpsumo1 as
select a.*, b.sumweight 
from ptgp as a, ptgpsum2 as b 
where a.fundcode = b.fundcode and a.reportperiod=b.reportperiod;
run;quit;

*882917 rows in ptgpsumo1;

data ptgpsumo1;
set ptgpsumo1;
stockweight=stockszfrac/sumweight;
run;

*in the fund holding, it reports a column which is equal to the computed weights;

*now we compute the prior semi-annual return of these stocks;

*we convert year & report to be date so that we can merge it with stock monthly data;

data ptgpsumo1;
set ptgpsumo1;
if report='n' then month=12;
if report='z' then month=6;
run;

*964983 rows in ptgpsumo1;

*now we have cleaned semi-annual fund holding & benchmark holding;
*we merge stock semi-annual data with these two holding datasets;

data brinson.stkpsemi;
set brinson.stkpsemi;
year=year(datetime);
month=month(datetime);
run;

*133010 entries in semi-annual stock prices;

*check whether every stock entry in the holding data has a match in stock semi-annual price data;

data stkpsemi;
set brinson.stkpsemi;
keep WINDCODE SEC_NAME year month;
run;

proc sql;
create table stkpsemi1 as
select DISTINCT (SEC_NAME), WINDCODE, year, month
from stkpsemi order by WINDCODE;
quit;

*in stock semi-annual price data, 126031 unique stock date entries are present;

data ptgp1;
set ptgp;
keep stockname stockcode year month;
run;

proc sql;
create table ptgp2 as
select DISTINCT (stockname), stockcode, year, month
from ptgp1 order by stockcode;
quit;

*in holding data, 45920 unique stock date entries are present;

*check to see whether some stock date entries are in holding data but not in semi-annual stock price data;

data stkpsemi1;
set stkpsemi1;
rename SEC_NAME=stockname WINDCODE=stockcode;
run;

proc sort data=ptgp2;
by stockcode year month;
run;

proc sort data=stkpsemi1;
by stockcode year month;
run;

data ptgp2;
informat stockname $38.;
format stockname $38.;
set ptgp2;
run;

data stkpsemi1;
informat stockname $38.;
format stockname $38.;
set stkpsemi1;
run;

data diffstk;
merge ptgp2(in=a) stkpsemi1(in=b);
by stockcode year month;
if a=1 and b=0;
run;

proc sort data=diffstk;
by year month;
run;

*130 stock date entries are in holding data but not in stock semi-annual price data;

data diffstk1;
set diffstk;
if year>=2005;
run;

*they are pre-IPO holding;
*to confirm, we download IPO date of these;
*confirm that they are included before IPO;

proc import out=mfdipodates
datafile="F:\mutualfundsipodates20180427.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc import out=stkipodates
datafile="F:\stockipodates20180427.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc import out=delipodates
datafile="F:\delistedstkipodeldates20180427.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc import out=delhsipodates
datafile="F:\delistedhshareipodates20180427.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc import out=hsipodates
datafile="F:\hshareipodates20180427.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data delhsipodates;
format _COL1 $38.;
informat _COL1 $38.;
set delhsipodates;
rename _COL0=stkcode _COL1=secname _COL2=ipodate;
run;

data hsipodates;
format _COL1 $38.;
informat _COL1 $38.;
set hsipodates;
rename _COL0=stkcode _COL1=secname _COL2=ipodate;
run;

data delipodates;
set delipodates;
rename _COL0=stkcode _COL1=secname _COL2=ipodate _COL3=deldate;
keep _COL0 _COL1 _COL2;
run;

data delipodates;
format secname $38.;
informat secname $38.;
set delipodates;
if stkcode ne '';
run;

data stkipodates;
set stkipodates;
rename _COL0=stkcode _COL1=secname _COL2=ipodate;
run;

data stkipodates;
format secname $38.;
informat secname $38.;
set stkipodates;
if stkcode ne '';
run;

data allstkipodates;
set delipodates stkipodates delhsipodates hsipodates;
run;

proc sql;
create table diffstk2 as
select a.*, b.ipodate 
from diffstk1 as a left join allstkipodates as b 
on a.stockcode = b.stkcode;
run;quit;

proc sort data=diffstk2;
by stockname year month;
run;

*output these special cases for further analysis;

PROC EXPORT DATA=diffstk2
FILE="F:\specialstockholding20180427"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;


proc import out=stkipop1
datafile="F:\stockipoprice20180427.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc import out=stkipop2
datafile="F:\delashareipoprice20180504.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc import out=stkipop3
datafile="F:\delhshareipoprice20180504.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc import out=stkipop4
datafile="F:\hshareipoprice20180504.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data stkipop1;
informat _COL1 $38.;
format _COL1 $38.;
set stkipop1;
rename _COL0=stkcode _COL1=stkname _COL2=ipop;
run;

data stkipop2;
informat _COL1 $38.;
format _COL1 $38.;
set stkipop2;
rename _COL0=stkcode _COL1=stkname _COL2=ipop;
run;

data stkipop3;
informat _COL1 $38.;
format _COL1 $38.;
set stkipop3;
rename _COL0=stkcode _COL1=stkname _COL2=ipop;
run;

data stkipop4;
informat _COL1 $38.;
format _COL1 $38.;
set stkipop4;
rename _COL0=stkcode _COL1=stkname _COL2=ipop;
run;

data stkipop;
set stkipop1 stkipop2 stkipop3 stkipop4;
run;

proc sql;
create table stkipo as
select a.*, b.ipop 
from Allstkipodates as a right join Stkipop as b 
on a.stkcode = b.stkcode;
run;quit;

data stkipo;
set stkipo;
pipodate=ipodate-365;
format pipodate date9.;
run;

PROC EXPORT DATA=stkipo
FILE="F:\stkipo20180504"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

*convert data with ipo dates and one year prior to ipo;
*set all monthly prices to be ipo price;
*we do this in R;
*then import the data to merge into stk prices dataset;



proc sql;
create table brinson.fundholding as
select a.*, b.* 
from ptgpsumo1 as a left join brinson.stkpsemi as b 
on a.stockcode = b.windcode and a.year=b.year and a.month=b.month;
run;quit;

*#data entries in ptgpsumo1=#data entries in ptgp;
*#data entries in fundholding=#data entries in ptgp-30000+;

data indcompo1;
set indcompo1;
year=year(date);
run;

proc sql;
create table brinson.benchholding as
select a.*, b.* 
from indcompo1 as a left join brinson.stkpsemi as b 
on a.wind_code = b.windcode and a.year=b.year and a.month=b.month;
run;quit;

*data entries # in indcompo1 is 495667;
*data entries # in brinson.benchholding is 495001;
*we left off some stocks semi-annual data in brinson.stkpsemi;

*then we collapse the benchmark holding data & fund holding data to be;
*their corresponding industry holding data;
*we need industry weight & industry return;

data brinson.fundholding;
set brinson.fundholding;
wpret=stockweight*pret;
run;

data brinson.benchholding;
set brinson.benchholding;
wniret=ni_weight*pret;
run;

proc means data=brinson.fundholding noprint;
  class fundcode reportperiod industry;
  var stockweight wpret;
  output out=fundholdi sum(stockweight)=sstkw sum(wpret)=swpret;
run;

data fundholdi1;
set fundholdi;
if _TYPE_=7;
run;

data fundholdi1;
set fundholdi1;
keep fundcode reportperiod industry sstkw swpret;
run;

*fundholdi1 is for stocks cross holding report dates;
*fundholdi1 has 137882 data entries;

proc means data=brinson.benchholding noprint;
  class indexcode date industry;
  var ni_weight wniret;
  output out=benchholdi sum(ni_weight)=bsstkw sum(wniret)=bswnret;
run;

data benchholdi1;
set benchholdi;
if _TYPE_=7;
run;

data benchholdi1;
set benchholdi1;
keep indexcode date industry bsstkw bswnret;
run;

*benchholdi1 has 16610 data entries;

*merge the benchmark holding & fund holding data;
*add year & month to benchmark holding & fund holding;
*use stockcode year month to merge the datasets;

data fundholdi1;
set fundholdi1;
year=substr(reportperiod,1,4);
mi=find(reportperiod,'年报');
run;

data fundholdi1;
set fundholdi1;
year1=input(strip(year),best12.);
run;

data fundholdi1;
set fundholdi1;
if mi ne 0 then month=12;
if mi=0 then month=6;
run;

data fundholdi1;
set fundholdi1;
drop mi year;
run;

data fundholdi1;
set fundholdi1;
rename year1=year;
run;

data benchholdi1;
set benchholdi1;
year=year(date);
month=month(date);
run;

*merge fundholdi with fund benchmark dataset ptgpvo1;

data fundholdi1;
set fundholdi1;
marker=substr(fundcode,1,length(fundcode)-3);
run;

data brinson.ptgpvo1;
set brinson.ptgpvo1;
marker=substr(windcode,1,length(windcode)-3);
run;

proc sql;
create table brinson.fundptgp as
select a.*, b.index_code, b.nindexw
from fundholdi1 as a left join brinson.ptgpvo1 as b 
on a.marker=b.marker;
run;quit;

*funds in fundholdi1 may end in .OF, .SH or .SZ;
*funds in brinson.ptgpvo1 only end in .OF;
*in the join, we should use marker not windcode;

*fundholdi1 has 137882 data entries;
*brinson.ptgpvo1 has 2912 data entries;
*brinson.fundptgp has 118098 data entries intersection;
*brinson.fundptgp has 141747 data entries on left join;
*brinson.fundptgp has 142046 data entries after using marker instead of windcode;

data che1;
set fundholdi1;
keep marker;
run;

proc sql;
 create table che2 as
 select DISTINCT (marker)
 from che1 order by marker;
quit;

*2086 funds in fundholdi1;

data her1;
set brinson.ptgpvo1;
keep marker;
run;

proc sql;
 create table her2 as
 select DISTINCT (marker)
 from her1 order by marker;
quit;

*2747 funds in brinson.ptgpvo1;

data cheher1;
merge che2(in=a) her2(in=b);
by marker;
if a and not b;
run;

*214 funds are in fundholdi1 but not in brinson.ptgpvo1;

data cheher2;
merge che2(in=a) her2(in=b);
by marker;
if b and not a;
run;

*875 funds are in brinson.ptgpvo1 but not in fundholdi1;

*we need to modify it and include all the funds in brinson.ptgpvo1;

proc sort data=fundholdi1;
by fundcode year month industry;
run;

proc sort data=brinson.fundptgp;
by fundcode year month industry;
run;

proc sql;
create table brinson.benchfundc as
select a.*, b.bsstkw, b.bswnret
from brinson.fundptgp as a left join benchholdi1 as b 
on a.industry=b.industry and a.year=b.year and a.month=b.month and 
a.index_code=b.indexcode;
run;quit;

*brinson.benchfundc has 141747 data entries on left join;

data jio1;
set brinson.fundptgp;
keep index_code;
rename index_code=indexcode;
run;

proc sql;
 create table jio2 as
 select DISTINCT (indexcode)
 from jio1 order by indexcode;
quit;

*113 benchmark indexes in brinson.fundptgp including one space;

data rio1;
set benchholdi1;
keep indexcode;
run;

proc sql;
 create table rio2 as
 select DISTINCT (indexcode)
 from rio1 order by indexcode;
quit;

*130 benchmark indexes in benchholdi1;

data jiorio1;
merge jio2(in=a) rio2(in=b);
by indexcode;
if a and not b;
run;

*only one space is in brinson.fundptgp but not in benchholdi1;

data jiorio2;
merge jio2(in=a) rio2(in=b);
by indexcode;
if b and not a;
run;

*only 18 indexes are in benchholdi1 but not in brinson.fundptgp;

*our indexes components dataset is well arranged.




*row sum by fundcode and reportdate for benchmark with multiple indices and weights;

data brinson.benchfundc1;
set brinson.benchfundc;
hbsstkw=nindexw*bsstkw;
hbswnret=nindexw*bswnret;
run;

proc means data=brinson.benchfundc1 noprint;
  class fundcode reportperiod industry index_code;
  var hbsstkw hbswnret;
  output out=brinson.benchfundc2 sum(hbsstkw)=bwi sum(hbswnret)=bri;
run;

proc sort data=brinson.benchfundc1;
by reportperiod fundcode;
run;

data brinson.benchfundc2;
set brinson.benchfundc2;
if _TYPE_=15;
run;

data brinson.benchfundc2;
set brinson.benchfundc2;
drop _TYPE_ _FREQ_;
run;

proc sql;
create table brinson.benchfundc3 as
select a.*, b.sstkw as fwi, b.swpret as fri
from brinson.benchfundc2 as a left join brinson.benchfundc1 as b 
on a.fundcode=b.fundcode and a.reportperiod=b.reportperiod and 
a.industry=b.industry and a.index_code=b.index_code;
run;quit;

*compute brinson model sum of squares;

data brinson.benchfundc4;
set brinson.benchfundc3;
taa=(fwi-bwi)*bri;
stks=bwi*(fri-bri);
inte=(fwi-bwi)*(fri-bri);
tva=fwi*fri-bwi*bri;
run;

proc means data=brinson.benchfundc4 noprint;
  class fundcode reportperiod;
  var taa stks inte tva;
  output out=brinson.benchfundc5 sum(taa)=staa sum(stks)=sstks sum(inte)=sinte sum(tva)=stva;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
if _TYPE_=3;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
drop _TYPE_ _FREQ_;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
year=substr(reportperiod,1,4);
ni=find(reportperiod,'年报');
zi=find(reportperiod,'中报');
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
year1=input(strip(year),best12.);
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
drop year;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
rename year1=year;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
if ni ne 0 then month=12;
if zi ne 0 then month=6;
drop ni zi;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
rename fundcode=windcode;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
timemaker=mdy(month,25,year);
format timemaker date9.;
run;

proc sort data=brinson.benchfundc5;
by windcode timemaker;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
rename windcode=fundcode;
run;

proc sort data=brinson.benchfundc5;
by timemaker fundcode year month;
run;

PROC EXPORT DATA=brinson.benchfundc5
FILE="&address.brinsonmodel20171231"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

*missing some funds compared to summary statistics of funds holding data;
*now I am going to check where I missed these funds;
*after adding more benchmark indexes, 1831 compared to 1989;
*need further check;

*after removing funds with missing benchmark, complex conditional formula benchmark;
*and fixed-rate benchmark, we have 1831 funds left in 2017n report;
*which is 1828 in our brinson model results of 2017n here;
*in 2015n, we have 64 both in our sample and in our brinson model results;

*another mission is to figure out why some funds have no brinson model output;
*that is missing output;

*we count number of funds per report period;
proc univariate data=brinson.benchfundc5 noprint;
   var staa;
   by timemaker;
   output out=brinson.brins NOBS=numfunds;
run;

data brinson.brins;
set brinson.brins;
year=year(timemaker);
month=month(timemaker);
run;

data brinson.allsummaryE1;
set brinson.allsummaryE1;
year=year(timer);
month=month(timer);
run;

proc sql;
create table brinson.brins2 as
select a.*, b.numfunds as numfunds1
from brinson.brins as a left join brinson.allsummaryE1 as b 
on a.year=b.year and a.month=b.month;
run;quit;

data brinson.brins2;
set brinson.brins2;
loss=numfunds1-numfunds;
run;

*starting from 2016n, there are three funds lost in brinson model results;
*we should figure out which three are lost;

data brinson.y1;
set brinson.summary2;
if reportperiod='2016年中报';
run;

data brinson.y11;
set brinson.benchfundc5;
if reportperiod='2016年中报';
rename fundcode=windcode;
run;

proc sort data=brinson.y1;
by windcode;
run;

proc sort data=brinson.y11;
by windcode;
run;

data brinson.y111;
merge brinson.y1(in=a) brinson.y11(in=b);
by windcode;
if a and not b;
run;

data brinson.y2;
set brinson.summary2;
if reportperiod='2016年年报';
run;

data brinson.y21;
set brinson.benchfundc5;
if reportperiod='2016年年报';
rename fundcode=windcode;
run;

proc sort data=brinson.y2;
by windcode;
run;

proc sort data=brinson.y21;
by windcode;
run;

data brinson.y211;
merge brinson.y2(in=a) brinson.y21(in=b);
by windcode;
if a and not b;
run;

data brinson.y3;
set brinson.summary2;
if reportperiod='2017年中报';
run;

data brinson.y31;
set brinson.benchfundc5;
if reportperiod='2017年中报';
rename fundcode=windcode;
run;

proc sort data=brinson.y3;
by windcode;
run;

proc sort data=brinson.y31;
by windcode;
run;

data brinson.y311;
merge brinson.y3(in=a) brinson.y31(in=b);
by windcode;
if a and not b;
run;

data brinson.y4;
set brinson.summary2;
if reportperiod='2017年年报';
run;

data brinson.y41;
set brinson.benchfundc5;
if reportperiod='2017年年报';
rename fundcode=windcode;
run;

proc sort data=brinson.y4;
by windcode;
run;

proc sort data=brinson.y41;
by windcode;
run;

data brinson.y411;
merge brinson.y4(in=a) brinson.y41(in=b);
by windcode;
if a and not b;
run;

*these three missing is due to mistakes in mutual fund basic info dataset amutual;
*we should update amutual using updated data in wind;
*we implement 1.R to create updated vertical table;
*we re-run the whole procedure;

*after updating mutual fund basic info dataset, we have everything in place;
*the number of funds in brinson model results is exactly the same as;
*the number of funds in holding data for every holding report period;

*now we check why the brinson model results for some funds are missing;
*benchmark info are not complete in our index components dataset;

*here is to extract one fund one report period as one example of brinson model calculation;
data print1;
set brinson.ptgp;
if fundcode='000404.OF' and year=2017 and report='n';
run;

PROC EXPORT DATA=print1
FILE="&address.print1"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data print11;
set brinson.fundholding;
if fundcode='000404.OF' and year=2017 and month=12;
run;

proc import out=stkipodates
datafile="F:\stockipodates20180427.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table print111 as
select a.*, b._COL2 as IPOdate
from print11 as a left join stkipodates as b 
on a.stockcode=b._COL0;
run;quit;

PROC EXPORT DATA=print111
FILE="&address.print11"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data print2;
set brinson.fundholdi1;
if fundcode='000404.OF' and year=2017 and month=12;
run;

PROC EXPORT DATA=print2
FILE="&address.print2"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data print3;
set brinson.indexcomponents;
if indexcode='399964.SZ' and date='31DEC2017'd;
run;

PROC EXPORT DATA=print3
FILE="&address.print3"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data print31;
set brinson.benchholding;
if indexcode='399964.SZ' and year=2017 and month=12;
run;

PROC EXPORT DATA=print31
FILE="&address.print31"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data print4;
set brinson.benchholdi1;
if indexcode='399964.SZ' and year=2017 and month=12;
run;

PROC EXPORT DATA=print4
FILE="&address.print4"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data print5;
set brinson.benchfundc;
if fundcode='000404.OF' and year=2017 and month=12;
run;

PROC EXPORT DATA=print5
FILE="&address.print5"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data print51;
set brinson.benchfundc1;
if fundcode='000404.OF' and year=2017 and month=12;
run;

PROC EXPORT DATA=print51
FILE="&address.print51"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data print52;
set brinson.benchfundc2;
if fundcode='000404.OF' and reportperiod='2017年年报';
run;

PROC EXPORT DATA=print52
FILE="&address.print52"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data print53;
set brinson.benchfundc3;
if fundcode='000404.OF' and reportperiod='2017年年报';
run;

PROC EXPORT DATA=print53
FILE="&address.print53"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data print54;
set brinson.benchfundc4;
if fundcode='000404.OF' and reportperiod='2017年年报';
run;

PROC EXPORT DATA=print54
FILE="&address.print54"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data print55;
set brinson.benchfundc5;
if fundcode='000404.OF' and reportperiod='2017年年报';
run;

PROC EXPORT DATA=print55
FILE="&address.print55"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

*this is for turnover calculations;

proc import out=brinson.stkturnover
datafile="F:\fund_index_weight\brinson\stkturnover20180507.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.stkturnover;
set brinson.stkturnover;
if report='n' then month=12;
if report='z' then month=6;
run;

data brinson.stkturnover;
set brinson.stkturnover;
timer=mdy(month,22,year);
format timer date9.;
run;

proc sort data=brinson.stkturnover;
by timer;
run;

proc univariate data=brinson.stkturnover noprint;
   var _COL8;
   by timer;
   output out=brinson.stkturnover1 NOBS=numfunds MEAN=m_COL8 STD=d_COL8;
run;

*we need to check how other papers compute holding turnover and calculates similar;
*turnover measures;


**benchmark info are not complete in our index components dataset;
*now after finishing the demonstration example, we start to complete the index components dataset;
*we need to figure out how many benchmark info is missing;
*it would be even better if we can figure why it went missing in our procedure;

data brinson.missbench;
set brinson.benchfundc5;
if year>=2005;
run;

data brinson.missbench;
set brinson.missbench;
if staa=.;
run;

data brinson.missbench;
set brinson.missbench;
marker=substr(fundcode,1,length(fundcode)-3);
run;

data brinson.ptgpv;
set brinson.ptgpv;
marker=substr(windcode,1,length(windcode)-3);
run;

proc sql;
create table brinson.missbench1 as
select a.*, b.index_code, b.index_name, b.index_weight 
from brinson.missbench as a left join brinson.ptgpv as b 
on a.marker = b.marker;
run;quit;

*we find the benchmark index of these funds with missing benchmark info;
*we need to drop these benchmark index of debt and fixed-rate interest;

data brinson.missbench1;
set brinson.missbench1;
ii=find(index_name,'利率');
run;

data brinson.missbench1;
set brinson.missbench1;
if ii=0;
run;

data brinson.missbench1;
set brinson.missbench1;
drop ii;
run;

data brinson.missbench1;
set brinson.missbench1;
ii=find(index_name,'债');
run;

data brinson.missbench1;
set brinson.missbench1;
if ii=0;
run;

data brinson.missbench1;
set brinson.missbench1;
drop ii;
run;

data brinson.missbench1;
set brinson.missbench1;
ii=SUBSTR(index_code,1,1);
run;

data brinson.missbench1;
set brinson.missbench1;
if ii ne 'M';
run;

data brinson.missbench1;
set brinson.missbench1;
drop ii;
run;

data brinson.missbench1;
set brinson.missbench1;
ii=find(index_name,'存款');
run;

data brinson.missbench1;
set brinson.missbench1;
if ii=0;
run;

data brinson.missbench1;
set brinson.missbench1;
drop ii;
run;

*export this table of missing benchmark info to have a check;
*see what caused the missingness and note in the exported table;

PROC EXPORT DATA=brinson.missbench1
FILE="&address.missbench1"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;




********************************************************************;


*persistence;


********************************************************************;

data brinson.ataa;
set _null_;
v1="000000000000000";
v2="000000000000000";
v3="0.00000000000000";
run;

data brinson.ass;
set _null_;
v1="000000000000000";
v2="000000000000000";
v3="0.00000000000000";
run;

data brinson.aint;
set _null_;
v1="000000000000000";
v2="000000000000000";
v3="0.00000000000000";
run;

data brinson.aar;
set _null_;
v1="000000000000000";
v2="000000000000000";
v3="0.00000000000000";
run;

%macro lcor(y,m,py,pm);
data temp;
set brinson.Benchfundc5;
if year=&y;
if month=&m;
run;

data temp1;
set brinson.Benchfundc5;
if year=&py;
if month=&pm;
run;

proc sql;
create table temp3 as
select a.windcode, a.staa, b.staa as staa1
from temp as a, temp1 as b 
where a.windcode = b.windcode;
run;quit;

proc corr data=temp3 noprint nomiss outp=temp3_1;
var staa staa1;
run;

proc sort data=temp3_1;
by staa;
run;

data temp3_1; 
set temp3_1;
if _TYPE_='CORR';
run;

data temp3_1; 
set temp3_1; 
if _n_=1 then do; call symput('corrq',staa); end;
run;

proc sql;
insert into brinson.ataa (v1,v2,v3)
values ("&py", "&pm", "&corrq");
quit;



proc sql;
create table temp3 as
select a.windcode, a.sstks, b.sstks as sstks1
from temp as a, temp1 as b 
where a.windcode = b.windcode;
run;quit;

proc corr data=temp3 noprint nomiss outp=temp3_1;
var sstks sstks1;
run;

proc sort data=temp3_1;
by sstks;
run;

data temp3_1; 
set temp3_1;
if _TYPE_='CORR';
run;

data temp3_1; 
set temp3_1; 
if _n_=1 then do; call symput('corrq',sstks); end;
run;

proc sql;
insert into brinson.ass (v1,v2,v3)
values ("&py", "&pm", "&corrq");
quit;




proc sql;
create table temp3 as
select a.windcode, a.sinte, b.sinte as sinte1
from temp as a, temp1 as b 
where a.windcode = b.windcode;
run;quit;

proc corr data=temp3 noprint nomiss outp=temp3_1;
var sinte sinte1;
run;

proc sort data=temp3_1;
by sinte;
run;

data temp3_1; 
set temp3_1;
if _TYPE_='CORR';
run;

data temp3_1; 
set temp3_1; 
if _n_=1 then do; call symput('corrq',sinte); end;
run;

proc sql;
insert into brinson.aint (v1,v2,v3)
values ("&py", "&pm", "&corrq");
quit;





proc sql;
create table temp3 as
select a.windcode, a.stva, b.stva as stva1
from temp as a, temp1 as b 
where a.windcode = b.windcode;
run;quit;

proc corr data=temp3 noprint nomiss outp=temp3_1;
var stva stva1;
run;

proc sort data=temp3_1;
by stva;
run;

data temp3_1; 
set temp3_1;
if _TYPE_='CORR';
run;

data temp3_1; 
set temp3_1; 
if _n_=1 then do; call symput('corrq',stva); end;
run;

proc sql;
insert into brinson.aar (v1,v2,v3)
values ("&py", "&pm", "&corrq");
quit;

%mend lcor;

%macro lpcor;
data _null_;
%do i=2008 %to 2017;
%lcor(&i,6,&i,12);
%end;
run;
data _null_;
%do i=2008 %to 2016;
%lcor(&i,12,%eval(&i+1),6);
%end;
run;
%mend lpcor;

%lpcor;

data brinson.aar;
set brinson.aar;
year=input(v1, best12.);
month=input(v2, best12.);
corrq=input(v3, best12.);
run;

proc sort data=brinson.aar;
by year month;
run;

data brinson.ass;
set brinson.ass;
year=input(v1, best12.);
month=input(v2, best12.);
corrq=input(v3, best12.);
run;

proc sort data=brinson.ass;
by year month;
run;

data brinson.aint;
set brinson.aint;
year=input(v1, best12.);
month=input(v2, best12.);
corrq=input(v3, best12.);
run;

proc sort data=brinson.aint;
by year month;
run;

data brinson.ataa;
set brinson.ataa;
year=input(v1, best12.);
month=input(v2, best12.);
corrq=input(v3, best12.);
run;

proc sort data=brinson.ataa;
by year month;
run;

PROC EXPORT DATA=brinson.aar
FILE="&address.aar"
DBMS=xlsx REPLACE;
SHEET="aar";
RUN;

PROC EXPORT DATA=brinson.ass
FILE="&address.ass"
DBMS=xlsx REPLACE;
SHEET="ass";
RUN;

PROC EXPORT DATA=brinson.aint
FILE="&address.aint"
DBMS=xlsx REPLACE;
SHEET="aint";
RUN;

PROC EXPORT DATA=brinson.ataa
FILE="&address.ataa"
DBMS=xlsx REPLACE;
SHEET="ataa";
RUN;


PROC EXPORT DATA=brinson.benchfundc5
FILE="&address.benchfundc5"
DBMS=xlsx REPLACE;
SHEET="a";
RUN;




data qie;
set brinson.benchfundc5;
if windcode='001158.OF';
run;

data qier;
set brinson.fundholding;
if fundcode='001158.OF';
run;

PROC EXPORT DATA=qie
FILE="&address.fundexample20180522"
DBMS=xlsx REPLACE;
SHEET="a1";
RUN;

PROC EXPORT DATA=qier
FILE="&address.fundexample20180522"
DBMS=xlsx REPLACE;
SHEET="a2";
RUN;



data tie;
set brinson.benchholding;
if indexcode='000986.SH';
if year>=2015;
run;

PROC EXPORT DATA=tie
FILE="&address.fundexample20180522"
DBMS=xlsx REPLACE;
SHEET="a3";
RUN;



data tie1;
set brinson.fundholdi;
if fundcode='001158.OF';
run;

PROC EXPORT DATA=tie1
FILE="&address.fundexample20180522"
DBMS=xlsx REPLACE;
SHEET="a4";
RUN;

data tie2;
set brinson.benchholdi;
if indexcode='000986.SH';
if year>=2015;
run;

PROC EXPORT DATA=tie2
FILE="&address.fundexample20180522"
DBMS=xlsx REPLACE;
SHEET="a5";
RUN;

data tie3;
set brinson.benchfundc;
if fundcode='001158.OF';
run;

PROC EXPORT DATA=tie3
FILE="&address.fundexample20180522"
DBMS=xlsx REPLACE;
SHEET="a6";
RUN;

