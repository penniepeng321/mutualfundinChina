%let address = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';

%let m=20180626;*fill in export date;

*to check assumption of no holding change between holding report semiannual;
*compare return under assumption & fund ret;

proc import out=brinson.fundnav
datafile="F:\fund_index_weight\brinson\clean_fund_benchmark_weight_horizontal_monthly20180105.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

*fundnav has duplicate observations in it;
*we delete duplicate obs first;
*we have dec5 and dec30 obs in it;
*we delete dec5 not month-end;
*we have 1.6206111968 and 1.620611197 taken as difference obs;
*indeed we need to rid of these duplicate ones as well;

data brinson.fundnav;
set brinson.fundnav;
fnavadj=round(fundnav_adj,0.0001);
run;

proc sql;
 create table brinson.fnav_nodup as
 select DISTINCT (windcode), fnavadj, date, erji
 from brinson.fundnav order by windcode;
quit;

proc sort data=brinson.fnav_nodup;
by windcode date;
run;

data brinson.fnav_nodup;
set brinson.fnav_nodup;
if date ne '05DEC2017'd and date ne '13OCT2017'd and date ne '16OCT2017'd
and date ne '03JAN2018'd;
run;

*get semi-annual return;
*accumulate return over specified time window;
*use brinson results and accumulate it similarly;

*brinson.mfnav is from csmar data of all mutual fund historical daily nav;
*we download mutual fund daily nav from csmar under default setting;
*downloaded file is deliminated text file;
*we use SAS import wizard to import text file and save as brinson.mfnav;
*brinson.fnav_nodup has some unknown missingness;
*brinson.fnav_nodup is from benchmark decomposition then download nav monthly;
*brinson.fnav_nodup is not all mutual fund data;

data mfnav;
set brinson.mfnav;
if _n_ ne 1;
if _n_ ne 2;
run;

data mfnav;
set mfnav;
year=substr(TradingDate,1,4);
month=substr(TradingDate,6,2);
day=substr(TradingDate,9,2);
run;

data mfnav;
set mfnav;
year1=input(year,best4.);
month1=input(month,best2.);
day1=input(day,best2.);
run;

data mfnav;
set mfnav;
TradingDate1=mdy(month1,day1,year1);
format TradingDate1 date9.;
run;

data mfnav;
set mfnav;
drop TradingDate AchieveReturn MillionAchieveReturn HundredAchieveReturn 
AccumulativeNAV AnnualizedYield CurrencyCode Currency Frequency 
MarketStatus year month day FundClassID;
run;

data mfnav;
set mfnav;
rename year1=year month1=month day1=day TradingDate1=TradingDate;
run;

data mfnav;
set mfnav;
nav1=input(NAV,best12.);
run;

data mfnav;
set mfnav;
drop NAV;
run;

data mfnav;
set mfnav;
rename nav1=nav;
run;

data brinson.mfnav1;
set mfnav;
run;




%let endm=7;
%let startm=%eval(&endm+6);
*this is to apply month 6 and 12 previous semi-annual return;
*endm varies from 0 to 6;
*endm=1 means five month before report and one month after;
*for six months before report, we simply use a.year=b.year and a.month=b.month;
*rather than a.year1=b.year and a.month1=b.month;
*or we can set endm=0;

%let windowlength=2;

*0 represents half year;
*for half year, no need to roll samples, compute semi-annual difference and output it;
*1 represents 1 year;
*2 represents 2 years;
*then 5 represents 5 years;

*%let year=2014;

data cumtv&windowlength;
set _null_;
run;

data aret&windowlength;
set _null_;
run;

data diff&windowlength;
set _null_;
run;

data symbol&windowlength;
set _null_;
run;

data Tcumtv&windowlength;
set _null_;
run;

data Taret&windowlength;
set _null_;
run;

data Tdiff&windowlength;
set _null_;
run;

data Tsymbol&windowlength;
set _null_;
run;

data summary&windowlength;
set _null_;
year=0;
mean=0;
median=0;
sd=0;
nobs=0;
run;

data brinson.Benchfundc5;
set brinson.Brinsonfilled&endm&startm;
rename fundcode=windcode;
run;

%macro rollingcheck(year);

%let year3=%eval(&year - &windowlength+1);
%let year1=%eval(&year+1);

data ythre;
set brinson.benchfundc5;
if year >= &year3 and year <= &year;
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
if numfunds=%eval(2* &windowlength);
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
otv=1+stv;
run;

proc sort data=ythresummary2; 
by windcode time; 
run;

data ythresummary3;
set ythresummary2;
by windcode;
array products[*] cumtaa cumss cumint cumtv;
retain cumtaa cumss cumint cumtv;
if first.windcode then do i = 1 to dim(products);  /* Initialise products at start of id */
   products[i] = 1;
   end;
cumtaa=cumtaa*otaa;
cumss=cumss*oss;
cumint=cumint*oint;
cumtv=cumtv*otv;
run;

data ythresummary4;
set ythresummary3;
if year=&year and month=12;
keep windcode cumtaa cumss cumint cumtv;
run;

data navthre;
set brinson.mfnav1;
if TradingDate="30jun&year3"d or TradingDate="30jun&year1"d;*future 6 months;
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

data ythresummary4;
set ythresummary4;
marker=substr(windcode,1,length(windcode)-3);
run;

proc sql;
create table ythresummary5 as
select a.*, b.*
from ythresummary4 as a left join navthre as b 
on a.marker=b.Symbol;
run;quit;

data ythresummary6;
set ythresummary5;
keep Symbol cumtv aret;
run;

data ythresummary6;
set ythresummary6;
diff=cumtv-aret;
run;

