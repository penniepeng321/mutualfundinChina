
%let address = F:\fund_index_weight\brinson\;
%LET OUT = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';

%let m=20180608;*fill in export date;

data brinson.benchfundc5;
set brinson.benchfundc5;
rename fundcode=windcode;
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
FILE="&address.taaStats&m"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

PROC EXPORT DATA=ssStats
FILE="&address.ssStats&m"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

PROC EXPORT DATA=intStats
FILE="&address.intStats&m"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

PROC EXPORT DATA=tvaStats
FILE="&address.tvaStats&m"
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
from taaStats as a left join brinson.amutual as b
on a.windcode=b.fundcode;
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
from ssStats as a left join brinson.amutual as b
on a.windcode=b.fundcode;
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
from intStats as a left join brinson.amutual as b
on a.windcode=b.fundcode;
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
from tvaStats as a left join brinson.amutual as b
on a.windcode=b.fundcode;
run;quit;

PROC EXPORT DATA=taaStats1
FILE="&address.wtaaStats&m"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

PROC EXPORT DATA=ssStats1
FILE="&address.wssStats&m"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

PROC EXPORT DATA=intStats1
FILE="&address.wintStats&m"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

PROC EXPORT DATA=tvaStats1
FILE="&address.wtvaStats&m"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;




*this section is for the correlation between adjacent holding reports;

/*
data brinson.Benchfundc5;
set brinson.Benchfundc5;
rename fundcode=windcode;
run;*/

data brinson.ataa;
set _null_;
v1="000000000000000";
v2="000000000000000";
v3="0.00000000000000";
v4="000000000000000";
v5="0.00000000000000";
run;

data brinson.ass;
set _null_;
v1="000000000000000";
v2="000000000000000";
v3="0.00000000000000";
v4="000000000000000";
v5="0.00000000000000";
run;

data brinson.aint;
set _null_;
v1="000000000000000";
v2="000000000000000";
v3="0.00000000000000";
v4="000000000000000";
v5="0.00000000000000";
run;

data brinson.aar;
set _null_;
v1="000000000000000";
v2="000000000000000";
v3="0.00000000000000";
v4="000000000000000";
v5="0.00000000000000";
run;


*%let y=2015;
*%let m=6;
*%let py=2015;
*%let pm=12;

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

proc corr data=temp3 noprint outp=temp3_1;
var staa staa1;
run;

proc corr data=temp3;
ods output PearsonCorr=T4;
var staa staa1;
run;

data T4;
set T4;
if _n_=1 then do; call symput('corrq',staa1); end;
run;

data T4;
set T4;
if _n_=1 then do; call symput('Pvalue',Pstaa1); end;
run;

data temp3_1; 
set temp3_1;
if _TYPE_='N';
run;

data temp3_1; 
set temp3_1; 
if _n_=1 then do; call symput('Nobs',staa); end;
run;

proc sql;
insert into brinson.ataa (v1,v2,v3,v4,v5)
values ("&py", "&pm", "&corrq", "&Nobs", "&Pvalue");
quit;

proc sql;
create table temp3 as
select a.windcode, a.sstks, b.sstks as sstks1
from temp as a, temp1 as b 
where a.windcode = b.windcode;
run;quit;

proc corr data=temp3 noprint outp=temp3_1;
var sstks sstks1;
run;

proc corr data=temp3;
ods output PearsonCorr=T4;
var sstks sstks1;
run;

data T4;
set T4;
if _n_=1 then do; call symput('corrq',sstks1); end;
run;

data T4;
set T4;
if _n_=1 then do; call symput('Pvalue',Psstks1); end;
run;

data temp3_1; 
set temp3_1;
if _TYPE_='N';
run;

data temp3_1; 
set temp3_1; 
if _n_=1 then do; call symput('Nobs',sstks); end;
run;

proc sql;
insert into brinson.ass (v1,v2,v3,v4,v5)
values ("&py", "&pm", "&corrq", "&Nobs", "&Pvalue");
quit;



proc sql;
create table temp3 as
select a.windcode, a.sinte, b.sinte as sinte1
from temp as a, temp1 as b 
where a.windcode = b.windcode;
run;quit;

proc corr data=temp3 noprint outp=temp3_1;
var sinte sinte1;
run;

proc corr data=temp3;
ods output PearsonCorr=T4;
var sinte sinte1;
run;

data T4;
set T4;
if _n_=1 then do; call symput('corrq',sinte1); end;
run;

data T4;
set T4;
if _n_=1 then do; call symput('Pvalue',Psinte1); end;
run;

data temp3_1; 
set temp3_1;
if _TYPE_='N';
run;

data temp3_1; 
set temp3_1; 
if _n_=1 then do; call symput('Nobs',sinte); end;
run;

proc sql;
insert into brinson.aint (v1,v2,v3,v4,v5)
values ("&py", "&pm", "&corrq", "&Nobs", "&Pvalue");
quit;



proc sql;
create table temp3 as
select a.windcode, a.stva, b.stva as stva1
from temp as a, temp1 as b 
where a.windcode = b.windcode;
run;quit;

