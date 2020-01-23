
%let address = F:\fund_index_weight\brinson\;
%LET OUT = F:\fund_index_weight\brinson\;
libname brinson 'F:\fund_index_weight\brinson\';
libname five 'F:\fund_index_weight\Download_data_for_all_mutual_funds\';
libname self_ben 'F:\fund_index_weight\';

%let m=20180515;*fill in export date;
********************************************************;


*number of stks per industry check;


**********************************************************;

proc import out=brinson.usstkhy
datafile="F:\fund_index_weight\brinson\usstkindustry.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.usstkhy;
set brinson.usstkhy;
hy=Header_SIC_Code-10*int(Header_SIC_Code/10);
run;

proc freq data=brinson.usstkhy;
   tables hy / out=FreqCount sparse;
run;

data brinson.usstkhy;
set brinson.usstkhy;
hy=int(Header_SIC_Code/100);
run;

proc freq data=brinson.usstkhy;
   tables hy / out=FreqCount sparse;
run;

proc import out=brinson.SICm
datafile="F:\USSICmaincode.xlsx"
DBMS=excel REPLACE; 
GETNAMES=YES;
MIXED=NO;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data brinson.SICm;
set brinson.SICm;
start1=input(start,best12.);
end1=input(end,best12.);
run;

/*
data _null_;
  set brinson.SICm;
      array starth(*) _numeric_;   
    do i = 1 to dim(starth);
        call symput(vname(starth[i]), start1[i]);
    end;
      array endh(*) _numeric_;  
    do i = 1 to dim(endh);
        call symput(vname(endh[i]), end1[i]);
    end;
    array Divisionh(*) _character_;
    do i = 1 to dim(Divisionh);
        call symput(vname(Divisionh[i]), Division[i]);
    end;
run;

data brinson.usstkhy;
set brinson.usstkhy;

    do i = 1 to dim(_startr_);
	if Header_SIC_Code<=_endr_[i] and Header_SIC_Code>=_startr_[i]
	then Div=_Divisionr_[i];
    end;

run;

*/



PROC EXPORT DATA=brinson.Stkcapindustry
FILE="&address.Stkcapindustry"
DBMS=xlsx REPLACE;
SHEET="all";
RUN;