proc univariate data=ythresummary6 noprint;
var diff;
output out=ythresummary7 NOBS=num MEAN=mean 
             STD=sd pctlpts=50
                       pctlpre = diff
                       pctlname = pct50;
run;

data ythresummary7;
set ythresummary7; 
if _n_=1 then do; 
  call symput('Nobs',num); 
  call symput('sd',sd);
  call symput('mean',mean);
  call symput('median',diffpct50);
  end;
run;

proc sql;
insert into summary&windowlength (year,mean,sd,median,nobs)
values (&year, &mean, &sd, &median, &Nobs);
quit;

data aspcheck&year&windowlength;
set ythresummary6;
rename  cumtv=cumtv&year&windowlength
    Symbol=Symbol&year&windowlength
    aret=aret&year&windowlength
    diff=diff&year&windowlength;
run;

data cumtv&year&windowlength;
set aspcheck&year&windowlength;
keep cumtv&year&windowlength;
run;

data cumtv&windowlength;
merge cumtv&windowlength cumtv&year&windowlength;
run;

data aret&year&windowlength;
set aspcheck&year&windowlength;
keep aret&year&windowlength;
run;

data aret&windowlength;
merge aret&windowlength aret&year&windowlength;
run;

data diff&year&windowlength;
set aspcheck&year&windowlength;
keep diff&year&windowlength;
run;

data diff&windowlength;
merge diff&windowlength diff&year&windowlength;
run;

data symbol&year&windowlength;
set aspcheck&year&windowlength;
keep Symbol&year&windowlength;
run;

data symbol&windowlength;
merge symbol&windowlength Symbol&year&windowlength;
run;

data Tcumtv&year&windowlength;
set ythresummary6;
endyear=&year;
keep cumtv endyear;
run;

data Tcumtv&windowlength;
set Tcumtv&windowlength Tcumtv&year&windowlength;
run;

data Taret&year&windowlength;
set ythresummary6;
endyear=&year;
keep aret endyear;
run;

data Taret&windowlength;
set Taret&windowlength Taret&year&windowlength;
run;

data Tdiff&year&windowlength;
set ythresummary6;
endyear=&year;
keep diff endyear;
run;

data Tdiff&windowlength;
set Tdiff&windowlength Tdiff&year&windowlength;
run;

data Tsymbol&year&windowlength;
set ythresummary6;
endyear=&year;
keep Symbol endyear;
run;

data Tsymbol&windowlength;
set Tsymbol&windowlength Tsymbol&year&windowlength;
run;

%mend rollingcheck;

%macro looprollingcheck;
data _null_;
%do i=%eval(2005+&windowlength-1) %to 2016;
%rollingcheck(&i);
%end;
run;
%mend looprollingcheck;
  
%looprollingcheck;

/*

ods graphics on / reset=all width=7in height=6in 
imagename="&windowlength.年模型假设下和实际收益率的差";
proc sgplot data=Tdiff&windowlength;
vbox diff/ category=endyear;
xaxis discreteorder=data;
YAXIS LABEL = "假设下的收益率和实际收益率的差"
LABELATTRS=(Weight=Bold)
VALUES = (-4 TO 4 BY 1);
XAXIS LABEL = "&windowlength.年样本末年"
LABELATTRS=(Weight=Bold);
REFLINE 0 / LABEL= "零线"
LINEATTRS= (PATTERN=DASH COLOR=RED);
TITLE "主动型股票基金Brinson模型假设下的收益率和实际收益率的差" BOLD;
run;

*With the SGPLOT procedure (SAS 9.2), you can set DISCRETEORDER=data on the XAXIS statement to get data order;

*/

proc sort data=Tdiff&windowlength;
by endyear;
run;

proc univariate data=Tdiff&windowlength noprint;
   var diff;
   by endyear;
   output out=Tdiffsum&windowlength MEAN=diffX STD=diffS NOBS=diffN
 pctlpts=2.5 25 50 75 97.5 PCTLPRE=dif pctlname =fL f1 fM f3 fH;
run;

data Tdiffsum&windowlength;
set Tdiffsum&windowlength;
label diffX='假设下的收益率和实际收益率的差';
run;

ods graphics on / reset=all width=7in height=6in 
imagename="&windowlength.年模型假设下和实际收益率的差&endm&startm";
TITLE "主动型股票基金Brinson模型假设下的收益率和实际收益率的差" BOLD;
proc boxplot history=Tdiffsum&windowlength;
   plot diff*endyear /
      odstitle = title
    VREF=0 LVREF=3
    GRID LGRID=1;
   label endyear="&windowlength.年样本末年";
run;

*boxstyle = schematic VAXIS=(-10 TO 10 BY 1);

PROC EXPORT DATA=cumtv&windowlength
FILE="&address.aspcheck&windowlength&endm&startm"
DBMS=xlsx REPLACE;
SHEET="tv";
RUN;

PROC EXPORT DATA=aret&windowlength
FILE="&address.aspcheck&windowlength&endm&startm"
DBMS=xlsx REPLACE;
SHEET="aret";
RUN;

PROC EXPORT DATA=diff&windowlength
FILE="&address.aspcheck&windowlength&endm&startm"
DBMS=xlsx REPLACE;
SHEET="diff";
RUN;

PROC EXPORT DATA=symbol&windowlength
FILE="&address.aspcheck&windowlength&endm&startm"
DBMS=xlsx REPLACE;
SHEET="symbol";
RUN;

PROC EXPORT DATA=summary&windowlength
FILE="&address.aspcheck&windowlength&endm&startm"
DBMS=xlsx REPLACE;
SHEET="table";
RUN;


