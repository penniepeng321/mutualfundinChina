/*check the alpha and gamma rank of mutual funds with rolling 3-year windows*/
%let address = E:\fund_index_weight\rolling_years_check_benchmark_adjusted_return\;
%LET OUT = E:\fund_index_weight\rolling_years_check_benchmark_adjusted_return\;
libname rolling 'E:\fund_index_weight\rolling_years_check_benchmark_adjusted_return\';
libname self_ben 'E:\fund_index_weight\';
libname five 'E:\fund_index_weight\Download_data_for_all_mutual_funds\';

%let m=20180110;*fill in export date;

%let windowlength=1;

data rolling.corr_year&windowlength;
set _null_;v1="000000000000000";v2="0.00000000000000";run;


%macro rollingcheck(year);

%let year3=%eval(&year - &windowlength);
%let year2=%eval(&year - &windowlength +1);

data rolling.fund_benchmark_weight4&windowlength;
set five.fund_benchmark_weight4;
if startdate<="31dec&year3"d;
if enddate>="31dec&year"d;
if date>="31dec&year3"d;
if date<="31dec&year"d;
run;

data rolling.fund_benchmark_weight4&windowlength;
set rolling.fund_benchmark_weight4&windowlength;
if smb ne .;
if hml ne .;
run;

proc sort data=rolling.fund_benchmark_weight4&windowlength; by windcode;run;
proc reg data=rolling.fund_benchmark_weight4&windowlength outest=rolling.reg_fbw4_rf&windowlength.rf edf  tableout  noprint;
model excess_return = sys_risk smb hml;
by windcode;
quit;
data rolling.a1 rolling.a2;
set rolling.reg_fbw4_rf&windowlength.rf;
if _TYPE_="PARMS" then output rolling.a1;
if _TYPE_="T" then output rolling.a2;
run;
proc sql;
create table rolling.reg_fbw4_rf1&windowlength as
select a.windcode,             c.fundname,
a.Intercept*12 as alpha_year , b.Intercept as t_alpha , 
a.sys_risk as beta ,       b.sys_risk as t_beta ,
a.smb ,                        b.smb as t_smb,
a.hml ,                        b.hml as t_hml,
a._RSQ_ as rsq
from rolling.a1 as a , rolling.a2 as b ,five.num_total as c
where a.windcode = b.windcode = c.windcode;
quit;
data rolling.reg_fbw4_rf2&windowlength.rf;
set rolling.reg_fbw4_rf1&windowlength; 

if t_alpha >= 1.64                    then   sig_alpha = "正显著";
else if t_alpha <= -1.64 and t_alpha ne . then   sig_alpha = "负显著";
else                                              sig_alpha = "不显著";

if t_beta >= 1.64                   then  sig_beta = "正显著";
else if t_beta <= -1.64 and t_beta ne .  then  sig_beta = "负显著";
else                                           sig_beta = "不显著";

format alpha_year percentn10.2  t_alpha 10.2 beta 10.2 t_beta 10.2 RSQ 10.2;
label alpha_year = alpha_year t_beta = t_beta t_alpha=t_alpha;
run;


proc sort data=rolling.fund_benchmark_weight4&windowlength; by windcode;run;
proc reg data=rolling.fund_benchmark_weight4&windowlength outest=rolling.reg_fbw4_rf&windowlength.bench edf  tableout  noprint;
model benchmark_adjusted_return = sys_risk smb hml;
by windcode;
quit;
data rolling.a1 rolling.a2;
set rolling.reg_fbw4_rf&windowlength.bench;
if _TYPE_="PARMS" then output rolling.a1;
if _TYPE_="T" then output rolling.a2;
run;
proc sql;
create table rolling.reg_fbw4_rf1&windowlength as
select a.windcode,             c.fundname,
a.Intercept*12 as alpha_year , b.Intercept as t_alpha , 
a.sys_risk as beta ,       b.sys_risk as t_beta ,
a.smb ,                        b.smb as t_smb,
a.hml ,                        b.hml as t_hml,
a._RSQ_ as rsq
from rolling.a1 as a , rolling.a2 as b ,five.num_total as c
where a.windcode = b.windcode = c.windcode;
quit;
data rolling.reg_fbw4_rf2&windowlength.bench;
set rolling.reg_fbw4_rf1&windowlength; 

if t_alpha >= 1.64                    then   sig_alpha = "正显著";
else if t_alpha <= -1.64 and t_alpha ne . then   sig_alpha = "负显著";
else                                              sig_alpha = "不显著";

if t_beta >= 1.64                   then  sig_beta = "正显著";
else if t_beta <= -1.64 and t_beta ne .  then  sig_beta = "负显著";
else                                           sig_beta = "不显著";

format alpha_year percentn10.2  t_alpha 10.2 beta 10.2 t_beta 10.2 RSQ 10.2;
label alpha_year = alpha_year t_beta = t_beta t_alpha=t_alpha;
run;

proc rank data=rolling.reg_fbw4_rf2&windowlength.rf out=rolling.T1 descending ties=low;   
var alpha_year;
ranks t_alphaRank1;
run;