proc corr data=temp3 noprint outp=temp3_1;
var stva stva1;
run;

proc corr data=temp3;
ods output PearsonCorr=T4;
var stva stva1;
run;

data T4;
set T4;
if _n_=1 then do; call symput('corrq',stva1); end;
run;

data T4;
set T4;
if _n_=1 then do; call symput('Pvalue',Pstva1); end;
run;

data temp3_1; 
set temp3_1;
if _TYPE_='N';
run;

data temp3_1; 
set temp3_1; 
if _n_=1 then do; call symput('Nobs',stva); end;
run;

proc sql;
insert into brinson.aar (v1,v2,v3,v4,v5)
values ("&py", "&pm", "&corrq", "&Nobs", "&Pvalue");
quit;

%mend lcor;

%macro lpcor;
data _null_;
%do i=2005 %to 2016;
%lcor(&i,6,&i,12);
%end;
run;
data _null_;
%do i=2005 %to 2016;
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
nobs=input(v4, best12.);
pvalue=input(v5, best12.);
run;

proc sort data=brinson.aar;
by year month;
run;

data brinson.ass;
set brinson.ass;
year=input(v1, best12.);
month=input(v2, best12.);
corrq=input(v3, best12.);
nobs=input(v4, best12.);
pvalue=input(v5, best12.);
run;

proc sort data=brinson.ass;
by year month;
run;

data brinson.aint;
set brinson.aint;
year=input(v1, best12.);
month=input(v2, best12.);
corrq=input(v3, best12.);
nobs=input(v4, best12.);
pvalue=input(v5, best12.);
run;

proc sort data=brinson.aint;
by year month;
run;

data brinson.ataa;
set brinson.ataa;
year=input(v1, best12.);
month=input(v2, best12.);
corrq=input(v3, best12.);
nobs=input(v4, best12.);
pvalue=input(v5, best12.);
run;

proc sort data=brinson.ataa;
by year month;
run;

data brinson.aar;
set brinson.aar;
timemaker=mdy(month,25,year);
format timemaker date9.;
run;

data brinson.ass;
set brinson.ass;
timemaker=mdy(month,25,year);
format timemaker date9.;
run;

data brinson.aint;
set brinson.aint;
timemaker=mdy(month,25,year);
format timemaker date9.;
run;

data brinson.ataa;
set brinson.ataa;
timemaker=mdy(month,25,year);
format timemaker date9.;
run;

PROC EXPORT DATA=brinson.aar
FILE="&address.aar&m"
DBMS=xlsx REPLACE;
SHEET="aar";
RUN;

PROC EXPORT DATA=brinson.ass
FILE="&address.ass&m"
DBMS=xlsx REPLACE;
SHEET="ass";
RUN;

PROC EXPORT DATA=brinson.aint
FILE="&address.aint&m"
DBMS=xlsx REPLACE;
SHEET="aint";
RUN;

PROC EXPORT DATA=brinson.ataa
FILE="&address.ataa&m"
DBMS=xlsx REPLACE;
SHEET="ataa";
RUN;





data shu;
set brinson.benchfundc5;
if reportperiod='2017ÄêÄê±¨' then delete;
run;

data shu;
set shu;
ptaa=staa/stva;
pss=sstks/stva;
pin=sinte/stva;
run;

****************************************************************************************;


*summary statistics of brinson model by proportional contribution to VA semi-annually;


******************************************************************************************;
proc sort data=shu;
by timemaker;
run;

proc univariate data=shu noprint;
   var ptaa;
   by timemaker;
   output out=taaStats mean=taaMean std=taaSD 
                       min=taaMin   max=taaMax
					   NOBS=taaN    SUM=taasum
					   var=taavar;
run;

proc univariate data=shu noprint;
   var pss;
   by timemaker;
   output out=ssStats mean=ssMean std=ssSD 
                       min=ssMin   max=ssMax
					   NOBS=ssN    SUM=sssum
					   var=ssvar;
run;

proc univariate data=shu noprint;
   var pin;
   by timemaker;
   output out=intStats mean=intMean std=intSD 
                       min=intMin   max=intMax
					   NOBS=intN    SUM=intsum
					   var=intvar;
run;

proc univariate data=shu noprint;
   var stva;
   by timemaker;
   output out=tvaStats mean=tvaMean std=tvaSD 
                       min=tvaMin   max=tvaMax
					   NOBS=tvaN    SUM=tvasum
					   var=tvavar;
run;


data shu1;
set brinson.benchfundc5;
keep reportperiod timemaker;
run;

proc sql;
 create table shu2 as
 select DISTINCT (reportperiod), timemaker
 from shu1 order by reportperiod;
quit;

proc sql;
create table shu3 as
select a.timemaker, e.reportperiod, a.taaMean, b.ssMean, c.intMean, d.tvaMean, a.taaSD, b.ssSD, c.intSD, d.tvaSD 
from taaStats as a, ssStats as b, intStats as c, tvaStats as d, shu2 as e
where a.timemaker=b.timemaker=c.timemaker=d.timemaker=e.timemaker;
run;quit;

PROC EXPORT DATA=shu3
FILE="&address.Stats&m"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;
