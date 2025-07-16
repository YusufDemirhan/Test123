/* Traditional EG-style analysis */
proc sql;
    create table work.customer_summary as
    select c.region,
           c.account_type,
           count(distinct c.customer_id) as num_customers,
           sum(c.account_balance) as total_balance,
           avg(c.risk_score) as avg_risk_score
    from work.customers c
    group by c.region, c.account_type
    order by total_balance desc;
quit;

/* Traditional reporting - exactly like EG */
ods html path="/tmp" file="customer_report.html";
proc report data=work.customer_summary;
    column region account_type num_customers total_balance avg_risk_score;
    define region / group "Region";
    define account_type / group "Account Type";
    define num_customers / sum "Number of Customers";
    define total_balance / sum "Total Balance" format=dollar15.2;
    define avg_risk_score / mean "Average Risk Score" format=4.2;
    title "Customer Portfolio Summary ";
run;
ods html close;

/* Traditional visualization - EG compatible */
proc sgplot data=work.customer_summary;
    vbar region / response=total_balance group=account_type;
    yaxis label="Total Balance (£)" grid;
    xaxis label="Region";
    title "Portfolio Distribution by Region";
run;