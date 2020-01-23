*under brinson model assumption, fund holding changes every semiannually;
*we should fill semiannual fund holding to be monthly;
*we merge index prices monthly data and stock prices monthly data;
*we compute monthly fund brinson model results;
*we analyze the effect of ff3 factors upon brinson model components;

%let address = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';
libname ddaa 'F:\dataset_download_and_analysis\';

%let m=20180716;*fill in export date;

data temp1;
set brinson.ptgp10;
run;

data temp2;
set brinson.ptgp10;
if month=6 then do; month1=7; year1=year; end;
if month=12 then do; month1=1; year1=year+1; end;
run;

data temp2;
set temp2;
drop month year;
run;

data temp2;
set temp2;
rename month1=month year1=year;
run;

data temp3;
set brinson.ptgp10;
if month=6 then do; month1=8; year1=year; end;
if month=12 then do; month1=2; year1=year+1; end;
run;

data temp3;
set temp3;
drop month year;
run;

data temp3;
set temp3;
rename month1=month year1=year;
run;

data temp4;
set brinson.ptgp10;
if month=6 then do; month1=9; year1=year; end;
if month=12 then do; month1=3; year1=year+1; end;
run;

data temp4;
set temp4;
drop month year;
run;

data temp4;
set temp4;
rename month1=month year1=year;
run;

data temp5;
set brinson.ptgp10;
if month=6 then do; month1=10; year1=year; end;
if month=12 then do; month1=4; year1=year+1; end;
run;

data temp5;
set temp5;
drop month year;
run;

data temp5;
set temp5;
rename month1=month year1=year;
run;

data temp6;
set brinson.ptgp10;
if month=6 then do; month1=11; year1=year; end;
if month=12 then do; month1=5; year1=year+1; end;
run;

data temp6;
set temp6;
drop month year;
run;

data temp6;
set temp6;
rename month1=month year1=year;
run;

data temp;
set temp1 temp2 temp3 temp4 temp5 temp6;
run;

proc sort data=temp;
by windcode year month;
run;

*fund monthly holding;
data brinson.fundmonhold;
set temp;
run;

data brinson.fundmonhold;
set brinson.fundmonhold;
rename windcode=fundcode holdingp=stockszfrac;
run;

data brinson.fundmonhold;
set brinson.fundmonhold;
stockweight=prop_stock_inv/100;
run;

data stkmon;
set brinson.Stkpmonthly1;
run;

*calculate stock monthly return;
*use future monthly return for monthly brinson model computations;
proc sort data=stkmon;
by WINDCODE descending DATETIME;
run;

data stkmon;
set stkmon;
leadclose=lag(close);
run;

data stkmon;
set stkmon;
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

data stkmon;
set stkmon;
drop leadclose i;
run;

data brinson.stkmon;
set stkmon;
run;

*prepare monthly data for monthly brinson computation;
*standardize the i_weight in indexcomponents dataset;

proc means data=brinson.monthlyindexcomplete noprint;
  class indexcode DATETIME;
  var i_weight;
  output out=indcomp1 sum=sumweight;
run;

*most i_weight for index sums up to be 1;
*some i_weight for index sums up to be hundreds;
*we still need standardization for i_weight;

data indcomp2;
set indcomp1;
if _TYPE_=3;
keep indexcode datetime sumweight;
run;

proc sql;
create table indcompo1 as
select a.*, b.sumweight 
from brinson.monthlyindexcomplete as a left join indcomp2 as b 
on a.indexcode = b.indexcode and a.datetime=b.datetime;
run;quit;

data indcompo1;
set indcompo1;
ni_weight=i_weight/sumweight;
year=year(datetime);
month=month(datetime);
run;

proc sql;
create table brinson.fundholdmon as
select a.*, b.* 
from brinson.fundmonhold as a left join brinson.stkmon as b 
on a.stockcode = b.windcode and a.year=b.year and a.month=b.month;
run;quit;

proc sort data=brinson.fundholdmon;
by reportperiod fundcode;
run;

proc sql;
create table brinson.benchholdmon as
select a.*, b.* 
from indcompo1 as a left join brinson.stkmon as b 
on a.wind_code = b.windcode and a.year=b.year and a.month=b.month;
run;quit;

