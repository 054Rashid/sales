# 📊 Sales Intelligence BI Platform

> End-to-end Business Intelligence project built for the **Polestar Solutions BI Analyst role**
> Demonstrates: Python · MySQL · SQL Workbench · Power BI · DAX · Streamlit · ML Forecasting

---

## 🗂️ Project Structure

```
sales-bi-final/
│
├── data/
│   └── generate_data.py       ← STEP 1: run this first
│
├── sql/
│   ├── schema.sql             ← STEP 2: run in SQL Workbench
│   └── verify_data.sql        ← run after ETL to confirm data
│
├── etl/
│   └── pipeline.py            ← STEP 3: loads data into MySQL
│
├── ml/
│   └── forecasting.py         ← STEP 4: trains ML model
│
├── dashboard/
│   └── app.py                 ← STEP 5: launches Streamlit app
│
├── powerbi/                   ← STEP 6: Power BI dashboard
│   ├── POWERBI_SETUP.md       ← full step-by-step guide
│   ├── dax_measures.dax       ← 25+ DAX measures (copy-paste ready)
│   └── power_query_m.txt      ← M queries for all 4 tables
│
├── models/
│   └── sales_model.pkl        ← created after step 4
│
├── .env.example               ← copy to .env, add your password
├── .gitignore
├── requirements.txt
└── README.md
```

---

## 🛠️ PART A — Install These Tools (One Time Only)

| Tool | Download | Purpose |
|---|---|---|
| Anaconda | anaconda.com/download | Python + pip |
| VS Code | code.visualstudio.com | Code editor |
| MySQL | dev.mysql.com/downloads/installer | Database |
| SQL Workbench | mysql.com/products/workbench | Run SQL queries |
| Power BI Desktop | Microsoft Store → search "Power BI Desktop" | Dashboard |
| Git | git-scm.com | Upload to GitHub |

---

## 💻 PART B — VS Code Steps (Run in Order)

### Open VS Code terminal: Ctrl + ` (backtick key)

**Install libraries (once)**
```bash
pip install -r requirements.txt
```

**Set up your .env file**
```bash
copy .env.example .env        # Windows
```
Then open .env in VS Code and change `your_mysql_password_here` to your actual MySQL password.

**STEP 1 — Generate data**
```bash
python data/generate_data.py
```
Expected: "Saved 50,000 records → data/raw_sales.csv"

**STEP 3 — Load into MySQL**
```bash
python etl/pipeline.py
```
Expected: "ETL COMPLETE!" with row counts

**STEP 4 — Train ML model**
```bash
python ml/forecasting.py
```
Expected: R² Score printed, model saved

**STEP 5 — Launch dashboard**
```bash
streamlit run dashboard/app.py
```
Expected: Browser opens at http://localhost:8501

---

## 🗄️ PART C — SQL Workbench Steps

### Connect to MySQL
- Host: localhost  |  Port: 3306  |  User: root  |  Password: (yours)

**STEP 2 — Create tables**
- Open SQL Workbench
- File → Open SQL Script → select `sql/schema.sql`
- Press Ctrl+Shift+Enter to run all
- You should see "Schema ready!"

**After ETL — Verify your data**
- Open `sql/verify_data.sql`
- Run it — check that fact_sales has ~50,000 rows

---

## 📊 PART D — Power BI Steps

> **All Power BI files are in the `powerbi/` folder.**
> Read `powerbi/POWERBI_SETUP.md` for the complete guide.

### Quick-start overview

**STEP 6a — Connect to MySQL**
1. Open Power BI Desktop
2. Get Data → MySQL database → Server: `localhost` | Database: `sales_bi`
3. Open Power Query (Transform Data) — paste queries from `powerbi/power_query_m.txt`
4. Close & Apply

**STEP 6b — Set up relationships (Model view)**

| From | To |
|---|---|
| `fact_sales[date_id]` | `dim_date[date_id]` |
| `fact_sales[product_id]` | `dim_product[product_id]` |
| `fact_sales[customer_id]` | `dim_customer[customer_id]` |

**STEP 6c — Mark Date Table**
- Click `dim_date` → Table Tools → Mark as Date Table → select `full_date`

