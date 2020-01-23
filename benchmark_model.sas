/*apply benchmark model in analysis*/

%let address = F:\fund_index_weight\Download_data_for_all_mutual_funds\;
%LET OUT = F:\fund_index_weight\Download_data_for_all_mutual_funds\;
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';
libname rolling 'F:\fund_index_weight\benchmark_explore\';

proc reg data=five.fund_benchmark_weight4 outest=s1 edf  tableout  noprint;
model excess_return = sys_risk smb hml;
by windcode;
quit;

proc reg data=five.fund_benchmark_weight4 outest=s2 edf  tableout  noprint;
model Benchmark_ret = sys_risk smb hml;
by windcode;
quit;

data s11;
set s1;
where _type_='PARMS';
rename sys_risk=c_s1 smb=c_smb1 hml=c_hml1;
keep windcode sys_risk smb hml;
run;

data s21;
set s2;
where _type_='PARMS';
rename sys_risk=c_s2 smb=c_smb2 hml=c_hml2;
keep windcode sys_risk smb hml;
run;

proc sql;
create table rec as
select a.date, a.windcode, a.fundname, a.excess_return, a.Benchmark_ret, a.sys_risk, a.smb, a.hml, b.c_s1, b.c_smb1, b.c_hml1, c.c_s2, c.c_smb2, c.c_hml2
from five.fund_benchmark_weight4 as a , s11 as b , s21 as c 
where a.windcode = b.windcode = c.windcode;
run;quit;

proc sort data=rec; by windcode date; run;

data rec1;
set rec;
rac=Benchmark_ret-sys_risk*c_s2-smb*c_smb2-hml*c_hml2;
rar=excess_return-sys_risk*c_s1-smb*c_smb1-hml*c_hml1;
run;

proc reg data=rec1 outest=s3 edf  tableout  noprint;
model rar = rac;
by windcode;
quit;

data s31;
set s3;
where _type_='PVALUE';
run;

data s32;
set s31;
where rac<0.05;
run;

proc sql;
create table cmatch as
select a.windcode, b.*
from s32 as a , five.num_total as b
where a.windcode = b.windcode;
run;quit;

data s33;
set s3;
where _type_='PARMS';
run;

proc rank data=s33 out=s33r descending ties=low;   
var Intercept;
ranks alpharank;
run;

proc sort data=s33; by descending Intercept; run;

proc sql;
create table amatch as
select a.*, b.*
from s33 as a , five.num_total as b
where a.windcode = b.windcode;
run;quit;

proc sort data=amatch; by descending Intercept; run;


/*rolling check ranks*/
  %let windowlength=3;
  
  data rolling.corr_year&windowlength;
  set _null_;v1="000000000000000";v2="0.00000000000000";run;

    
  %macro rollingcheck(year);
  
  %let year3=%eval(&year - &windowlength);
  %let year2=%eval(&year - &windowlength +1);
  
  data rolling.fund_benchmark_weight4&windowlength;
  set five.fund_benchmark_weight4;
  if startdate<="31oct&year3"d;
  if enddate>="01aug&year"d;
  if date>="31oct&year3"d;
  if date<="31oct&year"d;
  run;
  
  data rolling.fund_benchmark_weight4&windowlength;
  set rolling.fund_benchmark_weight4&windowlength;
  if smb ne .;
  if hml ne .;
  run;
  
proc reg data=rolling.fund_benchmark_weight4&windowlength outest=s1 edf  tableout  noprint;
model excess_return = sys_risk smb hml;
by windcode;
quit;

proc reg data=rolling.fund_benchmark_weight4&windowlength outest=s2 edf  tableout  noprint;
model Benchmark_ret = sys_risk smb hml;
by windcode;
quit;

data s11;
set s1;
where _type_='PARMS';
rename sys_risk=c_s1 smb=c_smb1 hml=c_hml1;
keep windcode sys_risk smb hml Intercept;
run;

proc rank data=s11 out=s11r descending ties=low;   
var Intercept;
ranks alpharanko;
run;

data s21;
set s2;
where _type_='PARMS';
rename sys_risk=c_s2 smb=c_smb2 hml=c_hml2;
keep windcode sys_risk smb hml;
run;

proc sql;
create table rec as
select a.date, a.windcode, a.fundname, a.excess_return, a.Benchmark_ret, a.sys_risk, a.smb, a.hml, b.c_s1, b.c_smb1, b.c_hml1, c.c_s2, c.c_smb2, c.c_hml2
from five.fund_benchmark_weight4 as a , s11 as b , s21 as c 
where a.windcode = b.windcode = c.windcode;
run;quit;

proc sort data=rec; by windcode date; run;

