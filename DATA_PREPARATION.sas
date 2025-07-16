/*****************************************************************
  1. RESET WORK LIB
 *****************************************************************/
proc datasets lib=work nolist kill; quit;

/*****************************************************************
  2. CREATE SAMPLE CUSTOMER DATA FROM SASHELP.CLASS
 *****************************************************************/
data work.customers;
    set sashelp.class;
    /* Convert the CLASS rows into “bank customers”                    */
    customer_id   = 1000 + _N_;                             /* 1001–1019 */
    
    /* Rotate through account types                                    */
    select (mod(_N_,3));
        when (1) account_type = "SAVINGS";
        when (2) account_type = "CURRENT";
        otherwise account_type = "BUSINESS";
    end;
    
    /* Rotate through regions                                           */
    array rgn[4] $12 _temporary_ ("LONDON","MANCHESTER",
                                  "BIRMINGHAM","GLASGOW");
    region        = rgn[mod(_N_-1, dim(rgn))+1];

    /* Build a vaguely realistic balance – height × £1 000 + noise      */
    account_balance = round(height*1000 + rand("Normal",0,5000), 50);
    format account_balance dollar12.2;

    /* Map CLASS age (11–16) into risk scores 1–4                       */
    risk_score = ceil(age/4);
    
    keep customer_id account_type region account_balance risk_score;
run;

/*****************************************************************
  3. CREATE SAMPLE TRANSACTIONS USING RANDOM DATA
 *****************************************************************/
data work.transactions;
    call streaminit(20250714);                   /* reproducible demo */
    length transaction_type $10;
    retain transaction_id 5000;
    
    do until (eof);                              /* loop over customers */
        set work.customers end=eof;
        
        n_trans = rand("Integer",1,3);           /* 1–3 txns each      */
        do i = 1 to n_trans;
            transaction_id + 1;
            customer_id     = customer_id;       /* from SET statement */
            
            /* Random date in January 2024 */
            transaction_date = '01JAN2024'd + rand("Integer",0,30);
            
            /* Generate ± amount, larger for transfers                  */
            select (rand("Table", .50, .35, .15));   /* weights         */
                when (1) do
                       amount = rand("Normal", 3000, 800);   transaction_type="DEPOSIT";
                     end;
                when (2) do
                       amount = -abs(rand("Normal", 1500,500)); transaction_type="WITHDRAWAL";
                     end;
                otherwise do
                       amount = rand("Normal", 75000,15000); transaction_type="TRANSFER";
                     end;
            end;
            output;
        end;
    end;
    
    format transaction_date date9. amount dollar10.2;
    drop i n_trans;
run;

/*****************************************************************
  4. BUILD RISK_METRICS AS BEFORE
 *****************************************************************/
proc sort data=work.transactions; by customer_id; run;
proc sort data=work.customers;    by customer_id; run;

data work.risk_metrics;
    merge work.customers work.transactions(in=b);
    by customer_id;
    if b;                                         /* keep only matched rows      */
    
    days_since_transaction = today() - transaction_date;

    if amount < 0            then transaction_risk = "HIGH";
    else if amount > 10000   then transaction_risk = "MEDIUM";
    else                           transaction_risk = "LOW";
run;

/*****************************************************************
  5. QUICK VALIDATION
 *****************************************************************/
title "Sample Customer Data – first 5 records";
proc print data=work.customers(obs=5); run;

title "Sample Transactions – first 5 records";
proc print data=work.transactions(obs=5); run;
