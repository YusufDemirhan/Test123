/* First, let's prepare data for Python analysis */
data work.ml_ready_data;
   set work.risk_metrics;
   /* Create numeric variables for ML */
   if account_type = 'SAVINGS' then account_type_num = 1;
   else if account_type = 'CURRENT' then account_type_num = 2;
   else account_type_num = 3;
   
   if region = 'LONDON' then region_num = 1;
   else if region = 'MANCHESTER' then region_num = 2;
   else if region = 'BIRMINGHAM' then region_num = 3;
   else region_num = 4;
run;

/* Now the magic - Python integration! */
proc python;
submit;

# Import required libraries
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report

# Access SAS data directly - this is the magic!
ml_data = SAS.sd2df('work.ml_ready_data')

print("Data loaded from SAS:")
print(ml_data.head())
print(f"\nDataset shape: {ml_data.shape}")

# Prepare features for risk prediction
features = ['account_balance', 'account_type_num', 'region_num', 'days_since_transaction', 'amount']
X = ml_data[features]
y = ml_data['risk_score']

# Split data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

# Train a Random Forest model
rf_model = RandomForestClassifier(n_estimators=100, random_state=42)
rf_model.fit(X_train, y_train)

# Calculate feature importance
feature_importance = pd.DataFrame({
   'feature': features,
   'importance': rf_model.feature_importances_
}).sort_values('importance', ascending=False)

print("\nFeature Importance:")
print(feature_importance)

# Create predictions
predictions = rf_model.predict(X_test)

# Add predictions back to the dataset
ml_data['predicted_risk'] = rf_model.predict(X)
ml_data['risk_probability'] = rf_model.predict_proba(X).max(axis=1)

# Send enhanced data back to SAS
SAS.df2sd(ml_data[['customer_id', 'predicted_risk', 'risk_probability']], 'work.risk_predictions')
SAS.df2sd(feature_importance, 'work.feature_importance')

print("\nModel training complete! Results saved back to SAS.")

endsubmit;
run;

/* Now use the Python results in SAS */
proc print data=work.risk_predictions(obs=10);
   title "Risk Predictions from Python Model";
run;

/* Visualize the feature importance from Python using SAS */
proc sgplot data=work.feature_importance;
   vbar feature / response=importance fillattrs=(color=steelblue);
   yaxis label="Importance Score" grid;
   xaxis label="Feature" discreteorder=data;
   title "ML Model Feature Importance - Close Brothers";
run;

/* Create additional SAS visualizations */
proc sgplot data=work.risk_predictions;
   histogram risk_probability / fillattrs=(color=lightblue);
   density risk_probability / lineattrs=(color=red thickness=2);
   xaxis label="Risk Probability" values=(0 to 1 by 0.1);
   yaxis label="Frequency";
   title "Distribution of Risk Probabilities from ML Model";
run;

/* Create a panel of visualizations */
proc sgpanel data=work.risk_predictions;
   panelby predicted_risk / columns=3 novarname;
   histogram risk_probability / fillattrs=(color=lightgreen);
   colaxis label="Risk Probability";
   rowaxis label="Count";
   title "Risk Probability Distribution by Predicted Risk Level";
run;