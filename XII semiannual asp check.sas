%let address = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';

%let m=20180625;*fill in export date;


data stva;
set _null_;
run;

data aret;
set _null_;
run;

data diff;
set _null_;
run;

data symbol;
set _null_;
run;

data Tstva;
set _null_;
run;

data Taret;
set _null_;
run;

data Tdiff;
set _null_;
run;

data Tsymbol;
set _null_;
run;

data summary;
set _null_;
year=0;
month=0;
mean=0;
median=0;
sd=0;
nobs=0;
run;

*%let year=2014;

%macro yearmid(year);
%let month=6;

data ythre;
set brinson.benchfundc5;
if year= &year and month=6;
stva=stva+1;
run;

data navthre;
set brinson.mfnav1;
if TradingDate="30jun&year"d or TradingDate="31dec&year"d;
run;

proc sort data=navthre;
by Symbol TradingDate;
run;

data navthre;
set navthre;
lnav=lag(nav);
run;

data navthre;
set navthre;
by Symbol;
retain i 1;
if first.Symbol then do;
i=1;
pret=.;
end;
else do;
i=i+1;
pret=nav/lnav-1;
end;
run;

data navthre;
set navthre;
if pret ne .;
run;

data navthre;
set navthre;
aret=1+pret;
drop lnav i;
run;

data ythre;
set ythre;
marker=substr(windcode,1,length(windcode)-3);
run;

proc sql;
create table ythre5 as
select a.*, b.*
from ythre as a left join navthre as b 
on a.marker=b.Symbol;
run;quit;

data ythre6;
set ythre5;
keep Symbol stva aret;
run;

data ythre6;
set ythre6;
diff=stva-aret;
run;

proc univariate data=ythre6 noprint;
var diff;
output out=ythre7 NOBS=num MEAN=mean 
        STD=sd pctlpts=50
                pctlpre = diff
                pctlname = pct50;
run;

data ythre7;
set ythre7; 
if _n_=1 then do; 
  call symput('Nobs',num); 
  call symput('sd',sd);
  call symput('mean',mean);
  call symput('median',diffpct50);
  end;
run;

proc sql;
insert into summary (year,month,mean,sd,median,nobs)
values (&year, &month, &mean, &sd, &median, &Nobs);
quit;

data aspcheck&year&month;
set ythre6;
rename  stva=stva&year&month
    Symbol=Symbol&year&month
    aret=aret&year&month
    diff=diff&year&month;
run;

data stva&year&month;
set aspcheck&year&month;
keep stva&year&month;
run;

data stva;
merge stva stva&year&month;
run;

data aret&year&month;
set aspcheck&year&month;
keep aret&year&month;
run;

data aret;
merge aret aret&year&month;
run;

data diff&year&month;
set aspcheck&year&month;
keep diff&year&month;
run;

data diff;
merge diff diff&year&month;
run;

data symbol&year&month;
set aspcheck&year&month;
keep Symbol&year&month;
run;

data symbol;
merge symbol Symbol&year&month;
run;

data Tstva&year&month;
set ythre6;
endyear=&year;
month=&month;
keep stva endyear month;
run;

data Tstva;
set Tstva Tstva&year&month;
run;

data Taret&year&month;
set ythre6;
endyear=&year;
month=&month;
keep aret endyear month;
run;

data Taret;
set Taret Taret&year&month;
run;

data Tdiff&year&month;
set ythre6;
endyear=&year;
month=&month;
keep diff endyear month;
run;

data Tdiff;
set Tdiff Tdiff&year&month;
run;

data Tsymbol&year&month;
set ythre6;
endyear=&year;
month=&month;
keep Symbol endyear month;
run;

data Tsymbol;
set Tsymbol Tsymbol&year&month;
run;

%mend yearmid;




%macro yearend(year);
%let month=12;
%let year1=%eval(&year+1);

data ythre;
set brinson.benchfundc5;
if year= &year and month=12;
stva=stva+1;
run;

data navthre;
set brinson.mfnav1;
if TradingDate="31dec&year"d or TradingDate="30jun&year1"d;
run;

proc sort data=navthre;
by Symbol TradingDate;
run;

data navthre;
set navthre;
lnav=lag(nav);
run;

data navthre;
set navthre;
by Symbol;
retain i 1;
if first.Symbol then do;
i=1;
pret=.;
end;
else do;
i=i+1;
pret=nav/lnav-1;
end;
run;

data navthre;
set navthre;
if pret ne .;
run;

data navthre;
set navthre;
aret=1+pret;
drop lnav i;
run;

data ythre;
set ythre;
marker=substr(windcode,1,length(windcode)-3);
run;

proc sql;
create table ythre5 as
select a.*, b.*
from ythre as a left join navthre as b 
on a.marker=b.Symbol;
run;quit;

data ythre6;
set ythre5;
keep Symbol stva aret;
run;

data ythre6;
set ythre6;
diff=stva-aret;
run;

