%let address = F:\fund_index_weight\brinson\;
%LET OUT = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';

%let m=20180515;*fill in export date;


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
