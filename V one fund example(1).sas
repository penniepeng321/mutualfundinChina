%let address = F:\fund_index_weight\brinson\;
%LET OUT = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';

%let m=20180531;*fill in export date;


data brinson.ptgp;
set brinson.ptgp;
if report='n' then month=12;
if report='z' then month=6;
run;

*here is to extract one fund one report period as one example of brinson model calculation;
data youb1;
set brinson.ptgp;
if fundcode='000404.OF' and year=2017 and month=6;
run;

PROC EXPORT DATA=youb1
FILE="&address.youb1"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data youb11;
set brinson.fundholding;
if fundcode='000404.OF' and year=2017 and month=6;
run;

proc import out=stkipodates
datafile="F:\stockipodates20180427.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table youb111 as
select a.*, b._COL2 as IPOdate
from youb11 as a left join stkipodates as b 
on a.stockcode=b._COL0;
run;quit;

PROC EXPORT DATA=youb111
FILE="&address.youb11"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data youb2;
set brinson.fundholdi1;
if fundcode='000404.OF' and year=2017 and month=6;
run;

PROC EXPORT DATA=youb2
FILE="&address.youb2"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data youb3;
set brinson.indexcomponents;
if indexcode='399964.SZ' and date='30JUN2017'd;
run;

PROC EXPORT DATA=youb3
FILE="&address.youb3"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data youb31;
set brinson.benchholding;
if indexcode='399964.SZ' and year=2017 and month=6;
run;

PROC EXPORT DATA=youb31
FILE="&address.youb31"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data youb4;
set brinson.benchholdi1;
if indexcode='399964.SZ' and year=2017 and month=6;
run;

PROC EXPORT DATA=youb4
FILE="&address.youb4"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data youb5;
set brinson.benchfundc;
if fundcode='000404.OF' and year=2017 and month=6;
run;

data youb5;
set youb5;
if sstkw=0 and bsstkw=0 then delete;
run;

PROC EXPORT DATA=youb5
FILE="&address.youb5"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data youb51;
set brinson.benchfundc1;
if fundcode='000404.OF' and year=2017 and month=6;
run;

PROC EXPORT DATA=youb51
FILE="&address.youb51"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data youb52;
set brinson.benchfundc2;
if fundcode='000404.OF' and reportperiod='2017年中报';
run;

PROC EXPORT DATA=youb52
FILE="&address.youb52"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data youb53;
set brinson.benchfundc3;
if fundcode='000404.OF' and reportperiod='2017年中报';
run;

PROC EXPORT DATA=youb53
FILE="&address.youb53"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data youb54;
set brinson.benchfundc4;
if fundcode='000404.OF' and reportperiod='2017年中报';
run;

PROC EXPORT DATA=youb54
FILE="&address.youb54"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data youb55;
set brinson.benchfundc5;
if windcode='000404.OF' and reportperiod='2017年中报';
run;

PROC EXPORT DATA=youb55
FILE="&address.youb55"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;








*here is to extract one fund all report periods as one example of brinson model calculation;
data brinnt0;
set brinson.Mutualbasicv;
if windcode='001158.OF';
run;

PROC EXPORT DATA=brinnt0
FILE="&address.brinnt0"
DBMS=xlsx REPLACE;
SHEET="all0";
RUN;

data brinnt1;
set brinson.ptgp;
if fundcode='001158.OF';
run;

PROC EXPORT DATA=brinnt1
FILE="&address.brinnt1"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data brinnt11;
set brinson.fundholding;
if fundcode='001158.OF';
run;

proc import out=stkipodates
datafile="F:\stockipodates20180427.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table brinnt111 as
select a.*, b._COL2 as IPOdate
from brinnt11 as a left join stkipodates as b 
on a.stockcode=b._COL0;
run;quit;

PROC EXPORT DATA=brinnt111
FILE="&address.brinnt11"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data brinnt2;
set brinson.fundholdi1;
if fundcode='001158.OF';
run;

PROC EXPORT DATA=brinnt2
FILE="&address.brinnt2"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data brinnt3;
set brinson.indexcomponents;
if indexcode='000986.SH' or indexcode='000987.SH';
run;

PROC EXPORT DATA=brinnt3
FILE="&address.brinnt3"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data brinnt31;
set brinson.benchholding;
if indexcode='000986.SH' or indexcode='000987.SH';
run;

PROC EXPORT DATA=brinnt31
FILE="&address.brinnt31"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data brinnt4;
set brinson.benchholdi1;
if indexcode='000986.SH' or indexcode='000987.SH';
run;

PROC EXPORT DATA=brinnt4
FILE="&address.brinnt4"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data brinnt5;
set brinson.benchfundc;
if fundcode='001158.OF';
run;

PROC EXPORT DATA=brinnt5
FILE="&address.brinnt5"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data brinnt51;
set brinson.benchfundc1;
if fundcode='001158.OF';
run;

PROC EXPORT DATA=brinnt51
FILE="&address.brinnt51"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data brinnt52;
set brinson.benchfundc2;
if fundcode='001158.OF';
run;

PROC EXPORT DATA=brinnt52
FILE="&address.brinnt52"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data brinnt53;
set brinson.benchfundc3;
if fundcode='001158.OF';
run;

PROC EXPORT DATA=brinnt53
FILE="&address.brinnt53"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data brinnt54;
set brinson.benchfundc4;
if fundcode='001158.OF';
run;

PROC EXPORT DATA=brinnt54
FILE="&address.brinnt54"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

data brinnt55;
set brinson.benchfundc5;
if windcode='001158.OF';
run;

PROC EXPORT DATA=brinnt55
FILE="&address.brinnt55"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;


