import snowflake.connector
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import roc_auc_score, classification_report
from xgboost import XGBClassifier
import joblib
import os

# Connect to Snowflake
conn = snowflake.connector.connect(
    user='AVJODD1421',
    password='AtharvaDhara@1421',
    account='unc76195.us-east-1',
    warehouse='DEV_WH',
    database='INSURANCE_PROJECT',
    schema='STAGING'
)

print("Fetching data from Snowflake...")
df = pd.read_sql("SELECT * FROM credit_risk_features", conn)
conn.close()

print(f"Data shape: {df.shape}")

# Prepare features
df.columns = df.columns.str.lower()
df = df.dropna(subset=['target'])

# Encode categoricals
cat_cols = ['name_contract_type', 'code_gender', 'flag_own_car', 
            'flag_own_realty', 'name_income_type', 'name_education_type',
            'name_family_status', 'name_housing_type']

for col in cat_cols:
    if col in df.columns:
        df[col] = df[col].astype('category').cat.codes

# Split
X = df.drop(columns=['target', 'sk_id_curr'])
y = df['target']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

print("Training XGBoost model...")
model = XGBClassifier(
    n_estimators=100,
    max_depth=6,
    learning_rate=0.1,
    scale_pos_weight=11,
    random_state=42,
    eval_metric='auc'
)

model.fit(X_train, y_train)

# Evaluate
y_pred_proba = model.predict_proba(X_test)[:, 1]
roc_auc = roc_auc_score(y_test, y_pred_proba)
print(f"ROC-AUC: {roc_auc:.4f}")

# Save model
os.makedirs('models', exist_ok=True)
joblib.dump(model, 'models/credit_risk_model.pkl')
print("Model saved to models/credit_risk_model.pkl")