proc sort data=brinson.benchholdmon;
by datetime indexcode;
run;

data brinson.fundholdmon;
set brinson.fundholdmon;
wpret=stockweight*pret;
run;

data brinson.benchholdmon;
set brinson.benchholdmon;
wniret=ni_weight*pret;
run;

*run from here;

proc means data=brinson.fundholdmon noprint;
  class fundcode year month industry;
  var stockweight wpret;
  output out=fundholdi sum(stockweight)=sstkw sum(wpret)=swpret;
run;

data fundholdi1;
set fundholdi;
if _TYPE_=15;
run;

data fundholdi1;
set fundholdi1;
keep fundcode year month industry sstkw swpret;
run;

proc means data=brinson.benchholdmon noprint;
  class indexcode year month industry;
  var ni_weight wniret;
  output out=benchholdi sum(ni_weight)=bsstkw sum(wniret)=bswnret;
run;

data benchholdi1;
set benchholdi;
if _TYPE_=15;
run;

data benchholdi1;
set benchholdi1;
keep indexcode year month industry bsstkw bswnret;
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
create table brinson.fundptgpmon as
select a.*, b.index_code, b.nindexw
from fundholdi1 as a left join brinson.ptgpvo1 as b 
on a.marker=b.marker;
run;quit;

proc sort data=fundholdi1;
by fundcode year month industry;
run;

proc sort data=brinson.fundptgpmon;
by fundcode year month industry;
run;

data yui1;
set brinson.fundptgpmon;
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
from yui44 as a left join brinson.fundptgpmon as b 
on a.marker=b.marker and a.industry=b.industry and a.year=b.year and a.month=b.month;
run;quit;

proc sql;
create table yui5 as
select a.*, b.*
from yui4 as a left join benchholdi1 as b 
on a.index_code=b.indexcode and a.industry=b.industry and a.year=b.year and a.month=b.month;
run;quit;

data benchmon;
set yui5;
run;

proc sort data=benchmon;
by fundcode year month industry;
run;

*row sum by fundcode and reportdate for benchmark with multiple indices and weights;

data benchmon1;
set benchmon;
hbsstkw=nindexw*bsstkw;
hbswnret=nindexw*bswnret;
run;

proc sort data=benchmon1;
by fundcode year month;
run;

proc means data=benchmon1 noprint;
  class fundcode year month industry index_code;
  var hbsstkw hbswnret sstkw swpret;
  output out=benchmon2 sum(hbsstkw)=bwi sum(hbswnret)=bri mean(sstkw)=fwi mean(swpret)=fri;
run;

data benchmon2;
set benchmon2;
if _TYPE_=31;
run;

data benchmon2;
set benchmon2;
drop _TYPE_ _FREQ_;
run;

*fill in zero weights & zero returns;

data benchmon3;
set benchmon2;
if bwi=. then bwi=0;
if bri=. then bri=0;
if fwi=. then fwi=0;
if fri=. then fri=0;
run;

data benchmon4;
set benchmon3;
taa=(fwi-bwi)*bri;
stks=bwi*(fri-bri);
inte=(fwi-bwi)*(fri-bri);
tva=fwi*fri-bwi*bri;
tv=fwi*fri;
run;

proc means data=benchmon4 noprint;
  class fundcode year month;
  var taa stks inte tva tv;
  output out=benchmon5 sum(taa)=staa sum(stks)=sstks sum(inte)=sinte sum(tva)=stva sum(tv)=stv;
run;

data benchmon5;
set benchmon5;
if _TYPE_=7;
run;

data benchmon5;
set benchmon5;
drop _TYPE_ _FREQ_;
run;

data brinson.monthlybrinson;
set benchmon5;
run;

*three factor model;
*profitability (RMW) and investment (CMA);

/*

A five-factor model that adds profitability (RMW) and investment (CMA) factors 
to the three-factor model of Fama and French (1993) suggests a shared story for 
several average-return anomalies. Specifically, positive exposures to RMW and CMA 
(stock returns that behave like those of profitable firms that invest conservatively) 
capture the high average returns associated with low market beta, share repurchases, 
and low stock return volatility. Conversely, negative RMW and CMA slopes (like those 
of relatively unprofitable firms that invest aggressively) help explain the low average 
stock returns associated with high beta, large share issues, and highly volatile returns.

*/

