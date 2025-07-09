
libname m_fld1 "/export/home/users/sukgeb/flowcode";

libname m_fld2 "/export/home/users/sukgeb/catalog";

filename infile1 "/export/home/users/sukgeb/RAW/raw_file1.txt";

filename infile2 "/export/home/users/sukgeb/RAW/raw_file2.txt";


data m_fld1.air_cust_accounts;
set sashelp.airline;
run;

proc sql;
create table m_fld2.air_new_custs as
select * from sashelp.airline;
quit;

%include "/export/home/users/sukgeb/parse/flight_num_lookup.sas";
proc sql;
create table audi_cars as
select make, model
from sashelp.cars
where make="Audi";
quit;

proc sql;
   connect to teradata (path="(DESCRIPTION=(ADDRESS = (PROTOCOL = TCP)(HOST = ora01-cluster.company.com)(PORT = 1521))
(CONNECT_DATA = (SERVICE_NAME=exadat12c)))" user=myuser password=mypasswd);
   execute (CREATE TABLE JEFFTEST (col1 varchar2(20))) by oracle;
quit;

PROC MEANS DATA=auto N MEAN STD ;
RUN; 

PROC FREQ DATA=auto;
RUN; 

proc anova data=PainRelief;
   class PainLevel Codeine Acupuncture;
   model Relief = PainLevel Codeine|Acupuncture;
run;
%include "/export/home/users/sukgeb/parse/libname_assign.sas";
proc boxplot data=Times;
   plot Delay*Day /
      boxstyle = schematic
      horizontal;
   label Delay = 'Delay in Minutes';
run;

data m_fld1.air_cust_accounts;
set sashelp.airline;
run;

%let output=m_fld1.flights_delayed;
%let lib=m_fld2;
%let intable=flight_time;

data &output;
set &lib.&intable;
run;

data race;
pr = probnorm(-15/sqrt(325));
run;
 
proc print data=race;
var pr;
run;

proc iml;
FF = FINV(0.05/32,2,29);
print FF;
quit;

proc print data=chisq;
var df chirat;
run;
 
proc plot data=chisq;
plot chirat*df;
run;

proc reg data=crack;
  model load = age;
  plot predicted. * age = 'P' load * age = '*' / overlay;
run;

proc glm data=crack;
  class agef;
  model load = age agef / p;
  output out=crackreg p=pred r=resid;
run;
 
proc plot data=crackreg;
  plot load*age="*" pred*age="+"/ overlay;
run;

proc anova data=toxic;
class poison treatment;
model life = poison treatment poison*treatment;
run;
