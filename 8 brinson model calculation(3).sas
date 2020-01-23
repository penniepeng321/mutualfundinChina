
%let address = F:\fund_index_weight\brinson\;
%LET OUT = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';

%let m=20180621;*fill in export date;

%let endm=6;
%let startm=%eval(&endm+6);
*this is to apply month 6 and 12 previous semi-annual return;

*************************************************************;

*after updating semi-annual index components & ;
*semi-annual stock prices including HK and A share;
*we compute brinson model using new pool of funds;
*covering ptgp, pghh and lhpz;

**************************************************************;

*no data missing from semiindcomp and stkpsemi;
*no data missing from ptgpv either;
*however data missing from benchfunding;
*missing benchmark leads to missing calculation results;
*got to fix this;

*standardize the i_weight in indexcomponents dataset;
proc means data=brinson.semiindcomp noprint;
  class indexcode date;
  var i_weight;
  output out=indcomp1 sum=sumweight;
run;

data indcomp2;
set indcomp1;
if _TYPE_=3;
keep indexcode date sumweight;
run;

proc sql;
create table indcompo1 as
select a.*, b.sumweight 
from brinson.semiindcomp as a left join indcomp2 as b 
on a.indexcode = b.indexcode and a.date=b.date;
run;quit;

data indcompo1;
set indcompo1;
ni_weight=i_weight/sumweight;
run;


*deal with fund holding;
*ptgp9 is the most complete clean funds holding data including ptgp, lhpz and pghh;

*standardize weights in fund holding;

*we need to use jizhun1 indicators to remove ptgp9 funds with;
*complex, missing or fixed-rate benchmark;

data nptgp;
set brinson.ptgp9;
run;

data nptgp;
set nptgp;
marker=substr(windcode,1,length(windcode)-3);
run;

proc sql;
create table summary2 as
select a.*, b._COL2 as tzlxej, b._COL3 as yjbjjz, b.indicator
from nptgp as a left join brinson.jizhun1 as b 
on a.marker=b.marker;
run;quit;

*no data lost in the left join;

data summary2;
set summary2;
if indicator=0;
run;


*964983 to 882917 after removing complex, missing or fixed-rate benchmark;
*this is funds holding report data;

data summary2;
set summary2;
if stockcode ne '002257.SZ';
if stockcode ne '002525.SZ';
run;

*882917 to 882787 after removing IPO zhongzhi stocks;

data brinson.ptgp10;
set summary2;
run;

data ptgp;
set brinson.ptgp10;
rename windcode=fundcode holdingp=stockszfrac;
run;

*882917 rows read from brinson.ptgp10;
*all holding data downloaded from wind;

proc means data=ptgp noprint;
  class fundcode reportperiod;
  var stockszfrac;
  output out=ptgpsum1 sum=sumweight;
run;

data ptgpsum2;
set ptgpsum1;
if _TYPE_=3;
keep fundcode reportperiod sumweight;
run;

proc sql;
create table ptgpsumo1 as
select a.*, b.sumweight 
from ptgp as a left join ptgpsum2 as b 
on a.fundcode = b.fundcode and a.reportperiod=b.reportperiod;
run;quit;

*882917 rows in ptgpsumo1;

data ptgpsumo1;
set ptgpsumo1;
stockweight=stockszfrac/sumweight;
run;

*in the fund holding, it reports a column which is equal to the computed weights;

*now we compute the prior semi-annual return of these stocks;

*we convert year & report to be date so that we can merge it with stock monthly data;

data ptgpsumo1;
set ptgpsumo1;
if report='n' then month=12;
if report='z' then month=6;
run;



*964983 rows in ptgpsumo1;

*now we have cleaned semi-annual fund holding & benchmark holding;
*we merge stock semi-annual data with these two holding datasets;

data brinson.stkpsemi;
set brinson.stkpsemi;
year=year(datetime);
month=month(datetime);
run;

proc sql;
create table brinson.fundholding as
select a.*, b.* 
from ptgpsumo1 as a left join brinson.stkpsemi as b 
on a.stockcode = b.windcode and a.year=b.year and a.month=b.month;
run;quit;

proc sort data=brinson.fundholding;
by reportperiod fundcode;
run;