data ddaa.tfacmonthly;
set ddaa.tfacmonthly;
rename RiskPremium1=RiskPremium
SMB1=SMB HML1=HML;
run;

*change date format;

data temp;
set ddaa.tfacmonthly;
format date date9.;
date=datepart(TradingMonth);
run;

data temp;
set temp;
year=year(date);
month=month(date);
run;

data temp;
set temp;
if month=1 then do; year1=year-1; month1=12; end;
else do; year1=year; month1=month-1; end;
run;

data temp;
set temp;
if MarkettypeID='P9710';
run;

data temp;
set temp;
keep year1 month1 date RiskPremium SMB HML;
run;

data temp;
set temp;
rename year1=year month1=month;
run;

proc sql;
create table tempr as
select a.*, b.*
from brinson.monthlybrinson as a left join temp as b 
on a.year=b.year and a.month=b.month;
run;quit;

data brinson.monthlybrinsonff3;
set tempr;
run;


***********************************************************;



*rolling 3-year or 5-year componentwise ff3;


************************************************************;


%let windowlength=5;

*fit model with rolling 3-year or 5-year sample;

%let year=2013;

%let year3=%eval(&year - &windowlength+1);
%let year1=%eval(&year+1);

data ythre;
set brinson.monthlybrinsonff3;
if year >= &year3 and year <= &year;
run;

proc sort data=ythre;
by fundcode;
run;

proc univariate data=ythre noprint;
var sstks;
by fundcode;
output out=ythresummary NOBS=numfunds;
run;

data ythresummary;
set ythresummary;
if numfunds=%eval(12* &windowlength);
run;

proc sql;
create table ythresummary1 as
select a.*, b.*
from ythresummary as a left join ythre as b 
on a.fundcode=b.fundcode;
run;quit;

data ythresummary1;
set ythresummary1;
if smb ne .;
if hml ne .;
run;

proc sort data=ythresummary1; 
by fundcode;
run;


***********************************************************;



*taa monthly ff3;


************************************************************;


proc reg data=ythresummary1 outest=ythresummary2 
edf  tableout  noprint;
model staa = RiskPremium SMB HML;
by fundcode;
quit;

data r1;
set ythresummary2;
if _TYPE_='PARMS';
run;

data r1;
set r1;
keep fundcode Intercept RiskPremium SMB HML;
run;

data r1;
set r1;
rename Intercept=Interceptparms
RiskPremium=RPparms SMB=smbparms HML=hmlparms;
run;

data r2;
set ythresummary2;
if _TYPE_='PVALUE';
run;

data r2;
set r2;
keep fundcode Intercept RiskPremium SMB HML;
run;

data r2;
set r2;
rename Intercept=Interceptpval
RiskPremium=RPpval SMB=smbpval HML=hmlpval;
run;

proc sql;
create table r3 as
select a.*, b.*
from r1 as a left join r2 as b 
on a.fundcode=b.fundcode;
run;quit;

data r4;
set r3;
if RPparms<0 and RPpval<0.05 then testrp='neg sig';
else if RPparms>0 and RPpval<0.05 then testrp='pos sig';
else testrp='non sig';
run;

data r4;
set r4;
if smbparms<0 and smbpval<0.05 then testsmb='neg sig';
else if smbparms>0 and smbpval<0.05 then testsmb='pos sig';
else testsmb='non sig';
run;

data r4;
set r4;
if hmlparms<0 and hmlpval<0.05 then testhml='neg sig';
else if hmlparms>0 and hmlpval<0.05 then testhml='pos sig';
else testhml='non sig';
run;

proc freq data=r4 noprint;
tables testrp / out=r5rp;
run;

data r5rp;
set r5rp;
PERCENT=PERCENT/100;
run;

proc transpose data=r5rp
out=r5rpt;
id testrp;
var COUNT PERCENT;
run;

data r5rpt;
set r5rpt;
type='risk premium';
run;

proc freq data=r4 noprint;
tables testsmb / out=r5smb;
run;

data r5smb;
set r5smb;
PERCENT=PERCENT/100;
run;

