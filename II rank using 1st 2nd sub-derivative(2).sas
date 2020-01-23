
%let address = F:\fund_index_weight\brinson\;
%LET OUT = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';

%let m=20180531;*fill in export date;
/*
proc glm data=brinson.benchfundc5 noprint;
   model staa=time;
   by windcode;
   output out=brinson.benchfd0 p=yhat r=resid stdr=eresid;
run;*/
*this piece produces output for each obs not parms or p values;

**********************************************;
********************************************;

* rank funds using slope;


*********************************************;
*********************************************;

data brinson.benchfundc5;
set brinson.benchfundc5;
rename fundcode=windcode;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
time=mdy(month,20,year);
format time date9.;
run;

PROC EXPORT DATA=brinson.benchfundc5
FILE="&address.fundsbrinson20171231"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;


data brinson.semianndecomp;
set brinson.benchfundc5;
*if reportperiod ne '2017ÄêÄê±¨';
run;

proc freq data=brinson.semianndecomp noprint;
   tables windcode / out=brinson.fundobs sparse;
run;

/*
data brinson.fundobs;
set brinson.fundobs;
if COUNT >4;
run;
*/

proc sql;
create table brinson.semianndecomp1 as
select a.windcode, b.*
from brinson.fundobs as a left join brinson.semianndecomp as b 
on a.windcode=b.windcode;
run;quit;

proc sort data=brinson.semianndecomp1;
by windcode time;
run;

proc rank data=brinson.semianndecomp1 out=brinson.semianndecomp2;
var time;
by windcode;
ranks r_time;
run;

****************************************;

* use date9. time;

*****************************************;

*For TAA:;
proc reg data=brinson.semianndecomp1 outest=brinson.benchfd0 edf  tableout  noprint;
model staa=time;
by windcode;
quit;

data brinson.benchfd1;
set brinson.benchfd0;
if _TYPE_='PARMS';
if _EDF_ >2;
run;

data brinson.benchfd2;
set brinson.benchfd0;
if _TYPE_='PVALUE';
run;

proc sql;
create table brinson.benchfd12 as
select a.windcode, a.time as parms, a._RSQ_,
		a._EDF_, b.time as pvalue
from brinson.benchfd1 as a left join brinson.benchfd2 as b 
on a.windcode=b.windcode;
run;quit;

data brinson.benchfd12;
set brinson.benchfd12;
marker=substr(windcode,1,length(windcode)-3);
run;

data brinson.allfunds;
set brinson.allfunds;
marker=substr(_COL0,1,length(_COL0)-3);
run;

proc sql;
create table brinson.benchfd12s as
select a.*, b.*
from brinson.benchfd12 as a left join brinson.allfunds as b 
on a.marker=b.marker;
run;quit;

data brinson.posSS;
set brinson.benchfd12s;
if parms>0;
run;

proc sort data=brinson.posSS;
by pvalue;
run;

PROC EXPORT DATA=brinson.posSS
FILE="&address.taadate9&m"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;



*For SS:;
proc reg data=brinson.semianndecomp1 outest=brinson.benchfd0 edf  tableout  noprint;
model sstks=time;
by windcode;
quit;

data brinson.benchfd1;
set brinson.benchfd0;
if _TYPE_='PARMS';
if _EDF_ >2;
run;

data brinson.benchfd2;
set brinson.benchfd0;
if _TYPE_='PVALUE';
run;

proc sql;
create table brinson.benchfd12 as
select a.windcode, a.time as parms, a._RSQ_,
		a._EDF_, b.time as pvalue
from brinson.benchfd1 as a left join brinson.benchfd2 as b 
on a.windcode=b.windcode;
run;quit;

data brinson.benchfd12;
set brinson.benchfd12;
marker=substr(windcode,1,length(windcode)-3);
run;

data brinson.allfunds;
set brinson.allfunds;
marker=substr(_COL0,1,length(_COL0)-3);
run;

proc sql;
create table brinson.benchfd12s as
select a.*, b.*
from brinson.benchfd12 as a left join brinson.allfunds as b 
on a.marker=b.marker;
run;quit;

data brinson.posSS;
set brinson.benchfd12s;
if parms>0;
run;

proc sort data=brinson.posSS;
by pvalue;
run;

