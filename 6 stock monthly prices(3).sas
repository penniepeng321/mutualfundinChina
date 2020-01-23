

%let address = F:\fund_index_weight\brinson\;
%LET OUT = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';
libname dat 'F:\dataset_download_and_analysis\月个股回报率文件_20180704';
libname rwind 'F:\RWinddata';

%let m=20180723;*fill in export date;


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

proc sort data=brinson.stksemiann1;
by WINDCODE descending DATETIME;
run;

data brinson.stksemiann1;
set brinson.stksemiann1;
leadclose=lag(close);
run;

/*
data brinson.stksemiann1;
set brinson.stksemiann;
lclose=lag(close);
run;
*/

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
pret=leadclose/close-1;
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
by WINDCODE descending DATETIME;
run;

data brinson.stkpsemi;
set brinson.stkpsemi;
if industry ne '';
run;

data brinson.stkpsemi;
set brinson.stkpsemi;
leadclose=lag(close);
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
pret=leadclose/close-1;
end;
run;

data brinson.stkpsemi;
set brinson.stkpsemi;
drop leadclose i;
run;



data brinson.stkpsemi;
set brinson.stkpsemi;
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
if month=6 or month=12;
run;

data stkipo1;
set stkipo1;
pret=.;
run;

data stkipo1;
set stkipo1;
rename secname=SEC_NAME stkcode=WINDCODE date=DATETIME ipop=CLOSE mkt_cap_float=MKT_CAP_FLOAT;
run;

data stkipo1;
set stkipo1;
keep SEC_NAME WINDCODE DATETIME industry CLOSE MKT_CAP_FLOAT year month pret;
run;



data stkipo2;
set stkipo2;
year=year(datetime);
month=month(datetime);
run;

data stkipo2;
set stkipo2;
if month=6 or month=12;
run;

proc sort data=stkipo2;
by WINDCODE descending DateTime;
run;

data stkipo2;
set stkipo2;
leadclose=lag(close);
run;

data stkipo2;
set stkipo2;
by windcode;
retain i 1;
if first.windcode then do;
i=1;
pret=.;
end;
else do;
i=i+1;
pret=leadclose/close-1;
end;
run;

data stkipo2;
set stkipo2;
drop leadclose i;
run;

data stkipo2;
set stkipo2;
rename INDUSTRY_CSRC12=industry;
run;

data stkipo2;
set stkipo2;
keep SEC_NAME WINDCODE DATETIME industry CLOSE MKT_CAP_FLOAT year month pret;
run;



data stkipo3;
set stkipo3;
year=year(datetime);
month=month(datetime);
run;

data stkipo3;
set stkipo3;
if month=6 or month=12;
run;

proc sort data=stkipo3;
by WINDCODE descending DateTime;
run;

data stkipo3;
set stkipo3;
leadclose=lag(close);
run;

data stkipo3;
set stkipo3;
by windcode;
retain i 1;
if first.windcode then do;
i=1;
pret=.;
end;
else do;
i=i+1;
pret=leadclose/close-1;
end;
run;

data stkipo3;
set stkipo3;
drop leadclose i;
run;

data stkipo3;
set stkipo3;
rename INDUSTRY_CSRC12=industry;
run;

data stkipo3;
set stkipo3;
keep SEC_NAME WINDCODE DATETIME industry CLOSE MKT_CAP_FLOAT year month pret;
run;



data stkipo4;
set stkipo4;
year=year(datetime);
month=month(datetime);
run;

data stkipo4;
set stkipo4;
if month=6 or month=12;
run;

proc sort data=stkipo4;
by WINDCODE descending DateTime;
run;

data stkipo4;
set stkipo4;
leadclose=lag(close);
run;

data stkipo4;
set stkipo4;
by windcode;
retain i 1;
if first.windcode then do;
i=1;
pret=.;
end;
else do;
i=i+1;
pret=leadclose/close-1;
end;
run;

data stkipo4;
set stkipo4;
drop leadclose i;
run;

data stkipo4;
set stkipo4;
rename INDUSTRY_CSRC12=industry;
run;

