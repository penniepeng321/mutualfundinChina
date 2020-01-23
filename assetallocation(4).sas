libname mf 'F:\mutual_fund_basic_China\';
%let address = F:\mutual_fund_basic_China\;

*prepare data for stock funds asset allocation calculations;

*quarterly asset holding data;
*prepare quarterly stock overall return dataset;
*based upon hs300 index;

data mf.tr;
set mf.stkmret;
month=month(datetime);
run;

data mf.tr;
set mf.tr;
if month=3 or month=6 or month=9 or month=12;
run;

data mf.stkmret;
set mf.tr;
run;

proc delete data=mf.tr;
run;

data mf.stkmret;
set mf.stkmret;
year=year(datetime);
run;

*prepare quarterly bond overall return dataset;
*based upon n11001 zhongzheng quanzhai including interest reinvestment index;

data mf.tr;
set mf.bdmret;
month=month(datetime);
year=year(datetime);
run;

data mf.tr;
set mf.tr;
if  month=3 or month=6 or month=9 or month=12;
run;

data mf.tr;
set mf.tr;
drop ADJFACTOR;
run;

data mf.bdmret;
set mf.tr;
run;

proc delete data=mf.tr;
run;

*calculate past quarterly return and future quarterly return at every point;

data mf.tr;
set mf.stkmret;
lclose=lag(close);
run;

data mf.tr;
set mf.tr;
lret=close/lclose-1;
run;

proc sort data=mf.tr;
by descending datetime;
run;

data mf.tr;
set mf.tr;
fclose=lag(close);
run;

proc sort data=mf.tr;
by datetime;
run;

data mf.tr;
set mf.tr;
fret=fclose/close-1;
run;

data mf.tr;
set mf.tr;
drop lclose fclose;
run;

data mf.stkmret;
set mf.tr;
run;

*calculate past quarterly return and future quarterly return for bond overall market;

data mf.tr;
set mf.bdmret;
lclose=lag(close);
run;

data mf.tr;
set mf.tr;
lret=close/lclose-1;
run;

proc sort data=mf.tr;
by descending datetime;
run;

data mf.tr;
set mf.tr;
fclose=lag(close);
run;

proc sort data=mf.tr;
by datetime;
run;

data mf.tr;
set mf.tr;
fret=fclose/close-1;
run;

data mf.tr;
set mf.tr;
drop lclose fclose;
run;

data mf.bdmret;
set mf.tr;
run;

proc delete data=mf.tr;
run;

*merge stock holding long data and bond holding long data in sas;
*these two data are organized in R;

proc sql;
create table mf.tr as 
select a.*, b.* 
from mf.sfzcpzgplong as a left join mf.sfzcpzzqlong as b
on a.fundnm=b.fundnm and a.fundcd=b.fundcd and a.year=b.year and a.month=b.month;
run;quit;

proc sort data=mf.tr;
by fundcd year month;
run;

data mf.tr;
set mf.tr;
if bholdweit=. then bholdweit=0;
run;

data mf.tr;
set mf.tr;
if sholdweit ne 0 or bholdweit ne 0;
run;

data mf.sfzcpzlong;
set mf.tr;
run;

proc delete data=mf.tr;
run;

*merge stock weight and bond weight in benchmark data with begin date and end date;
*with stock holding and bond holding merged data;
*long data;

*check which begin date and end date interval it belongs to;
*find corresponding stock weight and bond weight entry;


*add date to sfzcpzlong;

proc sql;
create table mf.tr as
select a.*, b.datetime 
from mf.sfzcpzlong as a left join mf.bdmret as b
on a.year=b.year and a.month=b.month;
run;quit;

data mf.sfzcpzlong;
set mf.tr;
run;

proc delete data=mf.tr;
run;

proc sort data=mf.sfzcpzlong;
by fundcd year month;
run;

data mf.tr1;
set mf.sfstockbondweit1;
keep cfundcd cfundnm cbdate cedate sweit bweit oweit cbenchmark;
run;

proc sql;
create table mf.tr2 as
select a.*, b.* 
from mf.sfzcpzlong as a full join mf.tr1 as b
on a.fundcd=b.cfundcd;
run;quit;


proc delete data=mf.tr1 mf.tr2;
run;


