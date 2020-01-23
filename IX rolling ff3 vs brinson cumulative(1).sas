
%let address = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';

%let m=20180606;*fill in export date;

%let windowlength=3;

data brinson.corr_year&windowlength;
set _null_;
v1="000000000000000";
v2="0.00000000000000";
v3="000000000000000";
v4="0.00000000000000";
run;

* %let year=2016;

%macro rollingcheck(year);

%let year3=%eval(&year - &windowlength+1);
%let year1=%eval(&year+1);

data brinson.fund_benchmark_weight4&windowlength;
set five.fund_benchmark_weight4;
if startdate<="30jun&year3"d;
if enddate>="30jun&year1"d;
if date>="30jun&year3"d;
if date<="30jun&year1"d;
run;

data brinson.fund_benchmark_weight4&windowlength;
set brinson.fund_benchmark_weight4&windowlength;
if smb ne .;
if hml ne .;
run;

proc sort data=brinson.fund_benchmark_weight4&windowlength; 
by windcode;
run;

proc reg data=brinson.fund_benchmark_weight4&windowlength outest=brinson.reg_fbw4_rf&windowlength 
edf  tableout  noprint;
model excess_return = sys_risk smb hml;
by windcode;
quit;

data brinson.ff3&windowlength;
set brinson.reg_fbw4_rf&windowlength;
if _TYPE_='PARMS';
keep windcode Intercept;
run;

data ythre;
set brinson.benchfundc5;
if year >= &year3 and year <= &year;
run;

proc sort data=ythre;
by windcode;
run;

proc univariate data=ythre noprint;
var sstks;
by windcode;
output out=ythresummary NOBS=numfunds;
run;

data ythresummary;
set ythresummary;
if numfunds=%eval(2* &windowlength);
run;

proc sql;
create table ythresummary1 as
select a.*, b.*
from ythresummary as a left join ythre as b 
on a.windcode=b.windcode;
run;quit;

proc sort data=ythresummary1;
by windcode time;
run;

data ythresummary2;
set ythresummary1;
otaa=1+staa;
oss=1+sstks;
oint=1+sinte;
otva=1+stva;
run;

proc sort data=ythresummary2; 
by windcode time; 
run;

data ythresummary3;
set ythresummary2;
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

data ythresummary4;
set ythresummary3;
if year=&year and month=12;
keep windcode cumss;
run;

data ythresummary4;
set ythresummary4;
marker=substr(windcode,1,length(windcode)-3);
run;

data brinson.ff3&windowlength;
set brinson.ff3&windowlength;
marker=substr(windcode,1,length(windcode)-3);
run;

proc sql;
create table ythresummary5 as
select a.*, b.Intercept
from ythresummary4 as a left join brinson.ff3&windowlength as b 
on a.marker=b.marker;
run;quit;

data ythresummary5;
set ythresummary5;
if Intercept ne .;
run;

proc rank data=ythresummary5 out=ythresummary5 descending ties=low;   
var Intercept;
ranks alpharank;
run;

proc rank data=ythresummary5 out=ythresummary5 descending ties=low;   
var cumss;
ranks ssrank;
run;

proc corr data=ythresummary5 noprint outp=T3;
var alpharank ssrank;
run;

proc corr data=ythresummary5;
ods output PearsonCorr=T4;
var alpharank ssrank;
run;

proc sort data=T3;
by alpharank;
run;

data T3; 
set T3; 
if _n_=1 then do; call symput('corr_rank',alpharank); end;
run;

data T31;
set T3;
if _TYPE_='N';
run;

data T31; 
set T31; 
if _n_=1 then do; call symput('Nobs',alpharank); end;
run;

data T4;
set T4;
if _n_=1 then do; call symput('Pvalue',Pssrank); end;
run;

proc sql;
insert into brinson.corr_year&windowlength (v1,v2,v3,v4)
values ("&year", "&corr_rank", "&Nobs", "&Pvalue");
quit;

%mend rollingcheck;

* %put &corr_rank;
* %put &Nobs;
* %put &Pvalue;


%macro looprollingcheck;
data _null_;
%do i=2007 %to 2016;
%rollingcheck(&i);
%end;
run;
%mend looprollingcheck;

%looprollingcheck;

data brinson.corr_year&windowlength;
set brinson.corr_year&windowlength;
label v1='年份' v2='相关性系数' v3='样本数' v4='P值';
year=input(v1, best12.);
corrq=input(v2, best12.);
nobs=input(v3, best12.);
pvalue=input(v4, best12.);
run;

filename graphout "&address.过去&windowlength.年两种选股能力排序的相关性系数.png";     
goptions reset=all device=png gsfname=graphout;

proc gchart data=brinson.corr_year&windowlength;                                                                                                                 
vbar year / sumvar=corrq discrete width=10                                                             
maxis=axis1 raxis=axis2;                                                                                                  
axis1 label=('年份');                                                                                                                 
axis2 label=(angle=90 '相关性系数') order=(-0.5 to 0.5 by 0.1);                                                                                                     
title1 "主动股票型基金过去&windowlength.年Fama-French三因子模型选股能力排序和
Brinson模型行业内选股能力排序的相关性系数";                                                                                           
run;                                                                                                                                    
quit;      

PROC EXPORT DATA=brinson.corr_year&windowlength
FILE="&address.主动股票型基金Fama-French三因子模型选股能力排序和
Brinson模型行业内选股能力排序的相关性系数"
DBMS=xlsx REPLACE;
SHEET="&windowlength.年样本";
RUN;






