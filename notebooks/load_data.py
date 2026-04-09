import snowflake.connector
import os

conn = snowflake.connector.connect(
    user='AVJODD1421',
    password='AtharvaDhara@1421',
    account='unc76195.us-east-1',
    warehouse='DEV_WH',
    database='INSURANCE_PROJECT',
    schema='RAW'
)

cs = conn.cursor()

files = [
    'bureau.csv',
    'bureau_balance.csv',
    'previous_application.csv',
    'installments_payments.csv',
    'POS_CASH_balance.csv',
    'credit_card_balance.csv'
]

for f in files:
    path = f"D:/Atharva_Content/Snowflake dbt/data/home-credit-default-risk/{f}"
    print(f"Uploading {f}...")
    cs.execute(f"PUT 'file://{path}' @upload_stage AUTO_COMPRESS=TRUE")
    print(f"Done: {f}")

print("All files uploaded to stage")
cs.close()
conn.close()