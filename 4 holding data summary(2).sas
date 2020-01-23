
%let address = F:\fund_index_weight\brinson\;
%LET OUT = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';

%let m=20180515;*fill in export date;

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
from brinson.summary1 as a left join brinson.ptgp as b 
on a.windcode = b.windcode and a.reportperiod = b.reportperiod;
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


