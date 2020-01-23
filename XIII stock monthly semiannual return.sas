%let address = F:\fund_index_weight\brinson\;
%LET OUT = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';

%let m=20180621;*fill in export date;

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

data brinson.stkmonthly1;
set brinson.stkmonthly1;
year=year(datetime);
month=month(datetime);
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
keep DATETIME SEC_NAME WINDCODE INDUSTRY_HS MKT_CAP_FLOAT CLOSE;
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

*clean up h share monthly data; 
*the rest part is for a share only;
*this is to add h share into consideration as well;

data brinson.hsmon1;
format SEC_NAME $38.;
informat SEC_NAME $38.;
set brinson.hsmon;
if close ne 0;
if close ne .;
run;

data brinson.hsmon1;
set brinson.hsmon1;
year=year(datetime);
month=month(datetime);
run;

data hsmon2;
set brinson.hsmon1;
if MKT_CAP_FLOAT ne 'NA';
INDUSTRY_CITIC='';
run; 

data hsmon2;
format INDUSTRY_HS $40.;
informat INDUSTRY_HS $40.;
format INDUSTRY_CITIC $40.;
informat INDUSTRY_CITIC $40.;
set hsmon2;
me1=input(MKT_CAP_FLOAT,best18.);
run;

data hsmon2;
set hsmon2;
rename me1=MKT_CAP_FLOAT;
keep sec_name windcode datetime INDUSTRY_HS INDUSTRY_CITIC me1 close;
run;



data stkmonthly2;
format MKT_CAP_FLOAT best18.;
informat MKT_CAP_FLOAT best18.;
format INDUSTRY_CSRC12 $40.;
informat INDUSTRY_CSRC12 $40.;
format INDUSTRY_CITIC $40.;
informat INDUSTRY_CITIC $40.;
set brinson.stkmonthly1;
keep sec_name windcode datetime INDUSTRY_CSRC12 INDUSTRY_CITIC MKT_CAP_FLOAT close;
run;

data brinson.stkmonthly1;
set hsmon2 stkmonthly2;
run;

data brinson.stkmonthly1;
set brinson.stkmonthly1;
year=year(datetime);
month=month(datetime);
run;

data brinson.hsmon2;
set hsmon2;
if MKT_CAP_FLOAT ne .;
if CLOSE ne .;
run;

data lis;
set brinson.hsmon2;
rename INDUSTRY_HS=industry;
keep SEC_NAME WINDCODE DATETIME INDUSTRY_HS MKT_CAP_FLOAT CLOSE;
run;

data lis1;
set brinson.stkmonthly1;
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

data lis1;
informat industry $38.;
format industry $38.;
set lis1;
run;

data lis;
informat industry $38.;
format industry $38.;
set lis;
run;

data lis2;
set lis lis1;
run;

proc sql;
 create table stkpmonthly as
 select DISTINCT (SEC_NAME), WINDCODE, DATETIME, industry, CLOSE, MKT_CAP_FLOAT
 from lis2 order by WINDCODE;
quit;

data brinson.stkpmonthly;
set stkpmonthly;
year=year(datetime);
month=month(datetime);
run;

*Add pre-IPO stock prices into semi-annual stock price dataset;
*Add left-off stock prices into semi-annual stock price dataset;

proc import out=stkipo1
datafile="F:\stkipo20180506.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc import out=stkipo2
datafile="F:\600566SH.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc import out=stkipo3
datafile="F:\601360SH.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc import out=stkipo4
datafile="F:\600180SH.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data stkipo1;
set stkipo1;
year=year(date);
month=month(date);
run;

data stkipo1;
set stkipo1;
rename secname=SEC_NAME stkcode=WINDCODE date=DATETIME ipop=CLOSE mkt_cap_float=MKT_CAP_FLOAT;
run;

data stkipo1;
set stkipo1;
keep SEC_NAME WINDCODE DATETIME industry CLOSE MKT_CAP_FLOAT year month;
run;

