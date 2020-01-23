
%let address = F:\fund_index_weight\brinson\;
%LET OUT = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';

%let m=20180515;*fill in export date;
/*program to read in data, run only once*/

%macro readata(y);

proc import out=brinson.nptgp&y
datafile="F:\fund_index_weight\brinson\全部持股(明细)&y.nptgp.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.nptgp&y;
format _COL0 $30.;
informat _COL0 $30.;
length _COL0 $30;
format _COL1 $30.;
informat _COL1 $30.;
length _COL1 $30;
format _COL4 $30.;
informat _COL4 $30.;
length _COL4 $30;
format _COL12 $30.;
informat _COL12 $30.;
length _COL12 $30;
set brinson.nptgp&y;
year=&y;
report='n';
run;

data brinson.ptgp;
set brinson.ptgp brinson.nptgp&y;
run;

proc import out=brinson.zptgp&y
datafile="F:\fund_index_weight\brinson\全部持股(明细)&y.zptgp.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.zptgp&y;
format _COL0 $30.;
informat _COL0 $30.;
length _COL0 $30;
format _COL1 $30.;
informat _COL1 $30.;
length _COL1 $30;
format _COL4 $30.;
informat _COL4 $30.;
length _COL4 $30;
format _COL12 $30.;
informat _COL12 $30.;
length _COL12 $30;
set brinson.zptgp&y;
year=&y;
report='z';
run;

data brinson.ptgp;
set brinson.ptgp brinson.zptgp&y;
run;


proc import out=brinson.npghh&y
datafile="F:\fund_index_weight\brinson\全部持股(明细)&y.npghh.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.npghh&y;
format _COL0 $30.;
informat _COL0 $30.;
length _COL0 $30;
format _COL1 $30.;
informat _COL1 $30.;
length _COL1 $30;
format _COL4 $30.;
informat _COL4 $30.;
length _COL4 $30;
format _COL12 $30.;
informat _COL12 $30.;
length _COL12 $30;
set brinson.npghh&y;
year=&y;
report='n';
run;

data brinson.ptgp;
set brinson.ptgp brinson.npghh&y;
run;

proc import out=brinson.zpghh&y
datafile="F:\fund_index_weight\brinson\全部持股(明细)&y.zpghh.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.zpghh&y;
format _COL0 $30.;
informat _COL0 $30.;
length _COL0 $30;
format _COL1 $30.;
informat _COL1 $30.;
length _COL1 $30;
format _COL4 $30.;
informat _COL4 $30.;
length _COL4 $30;
format _COL12 $30.;
informat _COL12 $30.;
length _COL12 $30;
set brinson.zpghh&y;
year=&y;
report='z';
run;

data brinson.ptgp;
set brinson.ptgp brinson.zpghh&y;
run;


proc import out=brinson.nlhpz&y
datafile="F:\fund_index_weight\brinson\全部持股(明细)&y.nlhpz.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.nlhpz&y;
format _COL0 $30.;
informat _COL0 $30.;
length _COL0 $30;
format _COL1 $30.;
informat _COL1 $30.;
length _COL1 $30;
format _COL4 $30.;
informat _COL4 $30.;
length _COL4 $30;
format _COL12 $30.;
informat _COL12 $30.;
length _COL12 $30;
set brinson.nlhpz&y;
year=&y;
report='n';
run;

data brinson.ptgp;
set brinson.ptgp brinson.nlhpz&y;
run;

proc import out=brinson.zlhpz&y
datafile="F:\fund_index_weight\brinson\全部持股(明细)&y.zlhpz.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.zlhpz&y;
format _COL0 $30.;
informat _COL0 $30.;
length _COL0 $30;
format _COL1 $30.;
informat _COL1 $30.;
length _COL1 $30;
format _COL4 $30.;
informat _COL4 $30.;
length _COL4 $30;
format _COL12 $30.;
informat _COL12 $30.;
length _COL12 $30;
set brinson.zlhpz&y;
year=&y;
report='z';
run;

data brinson.ptgp;
set brinson.ptgp brinson.zlhpz&y;
run;

%mend readata;

data brinson.ptgp;
set _null_;run;

%macro loopf1;

data _null_;
%do i=2003 %to 2017;
%readata(&i);
%end;
run;

%mend;

%loopf1;


/*create the list of all stocks covered by all the mutual funds*/

data brinson.ptgp;
set brinson.ptgp;
rename _COL0=windcode _COL1=fundname _COL2=reportperiod _COL3=stockcode _COL4=stockname 
_COL5=holdingq _COL6=chgholdingq _COL8=holdingp _COL9=prop_nav 
_COL10=prop_stock_inv;
run;