*#data entries in ptgpsumo1=#data entries in ptgp;
*#data entries in fundholding=#data entries in ptgp-30000+;

data indcompo1;
set indcompo1;
year=year(date);
run;

proc sql;
create table brinson.benchholding as
select a.*, b.* 
from indcompo1 as a left join brinson.stkpsemi as b 
on a.wind_code = b.windcode and a.year=b.year and a.month=b.month;
run;quit;

proc sort data=brinson.benchholding;
by date indexcode;
run;

*data entries # in indcompo1 is 495667;
*data entries # in brinson.benchholding is 495001;
*we left off some stocks semi-annual data in brinson.stkpsemi;

*then we collapse the benchmark holding data & fund holding data to be;
*their corresponding industry holding data;
*we need industry weight & industry return;

data brinson.fundholding;
set brinson.fundholding;
wpret=stockweight*pret;
run;

data brinson.benchholding;
set brinson.benchholding;
wniret=ni_weight*pret;
run;

proc means data=brinson.fundholding noprint;
  class fundcode reportperiod industry;
  var stockweight wpret;
  output out=fundholdi sum(stockweight)=sstkw sum(wpret)=swpret;
run;

data fundholdi1;
set fundholdi;
if _TYPE_=7;
run;

data fundholdi1;
set fundholdi1;
keep fundcode reportperiod industry sstkw swpret;
run;

*fundholdi1 is for stocks cross holding report dates;
*fundholdi1 has 137882 data entries;

proc means data=brinson.benchholding noprint;
  class indexcode date industry;
  var ni_weight wniret;
  output out=benchholdi sum(ni_weight)=bsstkw sum(wniret)=bswnret;
run;

data benchholdi1;
set benchholdi;
if _TYPE_=7;
run;

data benchholdi1;
set benchholdi1;
keep indexcode date industry bsstkw bswnret;
run;

*benchholdi1 has 16610 data entries;

*merge the benchmark holding & fund holding data;
*add year & month to benchmark holding & fund holding;
*use stockcode year month to merge the datasets;

data fundholdi1;
set fundholdi1;
year=substr(reportperiod,1,4);
mi=find(reportperiod,'年报');
run;

data fundholdi1;
set fundholdi1;
year1=input(strip(year),best12.);
run;

data fundholdi1;
set fundholdi1;
if mi ne 0 then month=12;
if mi=0 then month=6;
run;

data fundholdi1;
set fundholdi1;
drop mi year;
run;

data fundholdi1;
set fundholdi1;
rename year1=year;
run;

data benchholdi1;
set benchholdi1;
year=year(date);
month=month(date);
run;

*merge fundholdi with fund benchmark dataset ptgpvo1;

data fundholdi1;
set fundholdi1;
marker=substr(fundcode,1,length(fundcode)-3);
run;

data brinson.ptgpvo1;
set brinson.ptgpvo1;
marker=substr(windcode,1,length(windcode)-3);
run;

proc sql;
create table brinson.fundptgp as
select a.*, b.index_code, b.nindexw
from fundholdi1 as a left join brinson.ptgpvo1 as b 
on a.marker=b.marker;
run;quit;

*funds in fundholdi1 may end in .OF, .SH or .SZ;
*funds in brinson.ptgpvo1 only end in .OF;
*in the join, we should use marker not windcode;

*fundholdi1 has 137882 data entries;
*brinson.ptgpvo1 has 2912 data entries;
*brinson.fundptgp has 118098 data entries intersection;
*brinson.fundptgp has 141747 data entries on left join;
*brinson.fundptgp has 142046 data entries after using marker instead of windcode;



proc sort data=fundholdi1;
by fundcode year month industry;
run;

proc sort data=brinson.fundptgp;
by fundcode year month industry;
run;

/*
proc sql;
create table brinson.benchfundc as
select a.*, b.bsstkw, b.bswnret
from brinson.fundptgp as a full join benchholdi1 as b 
on a.industry=b.industry and a.year=b.year and a.month=b.month and 
a.index_code=b.indexcode;
run;quit;
*/

*left join 148495;
*full join 168380;

data yui1;
set brinson.fundptgp;
keep fundcode year month;
run;

proc sql;
 create table yui11 as
 select DISTINCT (fundcode),year,month
 from yui1 order by fundcode;