PROC EXPORT DATA=brinson.posSS
FILE="&address.ssdate9&m"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;



*For TVA:;
proc reg data=brinson.semianndecomp1 outest=brinson.benchfd0 edf  tableout  noprint;
model stva=time;
by windcode;
quit;

data brinson.benchfd1;
set brinson.benchfd0;
if _TYPE_='PARMS';
if _EDF_ >2;
run;

data brinson.benchfd2;
set brinson.benchfd0;
if _TYPE_='PVALUE';
run;

proc sql;
create table brinson.benchfd12 as
select a.windcode, a.time as parms, a._RSQ_,
		a._EDF_, b.time as pvalue
from brinson.benchfd1 as a left join brinson.benchfd2 as b 
on a.windcode=b.windcode;
run;quit;

data brinson.benchfd12;
set brinson.benchfd12;
marker=substr(windcode,1,length(windcode)-3);
run;

data brinson.allfunds;
set brinson.allfunds;
marker=substr(_COL0,1,length(_COL0)-3);
run;

proc sql;
create table brinson.benchfd12s as
select a.*, b.*
from brinson.benchfd12 as a left join brinson.allfunds as b 
on a.marker=b.marker;
run;quit;

data brinson.posSS;
set brinson.benchfd12s;
if parms>0;
run;

proc sort data=brinson.posSS;
by pvalue;
run;

PROC EXPORT DATA=brinson.posSS
FILE="&address.tvadate9&m"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;


***************************************************;


* use rank of time not date9. time;


****************************************************;

*For TAA:;
proc reg data=brinson.semianndecomp2 outest=brinson.benchfd0 edf  tableout  noprint;
model staa=r_time;
by windcode;
quit;

data brinson.benchfd1;
set brinson.benchfd0;
if _TYPE_='PARMS';
if _EDF_ >2;
run;

data brinson.benchfd2;
set brinson.benchfd0;
if _TYPE_='PVALUE';
run;

proc sql;
create table brinson.benchfd12 as
select a.windcode, a.r_time as parms, a._RSQ_,
		a._EDF_, b.r_time as pvalue
from brinson.benchfd1 as a left join brinson.benchfd2 as b 
on a.windcode=b.windcode;
run;quit;

data brinson.benchfd12;
set brinson.benchfd12;
marker=substr(windcode,1,length(windcode)-3);
run;

data brinson.allfunds;
set brinson.allfunds;
marker=substr(_COL0,1,length(_COL0)-3);
run;

proc sql;
create table brinson.benchfd12s as
select a.*, b.*
from brinson.benchfd12 as a left join brinson.allfunds as b 
on a.marker=b.marker;
run;quit;

data brinson.posSS;
set brinson.benchfd12s;
if parms>0;
run;

proc sort data=brinson.posSS;
by pvalue;
run;

PROC EXPORT DATA=brinson.posSS
FILE="&address.taarank&m"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;



*For SS:;
proc reg data=brinson.semianndecomp2 outest=brinson.benchfd0 edf  tableout  noprint;
model sstks=r_time;
by windcode;
quit;

data brinson.benchfd1;
set brinson.benchfd0;
if _TYPE_='PARMS';
if _EDF_ >2;
run;

data brinson.benchfd2;
set brinson.benchfd0;
if _TYPE_='PVALUE';
run;

proc sql;
create table brinson.benchfd12 as
select a.windcode, a.r_time as parms, a._RSQ_,
		a._EDF_, b.r_time as pvalue
from brinson.benchfd1 as a left join brinson.benchfd2 as b 
on a.windcode=b.windcode;
run;quit;

data brinson.benchfd12;
set brinson.benchfd12;
marker=substr(windcode,1,length(windcode)-3);
run;

data brinson.allfunds;
set brinson.allfunds;
marker=substr(_COL0,1,length(_COL0)-3);
run;

proc sql;
create table brinson.benchfd12s as
select a.*, b.*
from brinson.benchfd12 as a left join brinson.allfunds as b 
on a.marker=b.marker;
run;quit;

data brinson.posSS;
set brinson.benchfd12s;
if parms>0;
run;

proc sort data=brinson.posSS;
by pvalue;
run;

PROC EXPORT DATA=brinson.posSS
FILE="&address.ssrank&m"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;



