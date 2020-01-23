proc reg data=five.fund_benchmark_weight4 outest=t1 edf  tableout  noprint;
  model bar = smb hml mom sys_risk sys_square;
  by windcode;
  quit;

  data t1;
  set t1;
  if _type_='PVALUE';
  run;

    proc sql;
  create table t11 as
  select a.*, b.erji, b.yiji
  from t1 as a, five.fund_benchmark_weight4 as b
  where a.windcode=b.windcode;
  quit;

  data t11;
  set t11;
  by windcode;
  smb_sig=0;
  if smb<0.05 then smb_sig=1;
  hml_sig=0;
  if hml<0.05 then hml_sig=1;
  mom_sig=0;
  if mom<0.05 then mom_sig=1;
    sys_sig=0;
  if sys_risk<0.05 then sys_sig=1;
  sqr_sig=0;
  if sys_square<0.05 then sqr_sig=1;
run;

  title "PROC SGPANEL with PANELBY statement";
  proc sgpanel data=t11;
  panelby erji / rows=3 layout=rowlattice;
  histogram smb;
  run;

    title "PROC SGPANEL with PANELBY statement";
  proc sgpanel data=t11;
  panelby erji / rows=3 layout=rowlattice;
  histogram hml;
  run;
  
  title "PROC SGPANEL with PANELBY statement";
  proc sgpanel data=t11;
  panelby erji / rows=3 layout=rowlattice;
  histogram mom;
  run;

    title "PROC SGPANEL with PANELBY statement";
  proc sgpanel data=t11;
  panelby erji / rows=3 layout=rowlattice;
  histogram sys_risk;
  run;
  
  title "PROC SGPANEL with PANELBY statement";
  proc sgpanel data=t11;
  panelby erji / rows=3 layout=rowlattice;
  histogram sys_square;
  run;

title "PROC SGPANEL with PANELBY statement";
  proc sgplot data=t11;
  histogram smb /binwidth=0.05;
  run;

title "PROC SGPANEL with PANELBY statement";
  proc sgplot data=t11;
  histogram hml /binwidth=0.05;
  run;
  
title "PROC SGPANEL with PANELBY statement";
  proc sgplot data=t11;
  histogram mom /binwidth=0.05;
  run;

title "PROC SGPANEL with PANELBY statement";
  proc sgplot data=t11;
  histogram sys_risk /binwidth=0.05;
  run;
  
title "PROC SGPANEL with PANELBY statement";
  proc sgplot data=t11;
  histogram sys_square /binwidth=0.05;
  run;














  proc reg data=five.fund_benchmark_weight4 outest=t1 edf  tableout  noprint;
  model Benchmark_ret = smb hml mom sys_risk sys_square;
  by windcode;
  quit;

  data t1;
  set t1;
  if _type_='PVALUE';
  run;

    proc sql;
  create table t11 as
  select a.*, b.erji, b.yiji
  from t1 as a, five.fund_benchmark_weight4 as b
  where a.windcode=b.windcode;
  quit;

  data t11;
  set t11;
  by windcode;
  smb_sig=0;
  if smb<0.05 then smb_sig=1;
  hml_sig=0;
  if hml<0.05 then hml_sig=1;
  mom_sig=0;
  if mom<0.05 then mom_sig=1;
    sys_sig=0;
  if sys_risk<0.05 then sys_sig=1;
  sqr_sig=0;
  if sys_square<0.05 then sqr_sig=1;
run;

  title "PROC SGPANEL with PANELBY statement";
  proc sgpanel data=t11;
  panelby erji / rows=3 layout=rowlattice;
  histogram smb;
  run;

    title "PROC SGPANEL with PANELBY statement";
  proc sgpanel data=t11;
  panelby erji / rows=3 layout=rowlattice;
  histogram hml;
  run;
  
  title "PROC SGPANEL with PANELBY statement";
  proc sgpanel data=t11;
  panelby erji / rows=3 layout=rowlattice;
  histogram mom;
  run;

    title "PROC SGPANEL with PANELBY statement";
  proc sgpanel data=t11;
  panelby erji / rows=3 layout=rowlattice;
  histogram sys_risk;
  run;
  
  title "PROC SGPANEL with PANELBY statement";
  proc sgpanel data=t11;
  panelby erji / rows=3 layout=rowlattice;
  histogram sys_square;
  run;