proc transpose data=r5smb
out=r5smbt;
id testsmb;
var COUNT PERCENT;
run;

data r5smbt;
set r5smbt;
type='smb';
run;

proc freq data=r4 noprint;
tables testhml / out=r5hml;
run;

data r5hml;
set r5hml;
PERCENT=PERCENT/100;
run;

proc transpose data=r5hml
out=r5hmlt;
id testhml;
var COUNT PERCENT;
run;

data r5hmlt;
set r5hmlt;
type='hml';
run;

/*
data r5rpt;
set r5rpt;
rename testrp=test;
run;

data r5smbt;
set r5smbt;
rename testsmb=test;
run;

data r5hmlt;
set r5hmlt;
rename testhml=test;
run;
*/

data r6;
set r5rpt r5smbt r5hmlt;
run;

data r6;
retain type pos_sig neg_sig non_sig;
set r6;
run;

data r6;
set r6;
drop _name_ _label_;
run;

data brinson.taa&year.y&windowlength;
set r6;
run;


***********************************************************;



*stks monthly ff3;


************************************************************;

proc reg data=ythresummary1 outest=ythresummary2 
edf  tableout  noprint;
model sstks = RiskPremium SMB HML;
by fundcode;
quit;

data r1;
set ythresummary2;
if _TYPE_='PARMS';
run;

data r1;
set r1;
keep fundcode Intercept RiskPremium SMB HML;
run;

data r1;
set r1;
rename Intercept=Interceptparms
RiskPremium=RPparms SMB=smbparms HML=hmlparms;
run;

data r2;
set ythresummary2;
if _TYPE_='PVALUE';
run;

data r2;
set r2;
keep fundcode Intercept RiskPremium SMB HML;
run;

data r2;
set r2;
rename Intercept=Interceptpval
RiskPremium=RPpval SMB=smbpval HML=hmlpval;
run;

proc sql;
create table r3 as
select a.*, b.*
from r1 as a left join r2 as b 
on a.fundcode=b.fundcode;
run;quit;

data r4;
set r3;
if RPparms<0 and RPpval<0.05 then testrp='neg sig';
else if RPparms>0 and RPpval<0.05 then testrp='pos sig';
else testrp='non sig';
run;

data r4;
set r4;
if smbparms<0 and smbpval<0.05 then testsmb='neg sig';
else if smbparms>0 and smbpval<0.05 then testsmb='pos sig';
else testsmb='non sig';
run;

data r4;
set r4;
if hmlparms<0 and hmlpval<0.05 then testhml='neg sig';
else if hmlparms>0 and hmlpval<0.05 then testhml='pos sig';
else testhml='non sig';
run;

proc freq data=r4 noprint;
tables testrp / out=r5rp;
run;

data r5rp;
set r5rp;
PERCENT=PERCENT/100;
run;

proc transpose data=r5rp
out=r5rpt;
id testrp;
var COUNT PERCENT;
run;

data r5rpt;
set r5rpt;
type='risk premium';
run;

proc freq data=r4 noprint;
tables testsmb / out=r5smb;
run;

data r5smb;
set r5smb;
PERCENT=PERCENT/100;
run;

proc transpose data=r5smb
out=r5smbt;
id testsmb;
var COUNT PERCENT;
run;

data r5smbt;
set r5smbt;
type='smb';
run;

proc freq data=r4 noprint;
tables testhml / out=r5hml;
run;

data r5hml;
set r5hml;
PERCENT=PERCENT/100;
run;

proc transpose data=r5hml
out=r5hmlt;
id testhml;
var COUNT PERCENT;
run;

data r5hmlt;
set r5hmlt;
type='hml';
run;

data r6;
set r5rpt r5smbt r5hmlt;
run;

data r6;
retain type pos_sig neg_sig non_sig;
set r6;
run;

data r6;
set r6;
drop _name_ _label_;
run;

data brinson.stks&year.y&windowlength;
set r6;
run;

***********************************************************;



*interaction monthly ff3;


************************************************************;

proc reg data=ythresummary1 outest=ythresummary2 
edf  tableout  noprint;
model sinte = RiskPremium SMB HML;
by fundcode;
quit;

data r1;
set ythresummary2;
if _TYPE_='PARMS';
run;

