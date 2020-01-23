libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';
%let address = F:\fund_index_weight\brinson\;

*analyze the mutual fund holding proportions of stock, debt, option, cash and other;
*over time;
*from left to right, 年报 三季报 中报 一季报;
*one year one table;
%macro zcpzin(y);
proc import out=brinson.zcpz&y.
datafile="F:\fund_index_weight\brinson\资产配置(明细)&y..xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;
%mend zcpzin;

%macro lzcpzin;
data _null_;
%do i=2003 %to 2017;
%zcpzin(&i);
%end;
run;
%mend;

%lzcpzin;


%macro zcpzptgp(y);
data brinson.zcpzptgp&y.;
set brinson.zcpz&y.;
if _COL82='普通股票型基金' or _COL82='偏股混合型基金' or _COL82='灵活配置型基金';
run;
%mend zcpzptgp;

%macro lzcpzptgp;
data _null_;
%do i=2003 %to 2017;
%zcpzptgp(&i);
%end;
run;
%mend;

%lzcpzptgp;




%macro zcpzptgp(y);
data gp&y.;
set brinson.zcpzptgp&y.;
rename _COL0=windcode _COL1=fundname
_COL5=gp4&y.      
_COL25=gp3&y.     
_COL45=gp2&y.     
_COL65=gp1&y.;
keep _COL0 _COL1 
_COL5 _COL25 _COL45 _COL65;
run;

data zq&y.;
set brinson.zcpzptgp&y.;
rename _COL0=windcode _COL1=fundname
_COL8=zq4&y.
_COL28=zq3&y.
_COL48=zq2&y.
_COL68=zq1&y.;
keep _COL0 _COL1
_COL8 _COL28 _COL48 _COL68;
run;

data jj&y.;
set brinson.zcpzptgp&y.;
rename _COL0=windcode _COL1=fundname
_COL11=jj4&y.
_COL31=jj3&y.
_COL51=jj2&y.
_COL71=jj1&y.;
keep _COL0 _COL1
_COL11 _COL31 _COL51 _COL71;
run;

data qz&y.;
set brinson.zcpzptgp&y.;
rename _COL0=windcode _COL1=fundname
_COL14=qz4&y.
_COL34=qz3&y.
_COL54=qz2&y.
_COL74=qz1&y.;
keep _COL0 _COL1
_COL14 _COL34 _COL54 _COL74;
run;

data xj&y.;
set brinson.zcpzptgp&y.;
rename _COL0=windcode _COL1=fundname
_COL17=xj4&y.
_COL37=xj3&y.
_COL57=xj2&y.
_COL77=xj1&y.;
keep _COL0 _COL1
_COL17 _COL37 _COL57 _COL77;
run;

data qt&y.;
set brinson.zcpzptgp&y.;
rename _COL0=windcode _COL1=fundname
_COL20=qt4&y.
_COL40=qt3&y.
_COL60=qt2&y.
_COL80=qt1&y.;
keep _COL0 _COL1
_COL20 _COL40 _COL60 _COL80;
run;
%mend zcpzptgp;

%macro lzcpzptgp;
data _null_;
%do i=2003 %to 2017;
%zcpzptgp(&i);
%end;
run;
%mend;

%lzcpzptgp;






%macro zcpzptgp(y);
data ptgp&y.;
set brinson.zcpzptgp&y.;
rename _COL0=windcode _COL1=fundname
_COL5=gp4&y.      
_COL25=gp3&y.     
_COL45=gp2&y.     
_COL65=gp1&y.
_COL8=zq4&y.
_COL28=zq3&y.
_COL48=zq2&y.
_COL68=zq1&y.
_COL11=jj4&y.
_COL31=jj3&y.
_COL51=jj2&y.
_COL71=jj1&y.
_COL14=qz4&y.
_COL34=qz3&y.
_COL54=qz2&y.
_COL74=qz1&y.
_COL17=xj4&y.
_COL37=xj3&y.
_COL57=xj2&y.
_COL77=xj1&y.
_COL20=qt4&y.
_COL40=qt3&y.
_COL60=qt2&y.
_COL80=qt1&y.;
keep _COL0 _COL1 
_COL5 _COL25 _COL45 _COL65
_COL8 _COL28 _COL48 _COL68
_COL11 _COL31 _COL51 _COL71
_COL14 _COL34 _COL54 _COL74
_COL17 _COL37 _COL57 _COL77
_COL20 _COL40 _COL60 _COL80;
run;
%mend zcpzptgp;

