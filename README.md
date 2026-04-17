# Credit Risk Analytics Pipeline


<img width="950" height="543" alt="image" src="https://github.com/user-attachments/assets/514be49d-4c12-4b34-85d3-534d6958b645" />

An end-to-end data engineering and machine learning pipeline built on **Snowflake**, **dbt**, **Python**, and **Power BI** to predict credit default risk using the Home Credit Default Risk dataset.

---

## Architecture

```
Raw CSVs
   │
   ▼
Snowflake (RAW schema)        ← Python connector loads all source tables
   │
   ▼
dbt Staging Models            ← Clean, select relevant columns per table
   │
   ▼
dbt Marts Model               ← Join all tables, engineer features
   │
   ├──► XGBoost ML Model      ← Train on marts data, predict default probability
   │
   └──► Power BI Dashboard    ← Live connection to Snowflake marts layer
```

---

## Tech Stack

| Layer | Tool |
|---|---|
| Cloud Data Warehouse | Snowflake |
| Transformations | dbt (Data Build Tool) |
| Data Ingestion | Python (snowflake-connector-python) |
| Machine Learning | XGBoost, scikit-learn, pandas |
| Dashboard | Power BI |
| Version Control | Git / GitHub |

---

## Dataset

**Home Credit Default Risk** — [Kaggle](https://www.kaggle.com/c/home-credit-default-risk)

| Table | Description |
|---|---|
| `application_train` | Main application table (307,511 rows) |
| `bureau` | Credit bureau history |
| `previous_application` | Previous loan applications |
| `installments_payments` | Repayment history |

---

## Pipeline Walkthrough

### 1. Data Ingestion
All CSVs are loaded into Snowflake's `RAW` schema using the Python connector (`notebooks/load_data.py`). Data is stored as-is — no transformations at this stage.

### 2. dbt Staging Models
Each source table has a corresponding staging model that cleans and selects relevant columns:
- `stg_app_train.sql`
- `stg_bureau.sql`
- `stg_previous_application.sql`

### 3. dbt Marts Model
The `fct_credit_risk.sql` marts model joins all staging tables on `SK_ID_CURR` and engineers the following features:

- Bureau loan count and total outstanding debt
- Previous application approval and rejection counts
- Late payment count from installment history
- Core application features (income, credit amount, employment, demographics)

### 4. Data Quality Tests
7 dbt tests are defined in `schema.yml` to ensure pipeline reliability:
- Not-null checks on key columns
- Unique checks on primary keys
- Accepted value checks on categorical columns

Run tests with:
```bash
dbt test
```

### 5. Machine Learning Model
XGBoost classifier trained on the marts layer output.

| Metric | Value |
|---|---|
| Training samples | 307,511 |
| ROC-AUC | 0.70 |
| Class imbalance handling | `scale_pos_weight` |

### 6. Power BI Dashboard
Live dashboard connected directly to Snowflake showing:
- Default rate by loan type
- Default rate by gender
- Income vs credit amount distribution by default status
- Key metrics: total applications, average credit amount, overall default rate

---

## Results

- ✅ ROC-AUC: **0.70**
- ✅ 7 dbt data quality tests passing
- ✅ Full pipeline from raw CSV → Snowflake → dbt → ML model → dashboard

---

## Repository Structure

```
credit_risk/
├── models/
│   ├── staging/
│   │   ├── stg_app_train.sql
│   │   ├── stg_bureau.sql
│   │   └── stg_previous_application.sql
│   ├── marts/
│   │   └── fct_credit_risk.sql
│   └── schema.yml
├── dbt_project.yml
notebooks/
├── load_data.py          # Data ingestion to Snowflake
└── train_model.py        # XGBoost model training
assets/
└── dashboard.png         # Power BI dashboard screenshot
README.md
```

---

## Setup

### Prerequisites
- Snowflake account
- Python 3.8+
- dbt-snowflake
- Power BI Desktop

### Steps

1. **Clone the repo**
```bash
git clone https://github.com/AvJo1421/credit-risk-snowflake-dbt.git
cd credit-risk-snowflake-dbt
```

2. **Install dependencies**
```bash
pip install -r requirements.txt
```

3. **Configure Snowflake credentials**

Update `~/.dbt/profiles.yml`:
```yaml
credit_risk:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <your_account>
      user: <your_user>
      password: <your_password>
      role: ACCOUNTADMIN
      database: INSURANCE_PROJECT
      warehouse: DEV_WH
      schema: STAGING
```

4. **Load raw data into Snowflake**
```bash
python notebooks/load_data.py
```

5. **Run dbt models and tests**
```bash
dbt run
dbt test
```

6. **Train the ML model**
```bash
python notebooks/train_model.py
```

7. **Connect Power BI**
Open Power BI Desktop → Get Data → Snowflake → connect to `INSURANCE_PROJECT.MARTS`

---

## Author

**Atharva Joshi** — [GitHub](https://github.com/AvJo1421) | [Portfolio](https://avjo1421.github.io/)
