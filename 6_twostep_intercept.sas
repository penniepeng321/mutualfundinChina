%let address = E:\fund_index_weight\Download_data_for_all_mutual_funds\;
%LET OUT = E:\fund_index_weight\Download_data_for_all_mutual_funds\;
libname five 'E:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'E:\fund_index_weight\';

%include "E:\fund_index_weight\jackboot.sas";
%macro quint4(dsn,var,quintvar);
proc univariate noprint data=&dsn;
var &var;
output out=quintile pctlpts=25 50 75 pctlpre=pct;
run;
data _null_;
set quintile;
call symput('q1',pct25) ;
call symput('q2',pct50) ;
call symput('q3',pct75) ;
run;
data &dsn;
set &dsn;
if &var =. then &quintvar = .;
else if &var le &q1 then &quintvar=1;
else if &var le &q2 then &quintvar=2;
else if &var le &q3 then &quintvar=3;
else &quintvar=4;
run;
%mend quint4;


%let year=2017;

proc reg data=five.fund_benchmark_weight4 outest=five.firststep edf  tableout  noprint;
model changeratefundnav_adj = Benchmark_ret;
by windcode;
quit;
data five.firststep_p;
set five.firststep;
if _TYPE_="PARMS";
keep windcode Intercept;
run;
proc sql;
create table temp as
select a.* , b.Intercept
from five.fund_benchmark_weight4 as a , five.firststep_p as b 
where a.windcode = b.windcode;
quit;
data five.fund_benchmark_weight4;
set temp;
rename Intercept=baralpha;
run;

data five.fund_benchmark_weight4_3y;
set five.fund_benchmark_weight4;
if startdate<='31oct2014'd;
if enddate>='01aug2017'd;
if (year=2014 and month>=10) or (2015<=year<=2016) or (year=2017 and month<=10);
run;

data five.fund_benchmark_weight4_3y;
set five.fund_benchmark_weight4_3y;
if smb ne .;
if hml ne .;
run;

proc reg data=five.fund_benchmark_weight4_3y outest=five.firststep edf  tableout  noprint;
model changeratefundnav_adj = Benchmark_ret;
by windcode;
quit;
data five.firststep_p;
set five.firststep;
if _TYPE_="PARMS";
keep windcode Intercept;
run;
proc sql;
create table temp as
select a.* , b.Intercept
from five.fund_benchmark_weight4_3y as a , five.firststep_p as b 
where a.windcode = b.windcode;
quit;
data five.fund_benchmark_weight4_3y;
set temp;
rename Intercept=baralpha;
run;


/*
proc corr data=five.fund_benchmark_weight4_3y  pearson spearman nosimple outp=five.erbarcorr;
var excess_return bar;
by windcode;
run;
*/

data five.fund_benchmark_weight4_5y;
set five.fund_benchmark_weight4;
if startdate<='31oct2012'd;
if enddate>='01aug2017'd;
if date>='31oct2012'd;
if date<='31oct2017'd;
run;
data five.fund_benchmark_weight4_5y;
set five.fund_benchmark_weight4_5y;
if smb ne .;
if hml ne .;
run;

proc reg data=five.fund_benchmark_weight4_5y outest=five.firststep edf  tableout  noprint;
model changeratefundnav_adj = Benchmark_ret;
by windcode;
quit;
data five.firststep_p;
set five.firststep;
if _TYPE_="PARMS";
keep windcode Intercept;
run;
proc sql;
create table temp as
select a.* , b.Intercept
from five.fund_benchmark_weight4_5y as a , five.firststep_p as b 
where a.windcode = b.windcode;
quit;
data five.fund_benchmark_weight4_5y;
set temp;
rename Intercept=baralpha;
run;

data five.fund_benchmark_weight4_7y;
set five.fund_benchmark_weight4;
if startdate<='31oct2010'd;
if enddate>='01aug2017'd;
if date>='31oct2010'd;
if date<='31oct2017'd;
run;
data five.fund_benchmark_weight4_7y;
set five.fund_benchmark_weight4_7y;
if smb ne .;
if hml ne .;
run;

proc reg data=five.fund_benchmark_weight4_7y outest=five.firststep edf  tableout  noprint;
model changeratefundnav_adj = Benchmark_ret;
by windcode;
quit;
data five.firststep_p;
set five.firststep;
if _TYPE_="PARMS";
keep windcode Intercept;
run;
proc sql;
create table temp as
select a.* , b.Intercept
from five.fund_benchmark_weight4_7y as a , five.firststep_p as b 
where a.windcode = b.windcode;
quit;
data five.fund_benchmark_weight4_7y;
set temp;
rename Intercept=baralpha;
run;

data five.num_total;
set five.Mutualbasic_adjustabc;
keep windcode _COL2;
run;
data five.num_total;
set five.num_total;
rename _COL2=fundname;
run;

/*
proc corr data=five.fund_benchmark_weight4  pearson spearman nosimple outp=five.erbrcorr;
var excess_return benchmark_adjusted_return;
by windcode;
run;
*/