%macro lzcpzptgp;
data _null_;
%do i=2003 %to 2017;
%zcpzptgp(&i);
%end;
run;
%mend;

%lzcpzptgp;





data mptgp;
format fundname $24.;
informat fundname $24.;
set ptgp2003;
run;

%macro zcpzptgp(y);
data ptgp&y.;
format fundname $24.;
informat fundname $24.;
set ptgp&y.;
run;

proc sort data=mptgp;
by windcode;
run;

proc sort data=ptgp&y.;
by windcode;
run;

data mptgp;
merge mptgp(in=a) ptgp&y.(in=b);
by windcode;
if a or b;
run;
%mend zcpzptgp;

%macro lzcpzptgp;
data _null_;
%do i=2004 %to 2017;
%zcpzptgp(&i);
%end;
run;
%mend;

%lzcpzptgp;







data mgp;
format fundname $24.;
informat fundname $24.;
set gp2003;
run;

%macro zcpzgp(y);
data gp&y.;
format fundname $24.;
informat fundname $24.;
set gp&y.;
run;

proc sort data=mgp;
by windcode;
run;

proc sort data=gp&y.;
by windcode;
run;

data mgp;
merge mgp(in=a) gp&y.(in=b);
by windcode;
if a or b;
run;
%mend zcpzgp;

%macro lzcpzgp;
data _null_;
%do i=2004 %to 2017;
%zcpzgp(&i);
%end;
run;
%mend;

%lzcpzgp;



data mzq;
format fundname $24.;
informat fundname $24.;
set zq2003;
run;

%macro zcpzzq(y);
data zq&y.;
format fundname $24.;
informat fundname $24.;
set zq&y.;
run;

proc sort data=mzq;
by windcode;
run;

proc sort data=zq&y.;
by windcode;
run;

data mzq;
merge mzq(in=a) zq&y.(in=b);
by windcode;
if a or b;
run;
%mend zcpzzq;

%macro lzcpzzq;
data _null_;
%do i=2004 %to 2017;
%zcpzzq(&i);
%end;
run;
%mend;

%lzcpzzq;



data mjj;
format fundname $24.;
informat fundname $24.;
set jj2003;
run;

%macro zcpzjj(y);
data jj&y.;
format fundname $24.;
informat fundname $24.;
set jj&y.;
run;

proc sort data=mjj;
by windcode;
run;

proc sort data=jj&y.;
by windcode;
run;

data mjj;
merge mjj(in=a) jj&y.(in=b);
by windcode;
if a or b;
run;
%mend zcpzjj;

%macro lzcpzjj;
data _null_;
%do i=2004 %to 2017;
%zcpzjj(&i);
%end;
run;
%mend;

%lzcpzjj;



data mqz;
format fundname $24.;
informat fundname $24.;
set qz2003;
run;

%macro zcpzqz(y);
data qz&y.;
format fundname $24.;
informat fundname $24.;
set qz&y.;
run;

proc sort data=mqz;
by windcode;
run;

proc sort data=qz&y.;
by windcode;
run;

data mqz;
merge mqz(in=a) qz&y.(in=b);
by windcode;
if a or b;
run;
%mend zcpzqz;

%macro lzcpzqz;
data _null_;
%do i=2004 %to 2017;
%zcpzqz(&i);
%end;
run;
%mend;

%lzcpzqz;



data mxj;
format fundname $24.;
informat fundname $24.;
set xj2003;
run;

%macro zcpzxj(y);
data xj&y.;
format fundname $24.;
informat fundname $24.;
set xj&y.;
run;

proc sort data=mxj;
by windcode;
run;

proc sort data=xj&y.;
by windcode;
run;

data mxj;
merge mxj(in=a) xj&y.(in=b);
by windcode;
if a or b;
run;
%mend zcpzxj;

%macro lzcpzxj;
data _null_;
%do i=2004 %to 2017;
%zcpzxj(&i);
%end;
run;
%mend;

%lzcpzxj;



data mqt;
format fundname $24.;
informat fundname $24.;
set qt2003;
run;

%macro zcpzqt(y);
data qt&y.;
format fundname $24.;
informat fundname $24.;
set qt&y.;
run;