title "PROC SGPANEL with PANELBY statement";
  proc sgplot data=t11;
  histogram smb /binwidth=0.05;
  run;

title "PROC SGPANEL with PANELBY statement";
  proc sgplot data=t11;
  histogram hml /binwidth=0.05;
  run;
  
title "PROC SGPANEL with PANELBY statement";
  proc sgplot data=t11;
  histogram mom /binwidth=0.05;
  run;

title "PROC SGPANEL with PANELBY statement";
  proc sgplot data=t11;
  histogram sys_risk /binwidth=0.05;
  run;
  
title "PROC SGPANEL with PANELBY statement";
  proc sgplot data=t11;
  histogram sys_square /binwidth=0.05;
  run;








  proc reg data=five.fund_benchmark_weight4 outest=t1 edf  tableout  noprint;
  model excess_return = smb hml mom sys_risk sys_square Benchmark_ret;
  by windcode;
  quit;

  data t1;
  set t1;
  if _type_='PVALUE';
  run;

    proc sql;
  create table t11 as
  select a.*, b.erji, b.yiji
  from t1 as a, five.fund_benchmark_weight4 as b
  where a.windcode=b.windcode;
  quit;

  data t11;
  set t11;
  by windcode;
  smb_sig=0;
  if smb<0.05 then smb_sig=1;
  hml_sig=0;
  if hml<0.05 then hml_sig=1;
  mom_sig=0;
  if mom<0.05 then mom_sig=1;
    sys_sig=0;
  if sys_risk<0.05 then sys_sig=1;
  sqr_sig=0;
  if sys_square<0.05 then sqr_sig=1;
  bench_sig=0;
  if Benchmark_ret<0.05 then bench_sig=1;
  sys_bench=0;
  if sys_square<0.05 and Benchmark_ret<0.05 then sys_bench=1;
run;

  title "PROC SGPANEL with PANELBY statement";
  proc sgpanel data=t11;
  panelby erji / rows=3 layout=rowlattice;
  histogram smb;
  run;

    title "PROC SGPANEL with PANELBY statement";
  proc sgpanel data=t11;
  panelby erji / rows=3 layout=rowlattice;
  histogram hml;
  run;
  
  title "PROC SGPANEL with PANELBY statement";
  proc sgpanel data=t11;
  panelby erji / rows=3 layout=rowlattice;
  histogram mom;
  run;

    title "PROC SGPANEL with PANELBY statement";
  proc sgpanel data=t11;
  panelby erji / rows=3 layout=rowlattice;
  histogram sys_risk;
  run;
  
  title "PROC SGPANEL with PANELBY statement";
  proc sgpanel data=t11;
  panelby erji / rows=3 layout=rowlattice;
  histogram sys_square;
  run;

    title "PROC SGPANEL with PANELBY statement";
  proc sgpanel data=t11;
  panelby erji / rows=3 layout=rowlattice;
  histogram benchmark_ret;
  run;

    title "PROC SGPANEL with PANELBY statement";
  proc sgpanel data=t11;
  panelby erji / rows=3 layout=rowlattice;
  histogram sys_risk;
  run;


title "PROC SGPANEL with PANELBY statement";
  proc sgplot data=t11;
  histogram smb /binwidth=0.05;
  run;

title "PROC SGPANEL with PANELBY statement";
  proc sgplot data=t11;
  histogram hml /binwidth=0.05;
  run;
  
title "PROC SGPANEL with PANELBY statement";
  proc sgplot data=t11;
  histogram mom /binwidth=0.05;
  run;

title "PROC SGPANEL with PANELBY statement";
  proc sgplot data=t11;
  histogram sys_risk /binwidth=0.05;
  run;
  
title "PROC SGPANEL with PANELBY statement";
  proc sgplot data=t11;
  histogram sys_square /binwidth=0.05;
  run;

  title "PROC SGPANEL with PANELBY statement";
  proc sgplot data=t11;
  histogram benchmark_ret /binwidth=0.05;
  run;
  
title "PROC SGPANEL with PANELBY statement";
  proc sgplot data=t11;
  histogram sys_bench /binwidth=0.05;
  run;