data stkipo2;
set stkipo2;
year=year(datetime);
month=month(datetime);
run;

data stkipo2;
set stkipo2;
rename INDUSTRY_CSRC12=industry;
run;

data stkipo2;
set stkipo2;
keep SEC_NAME WINDCODE DATETIME industry CLOSE MKT_CAP_FLOAT year month;
run;

data stkipo3;
set stkipo3;
year=year(datetime);
month=month(datetime);
run;

data stkipo3;
set stkipo3;
rename INDUSTRY_CSRC12=industry;
run;

data stkipo3;
set stkipo3;
keep SEC_NAME WINDCODE DATETIME industry CLOSE MKT_CAP_FLOAT year month;
run;

data stkipo4;
set stkipo4;
year=year(datetime);
month=month(datetime);
run;

data stkipo4;
set stkipo4;
rename INDUSTRY_CSRC12=industry;
run;

data stkipo4;
set stkipo4;
keep SEC_NAME WINDCODE DATETIME industry CLOSE MKT_CAP_FLOAT year month;
run;

data brinson.stkpmonthly;
informat industry $38.;
format industry $38.;
set brinson.stkpmonthly;
run;

data stkipo1;
informat industry $38.;
format industry $38.;
set stkipo1;
run;

data stkipo2;
informat industry $38.;
format industry $38.;
set stkipo2;
run;

data stkipo3;
informat industry $38.;
format industry $38.;
set stkipo3;
run;

data stkipo4;
informat industry $38.;
format industry $38.;
set stkipo4;
run;

data uzi;
set brinson.stkpmonthly stkipo1 stkipo2 stkipo3 stkipo4;
run;

data rookie;
retain SEC_NAME WINDCODE DATETIME industry CLOSE MKT_CAP_FLOAT year month;
set uzi;
run;

proc sql;
create table rookie1 as
select DISTINCT (SEC_NAME), WINDCODE, DATETIME, industry, CLOSE, MKT_CAP_FLOAT, year, month
from rookie order by WINDCODE;
quit;

data brinson.stkpmonthly;
set rookie1;
run;

proc sort data=brinson.stkpmonthly;
by WINDCODE DATETIME descending industry;
run;
*descending applies to industry;

data brinson.stkpmonthly1;
set brinson.stkpmonthly;
by WINDCODE DATETIME;
retain i 1;
if first.DATETIME then do;
i=1;
end;
else do;
i=i+1;
end;
run;

data brinson.stkpmonthly1;
set brinson.stkpmonthly1;
if i=1;
run;

data brinson.stkpmonthly1;
set brinson.stkpmonthly1;
drop i;
run;

*%let endm=1;
*this is to compute month 1 and 7 previous semi-annual return;

%macro semiret(endm);

%let startm=%eval(&endm+6);

data stkpmonthly&endm&startm;
set brinson.stkpmonthly1;
if month=&endm or month=&startm;
run;

proc sort data=stkpmonthly&endm&startm;
by WINDCODE DATETIME;
run;

data stkpmonthly&endm&startm;
set stkpmonthly&endm&startm;
lclose=lag(close);
run;

data stkpmonthly&endm&startm;
set stkpmonthly&endm&startm;
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

data stkpmonthly&endm&startm;
set stkpmonthly&endm&startm;
drop lclose i;
run;

data stkpmonthlysemiret;
set stkpmonthlysemiret stkpmonthly&endm&startm;
run;

%mend semiret;
*pret is previous semi-annual return at the end of every month;

%macro lpsemiret;

data _null_;
%do i=1 %to 6;
%semiret(&i);
%end;
run;

%mend lpsemiret;

data stkpmonthlysemiret;
set _null_;
run;

%lpsemiret;

proc sort data=stkpmonthlysemiret;
by windcode datetime;
run;

data brinson.stkpmonthlysemiret;
set stkpmonthlysemiret;
run;

