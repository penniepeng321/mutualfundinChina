%let address = F:\fund_index_weight\brinson\;
%LET OUT = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';

%let m=20180621;*fill in export date;


proc import out=brinson.indexcomponents
datafile="F:\fund_index_weight\brinson\indexcomponents20180226.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;


proc import out=brinson.icomp
datafile="F:\fund_index_weight\brinson\indexcomponents20180304.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.indexcomponents1;
set brinson.indexcomponents brinson.icomp;
run;


*delete duplicate entries due to data downloading;

proc sql;
 create table dindexcomp as
 select DISTINCT (indexcode), i_weight, sec_name, wind_code, date
 from brinson.indexcomponents1 order by indexcode;
quit;

proc sort data=dindexcomp; by date indexcode; run;

data brinson.indexcomponents;
set dindexcomp;
run;

*ADD ZHONGXIN industry holding by hand to indexcomponents dataset;

*CI005013.WI zhongxin qiche;
*CI005018.WI zhongxin yiyao;
*CI005019.WI shipin yinliao;
*CI005020.WI nonglin muyu;
*CI005025.WI dianzi yuanqijian;
*CI005026.WI tongxin;
*CI005027.WI jisuanji;

data brinson.stkpmon2;
set brinson.stkmonthly1;
qci=find(INDUSTRY_CITIC,'汽车');
yyi=find(INDUSTRY_CITIC,'医药');
spi=find(INDUSTRY_CITIC,'食品');
nli=find(INDUSTRY_CITIC,'农林');
yqji=find(INDUSTRY_CITIC,'电子元器件');
txi=find(INDUSTRY_CITIC,'通信');
jsji=find(INDUSTRY_CITIC,'计算机');
run;


*zhongxin qiche;

data temp;
set brinson.stkpmon2;
if qci ne 0;
run;

data temp;
set temp;
indexcode='CI005013.WI';
run;

proc sort data=temp; by datetime; run;

proc means data=temp noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

data temp1;
set temp1;
if _TYPE_=1;
run;

proc sql;
create table brinson.qiche as
select a.*, b.sumweight 
from temp as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data brinson.qiche;
set brinson.qiche;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data brinson.qiche;
set brinson.qiche;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.qiche;
format sec_name $38.;
informat sec_name $38.;
set brinson.qiche;
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
format sec_name $38.;
informat sec_name $38.;
set brinson.indexcomponents;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.qiche;
run;

*zhongxin yiyao;

data temp;
set brinson.stkpmon2;
if yyi ne 0;
run;

data temp;
set temp;
indexcode='CI005018.WI';
run;

proc sort data=temp; 
by datetime; 
run;

proc means data=temp noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

data temp1;
set temp1;
if _TYPE_=1;
run;

proc sql;
create table brinson.yiyao as
select a.*, b.sumweight 
from temp as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data brinson.yiyao;
set brinson.yiyao;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data brinson.yiyao;
set brinson.yiyao;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.yiyao;
set brinson.yiyao;
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.yiyao;
run;

*shipinyinliao;

data temp;
set brinson.stkpmon2;
if spi ne 0;
run;

data temp;
set temp;
indexcode='CI005019.WI';
run;

proc sort data=temp; by datetime; run;

proc means data=temp noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

data temp1;
set temp1;
if _TYPE_=1;
run;

proc sql;
create table brinson.shipin as
select a.*, b.sumweight 
from temp as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data brinson.shipin;
set brinson.shipin;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data brinson.shipin;
set brinson.shipin;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.shipin;
set brinson.shipin;
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.shipin;
run;

*nonglin muyu;

data temp;
set brinson.stkpmon2;
if nli ne 0;
run;

data temp;
set temp;
indexcode='CI005020.WI';
run;

proc sort data=temp; by datetime; run;

proc means data=temp noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

data temp1;
set temp1;
if _TYPE_=1;
run;

proc sql;
create table brinson.muyu as
select a.*, b.sumweight 
from temp as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data brinson.muyu;
set brinson.muyu;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data brinson.muyu;
set brinson.muyu;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.muyu;
set brinson.muyu;
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.muyu;
run;

*yuanqijian;

data temp;
set brinson.stkpmon2;
if yqji ne 0;
run;

data temp;
set temp;
indexcode='CI005025.WI';
run;

proc sort data=temp; by datetime; run;

proc means data=temp noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

data temp1;
set temp1;
if _TYPE_=1;
run;

proc sql;
create table brinson.yuanqij as
select a.*, b.sumweight 
from temp as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data brinson.yuanqij;
set brinson.yuanqij;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data brinson.yuanqij;
set brinson.yuanqij;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.yuanqij;
set brinson.yuanqij;
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.yuanqij;
run;

*tongxin;

data temp;
set brinson.stkpmon2;
if txi ne 0;
run;

data temp;
set temp;
indexcode='CI005026.WI';
run;

proc sort data=temp; by datetime; run;

proc means data=temp noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

data temp1;
set temp1;
if _TYPE_=1;
run;

proc sql;
create table brinson.tongx as
select a.*, b.sumweight 
from temp as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;


data brinson.tongx;
set brinson.tongx;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data brinson.tongx;
set brinson.tongx;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.tongx;
set brinson.tongx;
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.tongx;
run;

*jisuanji;

data temp;
set brinson.stkpmon2;
if jsji ne 0;
run;

data temp;
set temp;
indexcode='CI005027.WI';
run;

proc sort data=temp; by datetime; run;

proc means data=temp noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

data temp1;
set temp1;
if _TYPE_=1;
run;

proc sql;
create table brinson.jisuan as
select a.*, b.sumweight 
from temp as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data brinson.jisuan;
set brinson.jisuan;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data brinson.jisuan;
set brinson.jisuan;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.jisuan;
set brinson.jisuan;
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.jisuan;
run;


