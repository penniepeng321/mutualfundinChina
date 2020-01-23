%let address = E:\fund_index_weight\Download_data_for_all_mutual_funds\;
%LET OUT = E:\fund_index_weight\Download_data_for_all_mutual_funds\;
libname ddd 'E:\fund_index_weight\Download_data_for_all_mutual_funds\';
PROC IMPORT OUT= ddd.fund_fullname 
            DATAFILE= "&address.fund_fullname20180103.xlsx" 
            DBMS=excel REPLACE; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
PROC IMPORT OUT= ddd.mutualfundbasic_20171204 
            DATAFILE= "&address.mutualfundbasic20180103.xlsx" 
            DBMS=excel REPLACE; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
data ddd.fund_fullname;
set ddd.fund_fullname;
rename _COL0=windcode _COL2=fullname;
run;
data ddd.mutualfundbasic_20171204;
set ddd.mutualfundbasic_20171204;
rename _COL0=windcode;
run;
proc sql;
create table ddd.mutualbasic as
select a.*, b.*
from ddd.fund_fullname as a, ddd.mutualfundbasic_20171204 as b
where a.windcode=b.windcode;
quit;
data ddd.mutualbasic;
set ddd.mutualbasic;
if _COL6=. then _COL6='03Jan2018'd; *not only check _COL6=. but also check _COL6=previous download date;
run;
data ddd.mutualbasic;
set ddd.mutualbasic;
timelength=_COL6-_COL5;
run;

/*
proc sql;
create table ddd.mutualbasic_adjustabc1 as
select DISTINCT(fullname) 
from ddd.mutualbasic
quit;
*/

proc sort data = ddd.mutualbasic;
by fullname descending timelength;
run;

data ddd.mutualbasic_adjustabc1;
set ddd.mutualbasic;
by fullname;
If first.fullname then output ddd.mutualbasic_adjustabc1;
run;

/*
data ddd.mutualbasic_adjustabc;
set ddd.mutualbasic_adjustabc;
if timelength=. then delete;
run;

data ddd.mutualbasic_adjustabc;
set ddd.mutualbasic_adjustabc;
drop _COL1 _COL4 timelength;
run;
*/

proc sort data=ddd.mutualbasic_adjustabc1;
by windcode;run;


data ddd.mutualbasic_adjustabc;
set ddd.mutualbasic_adjustabc1;
missingbench=0;
benchcond=0;
missingstartdate=0;
if _COL3='' then do; _COL3='万得全A'; missingbench=1; end;
if windcode='000259.OF' then do; _COL3='万得全A'; benchcond=1; end;
if _COL5='' then missingstartdate=1;
run;


data ddd.mutualbasic_adjabc_cl;
set ddd.mutualbasic_adjustabc;
if _COL5 ne '';
run;



proc sql;
   title 'Total benchmark missing situation';
   select sum(missingbench)  as countmissingbench,
          sum(benchcond) as countbenchcond,
		  sum(missingstartdate) as countmissingstartdate,
		  sum(missingbench*missingstartdate) as bothmissing,
          sum(calculated countmissingbench, calculated countbenchcond) as GrandTotal format=dollar10.
      from ddd.mutualbasic_adjabc_cl;
run;quit;

*in mutualbasic_adjustabc;
*total 63 missing benchmark self, 1 self in condition;
*total 88 missing start date, no overlap with missing benchmark self;

data ddd.mbasic_3y;
set ddd.mutualbasic_adjabc_cl;
if _COL5<='31dec2014'd;
if _COL6>='31dec2017'd;
if _COL8 in ('普通股票型基金','偏股混合型基金', '灵活配置型基金');
run;

proc sql;
   title 'Total benchmark missing situation';
   select sum(missingbench)  as countmissingbench,
          sum(benchcond) as countbenchcond,
		  sum(missingstartdate) as countmissingstartdate,
		  sum(missingbench*missingstartdate) as bothmissing,
          sum(calculated countmissingbench, calculated countbenchcond) as GrandTotal format=dollar10.
      from ddd.mbasic_3y;
run;quit;


*in three year sample 2015-2017, 1 missing self benchmark;

data ddd.mbasic_5y;
set ddd.mutualbasic_adjabc_cl;
if _COL5<='31dec2012'd;
if _COL6>='31dec2017'd;
if _COL8 in ('普通股票型基金','偏股混合型基金', '灵活配置型基金');
run;

proc sql;
   title 'Total benchmark missing situation';
   select sum(missingbench)  as countmissingbench,
          sum(benchcond) as countbenchcond,
		  sum(missingstartdate) as countmissingstartdate,
		  sum(missingbench*missingstartdate) as bothmissing,
          sum(calculated countmissingbench, calculated countbenchcond) as GrandTotal format=dollar10.
      from ddd.mbasic_5y;
run;quit;

*in four year sample 2013-2017, 1 missing self benchmark;

data ddd.mbasic_7y;
set ddd.mutualbasic_adjabc_cl;
if _COL5<='31dec2010'd;
if _COL6>='31dec2017'd;
if _COL8 in ('普通股票型基金','偏股混合型基金', '灵活配置型基金');
run;

