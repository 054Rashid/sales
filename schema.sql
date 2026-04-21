# 📊 Power BI Setup Guide — Sales Intelligence Platform

> Complete step-by-step guide to build the Power BI dashboard for this project.

---

## Prerequisites

- Power BI Desktop installed (free — Microsoft Store → search "Power BI Desktop")
- MySQL running locally with `sales_bi` database loaded (run ETL pipeline first)
- MySQL ODBC Connector installed: https://dev.mysql.com/downloads/connector/odbc/

---

## STEP 1 — Connect Power BI to MySQL

1. Open **Power BI Desktop**
2. Click **Get Data** (Home tab) → search **MySQL database** → click Connect
3. Enter:
   - **Server:** `localhost`
   - **Database:** `sales_bi`
4. Click **OK**
5. If prompted for credentials → select **Database** tab → enter:
   - Username: `root`
   - Password: *(your MySQL password)*
6. In the **Navigator** panel, check all 4 tables:
   - `dim_date`
   - `dim_product`
   - `dim_customer`
   - `fact_sales`
7. Click **Transform Data** (not Load) — this opens Power Query Editor

---

## STEP 2 — Power Query Transformations

Inside Power Query Editor, for each table, open **Advanced Editor** (Home → Advanced Editor) and paste the corresponding query from `power_query_m.txt`.

### What the transformations do:
| Table | Transformation |
|---|---|
| `fact_sales` | Sets column types, adds `gross_revenue` and `discount_amount` columns |
| `dim_date` | Sets `full_date` as date type, adds `quarter_label` (e.g. "Q1 2024") and `month_sort` |
| `dim_product` | Sets clean column types |
| `dim_customer` | Sets clean column types, adds `region_sort` for chart ordering |

After pasting each query, click **Done** then **Close & Apply** once all 4 are updated.

---

## STEP 3 — Set Up Relationships (Model View)

1. Click the **Model view** icon (left sidebar, looks like 3 connected boxes)
2. Create these relationships by dragging:

| From | To | Cardinality |
|---|---|---|
| `fact_sales[date_id]` | `dim_date[date_id]` | Many-to-One (★→1) |
| `fact_sales[product_id]` | `dim_product[product_id]` | Many-to-One (★→1) |
| `fact_sales[customer_id]` | `dim_customer[customer_id]` | Many-to-One (★→1) |

3. For each relationship, double-click it and confirm:
   - **Cross filter direction:** Single (from fact to dim)
   - **Cardinality:** Many to one (*:1)

Your schema is a **star schema** — fact_sales in the center, dimension tables as points.

---

## STEP 4 — Create DAX Measures

All DAX measures are in `dax_measures.dax`. Create them as follows:

1. In Report view, click on the `fact_sales` table in the **Fields** panel
2. Go to **Home → New Measure**
3. Paste each measure from `dax_measures.dax` one at a time
4. Press **Enter** or click the checkmark after each

### Measures to create (in this order):

**Core KPIs (create these first):**
- `Total Revenue`
- `Total Orders`
- `Total Units Sold`
- `Avg Order Value`
- `Avg Discount %`
- `Total Gross Revenue`
- `Total Discount Amount`

**Time Intelligence (requires the date table):**
- `MoM Growth %`
- `YoY Growth %`
- `Revenue YTD`
- `Revenue QTD`
- `Revenue MTD`
- `Revenue Rolling 3M`
- `Revenue Rolling 12M`
- `Revenue Prev Month`
- `Revenue Prev Year`

**Target & Achievement:**
- `Revenue Target`
- `Target Achievement %`
- `Revenue vs Target`
- `Revenue Target Dynamic`

**Rankings:**
- `Product Revenue Rank`
- `Is Top 10 Product`
- `Region Revenue Rank`

**Customer & Product Metrics:**
- `Unique Customers`
- `Revenue per Customer`
- `Orders per Customer`
- `Unique Products Sold`
- `Avg Unit Price`

**Dynamic Titles:**
- `Selected Year Title`
- `Selected Category Title`

---

## STEP 5 — Mark the Date Table

For time intelligence measures (YTD, MTD, etc.) to work correctly:

1. Click `dim_date` in the Fields panel
2. Go to **Table Tools → Mark as Date Table**
3. Select `full_date` as the date column
4. Click **OK**

---

## STEP 6 — Build the Dashboard (4 Pages)

### Page 1 — Executive Summary

Rename the page: double-click the tab → type "Executive Summary"

**Visuals to add:**