*add MSCI China A share index into indexcomponents by hand;
*download MSCI A share list from Wind;
*apply stockmonthly.R to download MSCI stock monthly data;
*replace NaN and NA;
*delete redundant columns;
*import wizard: import msci monthly data into work. library;


*this way imports the data well;
proc import out=mscia1
datafile="F:\fund_index_weight\brinson\mscimonthlydata20180304.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.msciam;
set mscia1;
run;

*msci a share index starts in 2005 may;
*we download indexcomponents semi-annually;
*we by hand calculate msci a share index from 2005z;
data brinson.msciam;
set brinson.msciam;
year=year(DATETIME);
month=month(DATETIME);
run;

data brinson.msciam1;
set brinson.msciam;
if year>=2005;
run;

proc sort data=brinson.msciam1; 
by datetime;
run;

*delete . missing close price of stocks;
data brinson.msciam2;
set brinson.msciam1;
if CLOSE ne .;
run;

proc means data=brinson.msciam2 noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table brinson.msciam3 as
select a.*, b.sumweight 
from brinson.msciam2 as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data brinson.msciam3;
set brinson.msciam3;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data brinson.msciam3;
set brinson.msciam3;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.msciam3;
set brinson.msciam3;
indexcode='133333.CSI';
keep date wind_code sec_name i_weight indexcode;
run;
* I checked benchmark index dictionary and saw that no index code 133333.CSI exists in it;
* it is likely that this index was not used;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.msciam3;
run;


*HSI.HI hengshengzhishu;
*HSCI.HI hengshengzonghezhishu;
*HSHCI.HI hengshengyiliaobaojianzhishu;
*HSFSI.HI hengshengjinronghangyezhishu;

proc import out=HSI
datafile="F:\fund_index_weight\brinson\hsihihengshengzhishu.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table hsimon as
select a.sec_name, a.windcode, b.datetime, b.INDUSTRY_HS, b.MKT_CAP_FLOAT, b.CLOSE
from HSI as a, brinson.hsmon2 as b 
where a.windcode = b.windcode;
run;quit;

proc sort data=hsimon;
by datetime;
run;

data hsimon;
set hsimon;
year=year(datetime);
run;

data hsimon;
set hsimon;
if year>=2005;
run;

proc means data=hsimon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table hsimon1 as
select a.*, b.sumweight 
from hsimon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data hsimon1;
set hsimon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data hsimon1;
set hsimon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.hsimon;
set hsimon1;
indexcode='HSI.HI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.hsimon;
run;




*HSCI.HI hengshengzonghezhishu;
*HSHCI.HI hengshengyiliaobaojianzhishu;
*HSFSI.HI hengshengjinronghangyezhishu;

proc import out=HSCI
datafile="F:\fund_index_weight\brinson\hscihihengshengzonghezhishu.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table HSCImon as
select a.sec_name, a.windcode, b.datetime, b.INDUSTRY_HS, b.MKT_CAP_FLOAT, b.CLOSE
from HSCI as a, brinson.hsmon2 as b 
where a.windcode = b.windcode;
run;quit;

proc sort data=HSCImon;
by DATETIME;
run;

data HSCImon;
set HSCImon;
year=year(datetime);
run;

data HSCImon;
set HSCImon;
if year>=2005;
run;

proc means data=HSCImon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table HSCImon1 as
select a.*, b.sumweight 
from HSCImon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data HSCImon1;
set HSCImon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data HSCImon1;
set HSCImon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.HSCImon;
set HSCImon1;
indexcode='HSCI.HI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.HSCImon;
informat sec_name $38.;
format sec_name $38.;
set brinson.HSCImon;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.HSCImon;
run;




*HSHCI.HI hengshengyiliaobaojianzhishu;
*HSFSI.HI hengshengjinronghangyezhishu;

proc import out=HSHCI
datafile="F:\fund_index_weight\brinson\HSHCIhengshengyiliaobaojian.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table HSHCImon as
select a.sec_name, a.windcode, b.datetime, b.INDUSTRY_HS, b.MKT_CAP_FLOAT, b.CLOSE
from HSHCI as a, brinson.hsmon2 as b 
where a.windcode = b.windcode;
run;quit;

proc sort data=HSHCImon;
by DATETIME;
run;

data HSHCImon;
set HSHCImon;
year=year(datetime);
run;

data HSHCImon;
set HSHCImon;
if year>=2005;
run;

proc means data=HSHCImon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table HSHCImon1 as
select a.*, b.sumweight 
from HSHCImon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data HSHCImon1;
set HSHCImon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data HSHCImon1;
set HSHCImon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.HSHCImon;
set HSHCImon1;
indexcode='HSHCI.HI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.HSHCImon;
informat sec_name $38.;
format sec_name $38.;
set brinson.HSHCImon;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.HSHCImon;
run;




*HSFSI.HI hengshengjinronghangyezhishu;

proc import out=HSFSI
datafile="F:\fund_index_weight\brinson\HSFSIhengshengjinrong.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table HSFSImon as
select a.sec_name, a.windcode, b.datetime, b.INDUSTRY_HS, b.MKT_CAP_FLOAT, b.CLOSE
from HSFSI as a, brinson.hsmon2 as b 
where a.windcode = b.windcode;
run;quit;

proc sort data=HSFSImon;
by DATETIME;
run;

data HSFSImon;
set HSFSImon;
year=year(datetime);
run;

data HSFSImon;
set HSFSImon;
if year>=2005;
run;

