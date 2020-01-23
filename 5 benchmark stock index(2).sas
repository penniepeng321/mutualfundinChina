
%let address = F:\fund_index_weight\brinson\;
%LET OUT = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';

%let m=20180620;*fill in export date;

proc import out=brinson.amutual
datafile="F:\fund_index_weight\brinson\amutual20180508.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.amutual;
set brinson.amutual;
rename _COL0=fundcode
_COL1=fundname
_COL2=fullname
_COL3=benchmark
_COL4=startdate
_COL5=enddate
_COL6=yiji
_COL7=erji
_COL8=fenji;
run;

*run 1.R to transform amutual.sas dataset to vertical fund benchmark table;
*save csv as excel workbook;
*import updated vertical benchmark table including all funds;

proc import out=brinson.mutualbasicv
datafile="F:\fund_index_weight\brinson\fund_benchmark_vertical20180508.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.ptgpv;
set brinson.mutualbasicv;
if erji='普通股票型基金' or erji='偏股混合型基金' or erji='灵活配置型基金';
run;

*export this table to clean up NA's in indexcode;
PROC EXPORT DATA=brinson.ptgpv
FILE="&address.ptgpv20180508"
DBMS=xlsx REPLACE;
SHEET="a1";
RUN;

*import data after cleaning NA's in indexcode;
proc import out=brinson.ptgpv
datafile="F:\fund_index_weight\brinson\ptgpv20180508.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

*update dictionary;
data juk;
set brinson.ptgpv;
keep index_code index_name;
rename index_code=index_c index_name=index_n;
run;

data brinson.indexdictionary;
set brinson.dic23 juk;
run;

proc sql;
 create table brinson.indexdictionary1 as
 select DISTINCT (index_c), index_n
 from brinson.indexdictionary order by index_c;
quit;
*the updated index dictionary is brinson.indexdictionary1;

*clean up self benchmark data so that we keep only stock indices and normalize weights to be 1;
*so that later we can merge benchmark holding with this data;
*we got ptgp vertical benchmark table from mutual fund analysis;
*we remove irrelevant indices in it;
data brinson.ptgpv1;
set brinson.ptgpv;
ii=find(index_name,'利率');
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
if ii=0;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
drop ii;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
ii=find(index_name,'债');
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
if ii=0;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
drop ii;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
ii=find(index_name,'万得全');
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
if ii=0;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
drop ii;
run;

/*
data brinson.ptgpv1;
set brinson.ptgpv1;
ii=find(index_name,'恒生');
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
if ii=0;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
drop ii;
run;
*/

data brinson.ptgpv1;
set brinson.ptgpv1;
ii=SUBSTR(index_code,1,1);
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
if ii ne 'M';
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
drop ii;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
ii=find(index_name,'存款');
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
if ii=0;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
drop ii;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
ii=find(index_name,'定存');
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
if ii=0;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
drop ii;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
ii=find(index_name,'%');
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
if ii=0;
run;

data brinson.ptgpv1;
set brinson.ptgpv1;
drop ii;
run;

data jip;
set brinson.ptgpv1;
keep index_code index_name;
run;

proc sql;
 create table jip1 as
 select DISTINCT (index_code), index_name
 from jip order by index_code;
quit;

*after cleaning up the indices to include only stock indices, we standardize the indices weights;
*standardization here does not equal (x-mean)/sd, it means x/sum(x_i) so that summation is 1;

proc means data=brinson.ptgpv1 noprint;
  class windcode;
  var index_weight;
  output out=brinson.ptgpo1 sum=sumweight;
run;

data brinson.ptgpo2;
set brinson.ptgpo1;
if _TYPE_=1;
keep windcode sumweight;
run;

/*data brinson.ptgpo2;
set brinson.ptgpo1 (firstobs=2);
keep windcode sumweight;
run;*/

proc sql;
create table brinson.ptgpvo1 as
select a.*, b.sumweight 
from brinson.ptgpv1 as a left join brinson.ptgpo2 as b 
on a.windcode = b.windcode;
run;quit;

*2912 data entries in brinson.ptgpv1;
*2912 in brinson.ptgpvo1 as well;

data brinson.ptgpvo1;
set brinson.ptgpvo1;
nindexw=index_weight/sumweight;
run;

*replace some indices with easier proxies;
/*
data brinson.ptgpvo1;
set brinson.ptgpvo1;
nindexcode=index_code;
if index_code='816000.CI' then nindexcode='000300.SH';
run;
*/