| Visual | Fields | Notes |
|---|---|---|
| **Card** × 4 | Total Revenue, Total Orders, Avg Order Value, Avg Discount % | Format: Currency for revenue |
| **Card** | Target Achievement % | Format with % and color: green if >100%, red if <80% |
| **Line Chart** | X: `month_name` (sorted by month), Y: `Total Revenue`, Legend: `year` | Monthly revenue trend |
| **Donut Chart** | Values: `Total Revenue`, Legend: `category` | Revenue by category |
| **Slicer** | `dim_date[year]` | Set to Dropdown style |
| **KPI Visual** | Value: `Total Revenue`, Target: `Revenue Target`, Trend: `Revenue MTD` | Shows progress bar |

**Design tips:**
- Use the "Teal" color theme for consistency with the Streamlit app
- Add a text box at the top: "Sales Intelligence Platform | Executive Summary"
- Group the 4 KPI cards in a row at the top

---

### Page 2 — Regional Performance

| Visual | Fields | Notes |
|---|---|---|
| **Bar Chart** (horizontal) | Y: `region`, X: `Total Revenue` | Sort by revenue descending |
| **Pie Chart** | Values: `Total Revenue`, Legend: `region` | Revenue share |
| **Matrix** | Rows: `region`, Columns: `category`, Values: `Total Revenue` | Heat-color the values |
| **Slicer** | `dim_product[category]` | Multi-select |
| **Map Visual** (optional) | Location: `region`, Size: `Total Revenue` | Requires region = city/state |

---

### Page 3 — Product Analysis

| Visual | Fields | Notes |
|---|---|---|
| **Treemap** | Group: `category`, Values: `Total Revenue` | Color by category |
| **Bar Chart** (horizontal) | Y: `product_name`, X: `Total Revenue` | Filter `Is Top 10 Product = TRUE` |
| **Line Chart** | X: `month`, Y: `Total Revenue`, Legend: `category` | Category trends |
| **Slicer** | `dim_date[year]` | Dropdown |
| **Slicer** | `dim_date[quarter]` | Tile style (shows Q1 Q2 Q3 Q4) |

**Pro tip:** Use a "Top N" filter on the bar chart:
- Click the chart → Filters pane → `product_name` → Filter type: Top N → Show: Top 10 by `Total Revenue`

---

### Page 4 — Time Intelligence

| Visual | Fields | Notes |
|---|---|---|
| **Line + Clustered Column** | Column Y: `Total Revenue`, Line Y: `MoM Growth %`, X: `month_sort` (sorted) | Dual axis |
| **Card** | `Target Achievement %` | Conditional formatting: green/red |
| **Card** | `Revenue YTD` | |
| **Card** | `YoY Growth %` | Show +/- with color |
| **Card** | `Revenue Rolling 3M` | |
| **Line Chart** | X: `quarter_label`, Y: `Revenue YTD` vs `Revenue Target` | Two series |
| **Slicer** | `dim_date[year]` | |
| **Slicer** | `dim_date[quarter]` | Tile style |

---

## STEP 7 — Formatting & Polish

### Conditional formatting on KPI cards:
1. Click a card visual → Format pane → **Callout value** → **Conditional formatting** (fx)
2. Set rules: if value > target → green, else → red

### Cross-filtering (drill-through):
- All slicers affect all visuals on the page by default
- To make a slicer affect all pages: Format → Edit Interactions → Sync Slicers

### Tooltips:
- Click any chart → Format → Tooltip → On
- Add `Avg Order Value`, `Total Orders` to tooltip fields for richer hover info

### Theme:
1. View tab → **Themes** → Browse for themes → download from https://community.fabric.microsoft.com/t5/Themes-Gallery
2. Or use the built-in "Teal" / "Executive" theme

---

## STEP 8 — Save & Export

### Save the file:
```
File → Save As → sales_dashboard.pbix
```

### Export to PDF:
```
File → Export → Export to PDF
```

### Export data from a visual:
- Right-click any visual → **Export data** → .csv or .xlsx

---

## STEP 9 — Publish Online (Optional, Free)

1. Sign up at https://app.powerbi.com (free Power BI account)
2. In Power BI Desktop: **Home → Publish**
3. Select workspace → click **Select**
4. Open https://app.powerbi.com → find your report
5. Click **Share** → copy the link for your resume!

> **Resume line:** "Published interactive Power BI dashboard to Power BI Service with 4 pages, 25+ DAX measures, and time intelligence (YTD, MoM, YoY growth)"

---

## Troubleshooting

| Problem | Fix |
|---|---|
| "MySQL connector not found" | Install MySQL ODBC Connector from dev.mysql.com/downloads/connector/odbc |
| "Cannot connect to database" | Check MySQL is running; verify credentials in the connection dialog |
| "Time intelligence not working" | Make sure you marked dim_date as a Date Table (Step 5) |
| "Relationship inactive warning" | Check no duplicate relationships exist in Model view |
| "MoM Growth % shows blank" | Need 2+ months of data in the filtered selection |
| "Treemap shows blank" | Make sure you selected the correct column (category not product_id) |