proc means data=HSFSImon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table HSFSImon1 as
select a.*, b.sumweight 
from HSFSImon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data HSFSImon1;
set HSFSImon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data HSFSImon1;
set HSFSImon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.HSFSImon;
set HSFSImon1;
indexcode='HSFSI.HI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.HSFSImon;
informat sec_name $38.;
format sec_name $38.;
set brinson.HSFSImon;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.HSFSImon;
run;





proc import out=HSAHH
datafile="F:\fund_index_weight\brinson\HSAHH.HI.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table HSAHHmon as
select a.sec_name, a.windcode, b.datetime, b.INDUSTRY_HS, b.MKT_CAP_FLOAT, b.CLOSE
from HSAHH as a, brinson.hsmon2 as b 
where a.windcode = b.windcode;
run;quit;

proc sort data=HSAHHmon;
by DATETIME;
run;

data HSAHHmon;
set HSAHHmon;
year=year(datetime);
run;

data HSAHHmon;
set HSAHHmon;
if year>=2005;
run;

proc means data=HSAHHmon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table HSAHHmon1 as
select a.*, b.sumweight 
from HSAHHmon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data HSAHHmon1;
set HSAHHmon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data HSAHHmon1;
set HSAHHmon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.HSAHHmon;
set HSAHHmon1;
indexcode='HSAHH.HI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.HSAHHmon;
run;





proc import out=HSCEI
datafile="F:\fund_index_weight\brinson\HSCEI.HI.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table HSCEImon as
select a.sec_name, a.windcode, b.datetime, b.INDUSTRY_HS, b.MKT_CAP_FLOAT, b.CLOSE
from HSCEI as a, brinson.hsmon2 as b 
where a.windcode = b.windcode;
run;quit;

proc sort data=HSCEImon;
by DATETIME;
run;

data HSCEImon;
set HSCEImon;
year=year(datetime);
run;

data HSCEImon;
set HSCEImon;
if year>=2005;
run;

proc means data=HSCEImon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table HSCEImon1 as
select a.*, b.sumweight 
from HSCEImon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data HSCEImon1;
set HSCEImon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data HSCEImon1;
set HSCEImon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.HSCEImon;
set HSCEImon1;
indexcode='HSCEI.HI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.HSCEImon;
run;




*for additional hand-computed index components;

*we compute each one;

****************************************************************************************;

*we do this because we add lhpz and pghh into our pool of funds to consider;
*we implement the following steps to create brinson model results;

****************************************************************************************;

proc import out=CI816000
datafile="F:\fund_index_weight\brinson\816000.CI.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table CI816000mon as
select a.sec_name, a.windcode, b.datetime, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from CI816000 as a, brinson.stkpmonthlysemiret as b 
where a.windcode = b.windcode;
run;quit;

proc sort data=CI816000mon;
by DATETIME;
run;

data CI816000mon;
set CI816000mon;
year=year(datetime);
run;

data CI816000mon;
set CI816000mon;
if year>=2005;
run;

proc means data=CI816000mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table CI816000mon1 as
select a.*, b.sumweight 
from CI816000mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data CI816000mon1;
set CI816000mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data CI816000mon1;
set CI816000mon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.CI816000;
set CI816000mon1;
indexcode='816000.CI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.CI816000;
run;





proc import out=CI816050
datafile="F:\fund_index_weight\brinson\816050.CI.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;


proc sql;
create table CI816050mon as
select a.sec_name, a.windcode, b.datetime, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from CI816050 as a, brinson.stkpmonthlysemiret as b 
where a.windcode = b.windcode;
run;quit;

proc sort data=CI816050mon;
by DATETIME;
run;

data CI816050mon;
set CI816050mon;
year=year(datetime);
run;

data CI816050mon;
set CI816050mon;
if year>=2005;
run;

proc means data=CI816050mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table CI816050mon1 as
select a.*, b.sumweight 
from CI816050mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data CI816050mon1;
set CI816050mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data CI816050mon1;
set CI816050mon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.CI816050;
set CI816050mon1;
indexcode='816050.CI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.CI816050;
run;







proc import out=CI816999
datafile="F:\fund_index_weight\brinson\816999.CI.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;


proc sql;
create table CI816999mon as
select a.sec_name, a.windcode, b.datetime, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from CI816999 as a, brinson.stkpmonthlysemiret as b 
where a.windcode = b.windcode;
run;quit;

proc sort data=CI816999mon;
by DATETIME;
run;

data CI816999mon;
set CI816999mon;
year=year(datetime);
run;

data CI816999mon;
set CI816999mon;
if year>=2005;
run;

proc means data=CI816999mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table CI816999mon1 as
select a.*, b.sumweight 
from CI816999mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data CI816999mon1;
set CI816999mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data CI816999mon1;
set CI816999mon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.CI816999;
set CI816999mon1;
indexcode='816999.CI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.CI816999;
run;







proc import out=CI818100
datafile="F:\fund_index_weight\brinson\818100.CI.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;


proc sql;
create table CI818100mon as
select a.sec_name, a.windcode, b.datetime, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from CI818100 as a, brinson.stkpmonthlysemiret as b 
where a.windcode = b.windcode;
run;quit;

proc sort data=CI818100mon;
by DATETIME;
run;

data CI818100mon;
set CI818100mon;
year=year(datetime);
run;

data CI818100mon;
set CI818100mon;
if year>=2005;
run;

proc means data=CI818100mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table CI818100mon1 as
select a.*, b.sumweight 
from CI818100mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data CI818100mon1;
set CI818100mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data CI818100mon1;
set CI818100mon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.CI818100;
set CI818100mon1;
indexcode='818100.CI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.CI818100;
run;






proc import out=CI816000G
datafile="F:\fund_index_weight\brinson\816000G.CI.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;