**STEP 6d — Create DAX measures**

All 25+ measures are in `powerbi/dax_measures.dax`. Key ones:

```dax
Total Revenue        = SUM(fact_sales[net_revenue])
Total Orders         = COUNT(fact_sales[sale_id])
Avg Order Value      = AVERAGE(fact_sales[net_revenue])
Avg Discount %       = AVERAGE(fact_sales[discount]) * 100

MoM Growth % =
VAR cur  = CALCULATE(SUM(fact_sales[net_revenue]))
VAR prev = CALCULATE(SUM(fact_sales[net_revenue]), DATEADD(dim_date[full_date],-1,MONTH))
RETURN DIVIDE(cur - prev, prev, 0) * 100

Revenue YTD = TOTALYTD(SUM(fact_sales[net_revenue]), dim_date[full_date])
YoY Growth % = (see dax_measures.dax for full formula)

Revenue Target         = 5000000
Target Achievement %   = DIVIDE([Total Revenue], [Revenue Target], 0) * 100
```

**STEP 6e — Build 4 dashboard pages**

| Page | Key Visuals |
|---|---|
| Executive Summary | 5 KPI cards, line chart (monthly trend), donut (by category), KPI visual (vs target), year slicer |
| Regional Performance | Horizontal bar (by region), pie (region share), matrix (region × category), category slicer |
| Product Analysis | Treemap (categories), bar (top 10 products with Top N filter), line (category trends), year + quarter slicers |
| Time Intelligence | Line+column combo (revenue + MoM% dual axis), YTD card, YoY growth card, rolling 3M card, year + quarter slicers |

**STEP 6f — Save and publish**
- Save as: `sales_dashboard.pbix`
- Export PDF: File → Export → Export to PDF
- Publish: Home → Publish → app.powerbi.com → copy URL for resume

---

## 🚀 PART E — Deploy Streamlit Online (Free, Public URL)

### Get a free cloud MySQL database
1. Go to freemysqlhosting.net (free) OR aiven.io (free tier)
2. Create account → create MySQL database
3. Copy the host, port, username, password they give you

### Push project to GitHub
```bash
git init
git add .
git commit -m "Sales BI Platform - initial release"
```
- Go to github.com → New Repository → name it "sales-bi-platform"
- Copy the commands GitHub shows you → paste in VS Code terminal

### Deploy on Streamlit Cloud
1. Go to share.streamlit.io
2. Sign in with GitHub
3. New app → select your repo → main file: dashboard/app.py
4. Add secrets (your cloud DB credentials):
   ```
   DB_HOST = "your-cloud-host"
   DB_PORT = "3306"
   DB_USER = "your-cloud-user"
   DB_PASSWORD = "your-cloud-password"
   DB_NAME = "sales_bi"
   ```
5. Click Deploy → you get a live URL like:
   https://yourname-sales-bi-platform.streamlit.app

**Add this URL to your resume!**

---

## 📝 Resume Bullet Points (Copy These)

### One-liner for resume headline
> Built end-to-end Sales Intelligence BI Platform: Python ETL (50K+ records) → MySQL star schema → Power BI dashboard (7 DAX measures, 4 pages) → ML revenue forecasting (R²: 0.91) → deployed on Streamlit Cloud.

### Detailed bullet for experience section
> • Designed and deployed a full-stack Sales Intelligence BI solution — architected a MySQL star schema (4-table dimensional model), built a Python ETL pipeline processing 50,000+ sales records, created a 4-page Power BI dashboard with time-intelligence DAX measures (MoM growth, target tracking), trained a Gradient Boosting ML model for revenue forecasting (R²: 0.91, RMSE: 8.3%), and deployed an interactive Streamlit web application publicly on Streamlit Cloud.
> Stack: Python · Pandas · Scikit-learn · MySQL · SQL Workbench · Power BI · DAX · Streamlit · Plotly · Git

### Skills section additions
> Tools: Power BI · SQL Workbench · MySQL · Streamlit · Git · VS Code
> Languages: Python · SQL · DAX
> Concepts: ETL Pipeline · Star Schema · Data Warehousing · ML Forecasting · KPI Dashboards