/*total sample risk-free-rate*/
  proc reg data=five.fund_benchmark_weight4 outest=five.reg_fbw4_rf edf  tableout  noprint;
  model excess_return = sys_risk smb hml;
  by windcode;
  quit;
  data five.a1 five.a2;
  set five.reg_fbw4_rf;
  if _TYPE_="PARMS" then output five.a1;
  if _TYPE_="T" then output five.a2;
  run;
  proc sql;
  create table five.reg_fbw4_rf1 as
  select a.windcode,                       c.fundname,
  a.Intercept*12 as alpha_year , b.Intercept as t_alpha , 
  a.sys_risk as beta ,       b.sys_risk as t_beta ,
  a.smb ,                        b.smb as t_smb,
  a.hml ,                        b.hml as t_hml,
  a._RSQ_ as rsq
  from five.a1 as a , five.a2 as b ,five.num_total as c
  where a.windcode = b.windcode = c.windcode;
  quit;
  data five.reg_fbw4_rf2;
  set five.reg_fbw4_rf1; 
  
  if t_alpha >= 1.64                    then   sig_alpha = "正显著";
  else if t_alpha <= -1.64 and t_alpha ne . then   sig_alpha = "负显著";
  else                                              sig_alpha = "不显著";
  
  if t_beta >= 1.64                   then  sig_beta = "正显著";
  else if t_beta <= -1.64 and t_beta ne .  then  sig_beta = "负显著";
  else                                           sig_beta = "不显著";
  
  format alpha_year percentn10.2  t_alpha 10.2 beta 10.2 t_beta 10.2 RSQ 10.2;
  label alpha_year = alpha_year t_beta = t_beta t_alpha=t_alpha ;
  run;
  /*total sample benchmark return*/
    proc reg data=five.fund_benchmark_weight4 outest=five.reg_fbw4_bench edf  tableout  noprint;
  model baralpha = sys_risk smb hml;
  by windcode;
  quit;
  data five.a1 five.a2;
  set five.reg_fbw4_bench;
  if _TYPE_="PARMS" then output five.a1;
  if _TYPE_="T" then output five.a2;
  run;
  proc sql;
  create table five.reg_fbw4_bench1 as
  select a.windcode,             c.fundname,
  a.Intercept*12 as alpha_year , b.Intercept as t_alpha , 
  a.sys_risk as beta ,       b.sys_risk as t_beta ,
  a.smb ,                        b.smb as t_smb,
  a.hml ,                        b.hml as t_hml,
  a._RSQ_ as rsq
  from five.a1 as a , five.a2 as b ,five.num_total as c
  where a.windcode = b.windcode = c.windcode;
  quit;
  data five.reg_fbw4_bench2;
  set five.reg_fbw4_bench1; 
  
  if t_alpha >= 1.64                    then   sig_alpha = "正显著";
  else if t_alpha <= -1.64 and t_alpha ne . then   sig_alpha = "负显著";
  else                                              sig_alpha = "不显著";
  
  if t_beta >= 1.64                   then  sig_beta = "正显著";
  else if t_beta <= -1.64 and t_beta ne .  then  sig_beta = "负显著";
  else                                           sig_beta = "不显著";
  
  format alpha_year percentn10.2  t_alpha 10.2 beta 10.2 t_beta 10.2 RSQ 10.2;
  label alpha_year = alpha_year t_beta = t_beta t_alpha=t_alpha ;
  run;
  
  proc sql;
  create table five.rf_bench_compare1 as
  select a.windcode, a.fundname, a.alpha_year as alpha_bench, b.alpha_year as alpha_rf, a.t_alpha as t_alpha_bench, b.t_alpha as t_alpha_rf 
  from five.reg_fbw4_bench2 as a , five.reg_fbw4_rf2 as b 
  where a.windcode = b.windcode;
  run;quit;
  
  %quint4(five.rf_bench_compare1,alpha_bench,alpha_bench_group);
  %quint4(five.rf_bench_compare1,alpha_rf,alpha_rf_group);
  
  data five.rf_bench_compare1;
  set five.rf_bench_compare1;
  if alpha_bench ne .;
  if alpha_rf ne .;
  run;
  
  proc sort data=five.rf_bench_compare1;by alpha_rf_group alpha_bench_group;run;
  proc freq data=five.rf_bench_compare1 noprint;
  by alpha_rf_group;                    /* X categories on BY statement */
    tables alpha_bench_group / out=five.rf_bench_compare2;    /* Y (stacked groups) on TABLES statement */
    run;
  proc sort data=five.rf_bench_compare2; by alpha_rf_group;run;
  ods graphics / width=500px imagename="totalsample";
  title "";
  proc sgplot data=five.rf_bench_compare2;
  vbar alpha_bench_group / response=Percent group=alpha_rf_group groupdisplay=stack;
  *xaxis discreteorder=data;
  yaxis grid values=(0 to 100 by 10) label="Percentage of Total with Group";
  run;
  ods graphics / reset;
  
  
  /*3 year risk-free-rate*/
    proc sort data=five.fund_benchmark_weight4_3y; by windcode;run;
  proc reg data=five.fund_benchmark_weight4_3y outest=five.reg_fbw4_rf_3y edf  tableout  noprint;
  model excess_return = sys_risk smb hml;
  by windcode;
  quit;
  data five.a1 five.a2;
  set five.reg_fbw4_rf_3y;
  if _TYPE_="PARMS" then output five.a1;
  if _TYPE_="T" then output five.a2;
  run;
  proc sql;
  create table five.reg_fbw4_rf1_3y as
  select a.windcode,                       c.fundname,
  a.Intercept*12 as alpha_year , b.Intercept as t_alpha , 
  a.sys_risk as beta ,       b.sys_risk as t_beta ,
  a.smb ,                        b.smb as t_smb,
  a.hml ,                        b.hml as t_hml,
  a._RSQ_ as rsq
  from five.a1 as a , five.a2 as b ,five.num_total as c
  where a.windcode = b.windcode = c.windcode;
  quit;
  data five.reg_fbw4_rf2_3y;
  set five.reg_fbw4_rf1_3y; 
  
  if t_alpha >= 1.64                    then   sig_alpha = "正显著";
  else if t_alpha <= -1.64 and t_alpha ne . then   sig_alpha = "负显著";
  else                                              sig_alpha = "不显著";
  
  if t_beta >= 1.64                   then  sig_beta = "正显著";
  else if t_beta <= -1.64 and t_beta ne .  then  sig_beta = "负显著";
  else                                           sig_beta = "不显著";
  
  format alpha_year percentn10.2  t_alpha 10.2 beta 10.2 t_beta 10.2 RSQ 10.2;
  label alpha_year = alpha_year t_beta = t_beta t_alpha=t_alpha ;
  run;
  /*3 year benchmark return*/
    proc sort data=five.fund_benchmark_weight4_3y; by windcode;run;
  proc reg data=five.fund_benchmark_weight4_3y outest=five.reg_fbw4_bench_3y edf  tableout  noprint;
  model baralpha = sys_risk smb hml;
  by windcode;
  quit;
  data five.a1 five.a2;
  set five.reg_fbw4_bench_3y;
  if _TYPE_="PARMS" then output five.a1;
  if _TYPE_="T" then output five.a2;
  run;
  proc sql;
  create table five.reg_fbw4_bench1_3y as
  select a.windcode,                       c.fundname,
  a.Intercept*12 as alpha_year , b.Intercept as t_alpha , 
  a.sys_risk as beta ,       b.sys_risk as t_beta ,
  a.smb ,                        b.smb as t_smb,
  a.hml ,                        b.hml as t_hml,
  a._RSQ_ as rsq
  from five.a1 as a , five.a2 as b ,five.num_total as c
  where a.windcode = b.windcode = c.windcode;
  quit;
  data five.reg_fbw4_bench2_3y;
  set five.reg_fbw4_bench1_3y; 
  
  if t_alpha >= 1.64                    then   sig_alpha = "正显著";
  else if t_alpha <= -1.64 and t_alpha ne . then   sig_alpha = "负显著";
  else                                              sig_alpha = "不显著";
  
  if t_beta >= 1.64                   then  sig_beta = "正显著";
  else if t_beta <= -1.64 and t_beta ne .  then  sig_beta = "负显著";
  else                                           sig_beta = "不显著";
  
  format alpha_year percentn10.2  t_alpha 10.2 beta 10.2 t_beta 10.2 RSQ 10.2;
  label alpha_year = alpha_year t_beta = t_beta t_alpha=t_alpha ;
  run;
  
  proc sql;
  create table five.rf_bench_compare1_3y as
  select a.windcode, a.fundname, a.alpha_year as alpha_bench, b.alpha_year as alpha_rf, a.t_alpha as t_alpha_bench, b.t_alpha as t_alpha_rf
  from five.reg_fbw4_bench2_3y as a , five.reg_fbw4_rf2_3y as b 
  where a.windcode = b.windcode;
  run;quit;
  
  %quint4(five.rf_bench_compare1_3y,alpha_bench,alpha_bench_group);
  %quint4(five.rf_bench_compare1_3y,alpha_rf,alpha_rf_group);
  
  data five.rf_bench_compare1_3y;
  set five.rf_bench_compare1_3y;
  if alpha_bench ne .;
  if alpha_rf ne .;
  run;
  
  proc sort data=five.rf_bench_compare1_3y;by alpha_rf_group alpha_bench_group;run;
  proc freq data=five.rf_bench_compare1_3y noprint;
  by alpha_rf_group;                    /* X categories on BY statement */
    tables alpha_bench_group / out=five.rf_bench_compare2_3y;    /* Y (stacked groups) on TABLES statement */
    run;
  proc sort data=five.rf_bench_compare2_3y; by alpha_rf_group;run;
  ods graphics / width=500px imagename="totalsample";
  title "";
  proc sgplot data=five.rf_bench_compare2_3y;
  vbar alpha_bench_group / response=Percent group=alpha_rf_group groupdisplay=stack;
  *xaxis discreteorder=data;
  yaxis grid values=(0 to 100 by 10) label="Percentage of Total with Group";
  run;
  ods graphics / reset;
  
  
  
  
  /*5 year risk-free-rate*/
    proc sort data=five.fund_benchmark_weight4_5y; by windcode;run;
  proc reg data=five.fund_benchmark_weight4_5y outest=five.reg_fbw4_rf_5y edf  tableout  noprint;
  model excess_return = sys_risk smb hml;
  by windcode;
  quit;
  data five.a1 five.a2;
  set five.reg_fbw4_rf_5y;
  if _TYPE_="PARMS" then output five.a1;
  if _TYPE_="T" then output five.a2;
  run;
  proc sql;
  create table five.reg_fbw4_rf1_5y as
  select a.windcode,             c.fundname,
  a.Intercept*12 as alpha_year , b.Intercept as t_alpha , 
  a.sys_risk as beta ,       b.sys_risk as t_beta ,
  a.smb ,                        b.smb as t_smb,
  a.hml ,                        b.hml as t_hml,
  a._RSQ_ as rsq
  from five.a1 as a , five.a2 as b ,five.num_total as c
  where a.windcode = b.windcode = c.windcode;
  quit;
  data five.reg_fbw4_rf2_5y;
  set five.reg_fbw4_rf1_5y; 
  
  if t_alpha >= 1.64                    then   sig_alpha = "正显著";
  else if t_alpha <= -1.64 and t_alpha ne . then   sig_alpha = "负显著";
  else                                              sig_alpha = "不显著";
  
  if t_beta >= 1.64                   then  sig_beta = "正显著";
  else if t_beta <= -1.64 and t_beta ne .  then  sig_beta = "负显著";
  else                                           sig_beta = "不显著";
  
  format alpha_year percentn10.2  t_alpha 10.2 beta 10.2 t_beta 10.2 RSQ 10.2;
  label alpha_year = alpha_year t_beta = t_beta t_alpha=t_alpha ;
  run;
  /*5 year benchmark return*/
    proc sort data=five.fund_benchmark_weight4_5y; by windcode;run;
  proc reg data=five.fund_benchmark_weight4_5y outest=five.reg_fbw4_bench_5y edf  tableout  noprint;
  model baralpha = sys_risk smb hml;
  by windcode;
  quit;
  data five.a1 five.a2;
  set five.reg_fbw4_bench_5y;
  if _TYPE_="PARMS" then output five.a1;
  if _TYPE_="T" then output five.a2;
  run;
  proc sql;
  create table five.reg_fbw4_bench1_5y as
  select a.windcode,                       c.fundname,
  a.Intercept*12 as alpha_year , b.Intercept as t_alpha , 
  a.sys_risk as beta ,       b.sys_risk as t_beta ,
  a.smb ,                        b.smb as t_smb,
  a.hml ,                        b.hml as t_hml,
  a._RSQ_ as rsq
  from five.a1 as a , five.a2 as b ,five.num_total as c
  where a.windcode = b.windcode = c.windcode;
  quit;
  data five.reg_fbw4_bench2_5y;
  set five.reg_fbw4_bench1_5y; 
  
  if t_alpha >= 1.64                    then   sig_alpha = "正显著";
  else if t_alpha <= -1.64 and t_alpha ne . then   sig_alpha = "负显著";
  else                                              sig_alpha = "不显著";
  
  if t_beta >= 1.64                   then  sig_beta = "正显著";
  else if t_beta <= -1.64 and t_beta ne .  then  sig_beta = "负显著";
  else                                           sig_beta = "不显著";
  
  format alpha_year percentn10.2  t_alpha 10.2 beta 10.2 t_beta 10.2 RSQ 10.2;
  label alpha_year = alpha_year t_beta = t_beta t_alpha=t_alpha ;
  run;
  
  proc sql;
  create table five.rf_bench_compare1_5y as
  select a.windcode, a.fundname, a.alpha_year as alpha_bench, b.alpha_year as alpha_rf, a.t_alpha as t_alpha_bench, b.t_alpha as t_alpha_rf
  from five.reg_fbw4_bench2_5y as a , five.reg_fbw4_rf2_5y as b 
  where a.windcode = b.windcode;
  run;quit;
  
  %quint4(five.rf_bench_compare1_5y,alpha_bench,alpha_bench_group);
  %quint4(five.rf_bench_compare1_5y,alpha_rf,alpha_rf_group);
  
  data five.rf_bench_compare1_5y;
  set five.rf_bench_compare1_5y;
  if alpha_bench ne .;
  if alpha_rf ne .;
  run;
  
  proc sort data=five.rf_bench_compare1_5y;by alpha_rf_group alpha_bench_group;run;
  proc freq data=five.rf_bench_compare1_5y noprint;
  by alpha_rf_group;                    /* X categories on BY statement */
    tables alpha_bench_group / out=five.rf_bench_compare2_5y;    /* Y (stacked groups) on TABLES statement */
    run;
  proc sort data=five.rf_bench_compare2_5y; by alpha_rf_group;run;
  ods graphics / width=500px imagename="totalsample";
  title "";
  proc sgplot data=five.rf_bench_compare2_5y;
  vbar alpha_bench_group / response=Percent group=alpha_rf_group groupdisplay=stack;
  *xaxis discreteorder=data;
  yaxis grid values=(0 to 100 by 10) label="Percentage of Total with Group";
  run;
  ods graphics / reset;
  
  
  
  
  /*7 year risk-free-rate*/
    proc sort data=five.fund_benchmark_weight4_7y; by windcode;run;
  proc reg data=five.fund_benchmark_weight4_7y outest=five.reg_fbw4_rf_7y edf  tableout  noprint;
  model excess_return = sys_risk smb hml;
  by windcode;
  quit;
  data five.a1 five.a2;
  set five.reg_fbw4_rf_7y;
  if _TYPE_="PARMS" then output five.a1;
  if _TYPE_="T" then output five.a2;
  run;
  proc sql;
  create table five.reg_fbw4_rf1_7y as
  select a.windcode,                       c.fundname,
  a.Intercept*12 as alpha_year , b.Intercept as t_alpha , 
  a.sys_risk as beta ,       b.sys_risk as t_beta ,
  a.smb ,                        b.smb as t_smb,
  a.hml ,                        b.hml as t_hml,
  a._RSQ_ as rsq
  from five.a1 as a , five.a2 as b ,five.num_total as c
  where a.windcode = b.windcode = c.windcode;
  quit;
  data five.reg_fbw4_rf2_7y;
  set five.reg_fbw4_rf1_7y; 
  
  if t_alpha >= 1.64                    then   sig_alpha = "正显著";
  else if t_alpha <= -1.64 and t_alpha ne . then   sig_alpha = "负显著";
  else                                              sig_alpha = "不显著";
  
  if t_beta >= 1.64                   then  sig_beta = "正显著";
  else if t_beta <= -1.64 and t_beta ne .  then  sig_beta = "负显著";
  else                                           sig_beta = "不显著";
  
  format alpha_year percentn10.2  t_alpha 10.2 beta 10.2 t_beta 10.2 RSQ 10.2;
  label alpha_year = alpha_year t_beta = t_beta t_alpha=t_alpha ;
  run;
  /*7 year benchmark return*/
    proc sort data=five.fund_benchmark_weight4_7y; by windcode;run;
  proc reg data=five.fund_benchmark_weight4_7y outest=five.reg_fbw4_bench_7y edf  tableout  noprint;
  model baralpha = sys_risk smb hml;
  by windcode;
  quit;
  data five.a1 five.a2;
  set five.reg_fbw4_bench_7y;
  if _TYPE_="PARMS" then output five.a1;
  if _TYPE_="T" then output five.a2;
  run;
  proc sql;
  create table five.reg_fbw4_bench1_7y as
  select a.windcode,                       c.fundname,
  a.Intercept*12 as alpha_year , b.Intercept as t_alpha , 
  a.sys_risk as beta ,       b.sys_risk as t_beta ,
  a.smb ,                        b.smb as t_smb,
  a.hml ,                        b.hml as t_hml,
  a._RSQ_ as rsq
  from five.a1 as a , five.a2 as b ,five.num_total as c
  where a.windcode = b.windcode = c.windcode;
  quit;
  data five.reg_fbw4_bench2_7y;
  set five.reg_fbw4_bench1_7y; 
  
  if t_alpha >= 1.64                    then   sig_alpha = "正显著";
  else if t_alpha <= -1.64 and t_alpha ne . then   sig_alpha = "负显著";
  else                                              sig_alpha = "不显著";
  
  if t_beta >= 1.64                   then  sig_beta = "正显著";
  else if t_beta <= -1.64 and t_beta ne .  then  sig_beta = "负显著";
  else                                           sig_beta = "不显著";
  
  format alpha_year percentn10.2  t_alpha 10.2 beta 10.2 t_beta 10.2 RSQ 10.2;
  label alpha_year = alpha_year t_beta = t_beta t_alpha=t_alpha ;
  run;
  
  proc sql;
  create table five.rf_bench_compare1_7y as
  select a.windcode, a.fundname, a.alpha_year as alpha_bench, b.alpha_year as alpha_rf, a.t_alpha as t_alpha_bench, b.t_alpha as t_alpha_rf
  from five.reg_fbw4_bench2_7y as a , five.reg_fbw4_rf2_7y as b 
  where a.windcode = b.windcode;
  run;quit;
  
  %quint4(five.rf_bench_compare1_7y,alpha_bench,alpha_bench_group);
  %quint4(five.rf_bench_compare1_7y,alpha_rf,alpha_rf_group);
  
  data five.rf_bench_compare1_7y;
  set five.rf_bench_compare1_7y;
  if alpha_bench ne .;
  if alpha_rf ne .;
  run;
  
  proc sort data=five.rf_bench_compare1_7y;by alpha_rf_group alpha_bench_group;run;
  proc freq data=five.rf_bench_compare1_7y noprint;
  by alpha_rf_group;                    /* X categories on BY statement */
    tables alpha_bench_group / out=five.rf_bench_compare2_7y;    /* Y (stacked groups) on TABLES statement */
    run;
  proc sort data=five.rf_bench_compare2_7y; by alpha_rf_group;run;
  ods graphics / width=500px imagename="totalsample";
  title "";
  proc sgplot data=five.rf_bench_compare2_7y;
  vbar alpha_bench_group / response=Percent group=alpha_rf_group groupdisplay=stack;
  *xaxis discreteorder=data;
  yaxis grid values=(0 to 100 by 10) label="Percentage of Total with Group";
  run;
  ods graphics / reset;
  
  
  
  
  
  /*total sample TM risk-free-rate*/
    proc sort data=five.fund_benchmark_weight4; by windcode; run;
  proc reg data=five.fund_benchmark_weight4 outest=five.reg_fbw4_rf_TM edf  tableout  noprint;
  model excess_return = sys_risk sys_square smb hml;
  by windcode;
  quit;
  data five.a1 five.a2;
  set five.reg_fbw4_rf_TM;
  if _TYPE_="PARMS" then output five.a1;
  if _TYPE_="T" then output five.a2;
  run;
  proc sql;
  create table five.reg_fbw4_rf1_TM as
  select a.windcode,                       c.fundname,
  a.Intercept*12 as alpha_year , b.Intercept as t_alpha , 
  a.sys_risk as beta ,       b.sys_risk as t_beta ,
  a.sys_square as gamma ,     b.sys_square as t_gamma ,
  a.smb ,                        b.smb as t_smb,
  a.hml ,                        b.hml as t_hml,
  a._RSQ_ as rsq
  from five.a1 as a , five.a2 as b ,five.num_total as c
  where a.windcode = b.windcode = c.windcode;
  quit;
  data five.reg_fbw4_rf2_TM;
  set five.reg_fbw4_rf1_TM; 
  
  if t_alpha >= 1.64                    then   sig_alpha = "正显著";
  else if t_alpha <= -1.64 and t_alpha ne . then   sig_alpha = "负显著";
  else                                              sig_alpha = "不显著";
  
  if t_beta >= 1.64                   then  sig_beta = "正显著";
  else if t_beta <= -1.64 and t_beta ne .  then  sig_beta = "负显著";
  else                                           sig_beta = "不显著";
  
  if t_gamma >= 1.64                   then  sig_gamma = "正显著";
  else if t_gamma <= -1.64 and t_gamma ne .  then  sig_gamma = "负显著";
  else                                              sig_gamma = "不显著";
  
  format alpha_year percentn10.2  t_alpha 10.2 beta 10.2 t_beta 10.2 t_gamma 10.2 RSQ 10.2;
  label alpha_year = alpha_year t_beta = t_beta t_alpha=t_alpha t_gamma=t_gamma;
  run;
  /*total sample TM benchmark return*/
    proc reg data=five.fund_benchmark_weight4 outest=five.reg_fbw4_bench_TM edf  tableout  noprint;
  model baralpha = sys_risk sys_square smb hml;
  by windcode;
  quit;
  data five.a1 five.a2;
  set five.reg_fbw4_bench_TM;
  if _TYPE_="PARMS" then output five.a1;
  if _TYPE_="T" then output five.a2;
  run;
  proc sql;
  create table five.reg_fbw4_bench1_TM as
  select a.windcode,                       c.fundname,
  a.Intercept*12 as alpha_year , b.Intercept as t_alpha , 
  a.sys_risk as beta ,       b.sys_risk as t_beta ,
  a.sys_square as gamma ,     b.sys_square as t_gamma ,
  a.smb ,                        b.smb as t_smb,
  a.hml ,                        b.hml as t_hml,
  a._RSQ_ as rsq
  from five.a1 as a , five.a2 as b ,five.num_total as c
  where a.windcode = b.windcode = c.windcode;
  quit;
  data five.reg_fbw4_bench2_TM;
  set five.reg_fbw4_bench1_TM; 
  
  if t_alpha >= 1.64                    then   sig_alpha = "正显著";
  else if t_alpha <= -1.64 and t_alpha ne . then   sig_alpha = "负显著";
  else                                              sig_alpha = "不显著";
  
  if t_beta >= 1.64                   then  sig_beta = "正显著";
  else if t_beta <= -1.64 and t_beta ne .  then  sig_beta = "负显著";
  else                                           sig_beta = "不显著";
  
  if t_gamma >= 1.64                   then  sig_gamma = "正显著";
  else if t_gamma <= -1.64 and t_gamma ne .  then  sig_gamma = "负显著";
  else                                              sig_gamma = "不显著";
  
  format alpha_year percentn10.2  t_alpha 10.2 beta 10.2 t_beta 10.2 t_gamma 10.2 RSQ 10.2;
  label alpha_year = alpha_year t_beta = t_beta t_alpha=t_alpha t_gamma=t_gamma;
  run;
  
  proc sql;
  create table five.rf_bench_compare1_TM as
  select a.windcode, a.fundname, a.gamma as gamma_bench, b.gamma as gamma_rf, a.t_gamma as t_gamma_bench, b.t_gamma as t_gamma_rf 
  from five.reg_fbw4_bench2_TM as a , five.reg_fbw4_rf2_TM as b 
  where a.windcode = b.windcode;
  run;quit;
  
  %quint4(five.rf_bench_compare1_TM,gamma_bench,gamma_bench_group);
  %quint4(five.rf_bench_compare1_TM,gamma_rf,gamma_rf_group);
  
  data five.rf_bench_compare1_TM;
  set five.rf_bench_compare1_TM;
  if gamma_bench ne .;
  if gamma_rf ne .;
  run;
  
  proc sort data=five.rf_bench_compare1_TM;by gamma_rf_group gamma_bench_group;run;
  proc freq data=five.rf_bench_compare1_TM noprint;
  by gamma_rf_group;                    /* X categories on BY statement */
    tables gamma_bench_group / out=five.rf_bench_compare2_TM;    /* Y (stacked groups) on TABLES statement */
    run;
  proc sort data=five.rf_bench_compare2_TM; by gamma_rf_group;run;
  ods graphics / width=500px imagename="totalsample";
  title "";
  proc sgplot data=five.rf_bench_compare2_TM;
  vbar gamma_bench_group / response=Percent group=gamma_rf_group groupdisplay=stack;
  *xaxis discreteorder=data;
  yaxis grid values=(0 to 100 by 10) label="Percentage of Total with Group";
  run;
  ods graphics / reset;
  
  
  /*3 year TM risk-free-rate*/
    proc sort data=five.fund_benchmark_weight4_3y; by windcode;run;
  proc reg data=five.fund_benchmark_weight4_3y outest=five.reg_fbw4_rf_3y_TM edf  tableout  noprint;
  model excess_return = sys_risk sys_square smb hml;
  by windcode;
  quit;
  data five.a1 five.a2;
  set five.reg_fbw4_rf_3y_TM;
  if _TYPE_="PARMS" then output five.a1;
  if _TYPE_="T" then output five.a2;
  run;
  proc sql;
  create table five.reg_fbw4_rf1_3y_TM as
  select a.windcode,                       c.fundname,
  a.Intercept*12 as alpha_year , b.Intercept as t_alpha , 
  a.sys_risk as beta ,       b.sys_risk as t_beta ,
  a.sys_square as gamma ,     b.sys_square as t_gamma ,
  a.smb ,                        b.smb as t_smb,
  a.hml ,                        b.hml as t_hml,
  a._RSQ_ as rsq
  from five.a1 as a , five.a2 as b ,five.num_total as c
  where a.windcode = b.windcode = c.windcode;
  quit;
  data five.reg_fbw4_rf2_3y_TM;
  set five.reg_fbw4_rf1_3y_TM; 
  
  if t_alpha >= 1.64                    then   sig_alpha = "正显著";
  else if t_alpha <= -1.64 and t_alpha ne . then   sig_alpha = "负显著";
  else                                              sig_alpha = "不显著";
  
  if t_beta >= 1.64                   then  sig_beta = "正显著";
  else if t_beta <= -1.64 and t_beta ne .  then  sig_beta = "负显著";
  else                                           sig_beta = "不显著";
  
  if t_gamma >= 1.64                   then  sig_gamma = "正显著";
  else if t_gamma <= -1.64 and t_gamma ne .  then  sig_gamma = "负显著";
  else                                              sig_gamma = "不显著";
  
  format alpha_year percentn10.2  t_alpha 10.2 beta 10.2 t_beta 10.2 t_gamma 10.2 RSQ 10.2;
  label alpha_year = alpha_year t_beta = t_beta t_alpha=t_alpha t_gamma=t_gamma;
  run;
  /*3 year TM benchmark return*/
    proc sort data=five.fund_benchmark_weight4_3y; by windcode;run;
  proc reg data=five.fund_benchmark_weight4_3y outest=five.reg_fbw4_bench_3y_TM edf  tableout  noprint;
  model baralpha = sys_risk sys_square smb hml;
  by windcode;
  quit;
  data five.a1 five.a2;
  set five.reg_fbw4_bench_3y_TM;
  if _TYPE_="PARMS" then output five.a1;
  if _TYPE_="T" then output five.a2;
  run;
  proc sql;
  create table five.reg_fbw4_bench1_3y_TM as
  select a.windcode,                       c.fundname,
  a.Intercept*12 as alpha_year , b.Intercept as t_alpha , 
  a.sys_risk as beta ,       b.sys_risk as t_beta ,
  a.sys_square as gamma ,     b.sys_square as t_gamma ,
  a.smb ,                        b.smb as t_smb,
  a.hml ,                        b.hml as t_hml,
  a._RSQ_ as rsq
  from five.a1 as a , five.a2 as b ,five.num_total as c
  where a.windcode = b.windcode = c.windcode;
  quit;
  data five.reg_fbw4_bench2_3y_TM;
  set five.reg_fbw4_bench1_3y_TM; 
  
  if t_alpha >= 1.64                    then   sig_alpha = "正显著";
  else if t_alpha <= -1.64 and t_alpha ne . then   sig_alpha = "负显著";
  else                                              sig_alpha = "不显著";
  
  if t_beta >= 1.64                   then  sig_beta = "正显著";
  else if t_beta <= -1.64 and t_beta ne .  then  sig_beta = "负显著";
  else                                           sig_beta = "不显著";
  
  if t_gamma >= 1.64                   then  sig_gamma = "正显著";
  else if t_gamma <= -1.64 and t_gamma ne .  then  sig_gamma = "负显著";
  else                                              sig_gamma = "不显著";
  
  format alpha_year percentn10.2  t_alpha 10.2 beta 10.2 t_beta 10.2 t_gamma 10.2 RSQ 10.2;
  label alpha_year = alpha_year t_beta = t_beta t_alpha=t_alpha t_gamma=t_gamma;
  run;
  
  proc sql;
  create table five.rf_bench_compare1_3y_TM as
  select a.windcode, a.fundname, a.gamma as gamma_bench, b.gamma as gamma_rf, a.t_gamma as t_gamma_bench, b.t_gamma as t_gamma_rf
  from five.reg_fbw4_bench2_3y_TM as a , five.reg_fbw4_rf2_3y_TM as b 
  where a.windcode = b.windcode;
  run;quit;
  
  %quint4(five.rf_bench_compare1_3y_TM,gamma_bench,gamma_bench_group);
  %quint4(five.rf_bench_compare1_3y_TM,gamma_rf,gamma_rf_group);
  
  data five.rf_bench_compare1_3y_TM;
  set five.rf_bench_compare1_3y_TM;
  if gamma_bench ne .;
  if gamma_rf ne .;
  run;
  
  proc sort data=five.rf_bench_compare1_3y_TM;by gamma_rf_group gamma_bench_group;run;
  proc freq data=five.rf_bench_compare1_3y_TM noprint;
  by gamma_rf_group;                    /* X categories on BY statement */
    tables gamma_bench_group / out=five.rf_bench_compare2_3y_TM;    /* Y (stacked groups) on TABLES statement */
    run;
  proc sort data=five.rf_bench_compare2_3y_TM; by gamma_rf_group;run;
  ods graphics / width=500px imagename="totalsample";
  title "";
  proc sgplot data=five.rf_bench_compare2_3y_TM;
  vbar gamma_bench_group / response=Percent group=gamma_rf_group groupdisplay=stack;
  *xaxis discreteorder=data;
  yaxis grid values=(0 to 100 by 10) label="Percentage of Total with Group";
  run;
  ods graphics / reset;
  
  
  
  
  /*5 year TM risk-free-rate*/
    proc sort data=five.fund_benchmark_weight4_5y; by windcode;run;
  proc reg data=five.fund_benchmark_weight4_5y outest=five.reg_fbw4_rf_5y_TM edf  tableout  noprint;
  model excess_return = sys_risk sys_square smb hml;
  by windcode;
  quit;
  data five.a1 five.a2;
  set five.reg_fbw4_rf_5y_TM;
  if _TYPE_="PARMS" then output five.a1;
  if _TYPE_="T" then output five.a2;
  run;
  proc sql;
  create table five.reg_fbw4_rf1_5y_TM as
  select a.windcode,                       c.fundname,
  a.Intercept*12 as alpha_year , b.Intercept as t_alpha , 
  a.sys_risk as beta ,       b.sys_risk as t_beta ,
  a.sys_square as gamma ,     b.sys_square as t_gamma ,
  a.smb ,                        b.smb as t_smb,
  a.hml ,                        b.hml as t_hml,
  a._RSQ_ as rsq
  from five.a1 as a , five.a2 as b ,five.num_total as c
  where a.windcode = b.windcode = c.windcode;
  quit;
  data five.reg_fbw4_rf2_5y_TM;
  set five.reg_fbw4_rf1_5y_TM; 
  
  if t_alpha >= 1.64                    then   sig_alpha = "正显著";
  else if t_alpha <= -1.64 and t_alpha ne . then   sig_alpha = "负显著";
  else                                              sig_alpha = "不显著";
  
  if t_beta >= 1.64                   then  sig_beta = "正显著";
  else if t_beta <= -1.64 and t_beta ne .  then  sig_beta = "负显著";
  else                                           sig_beta = "不显著";
  
  if t_gamma >= 1.64                   then  sig_gamma = "正显著";
  else if t_gamma <= -1.64 and t_gamma ne .  then  sig_gamma = "负显著";
  else                                              sig_gamma = "不显著";
  
  format alpha_year percentn10.2  t_alpha 10.2 beta 10.2 t_beta 10.2 t_gamma 10.2 RSQ 10.2;
  label alpha_year = alpha_year t_beta = t_beta t_alpha=t_alpha t_gamma=t_gamma;
  run;
  /*5 year TM benchmark return*/
    proc sort data=five.fund_benchmark_weight4_5y; by windcode;run;
  proc reg data=five.fund_benchmark_weight4_5y outest=five.reg_fbw4_bench_5y_TM edf  tableout  noprint;
  model baralpha = sys_risk sys_square smb hml;
  by windcode;
  quit;
  data five.a1 five.a2;
  set five.reg_fbw4_bench_5y_TM;
  if _TYPE_="PARMS" then output five.a1;
  if _TYPE_="T" then output five.a2;
  run;
  proc sql;
  create table five.reg_fbw4_bench1_5y_TM as
  select a.windcode,                       c.fundname,
  a.Intercept*12 as alpha_year , b.Intercept as t_alpha , 
  a.sys_risk as beta ,       b.sys_risk as t_beta ,
  a.sys_square as gamma ,     b.sys_square as t_gamma ,
  a.smb ,                        b.smb as t_smb,
  a.hml ,                        b.hml as t_hml,
  a._RSQ_ as rsq
  from five.a1 as a , five.a2 as b ,five.num_total as c
  where a.windcode = b.windcode = c.windcode;
  quit;
  data five.reg_fbw4_bench2_5y_TM;
  set five.reg_fbw4_bench1_5y_TM; 
  
  if t_alpha >= 1.64                    then   sig_alpha = "正显著";
  else if t_alpha <= -1.64 and t_alpha ne . then   sig_alpha = "负显著";
  else                                              sig_alpha = "不显著";
  
  if t_beta >= 1.64                   then  sig_beta = "正显著";
  else if t_beta <= -1.64 and t_beta ne .  then  sig_beta = "负显著";
  else                                           sig_beta = "不显著";
  
  if t_gamma >= 1.64                   then  sig_gamma = "正显著";
  else if t_gamma <= -1.64 and t_gamma ne .  then  sig_gamma = "负显著";
  else                                              sig_gamma = "不显著";
  
  format alpha_year percentn10.2  t_alpha 10.2 beta 10.2 t_beta 10.2 t_gamma 10.2 RSQ 10.2;
  label alpha_year = alpha_year t_beta = t_beta t_alpha=t_alpha t_gamma=t_gamma;
  run;
  
  proc sql;
  create table five.rf_bench_compare1_5y_TM as
  select a.windcode, a.fundname, a.gamma as gamma_bench, b.gamma as gamma_rf, a.t_gamma as t_gamma_bench, b.t_gamma as t_gamma_rf
  from five.reg_fbw4_bench2_5y_TM as a , five.reg_fbw4_rf2_5y_TM as b 
  where a.windcode = b.windcode;
  run;quit;
  
  %quint4(five.rf_bench_compare1_5y_TM,gamma_bench,gamma_bench_group);
  %quint4(five.rf_bench_compare1_5y_TM,gamma_rf,gamma_rf_group);
  
  data five.rf_bench_compare1_5y_TM;
  set five.rf_bench_compare1_5y_TM;
  if gamma_bench ne .;
  if gamma_rf ne .;
  run;
  
  proc sort data=five.rf_bench_compare1_5y_TM;by gamma_rf_group gamma_bench_group;run;
  proc freq data=five.rf_bench_compare1_5y_TM noprint;
  by gamma_rf_group;                    /* X categories on BY statement */
    tables gamma_bench_group / out=five.rf_bench_compare2_5y_TM;    /* Y (stacked groups) on TABLES statement */
    run;
  proc sort data=five.rf_bench_compare2_5y_TM; by gamma_rf_group;run;
  ods graphics / width=500px imagename="totalsample";
  title "";
  proc sgplot data=five.rf_bench_compare2_5y_TM;
  vbar gamma_bench_group / response=Percent group=gamma_rf_group groupdisplay=stack;
  *xaxis discreteorder=data;
  yaxis grid values=(0 to 100 by 10) label="Percentage of Total with Group";
  run;
  ods graphics / reset;
  
  
  
  
  /*7 year TM risk-free-rate*/
    proc sort data=five.fund_benchmark_weight4_7y; by windcode;run;
  proc reg data=five.fund_benchmark_weight4_7y outest=five.reg_fbw4_rf_7y_TM edf  tableout  noprint;
  model excess_return = sys_risk sys_square smb hml;
  by windcode;
  quit;
  data five.a1 five.a2;
  set five.reg_fbw4_rf_7y_TM;
  if _TYPE_="PARMS" then output five.a1;
  if _TYPE_="T" then output five.a2;
  run;
  proc sql;
  create table five.reg_fbw4_rf1_7y_TM as
  select a.windcode,                       c.fundname,
  a.Intercept*12 as alpha_year , b.Intercept as t_alpha , 
  a.sys_risk as beta ,       b.sys_risk as t_beta ,
  a.sys_square as gamma ,     b.sys_square as t_gamma ,
  a.smb ,                        b.smb as t_smb,
  a.hml ,                        b.hml as t_hml,
  a._RSQ_ as rsq
  from five.a1 as a , five.a2 as b ,five.num_total as c
  where a.windcode = b.windcode = c.windcode;
  quit;
  data five.reg_fbw4_rf2_7y_TM;
  set five.reg_fbw4_rf1_7y_TM; 
  
  if t_alpha >= 1.64                    then   sig_alpha = "正显著";
  else if t_alpha <= -1.64 and t_alpha ne . then   sig_alpha = "负显著";
  else                                              sig_alpha = "不显著";
  
  if t_beta >= 1.64                   then  sig_beta = "正显著";
  else if t_beta <= -1.64 and t_beta ne .  then  sig_beta = "负显著";
  else                                           sig_beta = "不显著";
  
  if t_gamma >= 1.64                   then  sig_gamma = "正显著";
  else if t_gamma <= -1.64 and t_gamma ne .  then  sig_gamma = "负显著";
  else                                              sig_gamma = "不显著";
  
  format alpha_year percentn10.2  t_alpha 10.2 beta 10.2 t_beta 10.2 t_gamma 10.2 RSQ 10.2;
  label alpha_year = alpha_year t_beta = t_beta t_alpha=t_alpha t_gamma=t_gamma;
  run;
  /*7 year TM benchmark return*/
    proc sort data=five.fund_benchmark_weight4_7y; by windcode;run;
  proc reg data=five.fund_benchmark_weight4_7y outest=five.reg_fbw4_bench_7y_TM edf  tableout  noprint;
  model baralpha = sys_risk sys_square smb hml;
  by windcode;
  quit;
  data five.a1 five.a2;
  set five.reg_fbw4_bench_7y_TM;
  if _TYPE_="PARMS" then output five.a1;
  if _TYPE_="T" then output five.a2;
  run;
  proc sql;
  create table five.reg_fbw4_bench1_7y_TM as
  select a.windcode,                       c.fundname,
  a.Intercept*12 as alpha_year , b.Intercept as t_alpha , 
  a.sys_risk as beta ,       b.sys_risk as t_beta ,
  a.sys_square as gamma ,     b.sys_square as t_gamma ,
  a.smb ,                        b.smb as t_smb,
  a.hml ,                        b.hml as t_hml,
  a._RSQ_ as rsq
  from five.a1 as a , five.a2 as b ,five.num_total as c
  where a.windcode = b.windcode = c.windcode;
  quit;
  data five.reg_fbw4_bench2_7y_TM;
  set five.reg_fbw4_bench1_7y_TM; 
  
  if t_alpha >= 1.64                    then   sig_alpha = "正显著";
  else if t_alpha <= -1.64 and t_alpha ne . then   sig_alpha = "负显著";
  else                                              sig_alpha = "不显著";
  
  if t_beta >= 1.64                   then  sig_beta = "正显著";
  else if t_beta <= -1.64 and t_beta ne .  then  sig_beta = "负显著";
  else                                           sig_beta = "不显著";
  
  if t_gamma >= 1.64                   then  sig_gamma = "正显著";
  else if t_gamma <= -1.64 and t_gamma ne .  then  sig_gamma = "负显著";
  else                                              sig_gamma = "不显著";
  
  format alpha_year percentn10.2  t_alpha 10.2 beta 10.2 t_beta 10.2 t_gamma 10.2 RSQ 10.2;
  label alpha_year = alpha_year t_beta = t_beta t_alpha=t_alpha t_gamma=t_gamma;
  run;
  
  proc sql;
  create table five.rf_bench_compare1_7y_TM as
  select a.windcode, a.fundname, a.gamma as gamma_bench, b.gamma as gamma_rf, a.t_gamma as t_gamma_bench, b.t_gamma as t_gamma_rf
  from five.reg_fbw4_bench2_7y_TM as a , five.reg_fbw4_rf2_7y_TM as b 
  where a.windcode = b.windcode;
  run;quit;
  
  %quint4(five.rf_bench_compare1_7y_TM,gamma_bench,gamma_bench_group);
  %quint4(five.rf_bench_compare1_7y_TM,gamma_rf,gamma_rf_group);
  
  data five.rf_bench_compare1_7y_TM;
  set five.rf_bench_compare1_7y_TM;
  if gamma_bench ne .;
  if gamma_rf ne .;
  run;
  
  proc sort data=five.rf_bench_compare1_7y_TM;by gamma_rf_group gamma_bench_group;run;
  proc freq data=five.rf_bench_compare1_7y_TM noprint;
  by gamma_rf_group;                    /* X categories on BY statement */
    tables gamma_bench_group / out=five.rf_bench_compare2_7y_TM;    /* Y (stacked groups) on TABLES statement */
    run;
  proc sort data=five.rf_bench_compare2_7y_TM; by gamma_rf_group;run;
  ods graphics / width=500px imagename="totalsample";
  title "";
  proc sgplot data=five.rf_bench_compare2_7y_TM;
  vbar gamma_bench_group / response=Percent group=gamma_rf_group groupdisplay=stack;
  *xaxis discreteorder=data;
  yaxis grid values=(0 to 100 by 10) label="Percentage of Total with Group";
  run;
  ods graphics / reset;
  
  
  data five.Rf_bench_compare1;
  set five.Rf_bench_compare1;
  if t_alpha_bench>1.64 then sig_alpha_bench='正显著';
  else if t_alpha_bench<-1.64 then sig_alpha_bench='负显著';
  else sig_alpha_bench='不显著';
  
  if t_alpha_rf>1.64 then sig_alpha_rf='正显著';
  else if t_alpha_rf<-1.64 then sig_alpha_rf='负显著';
  else sig_alpha_rf='不显著';
  run;
  
  data five.Rf_bench_compare1_3y;
  set five.Rf_bench_compare1_3y;
  if t_alpha_bench>1.64 then sig_alpha_bench='P';
  else if t_alpha_bench<-1.64 then sig_alpha_bench='N';
  else sig_alpha_bench='O';
  
  if t_alpha_rf>1.64 then sig_alpha_rf='P';
  else if t_alpha_rf<-1.64 then sig_alpha_rf='N';
  else sig_alpha_rf='O';
  run;
  
  proc freq data=five.Rf_bench_compare1_3y noprint;
  tables sig_alpha_bench / out=five.Rf_bench_compare1_3y_alpha_bench;
  run;
  proc transpose data=five.Rf_bench_compare1_3y_alpha_bench
  out=Rf_bench_compare1_3y_alpha_bench;
  id sig_alpha_bench;
  var COUNT PERCENT;
  run;
  data Rf_bench_compare1_3y_alpha_bench;
  set Rf_bench_compare1_3y_alpha_bench;
  drop _NAME_ _label_;
  range='三年样本(BR)';
  run;
  proc freq data=five.Rf_bench_compare1_3y noprint;
  tables sig_alpha_rf / out=five.rf_bench_compare1_3y_alpha_rf;
  run;
  proc transpose data=five.rf_bench_compare1_3y_alpha_rf
  out=Rf_bench_compare1_3y_alpha_rf;
  id sig_alpha_rf;
  var COUNT PERCENT;
  run;
  data rf_bench_compare1_3y_alpha_rf;
  set rf_bench_compare1_3y_alpha_rf;
  drop _NAME_ _label_;
  range='三年样本(ER)';
  run;
  
  data five.Rf_bench_compare1_5y;
  set five.Rf_bench_compare1_5y;
  if t_alpha_bench>1.64 then sig_alpha_bench='P';
  else if t_alpha_bench<-1.64 then sig_alpha_bench='N';
  else sig_alpha_bench='O';
  
  if t_alpha_rf>1.64 then sig_alpha_rf='P';
  else if t_alpha_rf<-1.64 then sig_alpha_rf='N';
  else sig_alpha_rf='O';
  run;
  
  proc freq data=five.Rf_bench_compare1_5y noprint;
  tables sig_alpha_bench / out=five.Rf_bench_compare1_5y_alpha_bench;
  run;
  proc transpose data=five.Rf_bench_compare1_5y_alpha_bench
  out=Rf_bench_compare1_5y_alpha_bench;
  id sig_alpha_bench;
  var COUNT PERCENT;
  run;
  data Rf_bench_compare1_5y_alpha_bench;
  set Rf_bench_compare1_5y_alpha_bench;
  drop _NAME_ _label_;
  range='五年样本(BR)';
  run;
  proc freq data=five.Rf_bench_compare1_5y noprint;
  tables sig_alpha_rf / out=five.rf_bench_compare1_5y_alpha_rf;
  run;
  proc transpose data=five.rf_bench_compare1_5y_alpha_rf
  out=Rf_bench_compare1_5y_alpha_rf;
  id sig_alpha_rf;
  var COUNT PERCENT;
  run;
  data rf_bench_compare1_5y_alpha_rf;
  set rf_bench_compare1_5y_alpha_rf;
  drop _NAME_ _label_;
  range='五年样本(ER)';
  run;
  
  data five.Rf_bench_compare1_7y;
  set five.Rf_bench_compare1_7y;
  if t_alpha_bench>1.64 then sig_alpha_bench='P';
  else if t_alpha_bench<-1.64 then sig_alpha_bench='N';
  else sig_alpha_bench='O';
  
  if t_alpha_rf>1.64 then sig_alpha_rf='P';
  else if t_alpha_rf<-1.64 then sig_alpha_rf='N';
  else sig_alpha_rf='O';
  run;
  
  proc freq data=five.Rf_bench_compare1_7y noprint;
  tables sig_alpha_bench / out=five.Rf_bench_compare1_7y_alpha_bench;
  run;
  proc transpose data=five.Rf_bench_compare1_7y_alpha_bench
  out=Rf_bench_compare1_7y_alpha_bench;
  id sig_alpha_bench;
  var COUNT PERCENT;
  run;
  data Rf_bench_compare1_7y_alpha_bench;
  set Rf_bench_compare1_7y_alpha_bench;
  drop _NAME_ _label_;
  range='七年样本(BR)';
  run;
  proc freq data=five.Rf_bench_compare1_7y noprint;
  tables sig_alpha_rf / out=five.rf_bench_compare1_7y_alpha_rf;
  run;
  proc transpose data=five.rf_bench_compare1_7y_alpha_rf
  out=Rf_bench_compare1_7y_alpha_rf;
  id sig_alpha_rf;
  var COUNT PERCENT;
  run;
  data rf_bench_compare1_7y_alpha_rf;
  set rf_bench_compare1_7y_alpha_rf;
  drop _NAME_ _label_;
  range='七年样本(ER)';
  run;
  data five.rf_bench_compare1_alpha;
  set Rf_bench_compare1_7y_alpha_bench
  rf_bench_compare1_7y_alpha_rf
  Rf_bench_compare1_5y_alpha_bench
  rf_bench_compare1_5y_alpha_rf
  Rf_bench_compare1_3y_alpha_bench
  rf_bench_compare1_3y_alpha_rf;
  run;
  
  
  
  
  
  data five.Rf_bench_compare1_3y_TM;
  set five.Rf_bench_compare1_3y_TM;
  if t_gamma_bench>1.64 then sig_gamma_bench='P';
  else if t_gamma_bench<-1.64 then sig_gamma_bench='N';
  else sig_gamma_bench='O';
  
  if t_gamma_rf>1.64 then sig_gamma_rf='P';
  else if t_gamma_rf<-1.64 then sig_gamma_rf='N';
  else sig_gamma_rf='O';
  run;
  
  proc freq data=five.Rf_bench_compare1_3y_TM noprint;
  tables sig_gamma_bench / out=T1;
  run;
  proc transpose data=T1
  out=Rf_bench_compare1_3y_gamma_bench;
  id sig_gamma_bench;
  var COUNT PERCENT;
  run;
  data Rf_bench_compare1_3y_gamma_bench;
  set Rf_bench_compare1_3y_gamma_bench;
  drop _NAME_ _label_;
  range='三年样本(BR)';
  run;
  proc freq data=five.Rf_bench_compare1_3y_TM noprint;
  tables sig_gamma_rf / out=T2;
  run;
  proc transpose data=T2
  out=Rf_bench_compare1_3y_gamma_rf;
  id sig_gamma_rf;
  var COUNT PERCENT;
  run;
  data Rf_bench_compare1_3y_gamma_rf;
  set Rf_bench_compare1_3y_gamma_rf;
  drop _NAME_ _label_;
  range='三年样本(ER)';
  run;
  
  data five.Rf_bench_compare1_5y_TM;
  set five.Rf_bench_compare1_5y_TM;
  if t_gamma_bench>1.64 then sig_gamma_bench='P';
  else if t_gamma_bench<-1.64 then sig_gamma_bench='N';
  else sig_gamma_bench='O';
  
  if t_gamma_rf>1.64 then sig_gamma_rf='P';
  else if t_gamma_rf<-1.64 then sig_gamma_rf='N';
  else sig_gamma_rf='O';
  run;
  
  proc freq data=five.Rf_bench_compare1_5y_TM noprint;
  tables sig_gamma_bench / out=T1;
  run;
  proc transpose data=T1
  out=Rf_bench_compare1_5y_gamma_bench;
  id sig_gamma_bench;
  var COUNT PERCENT;
  run;
  data Rf_bench_compare1_5y_gamma_bench;
  set Rf_bench_compare1_5y_gamma_bench;
  drop _NAME_ _label_;
  range='五年样本(BR)';
  run;
  proc freq data=five.Rf_bench_compare1_5y_TM noprint;
  tables sig_gamma_rf / out=T2;
  run;
  proc transpose data=T2
  out=Rf_bench_compare1_5y_gamma_rf;
  id sig_gamma_rf;
  var COUNT PERCENT;
  run;
  data Rf_bench_compare1_5y_gamma_rf;
  set Rf_bench_compare1_5y_gamma_rf;
  drop _NAME_ _label_;
  range='五年样本(ER)';
  run;
  
  data five.Rf_bench_compare1_7y_TM;
  set five.Rf_bench_compare1_7y_TM;
  if t_gamma_bench>1.64 then sig_gamma_bench='P';
  else if t_gamma_bench<-1.64 then sig_gamma_bench='N';
  else sig_gamma_bench='O';
  
  if t_gamma_rf>1.64 then sig_gamma_rf='P';
  else if t_gamma_rf<-1.64 then sig_gamma_rf='N';
  else sig_gamma_rf='O';
  run;
  
  proc freq data=five.Rf_bench_compare1_7y_TM noprint;
  tables sig_gamma_bench / out=T1;
  run;
  proc transpose data=T1
  out=Rf_bench_compare1_7y_gamma_bench;
  id sig_gamma_bench;
  var COUNT PERCENT;
  run;
  data Rf_bench_compare1_7y_gamma_bench;
  set Rf_bench_compare1_7y_gamma_bench;
  drop _NAME_ _label_;
  range='七年样本(BR)';
  run;
  proc freq data=five.Rf_bench_compare1_7y_TM noprint;
  tables sig_gamma_rf / out=T2;
  run;
  proc transpose data=T2
  out=Rf_bench_compare1_7y_gamma_rf;
  id sig_gamma_rf;
  var COUNT PERCENT;
  run;
  data Rf_bench_compare1_7y_gamma_rf;
  set Rf_bench_compare1_7y_gamma_rf;
  drop _NAME_ _label_;
  range='七年样本(ER)';
  run;
  
  data five.rf_bench_compare1_gamma;
  set Rf_bench_compare1_7y_gamma_bench
  rf_bench_compare1_7y_gamma_rf
  Rf_bench_compare1_5y_gamma_bench
  rf_bench_compare1_5y_gamma_rf
  Rf_bench_compare1_3y_gamma_bench
  Rf_bench_compare1_3y_gamma_rf;
  run;
  
  data five.Reg_fbw4_bench2_3y;
  set five.Reg_fbw4_bench2_3y;
  if t_alpha ne .;
  run;
  proc rank data=five.Reg_fbw4_bench2_3y out=bench3y group=10;
  var alpha_year;
  ranks group;
  run;
  proc summary data=bench3y nway;
  var alpha_year beta smb hml rsq;
  class group;
  output out=five.bench3y mean=;
  run;
  data five.bench3y;
  set five.bench3y;
  format smb 10.2;
  format hml 10.2;
  run;
  proc sort data=five.bench3y;
  by descending alpha_year;
  run;
  
  
  data five.Reg_fbw4_bench2_5y;
  set five.Reg_fbw4_bench2_5y;
  if t_alpha ne .;
  run;
  proc rank data=five.Reg_fbw4_bench2_5y out=bench5y group=10;
  var alpha_year;
  ranks group;
  run;
  proc summary data=bench5y nway;
  var alpha_year beta smb hml rsq;
  class group;
  output out=five.bench5y mean=;
  run;
  data five.bench5y;
  set five.bench5y;
  format smb 10.2;
  format hml 10.2;
  run;
  proc sort data=five.bench5y;
  by descending alpha_year;
  run;
  
  
  data five.Reg_fbw4_bench2_7y;
  set five.Reg_fbw4_bench2_7y;
  if t_alpha ne .;
  run;
  proc rank data=five.Reg_fbw4_bench2_7y out=bench7y group=10;
  var alpha_year;
  ranks group;
  run;
  proc summary data=bench7y nway;
  var alpha_year beta smb hml rsq;
  class group;
  output out=five.bench7y mean=;
  run;
  data five.bench7y;
  set five.bench7y;
  format smb 10.2;
  format hml 10.2;
  run;
  proc sort data=five.bench7y;
  by descending alpha_year;
  run;
  
  
  data five.Reg_fbw4_rf2_3y;
  set five.Reg_fbw4_rf2_3y;
  if t_alpha ne .;
  run;
  proc rank data=five.Reg_fbw4_rf2_3y out=rf3y group=10;
  var alpha_year;
  ranks group;
  run;
  proc summary data=rf3y nway;
  var alpha_year beta smb hml rsq;
  class group;
  output out=five.rf3y mean=;
  run;
  data five.rf3y;
  set five.rf3y;
  format smb 10.2;
  format hml 10.2;
  run;
  proc sort data=five.rf3y;
  by descending alpha_year;
  run;
  
  
  data five.Reg_fbw4_rf2_5y;
  set five.Reg_fbw4_rf2_5y;
  if t_alpha ne .;
  run;
  proc rank data=five.Reg_fbw4_rf2_5y out=rf5y group=10;
  var alpha_year;
  ranks group;
  run;
  proc summary data=rf5y nway;
  var alpha_year beta smb hml rsq;
  class group;
  output out=five.rf5y mean=;
  run;
  data five.rf5y;
  set five.rf5y;
  format smb 10.2;
  format hml 10.2;
  run;
  proc sort data=five.rf5y;
  by descending alpha_year;
  run;
  
  
  data five.Reg_fbw4_rf2_7y;
  set five.Reg_fbw4_rf2_7y;
  if t_alpha ne .;
  run;
  proc rank data=five.Reg_fbw4_rf2_7y out=rf7y group=10;
  var alpha_year;
  ranks group;
  run;
  proc summary data=rf7y nway;
  var alpha_year beta smb hml rsq;
  class group;
  output out=five.rf7y mean=;
  run;
  data five.rf7y;
  set five.rf7y;
  format smb 10.2;
  format hml 10.2;
  run;
  proc sort data=five.rf7y;
  by descending alpha_year;
  run;
  
  
  data five.Reg_fbw4_bench2_3y_tm;
  set five.Reg_fbw4_bench2_3y_tm;
  if t_gamma ne .;
  run;
  proc rank data=five.Reg_fbw4_bench2_3y_tm out=bench3ytm group=10;
  var gamma;
  ranks group;
  run;
  proc summary data=bench3ytm nway;
  var gamma alpha_year beta smb hml rsq;
  class group;
  output out=five.bench3ytm mean=;
  run;
  data five.bench3ytm;
  set five.bench3ytm;
  format smb 10.2;
  format hml 10.2;
  run;
  proc sort data=five.bench3ytm;
  by descending gamma;
  run;
  
  
  data five.Reg_fbw4_bench2_5y_tm;
  set five.Reg_fbw4_bench2_5y_tm;
  if t_gamma ne .;
  run;
  proc rank data=five.Reg_fbw4_bench2_5y_tm out=bench5ytm group=10;
  var gamma;
  ranks group;
  run;
  proc summary data=bench5ytm nway;
  var gamma alpha_year beta smb hml rsq;
  class group;
  output out=five.bench5ytm mean=;
  run;
  data five.bench5ytm;
  set five.bench5ytm;
  format smb 10.2;
  format hml 10.2;
  run;
  proc sort data=five.bench5ytm;
  by descending gamma;
  run;
  
  
  data five.Reg_fbw4_bench2_7y_tm;
  set five.Reg_fbw4_bench2_7y_tm;
  if t_gamma ne .;
  run;
  proc rank data=five.Reg_fbw4_bench2_7y_tm out=bench7ytm group=10;
  var gamma;
  ranks group;
  run;
  proc summary data=bench7ytm nway;
  var gamma alpha_year beta smb hml rsq;
  class group;
  output out=five.bench7ytm mean=;
  run;
  data five.bench7ytm;
  set five.bench7ytm;
  format smb 10.2;
  format hml 10.2;
  run;
  proc sort data=five.bench7ytm;
  by descending gamma;
  run;
  
  
  data five.Reg_fbw4_rf2_3y_tm;
  set five.Reg_fbw4_rf2_3y_tm;
  if t_gamma ne .;
  run;
  proc rank data=five.Reg_fbw4_rf2_3y_tm out=rf3ytm group=10;
  var gamma;
  ranks group;
  run;
  proc summary data=rf3ytm nway;
  var gamma alpha_year beta smb hml rsq;
  class group;
  output out=five.rf3ytm mean=;
  run;
  data five.rf3ytm;
  set five.rf3ytm;
  format smb 10.2;
  format hml 10.2;
  run;
  proc sort data=five.rf3ytm;
  by descending gamma;
  run;
  
  
  data five.Reg_fbw4_rf2_5y_tm;
  set five.Reg_fbw4_rf2_5y_tm;
  if t_gamma ne .;
  run;
  proc rank data=five.Reg_fbw4_rf2_5y_tm out=rf5ytm group=10;
  var gamma;
  ranks group;
  run;
  proc summary data=rf5ytm nway;
  var gamma alpha_year beta smb hml rsq;
  class group;
  output out=five.rf5ytm mean=;
  run;
  data five.rf5ytm;
  set five.rf5ytm;
  format smb 10.2;
  format hml 10.2;
  run;
  proc sort data=five.rf5ytm;
  by descending gamma;
  run;
  
  
  data five.Reg_fbw4_rf2_7y_tm;
  set five.Reg_fbw4_rf2_7y_tm;
  if t_gamma ne .;
  run;
  proc rank data=five.Reg_fbw4_rf2_7y_tm out=rf7ytm group=10;
  var gamma;
  ranks group;
  run;
  proc summary data=rf7ytm nway;
  var gamma alpha_year beta smb hml rsq;
  class group;
  output out=five.rf7ytm mean=;
  run;
  data five.rf7ytm;
  set five.rf7ytm;
  format smb 10.2;
  format hml 10.2;
  run;
  proc sort data=five.rf7ytm;
  by descending gamma;
  run;
  
  
  data five.bpbench5yal;
  set _null_;v1="0000000000000000000000000";v2="0.0000";v3="0000000000000000000000000";run;
  data five.bpbench5yga;
  set _null_;v1="0000000000000000000000000";v2="0.0000";v3="0000000000000000000000000";run;
  data five.bprf5yal;
  set _null_;v1="0000000000000000000000000";v2="0.0000";v3="0000000000000000000000000";run;
  data five.bprf5yga;
  set _null_;v1="0000000000000000000000000";v2="0.0000";v3="0000000000000000000000000";run;
  
  data five.bpbench5yalsig;
  set five.Reg_fbw4_bench2_5y;
  if sig_alpha='正显著';
  keep windcode fundname;
  run;
  
  data five.bpbench5ygasig;
  set five.Reg_fbw4_bench2_5y_tm;
  if sig_gamma='正显著';
  keep windcode fundname;
  run;
  
  data five.bprf5yalsig;
  set five.Reg_fbw4_rf2_5y;
  if sig_alpha='正显著';
  keep windcode fundname;
  run;
  
  data five.bprf5ygasig;
  set five.Reg_fbw4_rf2_5y_tm;
  if sig_gamma='正显著';
  keep windcode fundname;
  run;
  
  %macro bootsssa(i);
  
  data five.bpbench5yalsig; set five.bpbench5yalsig; if _n_=&i then do;
  call symput('specode',windcode);
  call symput('specname',fundname);
  end;run;
  
  data interesting;
  set five.Fund_benchmark_weight4_5y;
  where windcode="&specode";
  run;
  
  proc reg data=interesting outest=interestingooo noprint;
  model baralpha = sys_risk smb hml;
  output out=interestingly r=resid p=pred;
  run;quit;
  
  data interestingly;
  retain sys_risk smb hml baralpha pred resid;
  set interestingly;
  keep sys_risk smb hml baralpha pred resid;
  run;quit;
  
  %macro analyze(data=,out=);
  options nonotes;
  proc reg data=&data noprint
  outest=&out;
  model baralpha = sys_risk smb hml;
  %bystmt;
  run;quit;
  options notes;
  %mend;
  
  proc sql;
  select 1200*Intercept format=comma12.2 into :hundIntercept trimmed from interestingooo;
  select Intercept format=comma12.9 into :Intercept_ trimmed from interestingooo;
  quit; run;
  
  data interestingly;
  set interestingly;
  pred_a=pred-&Intercept_;
  run;
  
  title2 'Resampling Residuals';
  %boot(data=interestingly,stat=Intercept,residual=resid,samples=1000,
        equation=baralpha=pred_a+resid,random=5673);
  
  data Bootdist;
  set Bootdist;
  hundinter=1200*Intercept;
  up=0;
  if Intercept>&Intercept_ then up=1;
  dow=0;
  if Intercept<&Intercept_ then dow=1;
  run;
  
  proc sql;
  select min(sum(up),sum(dow))/1000 format=comma12.3 into :bootp trimmed from Bootdist;
  quit; run;
  
  ods listing style=listing;
  ods graphics / width=800px imagename="bench5yalphaboot&specname";
  
  proc sgplot data=Bootdist;
  title1 %cmpres("&specname, " "真实ALPHA=" "&hundIntercept"'%, ' "BOOTSTRAP_P=&bootp");
  density hundinter / type=kernel name='one' legendlabel="Boostrap ALPHA 分布";
  refline &hundIntercept /axis=x label="&hundIntercept" LABELPOS= Max
  lineattrs=(color=green thickness=2 pattern=shortdash) 
  name='two' legendlabel="真实 ALPHA %" noclip;
  xaxis label='ALPHA %';
  yaxis label='核密度';
  keylegend 'two' 'one';
  run;
  
  ods graphics / reset;
  
  proc sql;
  insert into five.bpbench5yal (v1,v2,v3)
  values ("&specname", "&bootp","&specode");
  quit;
  
  %mend bootsssa;
  
  data _null_;
  set five.bpbench5yalsig nobs=nobs;
  call symput('nobs1',nobs);;
  stop;
  run;
  
  
  %macro loopsssa;
  data _null_;
  %do i=1 %to &nobs1;
  %bootsssa(&i);
  %end;
  run;
  %mend loopsssa;
  
  %loopsssa;
  
  
  
  
  
  
  
  %macro bootsssb(i);
  
  data five.bpbench5ygasig; set five.bpbench5ygasig; if _n_=&i then do;
  call symput('specode',windcode);
  call symput('specname',fundname);
  end;run;
  
  data interesting;
  set five.Fund_benchmark_weight4_5y;
  where windcode="&specode";
  run;
  
  proc reg data=interesting outest=interestingooo noprint;
  model baralpha = sys_risk sys_square smb hml;
  output out=interestingly r=resid p=pred;
  run;quit;
  
  data interestingly;
  retain sys_risk sys_square smb hml baralpha pred resid;
  set interestingly;
  keep sys_risk sys_square smb hml baralpha pred resid;
  run;quit;
  
  %macro analyze(data=,out=);
  options nonotes;
  proc reg data=&data noprint
  outest=&out;
  model baralpha = sys_risk sys_square smb hml;
  %bystmt;
  run;quit;
  options notes;
  %mend;
  
  proc sql;
  select 1200*Intercept format=comma12.2 into :hundIntercept trimmed from interestingooo;
  select Intercept format=comma12.9 into :Intercept_ trimmed from interestingooo;
  select sys_square format=comma12.2 into :sys_square_ trimmed from interestingooo;
  quit; run;
  
  data interestingly;
  set interestingly;
  pred_g=pred-sys_square*&sys_square_;
  run;
  
  title2 'Resampling Residuals';
  %boot(data=interestingly,stat=sys_square,residual=resid,samples=1000,
  equation=baralpha=pred_g+resid,random=5673);
  
  data Bootdist;
  set Bootdist;
  up=0;
  if sys_square>&sys_square_ then up=1;
  dow=0;
  if sys_square<&sys_square_ then dow=1;
  run;
  
  proc sql;
  select min(sum(up),sum(dow))/1000 format=comma12.3 into :bootp trimmed from Bootdist;
  quit; run;
  
  ods listing style=listing;
  ods graphics / width=800px imagename="bench5ygammaboot&specname";
  
  proc sgplot data=Bootdist;
  title1 %cmpres("&specname, " "真实GAMMA=" "&sys_square_ , BOOTSTRAP_P=&bootp");
  density sys_square / type=kernel name='one' legendlabel="Boostrap GAMMA 分布";
  refline &sys_square_ /axis=x label="&sys_square_" LABELPOS= Max
  lineattrs=(color=green thickness=2 pattern=shortdash) 
  name='two' legendlabel="真实 GAMMA" noclip;
  xaxis label='GAMMA';* min=&plotmin max=&plotmax; * values=(-3 to 3 by 1) VALUESHINT;
  yaxis label='核密度';
  keylegend 'two' 'one';
  run;
  
  ods graphics / reset;
  
  
  proc sql;
  insert into five.bpbench5yga (v1,v2,v3)
  values ("&specname", "&bootp","&specode");
  quit;
  
  %mend bootsssb;
  
  data _null_;
  set five.bpbench5ygasig nobs=nobs;
  call symput('nobs2',nobs);;
  stop;
  run;
  
  
  %macro loopsssb;
  data _null_;
  %do i=1 %to &nobs2;
  %bootsssb(&i);
  %end;
  run;
  %mend loopsssb;
  
  %loopsssb;
  
  
  
  
  
  %macro bootsssc(i);
  
  data five.bprf5yalsig; set five.bprf5yalsig; if _n_=&i then do;
  call symput('specode',windcode);
  call symput('specname',fundname);
  end;run;
  
  data interesting;
  set five.Fund_benchmark_weight4_5y;
  where windcode="&specode";
  run;
  
  proc reg data=interesting outest=interestingooo noprint;
  model excess_return = sys_risk smb hml;
  output out=interestingly r=resid p=pred;
  run;quit;
  
  data interestingly;
  retain sys_risk smb hml excess_return pred resid;
  set interestingly;
  keep sys_risk smb hml excess_return pred resid;
  run;quit;
  
  %macro analyze(data=,out=);
  options nonotes;
  proc reg data=&data noprint
  outest=&out;
  model excess_return = sys_risk smb hml;
  %bystmt;
  run;quit;
  options notes;
  %mend;
  
  proc sql;
  select 1200*Intercept format=comma12.2 into :hundIntercept trimmed from interestingooo;
  select Intercept format=comma12.9 into :Intercept_ trimmed from interestingooo;
  quit; run;
  
  data interestingly;
  set interestingly;
  pred_a=pred-&Intercept_;
  run;
  
  title2 'Resampling Residuals';
  %boot(data=interestingly,stat=Intercept,residual=resid,samples=1000,
  equation=excess_return=pred_a+resid,random=5673);
  
  data Bootdist;
  set Bootdist;
  hundinter=1200*Intercept;
  up=0;
  if Intercept>&Intercept_ then up=1;
  dow=0;
  if Intercept<&Intercept_ then dow=1;
  run;
  
  proc sql;
  select min(sum(up),sum(dow))/1000 format=comma12.3 into :bootp trimmed from Bootdist;
  quit; run;
  
  ods listing style=listing;
  ods graphics / width=800px imagename="rf5yalphaboot&specname";
  
  proc sgplot data=Bootdist;
  title1 %cmpres("&specname, " "真实ALPHA=" "&hundIntercept"'%, ' "BOOTSTRAP_P=&bootp");
  density hundinter / type=kernel name='one' legendlabel="Boostrap ALPHA 分布";
  refline &hundIntercept /axis=x label="&hundIntercept" LABELPOS= Max
  lineattrs=(color=green thickness=2 pattern=shortdash) 
  name='two' legendlabel="真实 ALPHA %" noclip;
  xaxis label='ALPHA %';
  yaxis label='核密度';
  keylegend 'two' 'one';
  run;
  
  ods graphics / reset;
  
  proc sql;
  insert into five.bprf5yal (v1,v2,v3)
  values ("&specname", "&bootp","&specode");
  quit;
  
  %mend bootsssc;
  
  data _null_;
  set five.bprf5yalsig nobs=nobs;
  call symput('nobs3',nobs);;
  stop;
  run;
  
  
  %macro loopsssc;
  data _null_;
  %do i=1 %to &nobs3;
  %bootsssc(&i);
  %end;
  run;
  %mend loopsssc;
  
  %loopsssc;
  
  
  
  
  
  
  %macro bootsssd(i);
  
  data five.bprf5ygasig; set five.bprf5ygasig; if _n_=&i then do;
  call symput('specode',windcode);
  call symput('specname',fundname);
  end;run;
  
  data interesting;
  set five.Fund_benchmark_weight4_5y;
  where windcode="&specode";
  run;
  
  proc reg data=interesting outest=interestingooo noprint;
  model excess_return = sys_risk sys_square smb hml;
  output out=interestingly r=resid p=pred;
  run;quit;
  
  data interestingly;
  retain sys_risk sys_square smb hml excess_return pred resid;
  set interestingly;
  keep sys_risk sys_square smb hml excess_return pred resid;
  run;quit;
  
  %macro analyze(data=,out=);
  options nonotes;
  proc reg data=&data noprint
  outest=&out;
  model excess_return = sys_risk sys_square smb hml;
  %bystmt;
  run;quit;
  options notes;
  %mend;
  
  proc sql;
  select 1200*Intercept format=comma12.2 into :hundIntercept trimmed from interestingooo;
  select Intercept format=comma12.9 into :Intercept_ trimmed from interestingooo;
  select sys_square format=comma12.2 into :sys_square_ trimmed from interestingooo;
  quit; run;
  
  data interestingly;
  set interestingly;
  pred_g=pred-sys_square*&sys_square_;
  run;
  
  title2 'Resampling Residuals';
  %boot(data=interestingly,stat=sys_square,residual=resid,samples=1000,
  equation=excess_return=pred_g+resid,random=5673);
  
  data Bootdist;
  set Bootdist;
  up=0;
  if sys_square>&sys_square_ then up=1;
  dow=0;
  if sys_square<&sys_square_ then dow=1;
  run;
  
  proc sql;
  select min(sum(up),sum(dow))/1000 format=comma12.3 into :bootp trimmed from Bootdist;
  quit; run;
  
  ods listing style=listing;
  ods graphics / width=800px imagename="rf5ygammaboot&specname";
  
  proc sgplot data=Bootdist;
  title1 %cmpres("&specname, " "真实GAMMA=" "&sys_square_ , BOOTSTRAP_P=&bootp");
  density sys_square / type=kernel name='one' legendlabel="Boostrap GAMMA 分布";
  refline &sys_square_ /axis=x label="&sys_square_" LABELPOS= Max
  lineattrs=(color=green thickness=2 pattern=shortdash) 
  name='two' legendlabel="真实 GAMMA" noclip;
  xaxis label='GAMMA';
  yaxis label='核密度';
  keylegend 'two' 'one';
  run;
  
  ods graphics / reset;
  
  proc sql;
  insert into five.bprf5yga (v1,v2,v3)
  values ("&specname", "&bootp","&specode");
  quit;
  
  %mend bootsssd;
  
  data _null_;
  set five.bprf5ygasig nobs=nobs;
  call symput('nobs4',nobs);;
  stop;
  run;
  
  
  %macro loopsssd;
  data _null_;
  %do i=1 %to &nobs4;
  %bootsssd(&i);
  %end;
  run;
  %mend loopsssd;
  
  %loopsssd;
  
  
  
  
  data sigalpha7y;
  set five.Reg_fbw4_bench2_7y;
  if sig_alpha='不显著' then sig_alpha7y='O';
  else if sig_alpha='正显著' then sig_alpha7y='P';
  else sig_alpha7y='N';
  keep windcode fundname sig_alpha7y;
  run;
  data sigalpha5y;
  set five.Reg_fbw4_bench2_5y;
  if sig_alpha='不显著' then sig_alpha5y='O';
  else if sig_alpha='正显著' then sig_alpha5y='P';
  else sig_alpha5y='N';
  keep windcode fundname sig_alpha5y;
  run;
  data sigalpha3y;
  set five.Reg_fbw4_bench2_3y;
  if sig_alpha='不显著' then sig_alpha3y='O';
  else if sig_alpha='正显著' then sig_alpha3y='P';
  else sig_alpha3y='N';
  keep windcode fundname sig_alpha3y;
  run;
  proc sql;  create table sigalpha7y5y3y as
  select     COALESCE(A.windcode,B.windcode,C.windcode) as windcode,
  COALESCE(A.fundname,B.fundname,C.fundname) as fundname,
  A.sig_alpha7y,
  B.sig_alpha5y,
  C.sig_alpha3y
  from       sigalpha7y as A
  inner join  sigalpha5y as B
  on         A.windcode=B.windcode
  inner join  sigalpha3y as C
  on         A.windcode=C.windcode;
  quit;
  
  proc freq data=sigalpha7y5y3y noprint;
  tables sig_alpha7y / out=sig_alpha7y_;
  run;
  proc transpose data=sig_alpha7y_
  out=sig_alpha7y_q;
  id sig_alpha7y;
  var COUNT PERCENT;
  run;
  data sig_alpha7y_q;
  set sig_alpha7y_q;
  drop _NAME_ _label_;
  range='七年样本(BR)';
  run;
  
  proc freq data=sigalpha7y5y3y noprint;
  tables sig_alpha5y / out=sig_alpha5y_;
  run;
  proc transpose data=sig_alpha5y_
  out=sig_alpha5y_q;
  id sig_alpha5y;
  var COUNT PERCENT;
  run;
  data sig_alpha5y_q;
  set sig_alpha5y_q;
  drop _NAME_ _label_;
  range='五年样本(BR)';
  run;
  
  proc freq data=sigalpha7y5y3y noprint;
  tables sig_alpha3y / out=sig_alpha3y_;
  run;
  proc transpose data=sig_alpha3y_
  out=sig_alpha3y_q;
  id sig_alpha3y;
  var COUNT PERCENT;
  run;
  data sig_alpha3y_q;
  set sig_alpha3y_q;
  drop _NAME_ _label_;
  range='三年样本(BR)';
  run;
  
  data five.sig_alpha_bench753;
  set sig_alpha3y_q sig_alpha5y_q sig_alpha7y_q;
  run;
  
  
  
  
  
  
  data sigalpha7y;
  set five.Reg_fbw4_rf2_7y;
  if sig_alpha='不显著' then sig_alpha7y='O';
  else if sig_alpha='正显著' then sig_alpha7y='P';
  else sig_alpha7y='N';
  keep windcode fundname sig_alpha7y;
  run;
  data sigalpha5y;
  set five.Reg_fbw4_rf2_5y;
  if sig_alpha='不显著' then sig_alpha5y='O';
  else if sig_alpha='正显著' then sig_alpha5y='P';
  else sig_alpha5y='N';
  keep windcode fundname sig_alpha5y;
  run;
  data sigalpha3y;
  set five.Reg_fbw4_rf2_3y;
  if sig_alpha='不显著' then sig_alpha3y='O';
  else if sig_alpha='正显著' then sig_alpha3y='P';
  else sig_alpha3y='N';
  keep windcode fundname sig_alpha3y;
  run;
  proc sql;  create table sigalpha7y5y3y as
  select     COALESCE(A.windcode,B.windcode,C.windcode) as windcode,
  COALESCE(A.fundname,B.fundname,C.fundname) as fundname,
  A.sig_alpha7y,
  B.sig_alpha5y,
  C.sig_alpha3y
  from       sigalpha7y as A
  inner join  sigalpha5y as B
  on         A.windcode=B.windcode
  inner join  sigalpha3y as C
  on         A.windcode=C.windcode;
  quit;
  
  proc freq data=sigalpha7y5y3y noprint;
  tables sig_alpha7y / out=sig_alpha7y_;
  run;
  proc transpose data=sig_alpha7y_
  out=sig_alpha7y_q;
  id sig_alpha7y;
  var COUNT PERCENT;
  run;
  data sig_alpha7y_q;
  set sig_alpha7y_q;
  drop _NAME_ _label_;
  range='七年样本(ER)';
  run;
  
  proc freq data=sigalpha7y5y3y noprint;
  tables sig_alpha5y / out=sig_alpha5y_;
  run;
  proc transpose data=sig_alpha5y_
  out=sig_alpha5y_q;
  id sig_alpha5y;
  var COUNT PERCENT;
  run;
  data sig_alpha5y_q;
  set sig_alpha5y_q;
  drop _NAME_ _label_;
  range='五年样本(ER)';
  run;
  
  proc freq data=sigalpha7y5y3y noprint;
  tables sig_alpha3y / out=sig_alpha3y_;
  run;
  proc transpose data=sig_alpha3y_
  out=sig_alpha3y_q;
  id sig_alpha3y;
  var COUNT PERCENT;
  run;
  data sig_alpha3y_q;
  set sig_alpha3y_q;
  drop _NAME_ _label_;
  range='三年样本(ER)';
  run;
  
  data five.sig_alpha_rf753;
  set sig_alpha3y_q sig_alpha5y_q sig_alpha7y_q;
  run;
  
  
  
  data sigalpha5y;
  set five.Reg_fbw4_bench2_5y;
  if sig_alpha='不显著' then sig_alpha5y='O';
  else if sig_alpha='正显著' then sig_alpha5y='P';
  else sig_alpha5y='N';
  keep windcode fundname sig_alpha5y;
  run;
  data sigalpha3y;
  set five.Reg_fbw4_bench2_3y;
  if sig_alpha='不显著' then sig_alpha3y='O';
  else if sig_alpha='正显著' then sig_alpha3y='P';
  else sig_alpha3y='N';
  keep windcode fundname sig_alpha3y;
  run;
  proc sql;  create table sigalpha5y3y as
  select     COALESCE(A.windcode,B.windcode) as windcode,
  COALESCE(A.fundname,B.fundname) as fundname,
  A.sig_alpha5y,
  B.sig_alpha3y
  from       sigalpha5y as A
  inner join  sigalpha3y as B
  on         A.windcode=B.windcode;
  quit;
  
  proc freq data=sigalpha5y3y noprint;
  tables sig_alpha5y / out=sig_alpha5y_;
  run;
  proc transpose data=sig_alpha5y_
  out=sig_alpha5y_q;
  id sig_alpha5y;
  var COUNT PERCENT;
  run;
  data sig_alpha5y_q;
  set sig_alpha5y_q;
  drop _NAME_ _label_;
  range='五年样本(BR)';
  run;
  
  proc freq data=sigalpha5y3y noprint;
  tables sig_alpha3y / out=sig_alpha3y_;
  run;
  proc transpose data=sig_alpha3y_
  out=sig_alpha3y_q;
  id sig_alpha3y;
  var COUNT PERCENT;
  run;
  data sig_alpha3y_q;
  set sig_alpha3y_q;
  drop _NAME_ _label_;
  range='三年样本(BR)';
  run;
  
  data five.sig_alpha_bench53;
  set sig_alpha3y_q sig_alpha5y_q;
  run;
  
  
  
  data sigalpha5y;
  set five.Reg_fbw4_rf2_5y;
  if sig_alpha='不显著' then sig_alpha5y='O';
  else if sig_alpha='正显著' then sig_alpha5y='P';
  else sig_alpha5y='N';
  keep windcode fundname sig_alpha5y;
  run;
  data sigalpha3y;
  set five.Reg_fbw4_rf2_3y;
  if sig_alpha='不显著' then sig_alpha3y='O';
  else if sig_alpha='正显著' then sig_alpha3y='P';
  else sig_alpha3y='N';
  keep windcode fundname sig_alpha3y;
  run;
  proc sql;  create table sigalpha5y3y as
  select     COALESCE(A.windcode,B.windcode) as windcode,
  COALESCE(A.fundname,B.fundname) as fundname,
  A.sig_alpha5y,
  B.sig_alpha3y
  from       sigalpha5y as A
  inner join  sigalpha3y as B
  on         A.windcode=B.windcode;
  quit;
  
  proc freq data=sigalpha5y3y noprint;
  tables sig_alpha5y / out=sig_alpha5y_;
  run;
  proc transpose data=sig_alpha5y_
  out=sig_alpha5y_q;
  id sig_alpha5y;
  var COUNT PERCENT;
  run;
  data sig_alpha5y_q;
  set sig_alpha5y_q;
  drop _NAME_ _label_;
  range='五年样本(ER)';
  run;
  
  proc freq data=sigalpha5y3y noprint;
  tables sig_alpha3y / out=sig_alpha3y_;
  run;
  proc transpose data=sig_alpha3y_
  out=sig_alpha3y_q;
  id sig_alpha3y;
  var COUNT PERCENT;
  run;
  data sig_alpha3y_q;
  set sig_alpha3y_q;
  drop _NAME_ _label_;
  range='三年样本(ER)';
  run;
  
  data five.sig_alpha_rf53;
  set sig_alpha3y_q sig_alpha5y_q;
  run;
  
  
  
  data siggamma7y;
  set five.Reg_fbw4_bench2_7y_tm;
  if sig_gamma='不显著' then sig_gamma7y='O';
  else if sig_gamma='正显著' then sig_gamma7y='P';
  else sig_gamma7y='N';
  keep windcode fundname sig_gamma7y;
  run;
  data siggamma5y;
  set five.Reg_fbw4_bench2_5y_tm;
  if sig_gamma='不显著' then sig_gamma5y='O';
  else if sig_gamma='正显著' then sig_gamma5y='P';
  else sig_gamma5y='N';
  keep windcode fundname sig_gamma5y;
  run;
  data siggamma3y;
  set five.Reg_fbw4_bench2_3y_tm;
  if sig_gamma='不显著' then sig_gamma3y='O';
  else if sig_gamma='正显著' then sig_gamma3y='P';
  else sig_gamma3y='N';
  keep windcode fundname sig_gamma3y;
  run;
  proc sql;  create table siggamma7y5y3y as
  select     COALESCE(A.windcode,B.windcode,C.windcode) as windcode,
  COALESCE(A.fundname,B.fundname,C.fundname) as fundname,
  A.sig_gamma7y,
  B.sig_gamma5y,
  C.sig_gamma3y
  from       siggamma7y as A
  inner join  siggamma5y as B
  on         A.windcode=B.windcode
  inner join  siggamma3y as C
  on         A.windcode=C.windcode;
  quit;
  
  proc freq data=siggamma7y5y3y noprint;
  tables sig_gamma7y / out=sig_gamma7y_;
  run;
  proc transpose data=sig_gamma7y_
  out=sig_gamma7y_q;
  id sig_gamma7y;
  var COUNT PERCENT;
  run;
  data sig_gamma7y_q;
  set sig_gamma7y_q;
  drop _NAME_ _label_;
  range='七年样本(BR)';
  run;
  
  proc freq data=siggamma7y5y3y noprint;
  tables sig_gamma5y / out=sig_gamma5y_;
  run;
  proc transpose data=sig_gamma5y_
  out=sig_gamma5y_q;
  id sig_gamma5y;
  var COUNT PERCENT;
  run;
  data sig_gamma5y_q;
  set sig_gamma5y_q;
  drop _NAME_ _label_;
  range='五年样本(BR)';
  run;
  
  proc freq data=siggamma7y5y3y noprint;
  tables sig_gamma3y / out=sig_gamma3y_;
  run;
  proc transpose data=sig_gamma3y_
  out=sig_gamma3y_q;
  id sig_gamma3y;
  var COUNT PERCENT;
  run;
  data sig_gamma3y_q;
  set sig_gamma3y_q;
  drop _NAME_ _label_;
  range='三年样本(BR)';
  run;
  
  data five.sig_gamma_bench753;
  set sig_gamma3y_q sig_gamma5y_q sig_gamma7y_q;
  run;
  
  
  
  
  
  
  data siggamma7y;
  set five.Reg_fbw4_rf2_7y_tm;
  if sig_gamma='不显著' then sig_gamma7y='O';
  else if sig_gamma='正显著' then sig_gamma7y='P';
  else sig_gamma7y='N';
  keep windcode fundname sig_gamma7y;
  run;
  data siggamma5y;
  set five.Reg_fbw4_rf2_5y_tm;
  if sig_gamma='不显著' then sig_gamma5y='O';
  else if sig_gamma='正显著' then sig_gamma5y='P';
  else sig_gamma5y='N';
  keep windcode fundname sig_gamma5y;
  run;
  data siggamma3y;
  set five.Reg_fbw4_rf2_3y_tm;
  if sig_gamma='不显著' then sig_gamma3y='O';
  else if sig_gamma='正显著' then sig_gamma3y='P';
  else sig_gamma3y='N';
  keep windcode fundname sig_gamma3y;
  run;
  proc sql;  create table siggamma7y5y3y as
  select     COALESCE(A.windcode,B.windcode,C.windcode) as windcode,
  COALESCE(A.fundname,B.fundname,C.fundname) as fundname,
  A.sig_gamma7y,
  B.sig_gamma5y,
  C.sig_gamma3y
  from       siggamma7y as A
  inner join  siggamma5y as B
  on         A.windcode=B.windcode
  inner join  siggamma3y as C
  on         A.windcode=C.windcode;
  quit;
  
  proc freq data=siggamma7y5y3y noprint;
  tables sig_gamma7y / out=sig_gamma7y_;
  run;
  proc transpose data=sig_gamma7y_
  out=sig_gamma7y_q;
  id sig_gamma7y;
  var COUNT PERCENT;
  run;
  data sig_gamma7y_q;
  set sig_gamma7y_q;
  drop _NAME_ _label_;
  range='七年样本(ER)';
  run;
  
  proc freq data=siggamma7y5y3y noprint;
  tables sig_gamma5y / out=sig_gamma5y_;
  run;
  proc transpose data=sig_gamma5y_
  out=sig_gamma5y_q;
  id sig_gamma5y;
  var COUNT PERCENT;
  run;
  data sig_gamma5y_q;
  set sig_gamma5y_q;
  drop _NAME_ _label_;
  range='五年样本(ER)';
  run;
  
  proc freq data=siggamma7y5y3y noprint;
  tables sig_gamma3y / out=sig_gamma3y_;
  run;
  proc transpose data=sig_gamma3y_
  out=sig_gamma3y_q;
  id sig_gamma3y;
  var COUNT PERCENT;
  run;
  data sig_gamma3y_q;
  set sig_gamma3y_q;
  drop _NAME_ _label_;
  range='三年样本(ER)';
  run;
  
  data five.sig_gamma_rf753;
  set sig_gamma3y_q sig_gamma5y_q sig_gamma7y_q;
  run;
  
  
  
  data siggamma5y;
  set five.Reg_fbw4_bench2_5y_tm;
  if sig_gamma='不显著' then sig_gamma5y='O';
  else if sig_gamma='正显著' then sig_gamma5y='P';
  else sig_gamma5y='N';
  keep windcode fundname sig_gamma5y;
  run;
  data siggamma3y;
  set five.Reg_fbw4_bench2_3y_tm;
  if sig_gamma='不显著' then sig_gamma3y='O';
  else if sig_gamma='正显著' then sig_gamma3y='P';
  else sig_gamma3y='N';
  keep windcode fundname sig_gamma3y;
  run;
  proc sql;  create table siggamma5y3y as
  select     COALESCE(A.windcode,B.windcode) as windcode,
  COALESCE(A.fundname,B.fundname) as fundname,
  A.sig_gamma5y,
  B.sig_gamma3y
  from       siggamma5y as A
  inner join  siggamma3y as B
  on         A.windcode=B.windcode;
  quit;
  
  proc freq data=siggamma5y3y noprint;
  tables sig_gamma5y / out=sig_gamma5y_;
  run;
  proc transpose data=sig_gamma5y_
  out=sig_gamma5y_q;
  id sig_gamma5y;
  var COUNT PERCENT;
  run;
  data sig_gamma5y_q;
  set sig_gamma5y_q;
  drop _NAME_ _label_;
  range='五年样本(BR)';
  run;
  
  proc freq data=siggamma5y3y noprint;
  tables sig_gamma3y / out=sig_gamma3y_;
  run;
  proc transpose data=sig_gamma3y_
  out=sig_gamma3y_q;
  id sig_gamma3y;
  var COUNT PERCENT;
  run;
  data sig_gamma3y_q;
  set sig_gamma3y_q;
  drop _NAME_ _label_;
  range='三年样本(BR)';
  run;
  
  data five.sig_gamma_bench53;
  set sig_gamma3y_q sig_gamma5y_q;
  run;
  
  
  
  data siggamma5y;
  set five.Reg_fbw4_rf2_5y_tm;
  if sig_gamma='不显著' then sig_gamma5y='O';
  else if sig_gamma='正显著' then sig_gamma5y='P';
  else sig_gamma5y='N';
  keep windcode fundname sig_gamma5y;
  run;
  data siggamma3y;
  set five.Reg_fbw4_rf2_3y_tm;
  if sig_gamma='不显著' then sig_gamma3y='O';
  else if sig_gamma='正显著' then sig_gamma3y='P';
  else sig_gamma3y='N';
  keep windcode fundname sig_gamma3y;
  run;
  proc sql;  create table siggamma5y3y as
  select     COALESCE(A.windcode,B.windcode) as windcode,
  COALESCE(A.fundname,B.fundname) as fundname,
  A.sig_gamma5y,
  B.sig_gamma3y
  from       siggamma5y as A
  inner join  siggamma3y as B
  on         A.windcode=B.windcode;
  quit;
  
  proc freq data=siggamma5y3y noprint;
  tables sig_gamma5y / out=sig_gamma5y_;
  run;
  proc transpose data=sig_gamma5y_
  out=sig_gamma5y_q;
  id sig_gamma5y;
  var COUNT PERCENT;
  run;
  data sig_gamma5y_q;
  set sig_gamma5y_q;
  drop _NAME_ _label_;
  range='五年样本(ER)';
  run;
  
  proc freq data=siggamma5y3y noprint;
  tables sig_gamma3y / out=sig_gamma3y_;
  run;
  proc transpose data=sig_gamma3y_
  out=sig_gamma3y_q;
  id sig_gamma3y;
  var COUNT PERCENT;
  run;
  data sig_gamma3y_q;
  set sig_gamma3y_q;
  drop _NAME_ _label_;
  range='三年样本(ER)';
  run;
  
  data five.sig_gamma_rf53;
  set sig_gamma3y_q sig_gamma5y_q;
  run;
  
  
  
  
  
  
  
  PROC EXPORT DATA=five.Reg_fbw4_bench2
  FILE="&address.mutual_tables_bench_alpha.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_BR全样本";
  RUN;
  PROC EXPORT DATA=five.Reg_fbw4_bench2_3y
  FILE="&address.mutual_tables_bench_alpha.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_BR3y";
  RUN;
  PROC EXPORT DATA=five.Reg_fbw4_bench2_5y
  FILE="&address.mutual_tables_bench_alpha.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_BR5y";
  RUN;
  PROC EXPORT DATA=five.Reg_fbw4_bench2_7y
  FILE="&address.mutual_tables_bench_alpha.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_BR7y";
  RUN;
  
  PROC EXPORT DATA=five.Reg_fbw4_bench2_tm
  FILE="&address.mutual_tables_bench_gamma.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_BR全样本";
  RUN;
  PROC EXPORT DATA=five.Reg_fbw4_bench2_3y_tm
  FILE="&address.mutual_tables_bench_gamma.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_BR3y";
  RUN;
  PROC EXPORT DATA=five.Reg_fbw4_bench2_5y_tm
  FILE="&address.mutual_tables_bench_gamma.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_BR5y";
  RUN;
  PROC EXPORT DATA=five.Reg_fbw4_bench2_7y_tm
  FILE="&address.mutual_tables_bench_gamma.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_BR7y";
  RUN;
  
  PROC EXPORT DATA=five.Reg_fbw4_rf2
  FILE="&address.mutual_tables_rf_alpha.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_ER全样本";
  RUN;
  PROC EXPORT DATA=five.Reg_fbw4_rf2_3y
  FILE="&address.mutual_tables_rf_alpha.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_ER3y";
  RUN;
  PROC EXPORT DATA=five.Reg_fbw4_rf2_5y
  FILE="&address.mutual_tables_rf_alpha.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_ER5y";
  RUN;
  PROC EXPORT DATA=five.Reg_fbw4_rf2_7y
  FILE="&address.mutual_tables_rf_alpha.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_ER7y";
  RUN;
  
  PROC EXPORT DATA=five.Reg_fbw4_rf2_tm
  FILE="&address.mutual_tables_rf_gamma.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_ER全样本";
  RUN;
  PROC EXPORT DATA=five.Reg_fbw4_rf2_3y_tm
  FILE="&address.mutual_tables_rf_gamma.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_ER3y";
  RUN;
  PROC EXPORT DATA=five.Reg_fbw4_rf2_5y_tm
  FILE="&address.mutual_tables_rf_gamma.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_ER5y";
  RUN;
  PROC EXPORT DATA=five.Reg_fbw4_rf2_7y_tm
  FILE="&address.mutual_tables_rf_gamma.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_ER7y";
  RUN;
  
  PROC EXPORT DATA=five.Bpbench5yal
  FILE="&address.mutual_tables_bootstrap_pvalues.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_BR5y";
  RUN;
  PROC EXPORT DATA=five.Bpbench5yga
  FILE="&address.mutual_tables_bootstrap_pvalues.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_BR5y";
  RUN;
  PROC EXPORT DATA=five.Bprf5yal
  FILE="&address.mutual_tables_bootstrap_pvalues.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_ER5y";
  RUN;
  PROC EXPORT DATA=five.Bprf5yga
  FILE="&address.mutual_tables_bootstrap_pvalues.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_ER5y";
  RUN;
  
  PROC EXPORT DATA=five.bench3y
  FILE="&address.mutual_tables_bench_shizu.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_BR3y";
  RUN;
  PROC EXPORT DATA=five.bench5y
  FILE="&address.mutual_tables_bench_shizu.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_BR5y";
  RUN;
  PROC EXPORT DATA=five.bench7y
  FILE="&address.mutual_tables_bench_shizu.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_BR7y";
  RUN;
  PROC EXPORT DATA=five.bench3ytm
  FILE="&address.mutual_tables_bench_shizu.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_BR3y";
  RUN;
  PROC EXPORT DATA=five.bench5ytm
  FILE="&address.mutual_tables_bench_shizu.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_BR5y";
  RUN;
  PROC EXPORT DATA=five.bench7ytm
  FILE="&address.mutual_tables_bench_shizu.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_BR7y";
  RUN;
  
  PROC EXPORT DATA=five.rf3y
  FILE="&address.mutual_tables_rf_shizu.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_ER3y";
  RUN;
  PROC EXPORT DATA=five.rf5y
  FILE="&address.mutual_tables_rf_shizu.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_ER5y";
  RUN;
  PROC EXPORT DATA=five.rf7y
  FILE="&address.mutual_tables_rf_shizu.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_ER7y";
  RUN;
  PROC EXPORT DATA=five.rf3ytm
  FILE="&address.mutual_tables_rf_shizu.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_ER3y";
  RUN;
  PROC EXPORT DATA=five.rf5ytm
  FILE="&address.mutual_tables_rf_shizu.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_ER5y";
  RUN;
  PROC EXPORT DATA=five.rf7ytm
  FILE="&address.mutual_tables_rf_shizu.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_ER7y";
  RUN;
  
  PROC EXPORT DATA=five.Rf_bench_compare2
  FILE="&address.mutual_tables_compare_alpha.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_全样本";
  RUN;
  PROC EXPORT DATA=five.Rf_bench_compare2_3y
  FILE="&address.mutual_tables_compare_alpha.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_3y";
  RUN;
  PROC EXPORT DATA=five.Rf_bench_compare2_5y
  FILE="&address.mutual_tables_compare_alpha.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_5y";
  RUN;
  PROC EXPORT DATA=five.Rf_bench_compare2_7y
  FILE="&address.mutual_tables_compare_alpha.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_7y";
  RUN;
  
  PROC EXPORT DATA=five.Rf_bench_compare2_tm
  FILE="&address.mutual_tables_compare_gamma.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_全样本";
  RUN;
  PROC EXPORT DATA=five.Rf_bench_compare2_3y_tm
  FILE="&address.mutual_tables_compare_gamma.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_3y";
  RUN;
  PROC EXPORT DATA=five.Rf_bench_compare2_5y_tm
  FILE="&address.mutual_tables_compare_gamma.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_5y";
  RUN;
  PROC EXPORT DATA=five.Rf_bench_compare2_7y_tm
  FILE="&address.mutual_tables_compare_gamma.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_7y";
  RUN;
  
  PROC EXPORT DATA=five.Rf_bench_compare1_alpha
  FILE="&address.mutual_tables_summary.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力";
  RUN;
  PROC EXPORT DATA=five.Rf_bench_compare1_gamma
  FILE="&address.mutual_tables_summary.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力";
  RUN;
  PROC EXPORT DATA=five.Sig_alpha_bench753
  FILE="&address.mutual_tables_summary.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_BR753";
  RUN;
  PROC EXPORT DATA=five.Sig_alpha_bench53
  FILE="&address.mutual_tables_summary.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_BR53";
  RUN;
  PROC EXPORT DATA=five.Sig_alpha_rf753
  FILE="&address.mutual_tables_summary.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_ER753";
  RUN;
  PROC EXPORT DATA=five.Sig_alpha_rf53
  FILE="&address.mutual_tables_summary.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="选股能力_ER53";
  RUN;
  
  PROC EXPORT DATA=five.Sig_gamma_bench753
  FILE="&address.mutual_tables_summary.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_BR753";
  RUN;
  PROC EXPORT DATA=five.Sig_gamma_bench53
  FILE="&address.mutual_tables_summary.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_BR53";
  RUN;
  PROC EXPORT DATA=five.Sig_gamma_rf753
  FILE="&address.mutual_tables_summary.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_ER753";
  RUN;
  PROC EXPORT DATA=five.Sig_gamma_rf53
  FILE="&address.mutual_tables_summary.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="择时能力_ER53";
  RUN;
  
  proc delete data=five.a1;run;quit;
  proc delete data=five.a2;run;quit;
  
  
