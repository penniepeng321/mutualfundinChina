
%let address = F:\fund_index_weight\brinson\;
%LET OUT = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';

%let m=20180625;*fill in export date;

%let endm=0;
%let startm=%eval(&endm+6);
*this is to apply month 6 and 12 previous semi-annual return;
*endm varies from 0 to 6;
*endm=1 means five month before report and one month after;
*for six months before report, we simply use a.year=b.year and a.month=b.month;
*rather than a.year1=b.year and a.month1=b.month;
*or we can set endm=0;

*import sas data of brinson model results in r;
*to make further computations;

*we analyze the max-distance between 06 to 612;
*also the sum squared distance between 06 and 612;

proc sort data=brinson.brinsonfilled06;
by fundcode timemaker;
run;

proc sort data=brinson.brinsonfilled17;
by fundcode timemaker;
run;

proc sort data=brinson.brinsonfilled28;
by fundcode timemaker;
run;

proc sort data=brinson.brinsonfilled39;
by fundcode timemaker;
run;

proc sort data=brinson.brinsonfilled410;
by fundcode timemaker;
run;

proc sort data=brinson.brinsonfilled511;
by fundcode timemaker;
run;

proc sort data=brinson.brinsonfilled612;
by fundcode timemaker;
run;

*made elementwise comparison and store it in sensitivity_comparison.xlsx;