data r1;
set r1;
keep fundcode Intercept RiskPremium SMB HML;
run;

data r1;
set r1;
rename Intercept=Interceptparms
RiskPremium=RPparms SMB=smbparms HML=hmlparms;
run;

data r2;
set ythresummary2;
if _TYPE_='PVALUE';
run;

data r2;
set r2;
keep fundcode Intercept RiskPremium SMB HML;
run;

data r2;
set r2;
rename Intercept=Interceptpval
RiskPremium=RPpval SMB=smbpval HML=hmlpval;
run;

proc sql;
create table r3 as
select a.*, b.*
from r1 as a left join r2 as b 
on a.fundcode=b.fundcode;
run;quit;

data r4;
set r3;
if RPparms<0 and RPpval<0.05 then testrp='neg sig';
else if RPparms>0 and RPpval<0.05 then testrp='pos sig';
else testrp='non sig';
run;

data r4;
set r4;
if smbparms<0 and smbpval<0.05 then testsmb='neg sig';
else if smbparms>0 and smbpval<0.05 then testsmb='pos sig';
else testsmb='non sig';
run;

data r4;
set r4;
if hmlparms<0 and hmlpval<0.05 then testhml='neg sig';
else if hmlparms>0 and hmlpval<0.05 then testhml='pos sig';
else testhml='non sig';
run;

proc freq data=r4 noprint;
tables testrp / out=r5rp;
run;

data r5rp;
set r5rp;
PERCENT=PERCENT/100;
run;

proc transpose data=r5rp
out=r5rpt;
id testrp;
var COUNT PERCENT;
run;

data r5rpt;
set r5rpt;
type='risk premium';
run;

proc freq data=r4 noprint;
tables testsmb / out=r5smb;
run;

data r5smb;
set r5smb;
PERCENT=PERCENT/100;
run;

proc transpose data=r5smb
out=r5smbt;
id testsmb;
var COUNT PERCENT;
run;

data r5smbt;
set r5smbt;
type='smb';
run;

proc freq data=r4 noprint;
tables testhml / out=r5hml;
run;

data r5hml;
set r5hml;
PERCENT=PERCENT/100;
run;

proc transpose data=r5hml
out=r5hmlt;
id testhml;
var COUNT PERCENT;
run;

data r5hmlt;
set r5hmlt;
type='hml';
run;

data r6;
set r5rpt r5smbt r5hmlt;
run;

data r6;
retain type pos_sig neg_sig non_sig;
set r6;
run;

data r6;
set r6;
drop _name_ _label_;
run;

data brinson.int&year.y&windowlength;
set r6;
run;


***********************************************************;



*tva monthly ff3;


************************************************************;

proc reg data=ythresummary1 outest=ythresummary2 
edf  tableout  noprint;
model stva = RiskPremium SMB HML;
by fundcode;
quit;

data r1;
set ythresummary2;
if _TYPE_='PARMS';
run;

data r1;
set r1;
keep fundcode Intercept RiskPremium SMB HML;
run;

data r1;
set r1;
rename Intercept=Interceptparms
RiskPremium=RPparms SMB=smbparms HML=hmlparms;
run;

data r2;
set ythresummary2;
if _TYPE_='PVALUE';
run;

data r2;
set r2;
keep fundcode Intercept RiskPremium SMB HML;
run;

data r2;
set r2;
rename Intercept=Interceptpval
RiskPremium=RPpval SMB=smbpval HML=hmlpval;
run;

proc sql;
create table r3 as
select a.*, b.*
from r1 as a left join r2 as b 
on a.fundcode=b.fundcode;
run;quit;

data r4;
set r3;
if RPparms<0 and RPpval<0.05 then testrp='neg sig';
else if RPparms>0 and RPpval<0.05 then testrp='pos sig';
else testrp='non sig';
run;

data r4;
set r4;
if smbparms<0 and smbpval<0.05 then testsmb='neg sig';
else if smbparms>0 and smbpval<0.05 then testsmb='pos sig';
else testsmb='non sig';
run;

data r4;
set r4;
if hmlparms<0 and hmlpval<0.05 then testhml='neg sig';
else if hmlparms>0 and hmlpval<0.05 then testhml='pos sig';
else testhml='non sig';
run;