proc rank data=rolling.reg_fbw4_rf2&windowlength.bench out=rolling.T2 descending ties=low;   
var alpha_year;
ranks t_alphaRank2;
run;

proc sort data=rolling.T1;by windcode;run;
proc sort data=rolling.T2;by windcode;run;
data rolling.TT;
merge rolling.T1(in=xxx) rolling.T2(in=yyy);
by windcode;
if xxx and yyy;
run;

proc corr data=rolling.TT noprint nomiss outp=rolling.T3;
var t_alphaRank1 t_alphaRank2;
run;

proc sort data=rolling.T3;by t_alphaRank1;run;
data rolling.T3; 
set rolling.T3; 
if _n_=1 then do; call symput('corr_rank',t_alphaRank1); end;
run;

proc sql;
insert into rolling.corr_year&windowlength (v1,v2)
values ("&year", "&corr_rank");
quit;


%mend rollingcheck;

/*

data h1;
set five.firststep;
if _type_='PARMS';
keep windcode Benchmark_ret;
run;

title "PROC SGPANEL";
proc sgplot data=h1;
histogram Benchmark_ret /binwidth=0.1;
run;

data h1;
set h1;
cou=0;
if 0.9<Benchmark_ret<1.1 then cou=1;
if 0.8<Benchmark_ret<1.2 then coue=1;
if 0.7<Benchmark_ret<1.3 then couf=1;
run;

proc sql;
select sum(couf)/354 format=comma12.3 into :bootp trimmed from h1;
quit; run;


*/

%macro looprollingcheck;
data _null_;
%do i=2010 %to 2017;
%rollingcheck(&i);
%end;
run;
%mend looprollingcheck;

%looprollingcheck;

data rolling.corr_year&windowlength;
set rolling.corr_year&windowlength;
label v1='年份' v2='相关性系数';
year=input(v1, best12.);
corrq=input(v2, best12.);
run;

filename graphout "&address.过去&windowlength.年的选股能力排序的相关性系数.png";     
goptions reset=all device=png gsfname=graphout;

proc gchart data=rolling.corr_year&windowlength;                                                                                                                 
vbar year / sumvar=corrq discrete width=10                                                             
maxis=axis1 raxis=axis2;                                                                                                  
axis1 label=('年份');                                                                                                                 
axis2 label=(angle=90 '相关性系数') order=(0 to 1 by 0.1);                                                                                                     
title1 "主动型公募基金中过去&windowlength.年的选股能力排序的相关性系数";                                                                                           
run;                                                                                                                                    
quit;      

PROC EXPORT DATA=rolling.corr_year&windowlength
FILE="&address.选股能力&m"
DBMS=xlsx REPLACE;
SHEET="过去&windowlength.年";
RUN;







data rolling.corr_yeark&windowlength;
set _null_;v1="000000000000000";v2="0.00000000000000";run;

%macro rollingcheckk(year);

%let year3=%eval(&year - &windowlength);
%let year2=%eval(&year - &windowlength +1);

data rolling.fund_benchmark_weight4&windowlength;
set five.fund_benchmark_weight4;
if startdate<="31dec&year3"d;
if enddate>="31dec&year"d;
if date>="31dec&year3"d;
if date<="31dec&year"d;
run;
data rolling.fund_benchmark_weight4&windowlength;
set rolling.fund_benchmark_weight4&windowlength;
if smb ne .;
if hml ne .;
run;

proc sort data=rolling.fund_benchmark_weight4&windowlength; by windcode;run;
proc reg data=rolling.fund_benchmark_weight4&windowlength outest=rolling.reg_fbw4_rf&windowlength.rf edf  tableout  noprint;
model excess_return = sys_risk sys_square smb hml;
by windcode;
quit;
data rolling.a1 rolling.a2;
set rolling.reg_fbw4_rf&windowlength.rf;
if _TYPE_="PARMS" then output rolling.a1;
if _TYPE_="T" then output rolling.a2;
run;
proc sql;
create table rolling.reg_fbw4_rf1&windowlength as
select a.windcode,             c.fundname,
a.Intercept*12 as alpha_year , b.Intercept as t_alpha , 
a.sys_risk as beta ,       b.sys_risk as t_beta ,
a.sys_square as gamma ,     b.sys_square as t_gamma ,
a.smb ,                        b.smb as t_smb,
a.hml ,                        b.hml as t_hml,
a._RSQ_ as rsq
from rolling.a1 as a , rolling.a2 as b ,five.num_total as c
where a.windcode = b.windcode = c.windcode;
quit;
data rolling.reg_fbw4_rf2&windowlength.rf;
set rolling.reg_fbw4_rf1&windowlength; 

if t_alpha >= 1.64                    then   sig_alpha = "正显著";
else if t_alpha <= -1.64 and t_alpha ne . then   sig_alpha = "负显著";
else                                              sig_alpha = "不显著";

if t_beta >= 1.64                   then  sig_beta = "正显著";
else if t_beta <= -1.64 and t_beta ne .  then  sig_beta = "负显著";
else                                           sig_beta = "不显著";

