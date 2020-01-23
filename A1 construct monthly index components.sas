%let address = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';

%let m=20180705;*fill in export date;

*in brinson.monthlyindexcomp;
*for hand-computed index weights and components, their frequency is monthly;
*for wind-downloaded index weights and components, their frequency is semi-annually;

*we use A1 to construct monthly index weights and components;
*we impute monthly index components;
*merge with monthly stock cap;
*compute monthly index weights;

data opl;
set brinson.monthlyindexcomp;
year=year(date);
month=month(date);
run;

data opl;
set opl;
if month=6 or month=12;
run;

data temp1;
set opl;
run;

data temp2;
set opl;
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
set opl;
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
set opl;
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
set opl;
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
set opl;
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
by indexcode year month;
run;

data temp;
set temp;
drop i_weight;
run;

data temp;
set temp;
drop date;
run;

proc sql;
create table tempr as
select a.*, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from temp as a left join brinson.stkpmonthlysemiret as b 
on a.wind_code = b.WINDCODE and a.year=b.year and a.month=b.month;
run;quit; 

proc sort data=tempr;
by indexcode year month;
run;

proc means data=tempr noprint;
  class indexcode year month;
  var MKT_CAP_FLOAT;
  output out=tempr1 sum=sumweight;
run;

data tempr1;
set tempr1;
if _TYPE_=7;
run;

data tempr1;
set tempr1;
drop _TYPE_ _FREQ_;
run;

proc sql;
create table tempr2 as
select a.*, b.sumweight 
from tempr as a left join tempr1 as b 
on a.indexcode = b.indexcode and a.year=b.year and a.month=b.month;
run;quit;

data tempr2;
set tempr2;
i_weight=MKT_CAP_FLOAT/sumweight;
run;

data brinson.monthlyindexcomplete;
set tempr2;
run;

data brinson.monthlyindexcomplete;
set brinson.monthlyindexcomplete;
drop sumweight close;
run;




