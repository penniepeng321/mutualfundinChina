libname mf 'F:\中国公募基金基本信息下载\';
%let address = F:\中国公募基金基本信息下载\;


proc anova data=mf.mmf;
   class _COL6;
   model _COL4 = _COL6;
run;

proc anova data=mf.mmf;
   class _COL2;
   model _COL4 = _COL2;
run;

proc sort data=mf.mmf; by _COL6; run;

proc univariate data=mf.mmf noprint;
   var _COL4;
   by _COL6;
   output out=mf.mmfsummary  mean=mean std=std nobs=nobs;
run;

data mf.mmfsummary; set mf.mmfsummary; mr=mean/std; run;

proc sort data=mf.mmfsummary; by descending mean; run;

data mf.mmfchosen;
set mf.mmf;
if _COL6='兴全基金管理有限公司';
run;





proc anova data=mf.licai;
   class _COL6;
   model _COL4 = _COL6;
run;

proc anova data=mf.licai;
   class _COL2;
   model _COL4 = _COL2;
run;

proc sort data=mf.licai; by _COL6; run;

proc univariate data=mf.licai noprint;
   var _COL4;
   by _COL6;
   output out=mf.licaisummary  mean=mean std=std nobs=nobs;
run;

data mf.licaisummary; set mf.licaisummary; mr=mean/std; run;

proc sort data=mf.licaisummary; by descending mean; run;

data mf.licaichosen;
set mf.licai;
if _COL6='民生加银基金管理有限公司';
run;