proc sql;
create table CI816000Gmon as
select a.sec_name, a.windcode, b.datetime, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from CI816000G as a, brinson.stkpmonthlysemiret as b 
where a.windcode = b.windcode;
run;quit;

proc sort data=CI816000Gmon;
by DATETIME;
run;

data CI816000Gmon;
set CI816000Gmon;
year=year(datetime);
run;

data CI816000Gmon;
set CI816000Gmon;
if year>=2005;
run;

proc means data=CI816000Gmon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table CI816000Gmon1 as
select a.*, b.sumweight 
from CI816000Gmon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data CI816000Gmon1;
set CI816000Gmon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data CI816000Gmon1;
set CI816000Gmon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.CI816000G;
set CI816000Gmon1;
indexcode='816000G.CI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.CI816000G;
run;







proc import out=CI816000V
datafile="F:\fund_index_weight\brinson\816000V.CI.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;


proc sql;
create table CI816000Vmon as
select a.sec_name, a.windcode, b.datetime, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from CI816000V as a, brinson.stkpmonthlysemiret as b 
where a.windcode = b.windcode;
run;quit;

proc sort data=CI816000Vmon;
by DATETIME;
run;

data CI816000Vmon;
set CI816000Vmon;
year=year(datetime);
run;

data CI816000Vmon;
set CI816000Vmon;
if year>=2005;
run;

proc means data=CI816000Vmon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table CI816000Vmon1 as
select a.*, b.sumweight 
from CI816000Vmon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data CI816000Vmon1;
set CI816000Vmon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data CI816000Vmon1;
set CI816000Vmon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.CI816000V;
set CI816000Vmon1;
indexcode='816000V.CI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.CI816000V;
run;








proc import out=CICSPSADRP
datafile="F:\fund_index_weight\brinson\CSPSADRP.CI.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;


proc sql;
create table CICSPSADRPmon as
select a.sec_name, a.windcode, b.datetime, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from CICSPSADRP as a, brinson.stkpmonthlysemiret as b 
where a.windcode = b.windcode;
run;quit;

proc sort data=CICSPSADRPmon;
by DATETIME;
run;

data CICSPSADRPmon;
set CICSPSADRPmon;
year=year(datetime);
run;

data CICSPSADRPmon;
set CICSPSADRPmon;
if year>=2005;
run;

proc means data=CICSPSADRPmon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table CICSPSADRPmon1 as
select a.*, b.sumweight 
from CICSPSADRPmon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data CICSPSADRPmon1;
set CICSPSADRPmon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data CICSPSADRPmon1;
set CICSPSADRPmon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.CICSPSADRP;
set CICSPSADRPmon1;
indexcode='CSPSADRP.CI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.CICSPSADRP;
run;






proc import out=XI830002
datafile="F:\fund_index_weight\brinson\830002.XI.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table XI830002mon as
select a.sec_name, a.windcode, b.datetime, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from XI830002 as a, brinson.stkpmonthlysemiret as b 
where a.windcode = b.windcode;
run;quit;

proc sort data=XI830002mon;
by DATETIME;
run;

data XI830002mon;
set XI830002mon;
year=year(datetime);
run;

data XI830002mon;
set XI830002mon;
if year>=2005;
run;

proc means data=XI830002mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table XI830002mon1 as
select a.*, b.sumweight 
from XI830002mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data XI830002mon1;
set XI830002mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data XI830002mon1;
set XI830002mon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.XI830002;
set XI830002mon1;
indexcode='830002.XI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.XI830002;
run;






proc import out=XI830003
datafile="F:\fund_index_weight\brinson\830003.XI.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table XI830003mon as
select a.sec_name, a.windcode, b.datetime, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from XI830003 as a, brinson.stkpmonthlysemiret as b 
where a.windcode = b.windcode;
run;quit;

proc sort data=XI830003mon;
by DATETIME;
run;

data XI830003mon;
set XI830003mon;
year=year(datetime);
run;

data XI830003mon;
set XI830003mon;
if year>=2005;
run;

proc means data=XI830003mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table XI830003mon1 as
select a.*, b.sumweight 
from XI830003mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data XI830003mon1;
set XI830003mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data XI830003mon1;
set XI830003mon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.XI830003;
set XI830003mon1;
indexcode='830003.XI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.XI830003;
run;





proc import out=XI830223
datafile="F:\fund_index_weight\brinson\830223.XI.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table XI830223mon as
select a.sec_name, a.windcode, b.datetime, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from XI830223 as a, brinson.stkpmonthlysemiret as b 
where a.windcode = b.windcode;
run;quit;

proc sort data=XI830223mon;
by DATETIME;
run;

data XI830223mon;
set XI830223mon;
year=year(datetime);
run;

data XI830223mon;
set XI830223mon;
if year>=2005;
run;

proc means data=XI830223mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table XI830223mon1 as
select a.*, b.sumweight 
from XI830223mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data XI830223mon1;
set XI830223mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data XI830223mon1;
set XI830223mon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.XI830223;
set XI830223mon1;
indexcode='830223.XI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.XI830223;
run;






proc import out=WI886015
datafile="F:\fund_index_weight\brinson\886015.WI.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table WI886015mon as
select a.sec_name, a.windcode, b.datetime, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from WI886015 as a, brinson.stkpmonthlysemiret as b 
where a.windcode = b.windcode;
run;quit;

proc sort data=WI886015mon;
by DATETIME;
run;

data WI886015mon;
set WI886015mon;
year=year(datetime);
run;

data WI886015mon;
set WI886015mon;
if year>=2005;
run;

proc means data=WI886015mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table WI886015mon1 as
select a.*, b.sumweight 
from WI886015mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data WI886015mon1;
set WI886015mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data WI886015mon1;
set WI886015mon1;
rename datetime=date
windcode=wind_code
nindexw=i_weight;
run;