proc sort data=mqt;
by windcode;
run;

proc sort data=qt&y.;
by windcode;
run;

data mqt;
merge mqt(in=a) qt&y.(in=b);
by windcode;
if a or b;
run;
%mend zcpzqt;

%macro lzcpzqt;
data _null_;
%do i=2004 %to 2017;
%zcpzqt(&i);
%end;
run;
%mend;

%lzcpzqt;




data amutual;
format fundname $24.;
informat fundname $24.;
format fundcode $18.;
informat fundcode $18.;
set brinson.amutual;
rename fundcode=windcode;
run;

data mptgp;
format windcode $18.;
informat windcode $18.;
set mptgp;
run;

proc sort data=amutual;
by windcode;
run;

data mptgp;
merge mptgp(in=a) amutual(in=b);
by windcode;
if a;
run;


*merge proportions for each fund with fund benchmark horizontal table;
*to see whether holding matches benchmark weight;

proc import out=brinson.hordata
datafile="F:\fund_index_weight\brinson\horizontaldata.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

*no need to start from original horizontal table to extract stock component weight from benchmark;
*i already did it for ptgp;
*it is in ptgpo2 which contains fund code and corresponding stock weight in benchmark;

data brinson.ptgpo2;
format windcode $18.;
informat windcode $18.;
set brinson.ptgpo2;
run;

*consider the fund code ends in SZ SH or OF so that to merge we rid of these endings;
data mptgp;
set mptgp;
codel=reverse(substr(reverse(strip(windcode)),1,2));
pl=find(strip(windcode),'OF');
po=find(strip(windcode),'SZ');
ph=find(strip(windcode),'SH');
place=max(pl,po,ph);
coder=substr(strip(windcode),1,(place-2));
run;

data mgp;
set mgp;
codel=reverse(substr(reverse(strip(windcode)),1,2));
pl=find(strip(windcode),'OF');
po=find(strip(windcode),'SZ');
ph=find(strip(windcode),'SH');
place=max(pl,po,ph);
coder=substr(strip(windcode),1,(place-2));
run;

data brinson.ptgpo2;
set brinson.ptgpo2;
codel=reverse(substr(reverse(strip(windcode)),1,2));
pl=find(strip(windcode),'OF');
po=find(strip(windcode),'SZ');
ph=find(strip(windcode),'SH');
place=max(pl,po,ph);
coder=substr(strip(windcode),1,(place-2));
run;

proc sort data=brinson.ptgpo2;
by coder;
run;

data mptgp;
merge mptgp(in=a) brinson.ptgpo2(in=b);
by coder;
if a;
run;

data mgp;
merge mgp(in=a) brinson.ptgpo2(in=b);
by coder;
if a;
run;

*export the 'wide' panel data to analyse it in ptgpgp.R;
*reorganize every four seasons in the order of time;
*organize in ascending years;
*spaghetti plot for each fund and for each asset category;
*全部类别;
PROC EXPORT DATA=mptgp
FILE="&address.zcpzptgp"
DBMS=xlsx REPLACE;
SHEET="wind";
RUN;
*股票;
PROC EXPORT DATA=mgp
FILE="&address.zcpzptgpgp"
DBMS=xlsx REPLACE;
SHEET="gp";
RUN;
*基金;
PROC EXPORT DATA=mjj
FILE="&address.zcpzptgpjj"
DBMS=xlsx REPLACE;
SHEET="jj";
RUN;
*其他;
PROC EXPORT DATA=mqt
FILE="&address.zcpzptgpqt"
DBMS=xlsx REPLACE;
SHEET="qt";
RUN;
*权证;
PROC EXPORT DATA=mqz
FILE="&address.zcpzptgpqz"
DBMS=xlsx REPLACE;
SHEET="qz";
RUN;
*现金;
PROC EXPORT DATA=mxj
FILE="&address.zcpzptgpxj"
DBMS=xlsx REPLACE;
SHEET="xj";
RUN;
*债券;
PROC EXPORT DATA=mzq
FILE="&address.zcpzptgpzq"
DBMS=xlsx REPLACE;
SHEET="zq";
RUN;

*for each asset category, we form the summary statistics of stock holding over time and funds;
*our second goal is to figure out how to associate the allocation into stock and debts;
*with benchmark proportions to account for the factor of asset allocation;