if t_gamma >= 1.64                   then  sig_gamma = "正显著";
else if t_gamma <= -1.64 and t_gamma ne .  then  sig_gamma = "负显著";
else                                              sig_gamma = "不显著";

format alpha_year percentn10.2  t_alpha 10.2 beta 10.2 t_beta 10.2 RSQ 10.2;
label alpha_year = alpha_year t_beta = t_beta t_alpha=t_alpha;
run;


proc sort data=rolling.fund_benchmark_weight4&windowlength; by windcode;run;
proc reg data=rolling.fund_benchmark_weight4&windowlength outest=rolling.reg_fbw4_rf&windowlength.bench edf  tableout  noprint;
model benchmark_adjusted_return = sys_risk sys_square smb hml;
by windcode;
quit;
data rolling.a1 rolling.a2;
set rolling.reg_fbw4_rf&windowlength.bench;
if _TYPE_="PARMS" then output rolling.a1;
if _TYPE_="T" then output rolling.a2;
run;
proc sql;
create table rolling.reg_fbw4_rf1&windowlength as
select a.windcode,             c.fundname,
a.Intercept*12 as alpha_year , b.Intercept as t_alpha , 
a.sys_risk as beta ,       b.sys_risk as t_beta ,
a.sys_square as gamma ,     b.sys_square as t_gamma ,
a.smb ,                        b.smb as t_smb,
a.hml ,                        b.hml as t_hml,
a._RSQ_ as rsq
from rolling.a1 as a , rolling.a2 as b ,five.num_total as c
where a.windcode = b.windcode = c.windcode;
quit;
data rolling.reg_fbw4_rf2&windowlength.bench;
set rolling.reg_fbw4_rf1&windowlength; 

if t_alpha >= 1.64                    then   sig_alpha = "正显著";
else if t_alpha <= -1.64 and t_alpha ne . then   sig_alpha = "负显著";
else                                              sig_alpha = "不显著";

if t_beta >= 1.64                   then  sig_beta = "正显著";
else if t_beta <= -1.64 and t_beta ne .  then  sig_beta = "负显著";
else                                           sig_beta = "不显著";

if t_gamma >= 1.64                   then  sig_gamma = "正显著";
else if t_gamma <= -1.64 and t_gamma ne .  then  sig_gamma = "负显著";
else                                              sig_gamma = "不显著";

format alpha_year percentn10.2  t_alpha 10.2 beta 10.2 t_beta 10.2 RSQ 10.2;
label alpha_year = alpha_year t_beta = t_beta t_alpha=t_alpha;
run;

proc rank data=rolling.reg_fbw4_rf2&windowlength.rf out=rolling.T1 descending ties=low;   
var gamma;
ranks t_gammaRank1;
run;

proc rank data=rolling.reg_fbw4_rf2&windowlength.bench out=rolling.T2 descending ties=low;   
var gamma;
ranks t_gammaRank2;
run;

proc sort data=rolling.T1;by windcode;run;
proc sort data=rolling.T2;by windcode;run;
data rolling.TT;
merge rolling.T1(in=xxx) rolling.T2(in=yyy);
by windcode;
if xxx and yyy;
run;

proc corr data=rolling.TT noprint nomiss outp=rolling.T3;
var t_gammaRank1 t_gammaRank2;
run;

proc sort data=rolling.T3;by t_gammaRank1;run;
data rolling.T3; 
set rolling.T3; 
if _n_=1 then do; call symput('corr_rank',t_gammaRank1); end;
run;

proc sql;
insert into rolling.corr_yeark&windowlength (v1,v2)
values ("&year", "&corr_rank");
quit;


%mend rollingcheckk;


%macro looprollingcheckk;
data _null_;
%do i=2010 %to 2017;
%rollingcheckk(&i);
%end;
run;
%mend looprollingcheckk;

%looprollingcheckk;


data rolling.corr_yeark&windowlength;
set rolling.corr_yeark&windowlength;
label v1='年份' v2='相关性系数';
year=input(v1, best12.);
corrq=input(v2, best12.);
run;

filename graphout "&address.过去&windowlength.年的择时能力排序的相关性系数.png";     
goptions reset=all device=png gsfname=graphout;

proc gchart data=rolling.corr_yeark&windowlength;                                                                                                                 
vbar year / sumvar=corrq discrete width=10                                                             
maxis=axis1 raxis=axis2;                                                                                                  
axis1 label=('年份');                                                                                                                 
axis2 label=(angle=90 '相关性系数') order=(0 to 1 by 0.1);                                                                                                     
title1 "主动型公募基金中过去&windowlength.年的择时能力排序的相关性系数";                                                                                           
run;                                                                                                                                    
quit;      


PROC EXPORT DATA=rolling.corr_yeark&windowlength
FILE="&address.择时能力&m"
DBMS=xlsx REPLACE;
SHEET="过去&windowlength.年";
RUN;


proc delete data=rolling.a1 rolling.a2;run;
