
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