*For TVA:;
proc reg data=brinson.semianndecomp2 outest=brinson.benchfd0 edf  tableout  noprint;
model stva=r_time;
by windcode;
quit;

data brinson.benchfd1;
set brinson.benchfd0;
if _TYPE_='PARMS';
if _EDF_ >2;
run;

data brinson.benchfd2;
set brinson.benchfd0;
if _TYPE_='PVALUE';
run;

proc sql;
create table brinson.benchfd12 as
select a.windcode, a.r_time as parms, a._RSQ_,
		a._EDF_, b.r_time as pvalue
from brinson.benchfd1 as a left join brinson.benchfd2 as b 
on a.windcode=b.windcode;
run;quit;

data brinson.benchfd12;
set brinson.benchfd12;
marker=substr(windcode,1,length(windcode)-3);
run;

data brinson.allfunds;
set brinson.allfunds;
marker=substr(_COL0,1,length(_COL0)-3);
run;

proc sql;
create table brinson.benchfd12s as
select a.*, b.*
from brinson.benchfd12 as a left join brinson.allfunds as b 
on a.marker=b.marker;
run;quit;

data brinson.posSS;
set brinson.benchfd12s;
if parms>0;
run;

proc sort data=brinson.posSS;
by pvalue;
run;

PROC EXPORT DATA=brinson.posSS
FILE="&address.tvarank&m"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;


***************************************************;


* add rank of time square in our model;


****************************************************;

proc standard data=brinson.semianndecomp2 mean=0 std=1 replace
noprint out=brinson.semianndecomp3;
var r_time;
by windcode;	
run;

data brinson.semianndecomp3;
set brinson.semianndecomp3;
r_time2=r_time**2;
run;

proc corr data=brinson.semianndecomp3 nosimple noprint;
var r_time r_time2;
by windcode;
run;

*For TAA:;
proc reg data=brinson.semianndecomp3 outest=brinson.benchfd0 edf  tableout  noprint;
model staa=r_time r_time2;* r_time2;
by windcode;
quit;

data brinson.benchfd1;
set brinson.benchfd0;
if _TYPE_='PARMS';
if _EDF_ >2;
run;

data brinson.benchfd2;
set brinson.benchfd0;
if _TYPE_='PVALUE';
run;

proc sql;
create table brinson.benchfd12 as
select a.windcode, a.r_time as parms1, a._RSQ_,
		a._EDF_, b.r_time as pvalue1, a.r_time2 as parms2, b.r_time2 as pvalue2
from brinson.benchfd1 as a left join brinson.benchfd2 as b 
on a.windcode=b.windcode;
run;quit;
*, a.r_time2 as parms2, b.r_time2 as pvalue2;

data brinson.benchfd12;
set brinson.benchfd12;
marker=substr(windcode,1,length(windcode)-3);
run;

data brinson.allfunds;
set brinson.allfunds;
marker=substr(_COL0,1,length(_COL0)-3);
run;

proc sql;
create table brinson.benchfd12s as
select a.*, b.*
from brinson.benchfd12 as a left join brinson.allfunds as b 
on a.marker=b.marker;
run;quit;

data brinson.posSS;
set brinson.benchfd12s;
if parms1>0 and parms2>0;
run;
* and parms2>0;

proc sort data=brinson.posSS;
by pvalue1;
run;

PROC EXPORT DATA=brinson.posSS
FILE="&address.taaranksq&m"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;



*For SS:;
proc reg data=brinson.semianndecomp3 outest=brinson.benchfd0 edf  tableout  noprint;
model sstks=r_time r_time2;
by windcode;
quit;

data brinson.benchfd1;
set brinson.benchfd0;
if _TYPE_='PARMS';
if _EDF_ >2;
run;

data brinson.benchfd2;
set brinson.benchfd0;
if _TYPE_='PVALUE';
run;

proc sql;
create table brinson.benchfd12 as
select a.windcode, a.r_time as parms1, a._RSQ_,
		a._EDF_, b.r_time as pvalue1, a.r_time2 as parms2, b.r_time2 as pvalue2
from brinson.benchfd1 as a left join brinson.benchfd2 as b 
on a.windcode=b.windcode;
run;quit;

data brinson.benchfd12;
set brinson.benchfd12;
marker=substr(windcode,1,length(windcode)-3);
run;