data brinson.WI886015;
set WI886015mon1;
indexcode='886015.WI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.WI886015;
run;





*fill in missing benchmark data;


proc import out=SH000001
datafile="F:\SH000001.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SH000001mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SH000001 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; 

*it contains B shares which are excluded from stkpsemi for now;

data SH000001mon;
set SH000001mon;
if datetime<'01DEC2011'd and datetime ne .;
run;

proc means data=SH000001mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SH000001mon1 as
select a.*, b.sumweight 
from SH000001mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SH000001mon1;
set SH000001mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SH000001mon1;
set SH000001mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SH000001;
set SH000001mon1;
indexcode='000001.SH';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SH000001;
run;



proc import out=SH000002
datafile="F:\SH000002.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SH000002mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SH000002 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SH000002mon;
set SH000002mon;
if datetime<'01DEC2011'd and datetime ne .;
run;

proc means data=SH000002mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SH000002mon1 as
select a.*, b.sumweight 
from SH000002mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SH000002mon1;
set SH000002mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SH000002mon1;
set SH000002mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SH000002;
set SH000002mon1;
indexcode='000002.SH';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SH000002;
run;





proc import out=SH000010
datafile="F:\SH000010.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SH000010mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SH000010 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SH000010mon;
set SH000010mon;
if datetime<'01JUN2008'd and datetime ne .;
run;

proc means data=SH000010mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SH000010mon1 as
select a.*, b.sumweight 
from SH000010mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SH000010mon1;
set SH000010mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SH000010mon1;
set SH000010mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SH000010;
set SH000010mon1;
indexcode='000010.SH';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SH000010;
run;




proc import out=SH000015
datafile="F:\SH000015.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SH000015mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SH000015 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SH000015mon;
set SH000015mon;
if datetime<'01DEC2011'd and datetime ne .;
run;

proc means data=SH000015mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SH000015mon1 as
select a.*, b.sumweight 
from SH000015mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SH000015mon1;
set SH000015mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SH000015mon1;
set SH000015mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SH000015;
set SH000015mon1;
indexcode='000015.SH';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SH000015;
run;





proc import out=SH000017
datafile="F:\SH000017.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SH000017mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SH000017 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SH000017mon;
set SH000017mon;
if datetime<'01DEC2011'd and datetime ne .;
run;

proc means data=SH000017mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SH000017mon1 as
select a.*, b.sumweight 
from SH000017mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SH000017mon1;
set SH000017mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SH000017mon1;
set SH000017mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SH000017;
set SH000017mon1;
indexcode='000017.SH';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SH000017;
run;





proc import out=SH000808
datafile="F:\SH000808.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SH000808mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SH000808 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SH000808mon;
set SH000808mon;
if datetime<'01JUN2012'd and datetime ne .;
run;

proc means data=SH000808mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SH000808mon1 as
select a.*, b.sumweight 
from SH000808mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SH000808mon1;
set SH000808mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SH000808mon1;
set SH000808mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SH000808;
set SH000808mon1;
indexcode='000808.SH';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SH000808;
run;





proc import out=SH000827
datafile="F:\SH000827.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SH000827mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SH000827 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SH000827mon;
set SH000827mon;
if datetime<'01DEC2012'd and datetime ne .;
run;

proc means data=SH000827mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SH000827mon1 as
select a.*, b.sumweight 
from SH000827mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SH000827mon1;
set SH000827mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SH000827mon1;
set SH000827mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SH000827;
set SH000827mon1;
indexcode='000827.SH';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SH000827;
run;





proc import out=SH000906
datafile="F:\SH000906.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SH000906mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SH000906 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SH000906mon;
set SH000906mon;
if datetime<'01JUN2007'd and datetime ne .;
run;

proc means data=SH000906mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SH000906mon1 as
select a.*, b.sumweight 
from SH000906mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SH000906mon1;
set SH000906mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SH000906mon1;
set SH000906mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SH000906;
set SH000906mon1;
indexcode='000906.SH';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SH000906;
run;





proc import out=CSI000907
datafile="F:\CSI000907.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table CSI000907mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from CSI000907 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data CSI000907mon;
set CSI000907mon;
if datetime<'01JUN2016'd and datetime ne .;
run;

proc means data=CSI000907mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table CSI000907mon1 as
select a.*, b.sumweight 
from CSI000907mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data CSI000907mon1;
set CSI000907mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data CSI000907mon1;
set CSI000907mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.CSI000907;
set CSI000907mon1;
indexcode='000907.CSI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.CSI000907;
run;





proc import out=SH000919
datafile="F:\SH000919.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SH000919mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SH000919 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SH000919mon;
set SH000919mon;
if datetime<'01JUN2009'd and datetime ne .;
run;

proc means data=SH000919mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SH000919mon1 as
select a.*, b.sumweight 
from SH000919mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SH000919mon1;
set SH000919mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SH000919mon1;
set SH000919mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SH000919;
set SH000919mon1;
indexcode='000919.SH';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SH000919;
run;






proc import out=SH000922
datafile="F:\SH000922.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SH000922mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SH000922 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SH000922mon;
set SH000922mon;
if datetime<'01JUN2009'd and datetime ne .;
run;

proc means data=SH000922mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SH000922mon1 as
select a.*, b.sumweight 
from SH000922mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SH000922mon1;
set SH000922mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SH000922mon1;
set SH000922mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SH000922;
set SH000922mon1;
indexcode='000922.SH';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SH000922;
run;




proc import out=CSI000926
datafile="F:\CSI000926.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table CSI000926mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from CSI000926 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data CSI000926mon;
set CSI000926mon;
if datetime<'01JUN2016'd and datetime ne .;
run;