quit;

data yui2;
set benchholdi1;
keep industry;
run;

proc sql;
 create table yui22 as
 select DISTINCT (industry)
 from yui2 order by industry;
quit;

proc sql;
create table yui3 as
select *
from yui11 cross join yui22;
run;quit;

*447857 yui3 = 14447 yui11 * 31 yui22;
*right cross join;

data yui3;
set yui3;
marker=substr(fundcode,1,length(fundcode)-3);
run;

data yut;
set brinson.ptgpvo1;
keep marker index_code nindexw;
run;

proc sql;
create table yui44 as
select a.*, b.*
from yui3 as a left join yut as b 
on a.marker=b.marker;
run;quit;

proc sql;
create table yui4 as
select a.*, b.*
from yui44 as a left join brinson.fundptgp as b 
on a.marker=b.marker and a.industry=b.industry and a.year=b.year and a.month=b.month;
run;quit;

proc sql;
create table yui5 as
select a.*, b.*
from yui4 as a left join benchholdi1 as b 
on a.index_code=b.indexcode and a.industry=b.industry and a.year=b.year and a.month=b.month;
run;quit;

data brinson.benchfundc;
set yui5;
if sstkw=. then sstkw=0;
if swpret=. then swpret=0;
if bsstkw=. then bsstkw=0;
if bswnret=. then bswnret=0;
run;

proc sort data=brinson.benchfundc;
by fundcode year month industry;
run;

data brinson.benchholdi;
set benchholdi;
run;

data brinson.benchholdi1;
set benchholdi1;
run;

data brinson.fundholdi;
set fundholdi;
run;

data brinson.fundholdi1;
set fundholdi1;
run;

*row sum by fundcode and reportdate for benchmark with multiple indices and weights;

data brinson.benchfundc1;
set brinson.benchfundc;
hbsstkw=nindexw*bsstkw;
hbswnret=nindexw*bswnret;
run;

proc means data=brinson.benchfundc1 noprint;
  class fundcode reportperiod industry index_code;
  var hbsstkw hbswnret;
  output out=brinson.benchfundc2 sum(hbsstkw)=bwi sum(hbswnret)=bri;
run;

proc sort data=brinson.benchfundc1;
by reportperiod fundcode;
run;

data brinson.benchfundc2;
set brinson.benchfundc2;
if _TYPE_=15;
run;

data brinson.benchfundc2;
set brinson.benchfundc2;
drop _TYPE_ _FREQ_;
run;

proc sql;
create table brinson.benchfundc3 as
select a.*, b.sstkw as fwi, b.swpret as fri
from brinson.benchfundc2 as a left join brinson.benchfundc1 as b 
on a.fundcode=b.fundcode and a.reportperiod=b.reportperiod and 
a.industry=b.industry and a.index_code=b.index_code;
run;quit;

*compute brinson model sum of squares;

data brinson.benchfundc4;
set brinson.benchfundc3;
taa=(fwi-bwi)*bri;
stks=bwi*(fri-bri);
inte=(fwi-bwi)*(fri-bri);
tva=fwi*fri-bwi*bri;
run;

proc means data=brinson.benchfundc4 noprint;
  class fundcode reportperiod;
  var taa stks inte tva;
  output out=brinson.benchfundc5 sum(taa)=staa sum(stks)=sstks sum(inte)=sinte sum(tva)=stva;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
if _TYPE_=3;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
drop _TYPE_ _FREQ_;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
year=substr(reportperiod,1,4);
ni=find(reportperiod,'年报');
zi=find(reportperiod,'中报');
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
year1=input(strip(year),best12.);
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
drop year;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
rename year1=year;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
if ni ne 0 then month=12;
if zi ne 0 then month=6;
drop ni zi;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
rename fundcode=windcode;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
timemaker=mdy(month,25,year);
format timemaker date9.;
run;

proc sort data=brinson.benchfundc5;
by windcode timemaker;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
rename windcode=fundcode;
run;

proc sort data=brinson.benchfundc5;
by timemaker fundcode year month;
run;

data brinson.benchfundc5;
set brinson.benchfundc5;
if staa=. then staa=0;
if sstks=. then sstks=0;
if sinte=. then sinte=0;
if stva=. then stva=0;
run;