data stkipo4;
set stkipo4;
keep SEC_NAME WINDCODE DATETIME industry CLOSE MKT_CAP_FLOAT year month pret;
run;


data brinson.stkpsemi;
informat industry $38.;
format industry $38.;
set brinson.stkpsemi;
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
set brinson.stkpsemi stkipo1 stkipo2 stkipo3 stkipo4;
run;

data rookie;
retain SEC_NAME WINDCODE DATETIME industry CLOSE MKT_CAP_FLOAT year month pret;
set uzi;
run;

proc sql;
create table rookie1 as
select DISTINCT (SEC_NAME), WINDCODE, DATETIME, industry, CLOSE, MKT_CAP_FLOAT, year, month, pret
from rookie order by WINDCODE;
quit;

data brinson.stkpsemi;
set rookie1;
run;



proc import out=bmonthly_20180706
datafile="F:\bmonthly_20180706.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data bmonthly_20180706;
set bmonthly_20180706;
MKT_CAP_FLOAT1=input(MKT_CAP_FLOAT,best12.);
MKT_CAP_ARD1=input(MKT_CAP_ARD,best12.);
EV1=input(EV,best12.);
EV31=input(EV3,best12.);
CLOSE1=input(CLOSE,best12.);
run;

data bmonthly_20180706;
set bmonthly_20180706;
drop MKT_CAP_FLOAT MKT_CAP_ARD EV EV3 CLOSE;
run;

data bmonthly_20180706;
set bmonthly_20180706;
rename MKT_CAP_FLOAT1=MKT_CAP_FLOAT
MKT_CAP_ARD1=MKT_CAP_ARD
EV1=EV EV31=EV3 CLOSE1=CLOSE;
run;

data bmonthly;
set bmonthly_20180706;
keep SEC_NAME WINDCODE datetime INDUSTRY_CSRC12 CLOSE MKT_CAP_FLOAT;
rename datetime=DATETIME INDUSTRY_CSRC12=industry;
run;

data bmonthly;
set bmonthly;
year=year(datetime);
month=month(datetime);
run;

proc import out=amonthly20180101_20180704
datafile="F:\amonthly20180101_20180704.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data amonthly;
set amonthly20180101_20180704;
keep SEC_NAME WINDCODE datetime INDUSTRY_CSRC12 CLOSE MKT_CAP_FLOAT;
rename datetime=DATETIME INDUSTRY_CSRC12=industry;
run;

data amonthly;
set amonthly;
year=year(datetime);
month=month(datetime);
run;

proc import out=hmonthly20180101_20180704
datafile="F:\hmonthly20180101_20180704.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data hmonthly;
set hmonthly20180101_20180704;
keep SEC_NAME WINDCODE datetime INDUSTRY_HS CLOSE MKT_CAP_FLOAT;
rename datetime=DATETIME INDUSTRY_HS=industry;
run;

data hmonthly;
set hmonthly;
year=year(datetime);
month=month(datetime);
run;

data merge1;
set brinson.stkpmonthly1 bmonthly amonthly hmonthly;
run;

proc sort data=merge1;
by windcode datetime;
run;

/*

data dat.monstkcsmar;
set monstk;
run;

*/

*from daily data to monthly data in python;
*keep close and adjfactor in monthly data;
*replace close in current dataset with close and adjfactor from monthly data;

*read in compiled monthly data;
*import amonthly20150101_20171231 as ert;
data ert;
set ert;
format date date9.;
informat date date9.;
format datetime date9.;
informat datetime date9.;
run;
 
proc sort data=ert;
by stock_code DATE;
run;

data ert1;
set ert;
if DATE='29DEC2017'd;
run;
*for delisted stocks, it is not a valid way to get adjfactor as of last date;

*try;
data ert1;
set ert;
by stock_code DATE;
if last.date;
run;


data ert1;
set ert1;
keep STOCK_CODE ADJFACTOR;
run;

proc sql;
create table ert2 as
select a.*, b.ADJFACTOR as fADJFACTOR 
from ert as a left join ert1 as b 
on a.STOCK_CODE = b.STOCK_CODE;
run;quit;








*stock return from csmar;


data dq1;
set rwind.Astockmonthly2004010120180928;
keep 