proc means data=CSI000926mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table CSI000926mon1 as
select a.*, b.sumweight 
from CSI000926mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data CSI000926mon1;
set CSI000926mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data CSI000926mon1;
set CSI000926mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.CSI000926;
set CSI000926mon1;
indexcode='000926.CSI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.CSI000926;
run;





proc import out=SH000941
datafile="F:\SH000941.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SH000941mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SH000941 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SH000941mon;
set SH000941mon;
if datetime<'01JUN2016'd and datetime ne .;
run;

proc means data=SH000941mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SH000941mon1 as
select a.*, b.sumweight 
from SH000941mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SH000941mon1;
set SH000941mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SH000941mon1;
set SH000941mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SH000941;
set SH000941mon1;
indexcode='000941.SH';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SH000941;
run;





proc import out=CSI000942
datafile="F:\CSI000942.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table CSI000942mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from CSI000942 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data CSI000942mon;
set CSI000942mon;
if datetime<'01JUN2016'd and datetime ne .;
run;

proc means data=CSI000942mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table CSI000942mon1 as
select a.*, b.sumweight 
from CSI000942mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data CSI000942mon1;
set CSI000942mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data CSI000942mon1;
set CSI000942mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.CSI000942;
set CSI000942mon1;
indexcode='000942.CSI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.CSI000942;
run;





proc import out=CSI000955
datafile="F:\CSI000955.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table CSI000955mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from CSI000955 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data CSI000955mon;
set CSI000955mon;
if datetime<'01JUN2016'd and datetime ne .;
run;

proc means data=CSI000955mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table CSI000955mon1 as
select a.*, b.sumweight 
from CSI000955mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data CSI000955mon1;
set CSI000955mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data CSI000955mon1;
set CSI000955mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.CSI000955;
set CSI000955mon1;
indexcode='000955.CSI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.CSI000955;
run;





proc import out=SH000962
datafile="F:\SH000962.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SH000962mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SH000962 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SH000962mon;
set SH000962mon;
if datetime<'01JUN2015'd and datetime ne .;
run;

proc means data=SH000962mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SH000962mon1 as
select a.*, b.sumweight 
from SH000962mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SH000962mon1;
set SH000962mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SH000962mon1;
set SH000962mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SH000962;
set SH000962mon1;
indexcode='000962.SH';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SH000962;
run;





proc import out=SH000977
datafile="F:\SH000977.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SH000977mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SH000977 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SH000977mon;
set SH000977mon;
if datetime<'01DEC2011'd and datetime ne .;
run;

proc means data=SH000977mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SH000977mon1 as
select a.*, b.sumweight 
from SH000977mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SH000977mon1;
set SH000977mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SH000977mon1;
set SH000977mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SH000977;
set SH000977mon1;
indexcode='000977.SH';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SH000977;
run;





proc import out=CSI000988
datafile="F:\CSI000988.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table CSI000988mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from CSI000988 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data CSI000988mon;
set CSI000988mon;
if datetime<'01JUN2016'd and datetime ne .;
run;

proc means data=CSI000988mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table CSI000988mon1 as
select a.*, b.sumweight 
from CSI000988mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data CSI000988mon1;
set CSI000988mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data CSI000988mon1;
set CSI000988mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.CSI000988;
set CSI000988mon1;
indexcode='000988.CSI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.CSI000988;
run;





proc import out=MI128726
datafile="F:\MI128726.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table MI128726mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from MI128726 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data MI128726mon;
set MI128726mon;
if datetime<'01JUN2011'd and datetime ne .;
run;

proc means data=MI128726mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table MI128726mon1 as
select a.*, b.sumweight 
from MI128726mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data MI128726mon1;
set MI128726mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data MI128726mon1;
set MI128726mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.MI128726;
set MI128726mon1;
indexcode='128726.MI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.MI128726;
run;




proc import out=SZ399101
datafile="F:\SZ399101.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SZ399101mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SZ399101 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SZ399101mon;
set SZ399101mon;
if datetime<'01JUN2016'd and datetime ne .;
run;

proc means data=SZ399101mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SZ399101mon1 as
select a.*, b.sumweight 
from SZ399101mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SZ399101mon1;
set SZ399101mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SZ399101mon1;
set SZ399101mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SZ399101;
set SZ399101mon1;
indexcode='399101.SZ';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SZ399101;
run;





proc import out=SZ399102
datafile="F:\SZ399102.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SZ399102mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SZ399102 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SZ399102mon;
set SZ399102mon;
if datetime<'01JUN2016'd and datetime ne .;
run;

proc means data=SZ399102mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SZ399102mon1 as
select a.*, b.sumweight 
from SZ399102mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SZ399102mon1;
set SZ399102mon1;
if sumweight ne 0;
run;

data SZ399102mon1;
set SZ399102mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SZ399102mon1;
set SZ399102mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SZ399102;
set SZ399102mon1;
indexcode='399102.SZ';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SZ399102;
run;




proc import out=SZ399314
datafile="F:\SZ399314.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SZ399314mon as
select a._COL0 as windcode, a._COL1 as sec_name, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SZ399314 as a left join brinson.stkpmonthlysemiret as b 
on a._COL0 = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SZ399314mon;
set SZ399314mon;
if datetime<'01DEC2009'd and datetime ne .;
run;

proc means data=SZ399314mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SZ399314mon1 as
select a.*, b.sumweight 
from SZ399314mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SZ399314mon1;
set SZ399314mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SZ399314mon1;
set SZ399314mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SZ399314;
set SZ399314mon1;
indexcode='399314.SZ';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SZ399314;
run;