data rec1;
set rec;
rac=Benchmark_ret-sys_risk*c_s2-smb*c_smb2-hml*c_hml2;
rar=excess_return-sys_risk*c_s1-smb*c_smb1-hml*c_hml1;
run;

proc reg data=rec1 outest=s3 edf  tableout  noprint;
model rar = rac;
by windcode;
quit;

data s33;
set s3;
where _type_='PARMS';
run;

proc rank data=s33 out=s33r descending ties=low;   
var Intercept;
ranks alpharankn;
run;

  proc sort data=s11r;by windcode;run;
  proc sort data=s33r;by windcode;run;
  data tt;
  merge s11r(in=xxx) s33r(in=yyy);
  by windcode;
  if xxx and yyy;
  run;
  
  proc corr data=tt nomiss outp=uu;
  var alpharanko alpharankn;
  run;
  
  proc sort data=uu;by alpharanko;run;
  data uu; 
  set uu; 
  if _n_=1 then do; call symput('corr_rank',alpharanko); end;
  run;
  
  proc sql;
  insert into rolling.corr_year&windowlength (v1,v2)
  values ("&year", "&corr_rank");
  quit;
  
  %mend rollingcheck;

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
  FILE="&address.选股能力.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="过去&windowlength.年";
  RUN;
  











  /*rolling check ranks*/
  %let windowlength=3;
  
  data rolling.corr_year&windowlength;
  set _null_;v1="000000000000000";v2="0.00000000000000";run;

    
  %macro rollingcheck(year);
  
  %let year3=%eval(&year - &windowlength);
  %let year2=%eval(&year - &windowlength +1);
  
  data rolling.fund_benchmark_weight4&windowlength;
  set five.fund_benchmark_weight4;
  if startdate<="31oct&year3"d;
  if enddate>="01aug&year"d;
  if date>="31oct&year3"d;
  if date<="31oct&year"d;
  run;
  
  data rolling.fund_benchmark_weight4&windowlength;
  set rolling.fund_benchmark_weight4&windowlength;
  if smb ne .;
  if hml ne .;
  run;
  
proc reg data=rolling.fund_benchmark_weight4&windowlength outest=s1 edf  tableout  noprint;
model excess_return = sys_risk smb hml;
by windcode;
quit;

proc reg data=rolling.fund_benchmark_weight4&windowlength outest=s2 edf  tableout  noprint;
model Benchmark_ret = sys_risk smb hml;
by windcode;
quit;

data s11;
set s1;
where _type_='PARMS';
rename sys_risk=c_s1 smb=c_smb1 hml=c_hml1;
keep windcode sys_risk smb hml Intercept;
run;

proc rank data=s11 out=s11r descending ties=low;   
var Intercept;
ranks alpharanko;
run;

data s21;
set s2;
where _type_='PARMS';
rename sys_risk=c_s2 smb=c_smb2 hml=c_hml2;
keep windcode sys_risk smb hml;
run;

proc sql;
create table rec as
select a.date, a.windcode, a.fundname, a.excess_return, a.Benchmark_ret, a.sys_risk, a.smb, a.hml, b.c_s1, b.c_smb1, b.c_hml1, c.c_s2, c.c_smb2, c.c_hml2
from five.fund_benchmark_weight4 as a , s11 as b , s21 as c 
where a.windcode = b.windcode = c.windcode;
run;quit;

proc sort data=rec; by windcode date; run;

data rec1;
set rec;
rac=Benchmark_ret-sys_risk*c_s2-smb*c_smb2-hml*c_hml2;
rar=excess_return-sys_risk*c_s1-smb*c_smb1-hml*c_hml1;
run;

proc reg data=rec1 outest=s3 edf  tableout  noprint;
model rar = rac;
by windcode;
quit;

data s33;
set s3;
where _type_='PARMS';
run;

proc rank data=s33 out=s33r descending ties=low;   
var Intercept;
ranks alpharankn;
run;

  proc sort data=s11r;by windcode;run;
  proc sort data=s33r;by windcode;run;
  data tt;
  merge s11r(in=xxx) s33r(in=yyy);
  by windcode;
  if xxx and yyy;
  run;
  
  proc corr data=tt nomiss outp=uu;
  var alpharanko alpharankn;
  run;
  
  proc sort data=uu;by alpharanko;run;
  data uu; 
  set uu; 
  if _n_=1 then do; call symput('corr_rank',alpharanko); end;
  run;
  
  proc sql;
  insert into rolling.corr_year&windowlength (v1,v2)
  values ("&year", "&corr_rank");
  quit;
  
  %mend rollingcheck;

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
  FILE="&address.选股能力.xlsx"
  DBMS=xlsx REPLACE;
  SHEET="过去&windowlength.年";
  RUN;
  