data brinson.allfunds;
set brinson.allfunds;
marker=substr(_COL0,1,length(_COL0)-3);
run;

proc sql;
create table brinson.benchfd12s as
select a.*, b.*
from brinson.benchfd12 as a left join brinson.allfunds as b 
on a.marker=b.marker;
run;quit;

data brinson.posSS;
set brinson.benchfd12s;
if parms1>0 and parms2>0;
run;

proc sort data=brinson.posSS;
by pvalue1;
run;

PROC EXPORT DATA=brinson.posSS
FILE="&address.ssranksq&m"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;



*For TVA:;
proc reg data=brinson.semianndecomp3 outest=brinson.benchfd0 edf  tableout  noprint;
model stva=r_time r_time2;
by windcode;
quit;

data brinson.benchfd1;
set brinson.benchfd0;
if _TYPE_='PARMS';
if _EDF_ >2;
run;

data brinson.benchfd2;
set brinson.benchfd0;
if _TYPE_='PVALUE';
run;

proc sql;
create table brinson.benchfd12 as
select a.windcode, a.r_time as parms1, a._RSQ_,
		a._EDF_, b.r_time as pvalue1, a.r_time2 as parms2, b.r_time2 as pvalue2
from brinson.benchfd1 as a left join brinson.benchfd2 as b 
on a.windcode=b.windcode;
run;quit;

data brinson.benchfd12;
set brinson.benchfd12;
marker=substr(windcode,1,length(windcode)-3);
run;

data brinson.allfunds;
set brinson.allfunds;
marker=substr(_COL0,1,length(_COL0)-3);
run;

proc sql;
create table brinson.benchfd12s as
select a.*, b.*
from brinson.benchfd12 as a left join brinson.allfunds as b 
on a.marker=b.marker;
run;quit;

data brinson.posSS;
set brinson.benchfd12s;
if parms1>0 and parms2>0;
run;

proc sort data=brinson.posSS;
by pvalue1;
run;

PROC EXPORT DATA=brinson.posSS
FILE="&address.tvaranksq&m"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;



***************************************************;


* back test our ranking;


****************************************************;

%let fy=2017;
%let fm=6;
%let ny=2017;
%let nm=12;

*consider brinson decomp up to this report;
data brinson.dcp&fy&fm;
set brinson.semianndecomp3;
if year <= &fy and month <= &fm;
run;

*For SS date9.;
proc reg data=brinson.dcp&fy&fm outest=brinson.benchfd0 edf  tableout  noprint;
model sstks=time;
by windcode;
quit;

data brinson.benchfd1;
set brinson.benchfd0;
if _TYPE_='PARMS';
if _EDF_ >2;
run;

data brinson.benchfd2;
set brinson.benchfd0;
if _TYPE_='PVALUE';
run;

proc sql;
create table brinson.benchfd12 as
select a.windcode, a.time as parms, a._RSQ_,
		a._EDF_, b.time as pvalue
from brinson.benchfd1 as a left join brinson.benchfd2 as b 
on a.windcode=b.windcode;
run;quit;

data brinson.benchfd12;
set brinson.benchfd12;
marker=substr(windcode,1,length(windcode)-3);
run;

data brinson.allfunds;
set brinson.allfunds;
marker=substr(_COL0,1,length(_COL0)-3);
run;

proc sql;
create table brinson.benchfd12s as
select a.*, b.*
from brinson.benchfd12 as a left join brinson.allfunds as b 
on a.marker=b.marker;
run;quit;

proc rank data=brinson.benchfd12s out=brinson.benchfd12s1 descending;
var parms;
ranks r_parms;
run;

*after getting rank, we connect it to future half-year fund actual return;

data brinson.fret&ny&nm;
set brinson.Fnav_nodup1;
if year = &ny and month = &nm;
if pret ne .;
run;

*missingness from nonav in june 2017 and nav in dec 2017 causing missing change in nav;

proc sort data=brinson.benchfd12s1;
by windcode;
run;

proc sort data=brinson.fret0&ny&nm;
by windcode;
run;

data brinson.temp;
merge brinson.benchfd12s1(in=a) brinson.fret0&ny&nm(in=b);
by windcode;
if a;
run;

proc rank data=brinson.temp out=brinson.res&fy&fm descending;
var pret;
ranks r_pret;
run;