proc import out=SZ399315
datafile="F:\SZ399315.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SZ399315mon as
select a.SEC_NAME, a.WindCodes as windcode, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SZ399315 as a left join brinson.stkpmonthlysemiret as b 
on a.WindCodes = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SZ399315mon;
set SZ399315mon;
if datetime<'01DEC2009'd and datetime ne .;
run;

proc means data=SZ399315mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SZ399315mon1 as
select a.*, b.sumweight 
from SZ399315mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SZ399315mon1;
set SZ399315mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SZ399315mon1;
set SZ399315mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SZ399315;
set SZ399315mon1;
indexcode='399315.SZ';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SZ399315;
run;





proc import out=SZ399316
datafile="F:\SZ399316.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SZ399316mon as
select a.SEC_NAME, a.WindCodes as windcode, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SZ399316 as a left join brinson.stkpmonthlysemiret as b 
on a.WindCodes = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SZ399316mon;
set SZ399316mon;
if datetime<'01DEC2009'd and datetime ne .;
run;

proc means data=SZ399316mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SZ399316mon1 as
select a.*, b.sumweight 
from SZ399316mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SZ399316mon1;
set SZ399316mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SZ399316mon1;
set SZ399316mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SZ399316;
set SZ399316mon1;
indexcode='399316.SZ';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SZ399316;
run;



proc import out=SZ399330
datafile="F:\SZ399330.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SZ399330mon as
select a.SEC_NAME, a.WindCodes as windcode, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SZ399330 as a left join brinson.stkpmonthlysemiret as b 
on a.WindCodes = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SZ399330mon;
set SZ399330mon;
if datetime<'01DEC2009'd and datetime ne .;
run;

proc means data=SZ399330mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SZ399330mon1 as
select a.*, b.sumweight 
from SZ399330mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SZ399330mon1;
set SZ399330mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SZ399330mon1;
set SZ399330mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SZ399330;
set SZ399330mon1;
indexcode='399330.SZ';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SZ399330;
run;





proc import out=SZ399368
datafile="F:\SZ399368.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SZ399368mon as
select a.SEC_NAME, a.WindCodes as windcode, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SZ399368 as a left join brinson.stkpmonthlysemiret as b 
on a.WindCodes = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SZ399368mon;
set SZ399368mon;
if datetime ne .;
run;

proc means data=SZ399368mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SZ399368mon1 as
select a.*, b.sumweight 
from SZ399368mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SZ399368mon1;
set SZ399368mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SZ399368mon1;
set SZ399368mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SZ399368;
set SZ399368mon1;
indexcode='399368.SZ';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SZ399368;
run;





proc import out=SZ399812
datafile="F:\SZ399812.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SZ399812mon as
select a.SEC_NAME, a.WindCodes as windcode, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SZ399812 as a left join brinson.stkpmonthlysemiret as b 
on a.WindCodes = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SZ399812mon;
set SZ399812mon;
if datetime<'01JUN2016'd and datetime>'01DEC2015'd and datetime ne .;
run;

proc means data=SZ399812mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SZ399812mon1 as
select a.*, b.sumweight 
from SZ399812mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SZ399812mon1;
set SZ399812mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SZ399812mon1;
set SZ399812mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SZ399812;
set SZ399812mon1;
indexcode='399812.SZ';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SZ399812;
run;





proc import out=SZ399907
datafile="F:\SZ399907.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SZ399907mon as
select a.SEC_NAME, a.WindCodes as windcode, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SZ399907 as a left join brinson.stkpmonthlysemiret as b 
on a.WindCodes = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SZ399907mon;
set SZ399907mon;
if datetime<'01JUN2009'd and datetime ne .;
run;

proc means data=SZ399907mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SZ399907mon1 as
select a.*, b.sumweight 
from SZ399907mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SZ399907mon1;
set SZ399907mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SZ399907mon1;
set SZ399907mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SZ399907;
set SZ399907mon1;
indexcode='399907.SZ';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SZ399907;
run;





proc import out=SZ399933
datafile="F:\SZ399933.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SZ399933mon as
select a.SEC_NAME, a.WindCodes as windcode, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SZ399933 as a left join brinson.stkpmonthlysemiret as b 
on a.WindCodes = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SZ399933mon;
set SZ399933mon;
if datetime<'01DEC2011'd and datetime ne .;
run;

proc means data=SZ399933mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SZ399933mon1 as
select a.*, b.sumweight 
from SZ399933mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SZ399933mon1;
set SZ399933mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SZ399933mon1;
set SZ399933mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SZ399933;
set SZ399933mon1;
indexcode='399933.SZ';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SZ399933;
run;




proc import out=SZ399938
datafile="F:\SZ399938.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SZ399938mon as
select a.SEC_NAME, a.WindCodes as windcode, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SZ399938 as a left join brinson.stkpmonthlysemiret as b 
on a.WindCodes = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SZ399938mon;
set SZ399938mon;
if datetime<'01DEC2011'd and datetime ne .;
run;

proc means data=SZ399938mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SZ399938mon1 as
select a.*, b.sumweight 
from SZ399938mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SZ399938mon1;
set SZ399938mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SZ399938mon1;
set SZ399938mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SZ399938;
set SZ399938mon1;
indexcode='399938.SZ';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SZ399938;
run;





proc import out=SI801250
datafile="F:\SI801250.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table SI801250mon as
select a.SEC_NAME, a.WindCodes as windcode, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from SI801250 as a left join brinson.stkpmonthlysemiret as b 
on a.WindCodes = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data SI801250mon;
set SI801250mon;
if datetime<'01JUN2011'd and datetime ne .;
run;