proc freq data=r4 noprint;
tables testrp / out=r5rp;
run;

data r5rp;
set r5rp;
PERCENT=PERCENT/100;
run;

proc transpose data=r5rp
out=r5rpt;
id testrp;
var COUNT PERCENT;
run;

data r5rpt;
set r5rpt;
type='risk premium';
run;

proc freq data=r4 noprint;
tables testsmb / out=r5smb;
run;

data r5smb;
set r5smb;
PERCENT=PERCENT/100;
run;

proc transpose data=r5smb
out=r5smbt;
id testsmb;
var COUNT PERCENT;
run;

data r5smbt;
set r5smbt;
type='smb';
run;

proc freq data=r4 noprint;
tables testhml / out=r5hml;
run;

data r5hml;
set r5hml;
PERCENT=PERCENT/100;
run;

proc transpose data=r5hml
out=r5hmlt;
id testhml;
var COUNT PERCENT;
run;

data r5hmlt;
set r5hmlt;
type='hml';
run;

data r6;
set r5rpt r5smbt r5hmlt;
run;

data r6;
retain type pos_sig neg_sig non_sig;
set r6;
run;

data r6;
set r6;
drop _name_ _label_;
run;

data brinson.tva&year.y&windowlength;
set r6;
run;



***********************************************************;



*tva monthly ff3;


************************************************************;

proc reg data=ythresummary1 outest=ythresummary2 
edf  tableout  noprint;
model stv = RiskPremium SMB HML;
by fundcode;
quit;

data r1;
set ythresummary2;
if _TYPE_='PARMS';
run;

data r1;
set r1;
keep fundcode Intercept RiskPremium SMB HML;
run;

data r1;
set r1;
rename Intercept=Interceptparms
RiskPremium=RPparms SMB=smbparms HML=hmlparms;
run;

data r2;
set ythresummary2;
if _TYPE_='PVALUE';
run;

data r2;
set r2;
keep fundcode Intercept RiskPremium SMB HML;
run;

data r2;
set r2;
rename Intercept=Interceptpval
RiskPremium=RPpval SMB=smbpval HML=hmlpval;
run;

proc sql;
create table r3 as
select a.*, b.*
from r1 as a left join r2 as b 
on a.fundcode=b.fundcode;
run;quit;

data r4;
set r3;
if RPparms<0 and RPpval<0.05 then testrp='neg sig';
else if RPparms>0 and RPpval<0.05 then testrp='pos sig';
else testrp='non sig';
run;

data r4;
set r4;
if smbparms<0 and smbpval<0.05 then testsmb='neg sig';
else if smbparms>0 and smbpval<0.05 then testsmb='pos sig';
else testsmb='non sig';
run;

data r4;
set r4;
if hmlparms<0 and hmlpval<0.05 then testhml='neg sig';
else if hmlparms>0 and hmlpval<0.05 then testhml='pos sig';
else testhml='non sig';
run;

proc freq data=r4 noprint;
tables testrp / out=r5rp;
run;

data r5rp;
set r5rp;
PERCENT=PERCENT/100;
run;

proc transpose data=r5rp
out=r5rpt;
id testrp;
var COUNT PERCENT;
run;

data r5rpt;
set r5rpt;
type='risk premium';
run;

proc freq data=r4 noprint;
tables testsmb / out=r5smb;
run;

data r5smb;
set r5smb;
PERCENT=PERCENT/100;
run;

proc transpose data=r5smb
out=r5smbt;
id testsmb;
var COUNT PERCENT;
run;

data r5smbt;
set r5smbt;
type='smb';
run;

proc freq data=r4 noprint;
tables testhml / out=r5hml;
run;

data r5hml;
set r5hml;
PERCENT=PERCENT/100;
run;

proc transpose data=r5hml
out=r5hmlt;
id testhml;
var COUNT PERCENT;
run;

data r5hmlt;
set r5hmlt;
type='hml';
run;

data r6;
set r5rpt r5smbt r5hmlt;
run;

data r6;
retain type pos_sig neg_sig non_sig;
set r6;
run;

data r6;
set r6;
drop _name_ _label_;
run;

data brinson.tv&year.y&windowlength;
set r6;
run;