proc sql;
   title 'Total benchmark missing situation';
   select sum(missingbench)  as countmissingbench,
          sum(benchcond) as countbenchcond,
		  sum(missingstartdate) as countmissingstartdate,
		  sum(missingbench*missingstartdate) as bothmissing,
          sum(calculated countmissingbench, calculated countbenchcond) as GrandTotal format=dollar10.
      from ddd.mbasic_7y;
run;quit;

*in seven year sample 2011-2017, 1 missing self benchmark;





data ddd.mutualbasic_final;
set ddd.mutualbasic_adjustabc;
rename _COL1=fundname _COL3=benchmark _COL5=startdate _COL6=enddate _COL7=yiji _COL8=erji _COL9=fenji;
keep windcode _COL1 fullname _COL3 _COL5 _COL6 _COL7 _COL8 _COL9;
run;

PROC EXPORT 
DATA=ddd.mutualbasic_final
DBMS=excel
OUTFILE="&address.mutualbasic_adjustabc20180103.xlsx"
REPLACE;
run;




*after 1_2.R, run the following;

PROC IMPORT OUT= ddd.horizontaldata 
            DATAFILE= "&address.horizontaldata.xlsx" 
            DBMS=excel REPLACE; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;


proc sort data=ddd.horizontaldata; by windcode; run;
proc sort data=ddd.mutualbasic_adjabc_cl; 
by windcode; run;

data ddd.mbasichor;
merge ddd.mutualbasic_adjabc_cl(in=a) ddd.horizontaldata(in=b);
by windcode; if a=1; run;

data ddd.mbasichor;
set ddd.mbasichor;
index1prefix=substr(index1_code,1,1);
run;

data ddd.mbasichor;
set ddd.mbasichor;
constbench=0;
if index1_weight=1 and index1prefix='M' then constbench=1;
run;



data ddd.mbasic_3y;
set ddd.mbasichor;
if _COL5<='31dec2014'd;
if _COL6>='31dec2017'd;
if _COL8 in ('普通股票型基金','偏股混合型基金', '灵活配置型基金');
run;

proc sql;
   title 'Total benchmark missing situation';
   select sum(missingbench)  as countmissingbench,
          sum(constbench) as countconstbench,
		  sum(missingstartdate) as countmissingstartdate,
          sum(calculated countmissingbench, calculated countconstbench) as GrandTotal format=dollar10.
      from ddd.mbasic_3y;
run;quit;


*in three year sample 2015-2017, 1 missing self benchmark and 26 constant self benchmark;

data ddd.mbasic_5y;
set ddd.mbasichor;
if _COL5<='31dec2012'd;
if _COL6>='31dec2017'd;
if _COL8 in ('普通股票型基金','偏股混合型基金', '灵活配置型基金');
run;

proc sql;
   title 'Total benchmark missing situation';
   select sum(missingbench)  as countmissingbench,
          sum(constbench) as countconstbench,
		  sum(missingstartdate) as countmissingstartdate,
          sum(calculated countmissingbench, calculated countconstbench) as GrandTotal format=dollar10.
      from ddd.mbasic_5y;
run;quit;

*in four year sample 2013-2017, 1 missing self benchmark and 8 constant self benchmark;

data ddd.mbasic_7y;
set ddd.mbasichor;
if _COL5<='31dec2010'd;
if _COL6>='31dec2017'd;
if _COL8 in ('普通股票型基金','偏股混合型基金', '灵活配置型基金');
run;

proc sql;
   title 'Total benchmark missing situation';
   select sum(missingbench)  as countmissingbench,
          sum(constbench) as countconstbench,
		  sum(missingstartdate) as countmissingstartdate,
          sum(calculated countmissingbench, calculated countconstbench) as GrandTotal format=dollar10.
      from ddd.mbasic_7y;
run;quit;

*in seven year sample 2011-2017, 1 missing self benchmark and 4 constant self benchmark;



data ddd.mbasic_3y;
set ddd.mbasic_3y;
if constbench=0;
if missingbench=0;
run;
*692 in three year sample;

data ddd.mbasic_5y;
set ddd.mbasic_5y;
if constbench=0;
if missingbench=0;
run;
*491 in five year sample;

data ddd.mbasic_7y;
set ddd.mbasic_7y;
if constbench=0;
if missingbench=0;
run;
*367 in seven year sample;



data ddd.cleanliststockfund;
set ddd.mbasichor;
if constbench=0;
if missingbench=0;
run;

data ddd.mutualbasic_final;
set ddd.cleanliststockfund;
rename _COL1=fundname _COL3=benchmark _COL5=startdate _COL6=enddate _COL7=yiji _COL8=erji _COL9=fenji;
keep windcode _COL1 fullname _COL3 _COL5 _COL6 _COL7 _COL8 _COL9;
run;

PROC EXPORT 
DATA=ddd.mutualbasic_final
DBMS=excel
OUTFILE="&address.mutualbasic_adjustabc20180103.xlsx"
REPLACE;
run;