proc means data=SI801250mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table SI801250mon1 as
select a.*, b.sumweight 
from SI801250mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data SI801250mon1;
set SI801250mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data SI801250mon1;
set SI801250mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.SI801250;
set SI801250mon1;
indexcode='801250.SI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.SI801250;
run;





proc import out=XI830001
datafile="F:\XI830001.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table XI830001mon as
select a.SEC_NAME, a.WindCodes as windcode, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from XI830001 as a left join brinson.stkpmonthlysemiret as b 
on a.WindCodes = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data XI830001mon;
set XI830001mon;
if datetime ne '31DEC2015'd and datetime ne .;
run;

proc means data=XI830001mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table XI830001mon1 as
select a.*, b.sumweight 
from XI830001mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data XI830001mon1;
set XI830001mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data XI830001mon1;
set XI830001mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.XI830001;
set XI830001mon1;
indexcode='830001.XI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.XI830001;
run;





proc import out=CSI930625
datafile="F:\CSI930625.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table CSI930625mon as
select a.SEC_NAME, a.WindCodes as windcode, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from CSI930625 as a left join brinson.stkpmonthlysemiret as b 
on a.WindCodes = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data CSI930625mon;
set CSI930625mon;
if datetime ne '29DEC2017'd and datetime ne .;
run;

proc means data=CSI930625mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table CSI930625mon1 as
select a.*, b.sumweight 
from CSI930625mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data CSI930625mon1;
set CSI930625mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data CSI930625mon1;
set CSI930625mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.CSI930625;
set CSI930625mon1;
indexcode='930625.CSI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.CSI930625;
run;





proc import out=CSIH00806
datafile="F:\CSIH00806.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table CSIH00806mon as
select a.SEC_NAME, a.WindCodes as windcode, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from CSIH00806 as a left join brinson.stkpmonthlysemiret as b 
on a.WindCodes = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data CSIH00806mon;
set CSIH00806mon;
if datetime='31DEC2015'd or datetime<'01JUN2012'd;
run;

proc means data=CSIH00806mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table CSIH00806mon1 as
select a.*, b.sumweight 
from CSIH00806mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data CSIH00806mon1;
set CSIH00806mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data CSIH00806mon1;
set CSIH00806mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.CSIH00806;
set CSIH00806mon1;
indexcode='H00806.CSI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.CSIH00806;
run;





proc import out=CSIH11100
datafile="F:\CSIH11100.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table CSIH11100mon as
select a.SEC_NAME, a.WindCodes as windcode, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from CSIH11100 as a left join brinson.stkpmonthlysemiret as b 
on a.WindCodes = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data CSIH11100mon;
set CSIH11100mon;
if datetime<'01DEC2017'd and datetime ne .;
run;

proc means data=CSIH11100mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table CSIH11100mon1 as
select a.*, b.sumweight 
from CSIH11100mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data CSIH11100mon1;
set CSIH11100mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data CSIH11100mon1;
set CSIH11100mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.CSIH11100;
set CSIH11100mon1;
indexcode='H11100.CSI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.CSIH11100;
run;





proc import out=CSIH30355
datafile="F:\CSIH30355.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

proc sql;
create table CSIH30355mon as
select a.SEC_NAME, a.WindCodes as windcode, b.DATETIME, b.industry, b.MKT_CAP_FLOAT, b.CLOSE
from CSIH30355 as a left join brinson.stkpmonthlysemiret as b 
on a.WindCodes = b.WINDCODE;
run;quit; *it contains B shares which are excluded from stkpsemi for now;

data CSIH30355mon;
set CSIH30355mon;
if datetime<'01JUN2014'd and datetime ne .;
run;

proc means data=CSIH30355mon noprint;
  class DATETIME;
  var MKT_CAP_FLOAT;
  output out=temp1 sum=sumweight;
run;

proc sql;
create table CSIH30355mon1 as
select a.*, b.sumweight 
from CSIH30355mon as a, temp1 as b 
where a.datetime = b.datetime;
run;quit;

data CSIH30355mon1;
set CSIH30355mon1;
nindexw=MKT_CAP_FLOAT/sumweight;
run;

data CSIH30355mon1;
set CSIH30355mon1;
rename datetime=date windcode=wind_code nindexw=i_weight;
run;

data brinson.CSIH30355;
set CSIH30355mon1;
indexcode='H30355.CSI';
keep date wind_code sec_name i_weight indexcode;
run;

data brinson.indexcomponents;
set brinson.indexcomponents brinson.CSIH30355;
run;





*more indexes;

proc import out=moreind
datafile="F:\fund_index_weight\brinson\indexcomponents20180423.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data git;
set brinson.indexcomponents moreind;
run;

proc sql;
 create table gitt as
 select DISTINCT (indexcode), i_weight, sec_name, wind_code, date
 from git order by indexcode;
quit;

data gitt;
set gitt;
if i_weight ne 0;
run;

proc sort data=gitt;
by indexcode date wind_code;
run;

proc import out=moreind
datafile="F:\fund_index_weight\brinson\indexcomponents20180504.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data gitt;
informat sec_name $38.;
format sec_name $38.; 
set gitt;
run;

data git;
set gitt moreind;
run;

proc sql;
 create table gitt as
 select DISTINCT (indexcode), i_weight, sec_name, wind_code, date
 from git order by indexcode;
quit;

data gitt;
set gitt;
if i_weight ne 0;
run;

proc sort data=gitt;
by indexcode date wind_code;
run;

data brinson.monthlyindexcomp;
set gitt;
run;

*for hand-computed index weights and components, their frequency is monthly;
*for wind-downloaded index weights and components, their frequency is semi-annually;

*we use A1 to construct monthly index weights and components;
*we impute monthly index components;
*merge with monthly stock cap;
*compute monthly index weights;

