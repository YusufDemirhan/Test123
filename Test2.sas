/******************************************************************************
** Test2.sas        **
**                                                                           **
** Purpose: Demonstrate successful batch job execution                       **
** This program is designed to run without errors in SAS Viya batch         **
******************************************************************************/

/* Program start message */
%put NOTE: Test2.sas starting execution at %sysfunc(datetime(), datetime20.);
%put NOTE: Running as user &SYSUSERID on &SYSHOSTNAME;

/* Create a simple dataset */
data test2_results;
    length message $100 status $20;
    format run_timestamp datetime20.;
    
    /* Record execution details */
    run_timestamp = datetime();
    user_id = "&SYSUSERID";
    sas_version = "&SYSVLONG";
    hostname = "&SYSHOSTNAME";
    message = "Test2.sas executed successfully";
    status = "SUCCESS";
    
    /* Add some test data */
    do i = 1 to 10;
        test_value = ranuni(12345) * 100;
        output;
    end;
    
    drop i;
run;

/* Print summary statistics */
proc means data=test2_results n mean min max std;
    title "Test2.sas - Summary Statistics";
    var test_value;
run;

/* Create a frequency report */
proc freq data=test2_results;
    title "Test2.sas - Execution Status";
    tables status / nocum;
run;

/* Save results to a permanent location if needed */
data work.test2_output;
    set test2_results;
    completion_time = datetime();
    format completion_time datetime20.;
run;

/* Final status message */
%put NOTE: Test2.sas completed successfully at %sysfunc(datetime(), datetime20.);
%put NOTE: Created dataset work.test2_output with %sysfunc(countw(%sysfunc(getoption(obs)))) observations;

/* Create a simple report */
proc print data=work.test2_output (obs=5);
    title "Test2.sas - First 5 Records of Output";
    var run_timestamp user_id message status test_value;
run;


title;

