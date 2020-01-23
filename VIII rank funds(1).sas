
%let address = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';

%let m=20180531;*fill in export date;

*5-year sample;

data yfive;
set brinson.benchfundc5;
if year >= 2013;
run;

proc sort data=yfive;
by windcode;
run;

proc univariate data=yfive noprint;
   var sstks;
   by windcode;
   output out=yfivesummary NOBS=numfunds;
run;

data yfivesummary;
set yfivesummary;
if numfunds=10;
run;

proc sql;
create table yfivesummary1 as
select a.*, b.*
from yfivesummary as a left join yfive as b 
on a.windcode=b.windcode;
run;quit;

proc sort data=yfivesummary1;
by windcode time;
run;

data yfivesummary2;
set yfivesummary1;
otaa=1+staa;
oss=1+sstks;
oint=1+sinte;
otva=1+stva;
run;

proc sort data=yfivesummary2; 
by windcode time; 
run;

data yfivesummary3;
set yfivesummary2;
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

data yfivesummary4;
set yfivesummary3;
if reportperiod='2017年年报';
keep windcode numfunds cumtaa cumss cumint cumtva;
run;

data yfivesummary4;
set yfivesummary4;
marker=substr(windcode,1,length(windcode)-3);
run;

data brinson.amutual;
set brinson.amutual;
marker=substr(fundcode,1,length(fundcode)-3);
drop windcode;
run;

proc sql;
create table yfivesummary5 as
select a.*, b.fundname, b.startdate, b.erji
from yfivesummary4 as a left join brinson.amutual as b 
on a.marker=b.marker;
run;quit;

*output five-year table for ordering;

PROC EXPORT DATA=yfivesummary5
FILE="&address.yfive&m"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;





*3-year sample;

data ythre;
set brinson.benchfundc5;
if year >= 2015;
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
if numfunds=6;
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
if reportperiod='2017年年报';
keep windcode numfunds cumtaa cumss cumint cumtva;
run;

data ythresummary4;
set ythresummary4;
marker=substr(windcode,1,length(windcode)-3);
run;

data brinson.amutual;
set brinson.amutual;
marker=substr(fundcode,1,length(fundcode)-3);
drop windcode;
run;

proc sql;
create table ythresummary5 as
select a.*, b.fundname, b.startdate, b.erji
from ythresummary4 as a left join brinson.amutual as b 
on a.marker=b.marker;
run;quit;

*output thre-year table for ordering;

PROC EXPORT DATA=ythresummary5
FILE="&address.ythre&m"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;