proc univariate data=ythre6 noprint;
var diff;
output out=ythre7 NOBS=num MEAN=mean 
        STD=sd pctlpts=50
                pctlpre = diff
                pctlname = pct50;
run;

data ythre7;
set ythre7; 
if _n_=1 then do; 
  call symput('Nobs',num); 
  call symput('sd',sd);
  call symput('mean',mean);
  call symput('median',diffpct50);
  end;
run;

proc sql;
insert into summary (year,month,mean,sd,median,nobs)
values (&year, &month, &mean, &sd, &median, &Nobs);
quit;

data aspcheck&year&month;
set ythre6;
rename  stva=stva&year&month
    Symbol=Symbol&year&month
    aret=aret&year&month
    diff=diff&year&month;
run;

data stva&year&month;
set aspcheck&year&month;
keep stva&year&month;
run;

data stva;
merge stva stva&year&month;
run;

data aret&year&month;
set aspcheck&year&month;
keep aret&year&month;
run;

data aret;
merge aret aret&year&month;
run;

data diff&year&month;
set aspcheck&year&month;
keep diff&year&month;
run;

data diff;
merge diff diff&year&month;
run;

data symbol&year&month;
set aspcheck&year&month;
keep Symbol&year&month;
run;

data symbol;
merge symbol Symbol&year&month;
run;

data Tstva&year&month;
set ythre6;
endyear=&year;
month=&month;
keep stva endyear month;
run;

data Tstva;
set Tstva Tstva&year&month;
run;

data Taret&year&month;
set ythre6;
endyear=&year;
month=&month;
keep aret endyear month;
run;

data Taret;
set Taret Taret&year&month;
run;

data Tdiff&year&month;
set ythre6;
endyear=&year;
month=&month;
keep diff endyear month;
run;

data Tdiff;
set Tdiff Tdiff&year&month;
run;

data Tsymbol&year&month;
set ythre6;
endyear=&year;
month=&month;
keep Symbol endyear month;
run;

data Tsymbol;
set Tsymbol Tsymbol&year&month;
run;

%mend yearend;


%macro loopyear;
data _null_;
%do i=2005 %to 2017;
%yearmid(&i);
%end;
%do i=2005 %to 2016;
%yearend(&i);
%end;
run;
%mend loopyear;
  
%loopyear;

data Tdiff;
set Tdiff;
date=mdy(month,28,endyear);
format date date9.;
run;

proc sort data=Tdiff;
by date;
run;

data Tdiff;
set Tdiff;
if month=6 then mon='年中报';
if month=12 then mon='年年报';
rp=cats('',endyear,mon);
run;

proc sort data=Tdiff;
by rp;
run;

proc univariate data=Tdiff noprint;
   var diff;
   by rp;
   output out=Tdiffsum MEAN=diffX STD=diffS NOBS=diffN
 pctlpts=2.5 25 50 75 97.5 PCTLPRE=dif pctlname =fL f1 fM f3 fH;
run;

*the interval between fL and fH is 95% confidence interval;

data Tdiffsum;
set Tdiffsum;
label diffX='假设下的收益率和实际收益率的差';
run;

ods graphics on / reset=all width=7in height=6in 
imagename="半年模型假设下和实际收益率的差";
TITLE "主动型股票基金Brinson模型假设下的收益率和实际收益率的差" BOLD;
proc boxplot history=Tdiffsum;
   plot diff*rp /
      odstitle = title
	  VREF=0 LVREF=3
	  GRID LGRID=1;
   label rp="报告期";
run;

/*KWattsL contains the group minima (low values).

KWatts1 contains the th percentile (first quartile) for each group.

KWattsX contains the group means.

KWattsM contains the group medians.

KWatts3 contains the th percentile (third quartile) for each group.

KWattsH contains the group maxima (high values).

KWattsS contains the group standard deviations.

KWattsN contains the group sizes.*/
*suffix such as L,1,X,M,3,H,S,N represent the characteristics of data;
*You can use this data set as input to the BOXPLOT procedure by specifying;
*it with the HISTORY= option in the PROC BOXPLOT statement;

*boxplot here has maximum and minimum excluding outliners to be endlines of box;
*we set 97.5% and 2.5% percentiles excluding outliners to be endlines of box;
*so that every box represents a confidence interval covering 0 or not;

%let windowlength=0;

PROC EXPORT DATA=stva
FILE="&address.aspcheck&windowlength"
DBMS=xlsx REPLACE;
SHEET="tva";
RUN;

PROC EXPORT DATA=aret
FILE="&address.aspcheck&windowlength"
DBMS=xlsx REPLACE;
SHEET="aret";
RUN;

PROC EXPORT DATA=diff
FILE="&address.aspcheck&windowlength"
DBMS=xlsx REPLACE;
SHEET="diff";
RUN;

PROC EXPORT DATA=symbol
FILE="&address.aspcheck&windowlength"
DBMS=xlsx REPLACE;
SHEET="symbol";
RUN;

PROC EXPORT DATA=summary
FILE="&address.aspcheck&windowlength"
DBMS=xlsx REPLACE;
SHEET="table";
RUN;


